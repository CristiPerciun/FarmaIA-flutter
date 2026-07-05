/**
 * Multilingual embeddings for the catalog RAG (§12.3, step 4B.2).
 *
 * Real path: an OpenAI-compatible `/embeddings` endpoint (e.g. `bge-m3` or
 * `multilingual-e5` served by an EU provider) configured via
 * `EMBEDDING_BASE_URL`/`EMBEDDING_MODEL`/`EMBEDDING_API_KEY` (they default to
 * the LLM endpoint settings, one provider for both).
 *
 * Mock path (no key configured): a deterministic hashed bag-of-words vector.
 * Shared tokens land in shared buckets, so cosine similarity still ranks
 * "mal di testa" queries near products whose validated sheet mentions those
 * words — enough to exercise the whole pipeline on the emulator.
 */

import * as logger from "firebase-functions/logger";
import {normalizeWords} from "./fuzzy";

/** Dimension of the deterministic mock embedding. */
export const MOCK_DIMENSIONS = 256;
/** Model tag stored in `embeddingMeta` when running in mock mode. */
export const MOCK_MODEL = "mock-bow-256";

type FetchResponse = {
  ok: boolean;
  status: number;
  text: () => Promise<string>;
};
type FetchLike = (url: string, init: {
  method: string;
  headers: Record<string, string>;
  body: string;
}) => Promise<FetchResponse>;

/** Reads the embedding endpoint configuration from the environment. */
export function embeddingConfig(): {
  baseUrl: string;
  model: string;
  apiKey: string;
  configured: boolean;
} {
  const baseUrl = (
    process.env.EMBEDDING_BASE_URL ?? process.env.LLM_BASE_URL ?? ""
  ).replace(/\/+$/, "");
  const model = process.env.EMBEDDING_MODEL ?? "";
  const apiKey = process.env.EMBEDDING_API_KEY ??
    process.env.LLM_API_KEY ?? process.env.OPENAI_API_KEY ?? "";
  return {
    baseUrl,
    model,
    apiKey,
    configured: baseUrl.length > 0 && model.length > 0 && apiKey.length > 0,
  };
}

/** djb2 string hash (deterministic, fast — mock bucketing only). */
function djb2(input: string): number {
  let hash = 5381;
  for (let i = 0; i < input.length; i++) {
    hash = ((hash << 5) + hash + input.charCodeAt(i)) >>> 0;
  }
  return hash;
}

/** Deterministic hashed bag-of-words embedding, L2-normalized. */
export function mockEmbedding(text: string): number[] {
  const vector = new Array<number>(MOCK_DIMENSIONS).fill(0);
  const words = normalizeWords(text).split(" ").filter((w) => w.length > 1);
  for (const word of words) {
    vector[djb2(word) % MOCK_DIMENSIONS] += 1;
  }
  let sumSquares = 0;
  for (const v of vector) sumSquares += v * v;
  const norm = Math.sqrt(sumSquares);
  if (norm > 0) {
    for (let i = 0; i < vector.length; i++) vector[i] /= norm;
  }
  return vector;
}

/** Cosine similarity between two same-length vectors. */
export function cosineSimilarity(a: number[], b: number[]): number {
  if (a.length !== b.length || a.length === 0) return 0;
  let dot = 0;
  let normA = 0;
  let normB = 0;
  for (let i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  if (normA === 0 || normB === 0) return 0;
  return dot / (Math.sqrt(normA) * Math.sqrt(normB));
}

/**
 * Embeds `text`, returning the vector and the model that produced it.
 * Falls back to the deterministic mock when no endpoint is configured or the
 * provider call fails (the pipeline must keep working, §12.3).
 */
export async function embedText(
  text: string,
): Promise<{vector: number[]; model: string}> {
  const cfg = embeddingConfig();
  if (!cfg.configured) {
    return {vector: mockEmbedding(text), model: MOCK_MODEL};
  }
  try {
    const fetchImpl = (globalThis as unknown as {fetch: FetchLike}).fetch;
    const res = await fetchImpl(`${cfg.baseUrl}/embeddings`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${cfg.apiKey}`,
      },
      body: JSON.stringify({model: cfg.model, input: text}),
    });
    if (!res.ok) throw new Error(`embeddings-http-${res.status}`);
    const payload = JSON.parse(await res.text()) as {
      data?: {embedding?: number[]}[];
    };
    const vector = payload.data?.[0]?.embedding;
    if (!Array.isArray(vector) || vector.length === 0) {
      throw new Error("embeddings-empty-response");
    }
    return {vector, model: cfg.model};
  } catch (err) {
    logger.warn("Embedding provider failed, using mock", {error: `${err}`});
    return {vector: mockEmbedding(text), model: MOCK_MODEL};
  }
}
