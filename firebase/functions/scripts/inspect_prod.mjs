/**
 * READ-ONLY diagnostic for the cloud project: lists Auth users with their
 * Firestore `users/{uid}.role` and custom claim, and checks whether the
 * hand-created admin doc maps to a real Auth user. Mutates nothing.
 *
 *   cd firebase/functions
 *   GOOGLE_APPLICATION_CREDENTIALS="/abs/path/sa.json" node scripts/inspect_prod.mjs
 */
import {initializeApp, applicationDefault} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {getFirestore} from "firebase-admin/firestore";

initializeApp({credential: applicationDefault()});
const auth = getAuth();
const db = getFirestore();

const res = await auth.listUsers(1000);
console.log(`Auth users: ${res.users.length}`);
for (const u of res.users) {
  const providers = u.providerData.map((p) => p.providerId).join(",") || "(none)";
  let docRole = "(no users doc)";
  try {
    const snap = await db.doc(`users/${u.uid}`).get();
    if (snap.exists) docRole = String(snap.get("role") ?? "(no role field)");
  } catch (e) {
    docRole = `(read error: ${e.code || e})`;
  }
  console.log(
    `- uid=${u.uid} | email=${u.email ?? "(none)"} | providers=${providers} ` +
    `| claim.role=${u.customClaims?.role ?? "-"} | doc.role=${docRole}`,
  );
}

const XROG = "XrOG8wj5v5WQnZd6sATD9ZYEC7q1";
const xdoc = await db.doc(`users/${XROG}`).get();
console.log(
  `\nHand-created doc users/${XROG}: exists=${xdoc.exists}` +
  (xdoc.exists ? ` role=${xdoc.get("role")}` : ""),
);
try {
  await auth.getUser(XROG);
  console.log(`Auth user ${XROG}: EXISTS`);
} catch {
  console.log(`Auth user ${XROG}: DOES NOT EXIST -> phantom uid (wrong target)`);
}
process.exit(0);
