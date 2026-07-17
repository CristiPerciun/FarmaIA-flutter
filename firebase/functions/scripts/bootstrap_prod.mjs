/**
 * One-shot bootstrap for the REAL (cloud) Firebase project.
 *
 * Creates the core collections with the correct shapes (categories, products,
 * config) and promotes a real Auth user to `admin` — resolving the user BY
 * EMAIL so the role always lands on the right uid (doc role + custom claim).
 *
 * The Admin SDK bypasses security rules, so this writes fields the client can
 * never set (e.g. `role`, §5.5).
 *
 * REQUIRES a service account key for THIS project (never commit it, never ship
 * it in the app — local admin use only):
 *   Firebase Console -> Project settings -> Service accounts -> Generate new
 *   private key  (downloads a JSON).
 *
 * Usage (from firebase/functions, so firebase-admin resolves):
 *   GOOGLE_APPLICATION_CREDENTIALS="/abs/path/dbfarmacia-sa.json" \
 *     node scripts/bootstrap_prod.mjs <admin-email> [--with-demo]
 *
 * <admin-email>  the email of the account you sign into the app with.
 * --with-demo    also write demo categories/products (default: on). Pass
 *                --no-demo to only ensure config + promote the admin.
 */
import {initializeApp, applicationDefault} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {getFirestore, Timestamp} from "firebase-admin/firestore";

// --- safety: this script is for the CLOUD project, never the emulator ---
if (process.env.FIRESTORE_EMULATOR_HOST || process.env.FIREBASE_AUTH_EMULATOR_HOST) {
  console.error(
    "Refusing to run: an emulator host is set. Unset FIRESTORE_EMULATOR_HOST / " +
    "FIREBASE_AUTH_EMULATOR_HOST — this bootstrap targets the real cloud project.",
  );
  process.exit(1);
}

const email = process.argv[2];
const withDemo = !process.argv.includes("--no-demo");
const PROJECT_ID = process.env.GCLOUD_PROJECT || "dbfarmacia";

if (!email || !email.includes("@")) {
  console.error("Usage: node scripts/bootstrap_prod.mjs <admin-email> [--no-demo]");
  process.exit(1);
}
if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error(
    "GOOGLE_APPLICATION_CREDENTIALS is not set. Point it at the service account " +
    "JSON for project " + PROJECT_ID + ".",
  );
  process.exit(1);
}

initializeApp({credential: applicationDefault(), projectId: PROJECT_ID});
const auth = getAuth();
const db = getFirestore();

const now = Timestamp.now();
const l = (it, en) => ({it, en});

async function promoteAdmin() {
  let user;
  try {
    user = await auth.getUserByEmail(email);
  } catch {
    console.error(
      `No Firebase Auth user with email "${email}" in project ${PROJECT_ID}. ` +
      "Register/sign in once from the app first, then re-run.",
    );
    process.exit(1);
  }
  const uid = user.uid;

  // 1) Firestore profile: create if missing (full shape), else just set role.
  const ref = db.doc(`users/${uid}`);
  const snap = await ref.get();
  if (snap.exists) {
    await ref.set({role: "admin", updatedAt: now}, {merge: true});
  } else {
    await ref.set({
      role: "admin",
      email: user.email ?? email,
      displayName: user.displayName ?? null,
      locale: "it",
      addresses: [],
      consents: {
        marketing: false,
        medicineDataProcessing: false,
        aiAssistant: false,
        updatedAt: now,
      },
      loyaltyPoints: 0,
      createdAt: now,
    });
  }

  // 2) Custom claim — what the staff-only callables check (e.g.
  //    generateProductTexts). The user must sign out/in to refresh the token.
  await auth.setCustomUserClaims(uid, {role: "admin"});

  console.log(`Promoted ${email} (uid=${uid}) -> role=admin (doc + claim).`);
  return uid;
}

async function ensureConfig() {
  await db.doc("config/app").set({
    freeShippingThreshold: 4900,
    shippingCost: 490,
    defaultVatRate: 22,
    // Assistant chat stays OFF until the 4B.8 gate (step 4B.6b). Staff can test
    // regardless of the flag.
    assistantChatEnabled: false,
  }, {merge: true});
  await db.doc("config/assistant").set({
    redFlags: ["dolore addominale forte", "vomito con sangue"],
    rxTerms: [],
    maxPerDay: 40,
    maxPerSession: 30,
    updatedAt: now,
  }, {merge: true});
  console.log("Ensured config/app + config/assistant.");
}

async function seedDemo(adminUid) {
  const batch = db.batch();
  batch.set(db.doc("categories/analgesici"), {
    name: l("Analgesici", "Painkillers"),
    slug: l("analgesici", "painkillers"),
    isMedicineCategory: true,
    order: 1,
    parentRef: null,
  }, {merge: true});
  batch.set(db.doc("categories/cosmetici"), {
    name: l("Cosmetici", "Cosmetics"),
    slug: l("cosmetici", "cosmetics"),
    isMedicineCategory: false,
    order: 2,
    parentRef: null,
  }, {merge: true});

  batch.set(db.doc("products/prod_oki_task"), {
    sku: "OKI-TASK-10",
    barcode: "8052827950017",
    categoryRef: "categories/analgesici",
    type: "sop",
    isMedicine: true,
    name: l("Oki Task 10 bustine", "Oki Task 10 sachets"),
    shortDescription: l("Analgesico per mal di testa", "Pain reliever for headache"),
    description: l("Antinfiammatorio e analgesico.", "Anti-inflammatory and analgesic."),
    activeIngredient: l("Ketoprofene sale di lisina", "Ketoprofen lysine salt"),
    posology: l("1 bustina fino a 3 volte/die", "1 sachet up to 3 times/day"),
    contraindications: l("Ulcera peptica, gravidanza III trimestre.", "Peptic ulcer, third trimester."),
    warnings: l("Leggere il foglietto illustrativo.", "Read the package leaflet."),
    ceMarking: false,
    priceList: 999,
    priceSale: 699,
    currency: "EUR",
    vatRate: 10,
    stockQty: 42,
    available: true,
    images: [{url: "https://example.com/oki.webp", alt: l("Oki Task", "Oki Task")}],
    seo: {
      slug: l("oki-task-10-bustine", "oki-task-10-sachets"),
      title: l("Oki Task 10 bustine", "Oki Task 10 sachets"),
      metaDescription: l("Analgesico per mal di testa", "Pain reliever for headache"),
    },
    status: "published",
    aiGenerated: true,
    assistantEligible: true,
    reviewedBy: `users/${adminUid}`,
    reviewedAt: now,
    publishedAt: now,
    createdAt: now,
    updatedAt: now,
  }, {merge: true});
  batch.set(db.doc("products/prod_crema_viso"), {
    sku: "CREMA-VISO-50",
    barcode: "8000000000001",
    categoryRef: "categories/cosmetici",
    type: "cosmetico",
    isMedicine: false,
    name: l("Crema viso idratante", "Moisturizing face cream"),
    shortDescription: l("Per pelli secche", "For dry skin"),
    description: l("Idratazione intensa 24h.", "Intense 24h hydration."),
    activeIngredient: l("Acido ialuronico", "Hyaluronic acid"),
    posology: l("", ""),
    contraindications: l("", ""),
    warnings: l("Solo uso esterno.", "External use only."),
    ceMarking: false,
    priceList: 1590,
    priceSale: 0,
    currency: "EUR",
    vatRate: 22,
    stockQty: 30,
    available: true,
    images: [],
    seo: {
      slug: l("crema-viso-idratante", "moisturizing-face-cream"),
      title: l("Crema viso idratante", "Moisturizing face cream"),
      metaDescription: l("Per pelli secche", "For dry skin"),
    },
    status: "published",
    aiGenerated: false,
    assistantEligible: true,
    createdAt: now,
    updatedAt: now,
  }, {merge: true});
  await batch.commit();
  console.log("Seeded demo categories + products (2 published).");
}

async function main() {
  console.log(`Bootstrap on project "${PROJECT_ID}" (cloud).`);
  const adminUid = await promoteAdmin();
  await ensureConfig();
  if (withDemo) await seedDemo(adminUid);

  const published = await db.collection("products")
    .where("status", "==", "published").get();
  console.log(`Done. Published products now readable: ${published.size}.`);
  console.log("Sign out and back in on the app to refresh the admin claim.");
}

main().then(() => process.exit(0)).catch((err) => {
  console.error("Bootstrap failed:", err);
  process.exit(1);
});
