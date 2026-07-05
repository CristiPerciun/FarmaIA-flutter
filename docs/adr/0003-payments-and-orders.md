# ADR 0003 — Pagamenti & creazione ordine (step 3.3–3.4)

- **Stato:** Accettata (MVP con provider sandbox; gateway reali da integrare)
- **Data:** 2026-07-05
- **Contesto:** §5.5, §9.2, step 3.3–3.4 di `Per step.md`, Parte 2 §3

## Problema

L'ordine deve nascere in modo affidabile e sicuro: prezzi autoritativi lato
server, stock scalato **solo a pagamento confermato** (§9.2), e i clienti non
devono poter scrivere `orders` (§5.5). I gateway reali (PayPal, Stripe/Nexi,
Satispay, BNPL) richiedono account, chiavi server e webhook firmati che non
sono ancora disponibili.

## Decisione

**Order backend (fatto ora, §3.4).** Tre Cloud Functions + un webhook:

- `createOrder` (callable): riprezza il carrello dai documenti `products`
  autoritativi (solo `published`), calcola totali/IVA lato server, crea
  l'ordine `pending`/`created` con `userRef = "users/<uid>"`. **Non tocca lo
  stock.**
- `confirmMockPayment` (callable): conferma **sandbox** che sta al posto del
  webhook del gateway finché i gateway reali non sono integrati.
- `paymentWebhook` (HTTP): hook reale del gateway, **idempotente** via
  `webhookEvents/{eventId}`.
- `requestWithdrawal` (callable): recesso tracciato (art. 54-bis).

`markOrderPaid` è condivisa da `confirmMockPayment` e `paymentWebhook`: in una
transazione segna l'ordine `paid`/`confirmed` e **scala lo stock una sola
volta** (idempotente), poi svuota il carrello e accoda l'email transazionale.

**Pagamenti (MVP, §3.3).** L'app mostra la scelta del metodo (Carta, PayPal,
Satispay, BNPL) e usa il **provider sandbox**: nessun addebito reale. Le chiavi
non sono mai nel client (principio di progetto).

**Guest checkout (§3.2).** I clienti non autenticati vengono firmati in modo
**anonimo** (`ensureSignedIn`) al momento dell'ordine, così l'ordine ha un
proprietario e le regole `orders`/`carts` reggono. Richiede l'abilitazione del
provider **Anonymous** in Firebase Auth.

## Cosa manca (prima della produzione)

1. **Integrazione gateway reali**: SDK/redirect per Stripe/Nexi, PayPal,
   Satispay, BNPL; tokenizzazione (PCI-DSS) e **3-D Secure 2.0**; chiavi in
   Secret Manager.
2. **Verifica firma webhook** per ciascun gateway in `paymentWebhook` (oggi è
   validata forma + idempotenza; la firma è un TODO segnalato nel codice).
3. **Email transazionali reali** (SMTP/SendGrid) al posto dello stub `logger`.
4. Abilitare **Anonymous Auth** (dev+prod) per il guest checkout.
5. Test end-to-end in **sandbox** per ogni metodo abilitato (criterio ✓ di 3.3).

Finché 1–5 non sono completi, il flusso è dimostrabile solo con il provider
sandbox negli emulatori; la logica di ordine/stock/idempotenza è però già
quella definitiva.
