# Firebase — Baganza Farmacie 3.0

Progetto Firebase: **dbFarmacia** (alias `dev`).

## Prerequisiti

- Node.js ≥ 20
- Firebase CLI: `npm install -g firebase-tools`
- Login: `firebase login`

## Avvio emulatori

```bash
cd firebase
npm install --prefix functions
firebase emulators:start
```

| Servizio | Porta |
|---|---|
| Emulator UI | 4000 |
| Auth | 9099 |
| Firestore | 8080 |
| Storage | 9199 |
| Functions | 5001 |
| Hosting | 5000 |

## Deploy

```bash
firebase deploy --only functions,firestore,storage,hosting
```

## Secret Manager (Fase 4+)

I seguenti secret vanno configurati in Google Cloud Secret Manager e referenziati dalle Cloud Functions:

| Secret | Uso |
|---|---|
| `OPENAI_API_KEY` | Generazione testi prodotto IT/EN |
| `PHOTOROOM_API_KEY` | Scontorno immagini prodotto |
| `STRIPE_SECRET_KEY` | Pagamenti carta |
| `PAYPAL_CLIENT_SECRET` | Pagamenti PayPal |
| `SATISPAY_API_KEY` | Pagamenti Satispay |

Copiare `functions/.env.example` in `functions/.env` per lo sviluppo locale con emulatori (non committare `.env`).

## Struttura Functions

```
functions/src/
├── ai/           # Pipeline vision + LLM (Fase 4)
├── catalog/      # Trigger draft prodotto
├── orders/       # Creazione ordine, IVA
├── payments/     # Webhook gateway
├── search/       # Sync Algolia/Typesense
└── index.ts      # Export funzioni
```

## Ambienti

Alias definiti in `.firebaserc`. Selezione con `firebase use <alias>`.

| Alias | Progetto Firebase | Stato |
|---|---|---|
| `dev` / `default` | `dbfarmacia` | Attivo |
| `prod` | `dbfarmacia-prod` | **Da creare** in Firebase Console, poi `firebase use prod` |
