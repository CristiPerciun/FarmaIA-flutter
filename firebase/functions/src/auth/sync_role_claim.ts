import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {getAuth} from "firebase-admin/auth";
import * as logger from "firebase-functions/logger";

/**
 * Mirrors the server-controlled `users/{uid}.role` field into a custom auth
 * claim (§1.3). Storage rules can't read Firestore, so they rely on this claim
 * to identify staff (§5.5). Because the security rules forbid clients from
 * changing `role`, the field — and therefore the claim — is trustworthy.
 */
export const syncRoleClaim = onDocumentWritten("users/{uid}", async (event) => {
  const uid = event.params.uid;
  const after = event.data?.after;
  const role = after && after.exists ?
    (after.data()?.role as string | undefined) :
    undefined;

  try {
    // Set { role } for staff/customer; clear claims when the doc/role is gone.
    await getAuth().setCustomUserClaims(uid, role ? {role} : {});
    logger.info("Synced role claim", {uid, role: role ?? null});
  } catch (err) {
    logger.error("Failed to sync role claim", {uid, error: `${err}`});
  }
});
