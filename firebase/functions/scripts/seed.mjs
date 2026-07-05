/**
 * Seeds the Firestore emulator with example documents for every Step 1.1
 * collection, then reads a few back to prove round-trip access (§5, §16.5).
 *
 * The Admin SDK bypasses security rules, so this populates data regardless of
 * the deny-by-default posture that protects the client (§5.5).
 *
 * Usage (emulators must be running):
 *   cd firebase/functions
 *   npm run seed
 *
 * Or one-shot via the CLI (starts an emulator just for the seed):
 *   firebase emulators:exec --only firestore "npm --prefix functions run seed"
 */
import {initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";

// Point the Admin SDK at the local emulator (default port from firebase.json).
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";

const PROJECT_ID = process.env.GCLOUD_PROJECT || "dbfarmacia";

initializeApp({projectId: PROJECT_ID});
const db = getFirestore();

const now = Timestamp.now();
const l = (it, en) => ({it, en});

async function seed() {
  const batch = db.batch();

  // --- categories ---
  batch.set(db.doc("categories/analgesici"), {
    name: l("Analgesici", "Painkillers"),
    slug: l("analgesici", "painkillers"),
    isMedicineCategory: true,
    order: 1,
    parentRef: null,
  });
  batch.set(db.doc("categories/cosmetici"), {
    name: l("Cosmetici", "Cosmetics"),
    slug: l("cosmetici", "cosmetics"),
    isMedicineCategory: false,
    order: 2,
    parentRef: null,
  });

  // --- products (published medicine, published cosmetic, hidden draft) ---
  batch.set(db.doc("products/prod_oki_task"), {
    sku: "OKI-TASK-10",
    barcode: "8052827950017",
    categoryRef: "categories/analgesici",
    type: "SOP",
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
    reviewedBy: "users/uid_admin_01",
    reviewedAt: now,
    publishedAt: now,
    createdAt: now,
    updatedAt: now,
  });
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
  });
  batch.set(db.doc("products/prod_draft_hidden"), {
    sku: "DRAFT-001",
    barcode: "",
    categoryRef: "categories/cosmetici",
    type: "parafarmaco",
    isMedicine: false,
    name: l("Bozza non pubblicata", "Unpublished draft"),
    shortDescription: l("", ""),
    description: l("", ""),
    activeIngredient: l("", ""),
    posology: l("", ""),
    contraindications: l("", ""),
    warnings: l("", ""),
    ceMarking: false,
    priceList: 0,
    priceSale: 0,
    currency: "EUR",
    vatRate: 22,
    stockQty: 0,
    available: false,
    images: [],
    seo: {slug: l("", ""), title: l("", ""), metaDescription: l("", "")},
    status: "draft",
    aiGenerated: true,
    assistantEligible: true,
    createdAt: now,
    updatedAt: now,
  });

  // --- users (customer + admin) ---
  batch.set(db.doc("users/uid_cliente_77"), {
    role: "customer",
    email: "cliente@example.com",
    displayName: "Mario Rossi",
    phone: "3330000000",
    locale: "it",
    addresses: [],
    consents: {
      marketing: false,
      medicineDataProcessing: true,
      aiAssistant: false,
      updatedAt: now,
    },
    loyaltyPoints: 0,
    createdAt: now,
  });
  batch.set(db.doc("users/uid_admin_01"), {
    role: "admin",
    email: "admin@farmaciabaganza.com",
    displayName: "Dr. Marco Barbieri",
    locale: "it",
    addresses: [],
    consents: {marketing: false, medicineDataProcessing: false, aiAssistant: false, updatedAt: now},
    loyaltyPoints: 0,
    createdAt: now,
  });

  // --- locations (3 Baganza sites) ---
  batch.set(db.doc("locations/baganza"), {
    name: "Baganza",
    address: "Via Baganza 11/E",
    city: "Parma",
    province: "PR",
    zip: "43125",
    phone: "0521964022",
    whatsapp: "3311532690",
    email: "info@farmaciabaganza.com",
    geo: {lat: 44.79, lng: 10.31},
    openingHours: [],
    isCupPoint: false,
    services: [],
    order: 1,
  });
  batch.set(db.doc("locations/baganza2"), {
    name: "Baganza2",
    address: "Via Gramsci 1/E",
    city: "Parma",
    province: "PR",
    zip: "43126",
    phone: "0521292905",
    geo: {lat: 44.80, lng: 10.30},
    openingHours: [],
    isCupPoint: true,
    services: ["services/ecg-refertazione"],
    order: 2,
  });
  batch.set(db.doc("locations/baganza3"), {
    name: "Baganza3",
    address: "Via Garibaldi 28",
    city: "Parma",
    province: "PR",
    zip: "43121",
    phone: "0521233178",
    geo: {lat: 44.80, lng: 10.33},
    openingHours: [],
    isCupPoint: false,
    services: [],
    order: 3,
  });

  // --- services ---
  batch.set(db.doc("services/ecg-refertazione"), {
    slug: l("ecg-refertazione", "ecg-with-report"),
    name: l("Elettrocardiogramma con refertazione", "ECG with report"),
    description: l("ECG con referto cardiologico.", "ECG with cardiology report."),
    category: "telemedicina",
    price: 3500,
    bookingType: "appointment",
    externalUrl: null,
    availableAt: ["locations/baganza2"],
    prep: l("Presentarsi a riposo.", "Come rested."),
    durationMin: 20,
    requiresFasting: false,
    active: true,
  });

  // --- articles ---
  batch.set(db.doc("articles/mal-di-testa"), {
    slug: l("gestire-mal-di-testa", "managing-headaches"),
    title: l("Come gestire il mal di testa", "How to manage headaches"),
    body: l("Contenuto revisionato dal farmacista.", "Content reviewed by the pharmacist."),
    authorRef: "users/uid_admin_01",
    reviewedBy: "users/uid_admin_01",
    lastReviewedAt: now,
    status: "published",
  });

  // --- config ---
  batch.set(db.doc("config/global"), {
    freeShippingThreshold: 4900,
    shippingCost: 490,
    defaultVatRate: 22,
  });
  // The app and `createOrder` read `config/app` (§5.4). The assistant chat
  // feature flag ships OFF: it turns on only after the 4B.8 red-team gate
  // (step 4B.6b). Staff can always test regardless of the flag.
  batch.set(db.doc("config/app"), {
    freeShippingThreshold: 4900,
    shippingCost: 490,
    defaultVatRate: 22,
    assistantChatEnabled: false,
  });
  // Pharmacist-curated assistant lists (step 4B.7): merged with the
  // built-in defaults in `ai/guardrails.ts`, editable without a deploy.
  batch.set(db.doc("config/assistant"), {
    redFlags: ["dolore addominale forte", "vomito con sangue"],
    rxTerms: [],
    maxPerDay: 40,
    maxPerSession: 30,
    updatedAt: now,
  });

  // --- assistant chat sessions (Fase 4B demo data for the admin registry) ---
  const purgeAt = Timestamp.fromMillis(
    now.toMillis() + 90 * 24 * 60 * 60 * 1000);
  batch.set(db.doc("chatSessions/demo_session_ok"), {
    userRef: "users/uid_cliente_77",
    consentType: "account",
    locale: "it",
    surface: "mobile",
    startedAt: now,
    lastMessageAt: now,
    turnCount: 1,
    redFlagTriggered: false,
    escalated: false,
    escalationHandled: false,
    flaggedForReview: false,
    reviewNote: null,
    provenance: {mode: "mock", model: "mock", endpointHost: "unconfigured"},
    purgeAt,
  });
  batch.set(db.doc("chatSessions/demo_session_ok/messages/m1"), {
    role: "user",
    text: "Cosa posso prendere per il mal di testa?",
    productIds: [],
    mode: "mock",
    redFlag: false,
    createdAt: now,
  });
  batch.set(db.doc("chatSessions/demo_session_ok/messages/m2"), {
    role: "assistant",
    text: "Ecco alcuni prodotti del nostro catalogo che potrebbero " +
      "esserti utili. Leggi sempre il foglietto illustrativo.",
    productIds: ["prod_oki_task"],
    mode: "mock",
    redFlag: false,
    createdAt: Timestamp.fromMillis(now.toMillis() + 1),
  });
  batch.set(db.doc("chatSessions/demo_session_redflag"), {
    userRef: "users/uid_cliente_77",
    consentType: "session",
    locale: "it",
    surface: "desktop",
    startedAt: now,
    lastMessageAt: now,
    turnCount: 1,
    redFlagTriggered: true,
    escalated: true,
    escalationHandled: false,
    flaggedForReview: false,
    reviewNote: null,
    escalatedAt: now,
    provenance: {mode: "redflag", model: "mock", endpointHost: "unconfigured"},
    purgeAt,
  });
  batch.set(db.doc("chatSessions/demo_session_redflag/messages/m1"), {
    role: "user",
    text: "Ho un forte dolore al petto da stamattina",
    productIds: [],
    mode: "redflag",
    redFlag: true,
    createdAt: now,
  });
  batch.set(db.doc("chatSessions/demo_session_redflag/messages/m2"), {
    role: "assistant",
    text: "Quello che descrivi merita l'attenzione di un professionista. " +
      "Se i sintomi sono gravi o improvvisi chiama il 112.",
    productIds: [],
    mode: "redflag",
    redFlag: true,
    createdAt: Timestamp.fromMillis(now.toMillis() + 1),
  });

  await batch.commit();

  // --- read back (proves round-trip) ---
  const published = await db
    .collection("products")
    .where("status", "==", "published")
    .get();
  const drafts = await db
    .collection("products")
    .where("status", "==", "draft")
    .get();

  console.log(`Seed complete on project "${PROJECT_ID}".`);
  console.log(`  published products readable: ${published.size}`);
  console.log(`  draft products (hidden from clients): ${drafts.size}`);
  for (const doc of published.docs) {
    console.log(`  - ${doc.id}: ${doc.get("name").it}`);
  }
}

seed()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Seed failed:", err);
    process.exit(1);
  });
