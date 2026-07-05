/**
 * Embedding sync trigger (step 4B.2): extends the `products/{id}` write
 * pipeline so every published product carries a multilingual embedding of its
 * validated sheet. Loop-safe: the vector is recomputed only when the source
 * text actually changes (hash comparison), so our own update re-triggers as a
 * no-op.
 */

import {FieldValue} from "firebase-admin/firestore";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import {embedText, embeddingConfig, MOCK_MODEL} from "./embeddings";

const REGION = "europe-west1";

type Bi = {it?: string; en?: string};

function biText(value: unknown): string {
  const bi = (value ?? {}) as Bi;
  return [bi.it ?? "", bi.en ?? ""].filter((s) => s.length > 0).join(" \n");
}

/** The text the product is indexed under (both languages, validated fields). */
export function embeddingSourceText(
  data: FirebaseFirestore.DocumentData,
): string {
  return [
    biText(data.name),
    biText(data.shortDescription),
    biText(data.description),
    biText(data.activeIngredient),
    biText(data.warnings),
  ].filter((s) => s.length > 0).join(" \n");
}

/** djb2 hash in hex — cheap change detection for the source text. */
function textHash(input: string): string {
  let hash = 5381;
  for (let i = 0; i < input.length; i++) {
    hash = ((hash << 5) + hash + input.charCodeAt(i)) >>> 0;
  }
  return hash.toString(16);
}

/**
 * Keeps `products/{id}.embedding` in sync with the published sheet (§12.3).
 * Only published products are indexed; the retrieval query adds the
 * `available`/`assistantEligible` filters at read time.
 */
export const syncProductEmbedding = onDocumentWritten(
  {document: "products/{id}", region: REGION},
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;
    const data = after.data() as FirebaseFirestore.DocumentData;
    if (data.status !== "published") return;

    const text = embeddingSourceText(data);
    if (text.length === 0) return;

    const cfg = embeddingConfig();
    const model = cfg.configured ? cfg.model : MOCK_MODEL;
    const hash = textHash(text);
    const meta = data.embeddingMeta as
      {textHash?: string; model?: string} | undefined;
    if (meta?.textHash === hash && meta?.model === model) return;

    try {
      const {vector, model: usedModel} = await embedText(text);
      await after.ref.update({
        embedding: FieldValue.vector(vector),
        embeddingMeta: {
          model: usedModel,
          dimensions: vector.length,
          textHash: hash,
          generatedAt: FieldValue.serverTimestamp(),
        },
      });
      logger.info("Product embedding synced", {
        productId: event.params.id,
        model: usedModel,
        dimensions: vector.length,
      });
    } catch (err) {
      logger.error("Product embedding sync failed", {
        productId: event.params.id,
        error: `${err}`,
      });
    }
  },
);
