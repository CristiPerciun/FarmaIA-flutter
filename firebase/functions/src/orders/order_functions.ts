import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {onCall, onRequest, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {markOrderPaid} from "./fulfillment";

const REGION = "europe-west1";

type CartItem = {productRef: string; qty: number; priceSnapshot?: number};

/**
 * Creates an order from the caller's cart (§3.4). Prices are recomputed
 * server-side from the authoritative `products` docs (never trusting client
 * amounts); only `published` products are included. The order starts
 * `pending`/`created` — stock is untouched until payment is confirmed (§9.2).
 * Clients cannot write `orders` directly (§5.5), so this is the only entry.
 */
export const createOrder = onCall({region: REGION}, async (req) => {
  const uid = req.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  const db = getFirestore();

  const cartSnap = await db.collection("carts").doc(uid).get();
  const items = (cartSnap.data()?.items as CartItem[] | undefined) ?? [];
  if (items.length === 0) {
    throw new HttpsError("failed-precondition", "Cart is empty.");
  }

  const config = (await db.collection("config").doc("app").get()).data() ?? {};
  const shippingCost = (config.shippingCost as number) ?? 490;
  const freeThreshold = (config.freeShippingThreshold as number) ?? 4900;
  const defaultVat = (config.defaultVatRate as number) ?? 22;

  const productSnaps = await db.getAll(
    ...items.map((i) => db.collection("products").doc(i.productRef)),
  );

  const orderItems: Array<Record<string, unknown>> = [];
  let subtotal = 0;
  let vat = 0;
  productSnaps.forEach((pSnap, idx) => {
    const p = pSnap.data();
    if (!p || p.status !== "published") return; // skip unavailable
    const priceList = (p.priceList as number) ?? 0;
    const priceSale = (p.priceSale as number) ?? 0;
    const unitPrice =
      priceSale > 0 && priceSale < priceList ? priceSale : priceList;
    const qty = items[idx].qty ?? 0;
    if (qty <= 0) return;
    const rate = (p.vatRate as number) ?? defaultVat;
    const lineTotal = unitPrice * qty;
    subtotal += lineTotal;
    vat += rate > 0 ? Math.round((lineTotal * rate) / (100 + rate)) : 0;
    orderItems.push({
      productRef: items[idx].productRef,
      nameSnapshot: (p.name?.it as string) ?? "",
      qty,
      unitPrice,
      vatRate: rate,
    });
  });

  if (orderItems.length === 0) {
    throw new HttpsError("failed-precondition", "No available items.");
  }

  const shipping = subtotal >= freeThreshold ? 0 : shippingCost;
  const total = subtotal + shipping;
  // Human-friendly order number; not security-sensitive.
  const orderNumber =
    "BF-" + Date.now().toString(36).toUpperCase().slice(-8);

  const orderRef = db.collection("orders").doc();
  await orderRef.set({
    orderNumber,
    userRef: `users/${uid}`,
    items: orderItems,
    totals: {subtotal, shipping, vat, total},
    shippingAddress: req.data?.shippingAddress ?? {},
    billingAddress: null,
    paymentMethod: (req.data?.paymentMethod as string) ?? "card",
    paymentStatus: "pending",
    shippingStatus: "processing",
    status: "created",
    recessoRequested: false,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  logger.info("Order created", {orderId: orderRef.id, uid, total});
  return {orderId: orderRef.id, orderNumber};
});

/**
 * Sandbox payment confirmation (§3.3/§3.4). Stands in for the gateway webhook
 * while real gateways are not wired (ADR 0003): verifies ownership, then marks
 * the order paid (idempotent), scaling stock and clearing the cart.
 */
export const confirmMockPayment = onCall({region: REGION}, async (req) => {
  const uid = req.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  const orderId = req.data?.orderId as string | undefined;
  if (!orderId) {
    throw new HttpsError("invalid-argument", "orderId required.");
  }
  const db = getFirestore();
  const snap = await db.collection("orders").doc(orderId).get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Order not found.");
  }
  if (snap.data()?.userRef !== `users/${uid}`) {
    throw new HttpsError("permission-denied", "Not your order.");
  }
  await markOrderPaid(db, orderId, `sandbox_${orderId}`);
  return {ok: true};
});

/**
 * Real payment gateway webhook (§3.4). Idempotent via `webhookEvents/{eventId}`
 * so retried deliveries are processed once. NOTE: signature verification per
 * gateway is required before production (ADR 0003) — this validates shape and
 * idempotency; the signature check is a documented TODO.
 */
export const paymentWebhook = onRequest({region: REGION}, async (req, res) => {
  const eventId = (req.body?.eventId as string | undefined) ?? "";
  const orderId = (req.body?.orderId as string | undefined) ?? "";
  const status = (req.body?.status as string | undefined) ?? "";
  if (!eventId || !orderId) {
    res.status(400).json({error: "eventId and orderId required"});
    return;
  }

  const db = getFirestore();
  const eventRef = db.collection("webhookEvents").doc(eventId);

  // Idempotency guard: create the event doc only if it doesn't exist.
  try {
    await eventRef.create({
      orderId,
      status,
      receivedAt: FieldValue.serverTimestamp(),
    });
  } catch {
    logger.info("Duplicate webhook ignored", {eventId, orderId});
    res.status(200).json({ok: true, duplicate: true});
    return;
  }

  if (status === "paid" || status === "succeeded") {
    await markOrderPaid(db, orderId, `gw_${eventId}`);
  } else if (status === "failed") {
    await db.collection("orders").doc(orderId).update({
      paymentStatus: "failed",
      updatedAt: FieldValue.serverTimestamp(),
    });
  }
  res.status(200).json({ok: true});
});

/**
 * Records a tracked right-of-withdrawal request on an order (art. 54-bis,
 * §16.8). Owner-only; clients cannot write `orders` directly (§5.5).
 */
export const requestWithdrawal = onCall({region: REGION}, async (req) => {
  const uid = req.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  const orderId = req.data?.orderId as string | undefined;
  if (!orderId) {
    throw new HttpsError("invalid-argument", "orderId required.");
  }
  const db = getFirestore();
  const ref = db.collection("orders").doc(orderId);
  const snap = await ref.get();
  if (!snap.exists || snap.data()?.userRef !== `users/${uid}`) {
    throw new HttpsError("permission-denied", "Not your order.");
  }
  await ref.update({
    recessoRequested: true,
    recessoRequestedAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });
  logger.info("Withdrawal requested", {orderId, uid});
  return {ok: true};
});
