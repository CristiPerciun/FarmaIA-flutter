# Firebase — Baganza Farmacie 3.0

Progetto Firebase: **dbFarmacia** (alias `dev`).

## Prerequisiti

- Node.js ≥ 20
- Firebase CLI: `npm install -g firebase-tools`
- Login: `firebase login`

> **Nota JDK:** gli emulatori Firebase (Firestore/Storage) richiedono **Java ≥ 21**.
> Se non presente a sistema, si può usare il JDK incluso in Android Studio:
> `export JAVA_HOME="/c/Program Files/Android/Android Studio/jbr"`.

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

## Dati di esempio (seed) — Step 1.1

Popola l'emulatore con documenti di esempio per tutte le collezioni e li rilegge
(l'Admin SDK bypassa le security rules):

```bash
# con emulatori attivi
npm --prefix functions run seed
# oppure one-shot (avvia un emulatore firestore solo per il seed)
firebase emulators:exec --only firestore "npm --prefix functions run seed"
```

## Test delle Security Rules — Step 1.2

```bash
cd tests
npm install                 # una tantum (@firebase/rules-unit-testing)
npm run test:emulator       # avvia un emulatore firestore ed esegue i test
```

Verificano: bozze invisibili ai non-staff, isolamento per-utente, `role` non
modificabile dal client, ordini scrivibili solo lato Functions.

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
| `LLM_BASE_URL` / `LLM_MODEL` / `LLM_API_KEY` | Assistente cliente (Fase 4B, provider EU OpenAI-compatibile — ADR 0005) |
| `EMBEDDING_BASE_URL` / `EMBEDDING_MODEL` / `EMBEDDING_API_KEY` | Embeddings RAG catalogo (default: endpoint LLM) |

Copiare `functions/.env.example` in `functions/.env` per lo sviluppo locale con emulatori (non committare `.env`).

## Assistente cliente (Fase 4B)

Senza chiavi LLM le funzioni girano in **modalità mock deterministica**: tutta
la pipeline (router pre-LLM → guardrail → retrieval → risposta → log su
`chatSessions`) è testabile sugli emulatori. Il feature flag
`config/app.assistantChatEnabled` è **OFF** di default (si accende solo dopo
il gate 4B.8); lo staff bypassa il flag per il red-team.

Harness golden set / red-team (emulatori attivi, catalogo seedato):

```bash
firebase --project=dbfarmacia emulators:exec --only functions,firestore,auth \
  "npm --prefix functions run seed && npm --prefix functions run eval:assistant"
```

Le categorie red_flag/rx/injection/moderazione devono passare al **100%**
(exit code ≠ 0 altrimenti). Nota: il primo deploy dell'indice vettoriale
(`products.embedding`, dim 1024) avviene con `firebase deploy --only
firestore:indexes`; sull'emulatore il retrieval usa il fallback in-memory.

## Struttura Functions

```
functions/src/
├── auth/         # syncRoleClaim: mirror users.role → custom claim (Fase 1)
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
