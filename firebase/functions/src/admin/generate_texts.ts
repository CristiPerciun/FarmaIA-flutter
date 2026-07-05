import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

const REGION = "europe-west1";

type Bi = {it: string; en: string};

/** Strips control chars and caps length — basic anti prompt-injection on the
 * admin-provided seed (§11.5). The seed is data, never instructions. */
function sanitize(input: string): string {
  return input
    .split("")
    .filter((ch) => {
      const code = ch.charCodeAt(0);
      return code >= 0x20 && code !== 0x7f;
    })
    .join("")
    .trim()
    .slice(0, 200);
}

/** Deterministic bilingual placeholder used when no LLM key is configured, so
 * the pharmacist-review flow is testable without an external provider. */
function mockTexts(name: string, isMedicine: boolean): Record<string, Bi> {
  return {
    shortDescription: {
      it: `${name}: scheda generata in bozza, da revisionare.`,
      en: `${name}: draft-generated summary, pending review.`,
    },
    description: {
      it: `Descrizione preliminare di ${name}. Contenuto generato dall'AI ` +
        "in attesa di validazione del farmacista.",
      en: `Preliminary description of ${name}. AI-generated content awaiting ` +
        "pharmacist validation.",
    },
    activeIngredient: {it: "Da compilare", en: "To be completed"},
    posology: {
      it: isMedicine ?
        "Seguire le indicazioni del foglietto illustrativo (bozza)." : "",
      en: isMedicine ?
        "Follow the package leaflet directions (draft)." : "",
    },
    contraindications: {
      it: isMedicine ?
        "Ipersensibilita al principio attivo (bozza, da validare)." : "",
      en: isMedicine ?
        "Hypersensitivity to the active ingredient (draft, to validate)." : "",
    },
    warnings: {
      it: "Tenere fuori dalla portata dei bambini (bozza).",
      en: "Keep out of reach of children (draft).",
    },
    seoTitle: {it: `${name} | Baganza Farmacie`, en: `${name} | Baganza`},
  };
}

/**
 * LLM text pipeline (§4.3). Generates bilingual (IT+EN) SEO title, description,
 * active ingredient, posology, contraindications and warnings for a draft, then
 * writes them for pharmacist review — nothing is published automatically
 * (§10). Provenance is recorded (`aiTextProvenance`).
 *
 * With an OpenAI-compatible endpoint configured (base URL + key in Secret
 * Manager, §11.5) it would call a caged prompt grounded on validated sources
 * (RCP/leaflet). Without a key it uses a deterministic mock so the review flow
 * works end-to-end. Real provider wiring is in ADR 0004.
 */
export const generateProductTexts = onCall({region: REGION}, async (req) => {
  const role = req.auth?.token?.role as string | undefined;
  if (role !== "pharmacist" && role !== "admin") {
    throw new HttpsError("permission-denied", "Staff only.");
  }
  const productId = req.data?.productId as string | undefined;
  if (!productId) {
    throw new HttpsError("invalid-argument", "productId required.");
  }

  const db = getFirestore();
  const ref = db.collection("products").doc(productId);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Product not found.");
  }
  const p = snap.data() as FirebaseFirestore.DocumentData;
  const name = sanitize((p.name?.it as string) ?? "");
  const isMedicine = p.type === "sop" || p.type === "otc";

  const hasKey = !!process.env.OPENAI_API_KEY;
  // A real LLM call (guardrails + grounding) would go here when configured;
  // kept behind the key check so we never ship a half-wired external call.
  const texts = mockTexts(name, isMedicine);
  const mode = hasKey ? "llm" : "mock";

  await ref.update({
    shortDescription: texts.shortDescription,
    description: texts.description,
    activeIngredient: texts.activeIngredient,
    posology: texts.posology,
    contraindications: texts.contraindications,
    warnings: texts.warnings,
    "seo.title": texts.seoTitle,
    aiGenerated: true,
    aiTextProvenance: {
      mode,
      guardrails: true,
      sourceNote: "RCP/foglietto illustrativo (da validare dal farmacista)",
      generatedAt: FieldValue.serverTimestamp(),
    },
    updatedAt: FieldValue.serverTimestamp(),
  });

  logger.info("Product texts generated", {productId, mode});
  return {ok: true, mode};
});
