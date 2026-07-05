/**
 * Catalog retrieval for the assistant (§12.3, step 4B.2): top-k products for
 * a natural-language request, under the rigid filters
 * `status == published · available == true · assistantEligible == true`.
 *
 * Primary path: Firestore Vector Search (`findNearest` on `embedding`,
 * COSINE) — decided in the ADR 0002 addendum: no new infrastructure, the
 * client fuzzy stays as-is. Fallback path (emulator, missing vector index,
 * mock embeddings): in-memory scoring over the same filtered set, so the
 * pipeline works end-to-end in every environment.
 */

import type {Firestore, Query} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {cosineSimilarity, embedText, mockEmbedding, MOCK_MODEL}
  from "./embeddings";
import {bestScore} from "./fuzzy";
import {normalizeWords} from "./fuzzy";

export type RetrievedProduct = {
  id: string;
  score: number;
  data: FirebaseFirestore.DocumentData;
};

/** The filtered query every retrieval path starts from. */
export function eligibleProductsQuery(db: Firestore): Query {
  return db.collection("products")
    .where("status", "==", "published")
    .where("available", "==", true)
    .where("assistantEligible", "==", true);
}

function biValues(data: FirebaseFirestore.DocumentData): string[] {
  const fields = ["name", "shortDescription", "description",
    "activeIngredient", "warnings"];
  const out: string[] = [];
  for (const field of fields) {
    const bi = (data[field] ?? {}) as {it?: string; en?: string};
    if (bi.it) out.push(bi.it);
    if (bi.en) out.push(bi.en);
  }
  return out;
}

/** Keyword + fuzzy relevance of a product for `query` (fallback scoring). */
function keywordScore(
  query: string,
  data: FirebaseFirestore.DocumentData,
): number {
  const texts = biValues(data);
  const docWords = new Set(
    normalizeWords(texts.join(" ")).split(" ").filter((w) => w.length > 1));
  const queryWords =
    normalizeWords(query).split(" ").filter((w) => w.length > 2);
  let hits = 0;
  for (const qw of queryWords) {
    let hit = docWords.has(qw);
    if (!hit) {
      for (const dw of docWords) {
        // Poor-man's Italian stemming: shared 4-char prefix links
        // inflections ("pelle"/"pelli", "secca"/"secche").
        const sharedStem = qw.length >= 4 && dw.length >= 4 &&
          qw.slice(0, 4) === dw.slice(0, 4);
        if (sharedStem || dw.startsWith(qw) || qw.startsWith(dw)) {
          hit = true;
          break;
        }
      }
    }
    if (hit) hits++;
  }
  const overlap = queryWords.length > 0 ? hits / queryWords.length : 0;
  const nameBi = (data.name ?? {}) as {it?: string; en?: string};
  const fuzzy = bestScore(query, [nameBi.it ?? "", nameBi.en ?? ""]);
  return 0.7 * overlap + 0.3 * fuzzy;
}

/**
 * Returns the top-`k` assistant-eligible products for `queryText`, best
 * match first. Never throws: on any vector-search failure it degrades to the
 * in-memory fallback (§12.3 — the chat degrades, it never blocks).
 */
export async function retrieveProducts(
  db: Firestore,
  queryText: string,
  k = 8,
): Promise<RetrievedProduct[]> {
  const base = eligibleProductsQuery(db);

  try {
    const {vector, model} = await embedText(queryText);
    // Mock vectors only make sense against mock-embedded docs; the emulator
    // has no vector index anyway, so go straight to the fallback.
    if (model !== MOCK_MODEL) {
      const snap = await base.findNearest({
        vectorField: "embedding",
        queryVector: vector,
        limit: k,
        distanceMeasure: "COSINE",
      }).get();
      return snap.docs.map((doc, i) => ({
        id: doc.id,
        score: 1 - i / Math.max(snap.docs.length, 1),
        data: doc.data(),
      }));
    }
  } catch (err) {
    logger.warn("Vector search unavailable, using in-memory retrieval", {
      error: `${err}`,
    });
  }

  // Fallback: in-memory scoring over the (small/medium) filtered catalog.
  const snap = await base.limit(500).get();
  const queryVector = mockEmbedding(queryText);
  const scored: RetrievedProduct[] = [];
  for (const doc of snap.docs) {
    const data = doc.data();
    let score = keywordScore(queryText, data);
    const meta = data.embeddingMeta as {model?: string} | undefined;
    const embedding = data.embedding as
      {toArray?: () => number[]} | number[] | undefined;
    if (meta?.model === MOCK_MODEL && embedding) {
      const values = Array.isArray(embedding) ?
        embedding : embedding.toArray?.() ?? [];
      score = Math.max(score, cosineSimilarity(queryVector, values));
    }
    if (score > 0.15) scored.push({id: doc.id, score, data});
  }
  scored.sort((a, b) => b.score - a.score);
  return scored.slice(0, k);
}
