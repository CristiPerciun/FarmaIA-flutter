import {initializeApp} from "firebase-admin/app";
import {setGlobalOptions} from "firebase-functions/v2";
import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

// Initialize the Admin SDK once for all functions.
initializeApp();

setGlobalOptions({maxInstances: 10});

/**
 * Health check endpoint for emulator and deployment verification.
 */
export const health = onRequest((request, response) => {
  logger.info("Health check", {structuredData: true});
  response.json({
    status: "ok",
    project: "dbFarmacia",
    timestamp: new Date().toISOString(),
  });
});

// Keeps the `role` custom claim in sync with the users doc (§1.3, §5.5).
export {syncRoleClaim} from "./auth/sync_role_claim";

// Orders: creation, payment confirmation/webhook, withdrawal (§3.4, §5.5).
export {
  createOrder,
  confirmMockPayment,
  paymentWebhook,
  requestWithdrawal,
} from "./orders/order_functions";

// Admin AI pipeline: image Vision trigger + bilingual text generation (§4.2-4.3).
export {processProductImage} from "./admin/vision_pipeline";
export {generateProductTexts} from "./admin/generate_texts";

// Customer assistant (§12, Fase 4B): chat pipeline with pre-LLM router and
// guardrails, pharmacist escalation/review, embedding sync, GDPR purge and
// daily monitoring.
export {
  assistantChat,
  assistantEscalate,
  assistantReview,
} from "./ai/assistant_chat";
export {syncProductEmbedding} from "./ai/product_embeddings";
export {
  purgeChatSessions,
  assistantDailyReport,
} from "./ai/assistant_maintenance";
