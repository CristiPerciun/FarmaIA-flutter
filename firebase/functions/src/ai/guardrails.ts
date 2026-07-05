/**
 * Deterministic guardrails for the customer assistant (§12.3–12.4).
 *
 * The red-flag triage runs BEFORE the LLM: on serious cases the model is
 * never allowed to decide. Lists are curated by the pharmacist in
 * `config/assistant` (fields `redFlags`, `rxTerms`) and merged with the
 * built-in defaults below, so an update never weakens the baseline and needs
 * no deploy (step 4B.7).
 *
 * Matching is normalization-based (diacritics/case-insensitive):
 * - a term containing a space matches as a phrase substring;
 * - a single-word term matches as a word prefix ("sanguin" hits
 *   "sanguinamento" but "male" does not hit "normale").
 */

import {normalizeWords} from "./fuzzy";

/** Serious symptoms → STOP: no products, refer to doctor/112/pharmacist. */
export const DEFAULT_RED_FLAGS: string[] = [
  // emergencies
  "dolore al petto", "dolore toracico", "chest pain",
  "difficolta a respirare", "non riesco a respirare", "dispnea",
  "shortness of breath", "cant breathe", "can t breathe",
  "svenimento", "svenuto", "svenuta", "perdita di coscienza",
  "fainted", "fainting", "unconscious",
  "convulsioni", "seizure", "seizures",
  "infarto", "ictus", "heart attack", "stroke",
  "emorragia", "sanguinamento", "sangue", "bleeding", "blood",
  "avvelenamento", "avvelenato", "poisoning", "poisoned", "overdose",
  // vulnerable groups → always a professional (stems cover inflections:
  // "allatt" → allattamento/allattando, "gravid" → gravidanza/gravida)
  "incinta", "gravid", "allatt",
  "pregnant", "pregnancy", "breastfeed",
  "neonato", "neonata", "lattante", "bambino", "bambina",
  "mio figlio", "mia figlia", "pediatrico", "pediatrica",
  "newborn", "infant", "toddler", "my son", "my daughter", "child", "baby",
  // persistent/serious course
  "febbre alta", "febbre da giorni", "febbre persistente",
  "high fever", "fever for days",
  // self-harm
  "suicid", "autolesion", "farmi del male", "voglio morire",
  "kill myself", "self harm", "hurt myself", "want to die",
];

/** Prescription-only requests → polite refusal, refer to doctor/pharmacist. */
export const DEFAULT_RX_TERMS: string[] = [
  "ricetta", "prescrizione", "prescrivimi", "prescription", "prescribe",
  "antibiotico", "antibiotici", "antibiotic", "antibiotics",
  "benzodiazepine", "xanax", "tavor", "lexotan", "valium",
  "antidepressivo", "antidepressivi", "antidepressant",
  "cortisone orale", "morfina", "ossicodone", "opioide", "opioidi",
  "viagra", "cialis",
];

/**
 * Words that mark an input as symptomatic/conversational: if any is present
 * the pre-LLM router must NOT answer, even when a product name also matches
 * (§12.6 — "oki per il mal di testa" goes through the full pipeline).
 */
export const SYMPTOM_HINTS: string[] = [
  "male", "mal di", "dolore", "dolori", "sintomo", "sintomi",
  "febbre", "tosse", "raffreddore", "influenza", "nausea", "vomito",
  "diarrea", "stitichezza", "prurito", "bruciore", "eruzione",
  "allergia", "allergico", "allergica", "insonnia", "ansia", "stress",
  "stanchezza", "stanco", "stanca", "mi fa", "ho la", "ho il", "ho un",
  "consiglio", "consigliami", "cosa prendo", "cosa posso", "aiuto", "aiutami",
  "pain", "ache", "hurts", "hurt", "sore", "fever", "cough", "cold", "flu",
  "itch", "itchy", "burn", "burning", "rash", "tired", "sleep", "insomnia",
  "advice", "recommend", "what should", "help",
];

/** Abuse/off-domain content blocked before any processing. */
export const MODERATION_BLOCKLIST: string[] = [
  "bomba", "esplosivo", "arma", "uccidere", "ammazzare",
  "sballarmi", "sballo", "drogarmi",
  "bomb", "explosive", "weapon", "get high", "kill someone",
];

/** Max accepted length for a single chat message. */
export const MAX_MESSAGE_LENGTH = 500;

/**
 * Strips control characters and caps length — the user message is data,
 * never instructions (same posture as the admin pipeline, §11.5).
 */
export function sanitizeMessage(input: string): string {
  return input
    .split("")
    .filter((ch) => {
      const code = ch.charCodeAt(0);
      return (code >= 0x20 && code !== 0x7f) || code === 0x0a;
    })
    .join("")
    .trim()
    .slice(0, MAX_MESSAGE_LENGTH);
}

/**
 * Returns the first term of `terms` that matches `message`, or null.
 * Phrase terms (with spaces) match as substrings on the normalized text;
 * single-word terms match as word prefixes.
 */
export function matchTerm(message: string, terms: string[]): string | null {
  const norm = normalizeWords(message);
  if (norm.length === 0) return null;
  const padded = ` ${norm} `;
  const words = norm.split(" ");
  for (const term of terms) {
    const t = normalizeWords(term);
    if (t.length === 0) continue;
    if (t.includes(" ")) {
      if (padded.includes(` ${t} `) || norm.includes(t)) return term;
    } else if (words.some((w) => w.startsWith(t))) {
      return term;
    }
  }
  return null;
}

/**
 * Whether the message contains symptomatic/conversational content and must
 * therefore skip the pre-LLM router (§12.3).
 */
export function hasSymptomaticContent(
  message: string,
  extraHints: string[] = [],
): boolean {
  return matchTerm(message, [...SYMPTOM_HINTS, ...extraHints]) !== null;
}
