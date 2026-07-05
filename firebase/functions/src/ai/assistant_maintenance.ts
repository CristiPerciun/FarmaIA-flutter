/**
 * Scheduled maintenance for the assistant (steps 4B.4 and 4B.8).
 *
 * - `purgeChatSessions`: GDPR short-retention job (§12.5) — deletes sessions
 *   (and their messages) whose `purgeAt` has passed. Retention is rolling
 *   ~90 days from the last message, set by `assistantChat`.
 * - `assistantDailyReport`: post-launch monitoring — daily counts of
 *   red-flag/flagged/escalated sessions written to `assistantReports/` and
 *   logged with a warning on anomalous volumes, so a Cloud Monitoring alert
 *   policy can hook onto the log entry.
 */

import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

const REGION = "europe-west1";
const PURGE_BATCH = 100;
const MAX_PURGE_LOOPS = 20;
const RED_FLAG_WARN_RATIO = 0.3;
const FLAGGED_WARN_COUNT = 5;

/** Deletes expired chat sessions and their messages (§12.5 retention). */
export const purgeChatSessions = onSchedule(
  {schedule: "every day 03:30", timeZone: "Europe/Rome", region: REGION},
  async () => {
    const db = getFirestore();
    let purged = 0;
    for (let i = 0; i < MAX_PURGE_LOOPS; i++) {
      const snap = await db.collection("chatSessions")
        .where("purgeAt", "<=", Timestamp.now())
        .limit(PURGE_BATCH)
        .get();
      if (snap.empty) break;
      for (const doc of snap.docs) {
        await db.recursiveDelete(doc.ref);
        purged++;
      }
      if (snap.size < PURGE_BATCH) break;
    }
    logger.info("Chat sessions purged", {purged});
  },
);

/** Daily assistant monitoring report (step 4B.8 post-launch monitoring). */
export const assistantDailyReport = onSchedule(
  {schedule: "every day 07:00", timeZone: "Europe/Rome", region: REGION},
  async () => {
    const db = getFirestore();
    const dayAgo = Timestamp.fromMillis(Date.now() - 24 * 60 * 60 * 1000);
    const sessions = db.collection("chatSessions");

    const countWhere = async (
      field: string | null,
    ): Promise<number> => {
      let query = field === null ?
        sessions.where("lastMessageAt", ">=", dayAgo) :
        sessions.where(field, "==", true)
          .where("lastMessageAt", ">=", dayAgo);
      query = query.orderBy("lastMessageAt", "desc");
      const agg = await query.count().get();
      return agg.data().count;
    };

    const [total, redFlagged, flagged, escalated] = await Promise.all([
      countWhere(null),
      countWhere("redFlagTriggered"),
      countWhere("flaggedForReview"),
      countWhere("escalated"),
    ]);

    const dateKey = new Date().toISOString().slice(0, 10);
    await db.collection("assistantReports").doc(dateKey).set({
      date: dateKey,
      totalSessions: total,
      redFlagSessions: redFlagged,
      flaggedSessions: flagged,
      escalatedSessions: escalated,
      createdAt: Timestamp.now(),
    });

    const redFlagRatio = total > 0 ? redFlagged / total : 0;
    if (redFlagRatio > RED_FLAG_WARN_RATIO || flagged > FLAGGED_WARN_COUNT) {
      // Cloud Monitoring alert policies key on this warning (step 4B.8).
      logger.warn("Assistant anomaly detected", {
        total, redFlagged, flagged, escalated, redFlagRatio,
      });
    } else {
      logger.info("Assistant daily report", {
        total, redFlagged, flagged, escalated,
      });
    }
  },
);
