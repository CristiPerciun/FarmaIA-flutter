/**
 * Server-side port of the client fuzzy matcher
 * (`app/lib/core/utils/fuzzy.dart`, ADR 0002). Same semantics: normalization
 * strips diacritics, lowercases and drops non-alphanumerics, so "okitask"
 * matches "Oki Task". Used by the assistant's pre-LLM router (§12.3, §12.6):
 * catalog-name queries are answered without touching the LLM.
 *
 * Keep the scoring in sync with the Dart original — the acceptance criteria
 * (§15) assume identical behaviour on both surfaces.
 */

const DIACRITICS: Record<string, string> = {
  "à": "a", "á": "a", "â": "a", "ã": "a", "ä": "a", "å": "a",
  "è": "e", "é": "e", "ê": "e", "ë": "e",
  "ì": "i", "í": "i", "î": "i", "ï": "i",
  "ò": "o", "ó": "o", "ô": "o", "õ": "o", "ö": "o",
  "ù": "u", "ú": "u", "û": "u", "ü": "u",
  "ñ": "n", "ç": "c", "ß": "ss",
};

/** Lowercase, strip diacritics, keep only `[a-z0-9]` (drops spaces too). */
export function normalize(input: string): string {
  const lower = input.toLowerCase();
  let out = "";
  for (const ch of lower) {
    const mapped = DIACRITICS[ch] ?? ch;
    for (const c of mapped) {
      if ((c >= "0" && c <= "9") || (c >= "a" && c <= "z")) out += c;
    }
  }
  return out;
}

/**
 * Like {@link normalize} but keeps word boundaries (runs of
 * non-alphanumerics collapse to a single space). Used for phrase matching in
 * the guardrails ("dolore toracico" must match as a phrase, not as glued
 * characters).
 */
export function normalizeWords(input: string): string {
  const lower = input.toLowerCase();
  let out = "";
  for (const ch of lower) {
    const mapped = DIACRITICS[ch] ?? ch;
    for (const c of mapped) {
      if ((c >= "0" && c <= "9") || (c >= "a" && c <= "z")) {
        out += c;
      } else if (!out.endsWith(" ")) {
        out += " ";
      }
    }
  }
  return out.trim();
}

/** Levenshtein edit distance between two strings. */
export function levenshtein(a: string, b: string): number {
  if (a === b) return 0;
  if (a.length === 0) return b.length;
  if (b.length === 0) return a.length;

  let previous = Array.from({length: b.length + 1}, (_, i) => i);
  let current = new Array<number>(b.length + 1).fill(0);

  for (let i = 0; i < a.length; i++) {
    current[0] = i + 1;
    for (let j = 0; j < b.length; j++) {
      const cost = a.charCodeAt(i) === b.charCodeAt(j) ? 0 : 1;
      current[j + 1] = Math.min(
        current[j] + 1,
        previous[j + 1] + 1,
        previous[j] + cost,
      );
    }
    const tmp = previous;
    previous = current;
    current = tmp;
  }
  return previous[b.length];
}

/** Similarity in `[0, 1]` from edit distance (1 = identical). */
function similarity(a: string, b: string): number {
  if (a.length === 0 || b.length === 0) return 0;
  const maxLen = Math.max(a.length, b.length);
  return 1 - levenshtein(a, b) / maxLen;
}

/**
 * Relevance score in `[0, 1]` of `target` for the given `query`.
 * Exact/prefix substring hits score highest; otherwise the best per-token
 * edit-distance similarity is used, so single-word typos still match.
 */
export function fuzzyScore(query: string, target: string): number {
  const q = normalize(query);
  if (q.length === 0) return 0;
  const t = normalize(target);
  if (t.length === 0) return 0;

  if (t.startsWith(q)) return 1;
  if (t.includes(q)) return 0.85 + 0.15 * (q.length / t.length);

  let best = similarity(q, t);
  for (const token of target.split(/\s+/)) {
    const nt = normalize(token);
    if (nt.length === 0) continue;
    if (nt.startsWith(q)) return 0.95;
    if (nt.includes(q)) return 0.9;
    const s = similarity(q, nt);
    if (s > best) best = s;
  }
  return best;
}

/** Best score of `query` across several `targets` (name, sku, barcode…). */
export function bestScore(query: string, targets: string[]): number {
  let best = 0;
  for (const target of targets) {
    const s = fuzzyScore(query, target);
    if (s > best) best = s;
    if (best >= 1) break;
  }
  return best;
}
