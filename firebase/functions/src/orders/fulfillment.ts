import {getFirestore, FieldValue, Firestore} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

/**
 * Marks an order paid exactly once, decrementing stock and confirming the
 * order in a single transaction, then clears the buyer's cart and "sends" the
 * transactional email (§4.2, §9.2). Idempotent: a second call for an
 * already-paid order is a no-op, so it is safe to invoke from both the sandbox
 * confirmation and the real gateway webhook.
 *
 * Stock is scaled ONLY here — i.e. only once payment is confirmed (§9.2); a
 * pending or failed payment never touches stock.
 *
 * @param {Firestore} db Firestore instance.
 * @param {string} orderId The order document id.
 * @param {string} paymentRef Gateway/payment reference to record.
 * @return {Promise<boolean>} true if it transitioned to paid, false if it was
 *   already paid (idempotent no-op).
 */
export async function markOrderPaid(
  db: Firestore,
  orderId: string,
  paymentRef: string,
): Promise<boolean> {
  const orderRef = db.collection("orders").doc(orderId);

  const transitioned = await db.runTransaction(async (tx) => {
    const snap = await tx.get(orderRef);
    if (!snap.exists) {
      throw new Error(`order ${orderId} not found`);
    }
    const order = snap.data() as FirebaseFirestore.DocumentData;
    if (order.paymentStatus === "paid") {
      return false; // already processed — idempotent
    }

    // All reads before any writes (Firestore transaction rule).
    const items: Array<{productRef: string; qty: number}> = order.items ?? [];
    const productRefs = items.map((i) =>
      db.collection("products").doc(i.productRef),
    );
    const productSnaps = productRefs.length ?
      await tx.getAll(...productRefs) :
      [];

    // Writes: decrement stock, then confirm the order.
    productSnaps.forEach((pSnap, idx) => {
      if (!pSnap.exists) return;
      const stock = (pSnap.data()?.stockQty as number | undefined) ?? 0;
      const qty = items[idx].qty ?? 0;
      tx.update(pSnap.ref, {stockQty: Math.max(0, stock - qty)});
    });

    tx.update(orderRef, {
      paymentStatus: "paid",
      status: "confirmed",
      paymentRef,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return true;
  });

  if (transitioned) {
    // Clear the buyer's cart (userRef is stored as "users/<uid>").
    const snap = await orderRef.get();
    const userRef = (snap.data()?.userRef as string | undefined) ?? "";
    const uid = userRef.startsWith("users/") ? userRef.slice(6) : "";
    if (uid) {
      await db.collection("carts").doc(uid).delete().catch(() => undefined);
    }
    // Transactional email — stubbed (real SMTP/SendGrid is in ADR 0003).
    logger.info("Order paid → email queued", {orderId, paymentRef});
  }
  return transitioned;
}

/** Convenience accessor kept local so tests can inject a Firestore. */
export function db(): Firestore {
  return getFirestore();
}
