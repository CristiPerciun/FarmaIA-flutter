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
