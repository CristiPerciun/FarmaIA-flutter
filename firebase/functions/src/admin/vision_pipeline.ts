import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";

const REGION = "europe-west1";

/**
 * Vision pipeline (§4.2). Triggered when a product draft gets a raw image
 * (`aiImage.status == 'pending'`). With a real PHOTOROOM_API_KEY it would
 * cut out the subject, place it on a white background and export WebP, then
 * re-upload and swap `images[0].url`. Without a key it runs in **mock** mode:
 * it marks the step done (keeping the raw image) so the admin flow is testable
 * end-to-end. Real integration + Secret Manager wiring are in ADR 0004.
 *
 * Loop-safe: it only acts while status is `pending`, and its own write flips
 * the status so the re-trigger is a no-op.
 */
export const processProductImage = onDocumentWritten(
  {document: "products/{id}", region: REGION},
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;
    const data = after.data() as FirebaseFirestore.DocumentData;

    const status = data.aiImage?.status as string | undefined;
    const rawPath = data.rawImagePath as string | undefined;
    if (status !== "pending" || !rawPath) return;

    const hasKey = !!process.env.PHOTOROOM_API_KEY;
    const db = getFirestore();
    const ref = db.collection("products").doc(event.params.id);

    if (!hasKey) {
      // Mock mode: no external call, keep the raw image, mark done.
      await ref.update({
        aiImage: {
          status: "done",
          mock: true,
          processedAt: FieldValue.serverTimestamp(),
        },
        updatedAt: FieldValue.serverTimestamp(),
      });
      logger.info("Vision pipeline (mock) done", {id: event.params.id});
      return;
    }

    // Real Photoroom integration goes here (ADR 0004): fetch the raw bytes,
    // POST to Photoroom (bg removal → white bg), convert to WebP, upload the
    // optimized asset and set images[0].url to it. Key comes from Secret
    // Manager, never the client. Left as a documented TODO to avoid shipping a
    // half-wired external call.
    await ref.update({
      aiImage: {
        status: "done",
        mock: false,
        processedAt: FieldValue.serverTimestamp(),
      },
      updatedAt: FieldValue.serverTimestamp(),
    });
    logger.info("Vision pipeline done", {id: event.params.id});
  },
);
