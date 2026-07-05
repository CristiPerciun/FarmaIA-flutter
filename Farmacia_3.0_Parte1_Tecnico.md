# Baganza Farmacie 3.0 — Documento Tecnico (PWA, Architettura, Frontend & Backend)
### Parte 1 di 2 · App di Farmacia Baganza (Parma) · Italia

> Questo è il **documento tecnico** del progetto. Raccoglie tutto ciò che riguarda la PWA: obiettivo e ruoli, funzionalità, architettura dei progetti (frontend + backend), modello dati, stile, SEO/rendering, funzionamento offline, casi limite, la "killer feature" AI, criteri di accettazione.
> La **Parte 2 di 2** (documento business/operativo) contiene mercato e concorrenza, conversione, pagamenti, fidelizzazione, logistica, compliance legale, modello di business, KPI, roadmap, considerazioni e fonti.

**Decisioni di base (confermate):**
- **Cliente:** **Farmacia Baganza** ("Baganza Farmacie", gruppo indipendente con **3 sedi a Parma**, titolare Dr. Marco Barbieri). L'app è l'**evoluzione e il consolidamento** dei due web attuali — il sito vetrina `farmaciabaganza.it` e l'e-commerce `benesserefarmacia.it` — in un'unica esperienza. **Tutta la personalizzazione (brand, logo, splash animato, servizi, multi-sede, integrazioni regionali) è nel §16.**
- **App standalone nuova** (non integrata in progetti esistenti).
- **Nessun backend preesistente:** il progetto comprende **due repository** — un progetto **frontend (Flutter)** e un progetto **backend (Firebase / Cloud Functions)**. Il backend, seppur "leggero", **serve** (sicurezza chiavi AI, pipeline di generazione, pagamenti, compliance: vedi §11).
- **Offline:** è supportata **solo la consultazione del catalogo** già scaricato; tutte le azioni transazionali richiedono connessione (vedi §9).
- **Lingue:** **italiano e inglese** (i18n: vedi §8).
- **Due AI, due ruoli:** oltre alla pipeline AI **lato admin** (creazione catalogo da foto, §10), l'app include un **assistente AI lato cliente** — una chat che ascolta i bisogni/sintomi lievi dell'utente e propone **solo prodotti del catalogo** (SOP/OTC/parafarmaci), basata su **LLM open-weights su hosting EU** con guardrail clinici e escalation al farmacista (vedi **§12**). UI dedicata: widget flottante + pannello 70/30 su web, tab nella bottom bar su mobile (§12.6).

---

## 1. Executive Summary (tecnico)

La soluzione è una **PWA (Progressive Web App)** e un'app per iOS, Android e Windows, costruita con **Flutter** (codice unico multipiattaforma) e backend **Firebase**, per **Farmacia Baganza** (gruppo con 3 sedi a Parma) come **evoluzione** dei suoi attuali siti, operante in **Italia**, con e-commerce limitato a **SOP, OTC, parafarmaci, integratori, cosmetici e dispositivi medici** (no farmaci con obbligo di prescrizione).

Oltre all'e-commerce, l'app integra i **servizi in farmacia** (prenotazione di autoanalisi, telemedicina, consulenze, info CUP e ritiro referti) e la **scelta della sede**, che per questa farmacia sono il vero elemento differenziante — vedi **§16**.

Gli elementi tecnici distintivi sono **due sistemi AI complementari**:
1. **Pannello di amministrazione "AI-Driven"** che automatizza l'inserimento del catalogo: da una foto grezza e da una descrizione minima, il sistema genera immagine ottimizzata e scheda prodotto **bilingue (IT/EN)**. Per **sicurezza e tutela legale**, tutta la logica di IA risiede nel backend e ogni contenuto sanitario passa per la **validazione umana obbligatoria del farmacista** prima della pubblicazione.
2. **Assistente AI per il cliente (§12):** una chat, alimentata da un **LLM open-weights ospitato in EU** e ancorata via **RAG al solo catalogo pubblicato**, che ascolta bisogni e disturbi lievi ("mi fa male la testa") e propone una lista di **prodotti da banco adatti**, con guardrail clinici (red-flag → rimando al medico), trasparenza AI e **escalation al farmacista** sempre disponibile. Non fa diagnosi: è un "commesso digitale", non un medico.

Due scelte architetturali del piano originale vanno riviste: **l'hosting** (GitHub Pages non è adatto a un e-commerce — §3 e §6) e **il rendering** (Flutter Web "puro" è quasi invisibile a Google — §6).

---

## 2. Obiettivo, Ruoli e Funzionalità (user stories)

### 2.1 Cosa risolve (in una frase)
Un e-commerce per una farmacia che permette ai clienti di **acquistare online prodotti SOP/OTC, parafarmaci e cosmetici** e di **ricevere consulenza professionale**, e al titolare di **gestire il catalogo in modo rapido grazie all'AI**, nel rispetto della normativa italiana.

### 2.2 Attori (chi la usa)
| Ruolo | Chi è | Accesso |
|---|---|---|
| **Visitatore (guest)** | Utente non autenticato | Sfoglia catalogo e contenuti; per acquistare deve registrarsi/accedere. |
| **Cliente** | Utente registrato | Acquista, gestisce ordini, abbonamenti, indirizzi, consensi, consulenze. |
| **Amministratore / Farmacista** | Titolare e personale autorizzato | Gestione catalogo (pipeline AI + validazione), ordini, consulenze. Lo switch Cliente/Admin avviene nel **Profilo**. |

> Il ruolo è memorizzato sul profilo utente (`role`) ed è applicato sia lato UI (route guard) sia lato dati (security rules). Vedi §5 e §9.

### 2.3 Funzionalità principali per ruolo (user stories)

**Cliente — deve poter:**
1. **Cercare** un prodotto per nome (con tolleranza ai refusi) o **scansionando il codice a barre**.
2. **Consultare** la scheda prodotto bilingue (descrizione, principio attivo, posologia, controindicazioni).
3. **Aggiungere al carrello** e **completare l'acquisto** con pagamento online.
4. **Gestire il proprio account**: ordini e stato spedizione, indirizzi, consensi (marketing e trattamento dati dei medicinali), abbonamenti.
5. **Prenotare una consulenza** con farmacista o cosmetologo (chat/video).
6. **Chattare con l'assistente AI** (web e mobile): descrivere un disturbo lieve o un bisogno ("mi fa male la testa", "cerco una crema per pelle secca") e ricevere una **lista di prodotti adatti dal catalogo**, con possibilità in ogni momento di **passare al farmacista umano**. L'assistente rifiuta i casi seri (red-flag) rimandando al medico.

**Amministratore / Farmacista — deve poter:**
1. **Aggiungere un prodotto** inserendo solo foto + descrizione minima + prezzo iniziale + prezzo scontato.
2. **Ricevere** dal sistema la scheda completa generata dall'AI (immagine ottimizzata + testi IT/EN).
3. **Validare e pubblicare**: rivedere i contenuti sanitari e pubblicare; finché non pubblica, il prodotto resta invisibile ai clienti.
4. **Gestire ordini** (stato, spedizione/tracking) e **gestire le richieste di consulenza** (slot, completamento).
5. **Gestire il catalogo** (modifica, disattivazione, gestione stock).
6. **Supervisionare l'assistente AI**: consultare il registro delle conversazioni, gestire le richieste di escalation, mantenere la lista dei sintomi "red-flag" e segnalare risposte scorrette (vedi §12.4).

### 2.4 Le 4 cose che rendono il progetto distintivo
Pipeline **AI per il data-entry** (admin), **assistente AI sintomi→prodotti** (cliente, §12), **consulenza professionale** integrata, **bilinguismo IT/EN** del catalogo. *(Il posizionamento commerciale è nella Parte 2.)*

---

## 3. Stack Tecnologico

| Componente | Tecnologia scelta | Motivazione & best practice |
|---|---|---|
| **Frontend & UI** | Flutter | Singolo codice base per Web, iOS, Android e Desktop. |
| **State Management** | Riverpod + Hooks | Riverpod (con `riverpod_generator`) per logica di business e chiamate API; `flutter_hooks` per stati effimeri della UI (animazioni, form), evitando il boilerplate del `setState`. |
| **Backend & Database** | Firebase | Cloud Firestore (NoSQL flessibile), Cloud Storage (immagini), Firebase Auth (autenticazione). |
| **Logica server** | Firebase Cloud Functions | Ambiente serverless Node.js/TypeScript: indispensabile per nascondere le chiavi API e processare i dati AI in sicurezza (vedi §10–§11). |
| **Integrazioni AI (admin)** | API immagini + LLM | API per scontorno/ottimizzazione immagini (es. Photoroom) + LLM (es. GPT-4o) per testi commerciali e sanitari, generati in **IT ed EN**. |
| **AI conversazionale (cliente)** | **LLM open-weights** via endpoint OpenAI-compatibile su **hosting EU** | Modello consigliato: **Qwen 3** (miglior open per l'italiano) o **Mistral Small 3.x** (alternativa EU-native, Apache 2.0); **DeepSeek V3.x** come alternativa frontier **solo su hosting EU/occidentale, mai l'API ufficiale cinese** (caso Garante); **OpenBioLLM scartato** come primario (solo EN). Architettura **model-agnostic** (base URL + nome modello configurabili). Dettagli e confronto in **§12.2**. |
| **RAG & embeddings (chat)** | Embedding multilingue open (es. `bge-m3`/`multilingual-e5`) + **Firestore Vector Search o Typesense (ibrido)** | Grounding della chat **sul solo catalogo pubblicato**; se si sceglie Typesense per la ricerca fuzzy, lo stesso motore copre anche il vettoriale (un componente in meno). Vedi §12.3. |
| **Moderazione AI (chat)** | Llama Guard 3 (o filtri del provider) | Guardrail su input/output della chat cliente; supporta l'**italiano**. Vedi §12.4. |
| **Routing** | go_router | Navigazione nativa e web; routing **basato su path** (non hash) per favorire l'indicizzazione e prevenire 404 sulla PWA. |
| **Ricerca** | **MVP: fuzzy client-side** (`core/utils/fuzzy.dart`) — *deciso, ADR 0002* | Normalizzazione (diacritici/spazi) + Levenshtein sul catalogo pubblicato in memoria: zero infrastruttura, funziona **offline** (§9.1), adeguata a un catalogo di farmacia. **Migrazione registrata** (ADR 0002): quando il catalogo cresce o serve il vettoriale per la chat (§12.3), **Typesense** copre fuzzy *e* vettoriale con una Cloud Function di sync (`search/`); il contratto lato app (`filteredProductsProvider`) resta stabile. Algolia resta l'alternativa premium. |
| **Effetti & motion UI** | `flutter_animate` + `BackdropFilter` + `Transform`/`Hero` (+ Rive per lo splash) | Linguaggio visivo §7.2: gradienti ambientali, glassmorphism con fallback solido, card 3D con tilt, transizioni hero, skeleton shimmer. Token in `ThemeExtension`, condivisi con lo storefront SSR via CSS variables. |
| **Internazionalizzazione** | `flutter_localizations` + ARB (`intl`) | Stringhe UI esternalizzate in `.arb` per IT/EN; contenuti di catalogo bilingui nel dato (vedi §5 e §8). |
| **Persistenza offline** | Firestore offline persistence + cache immagini | Solo per la **consultazione catalogo** (vedi §9). |
| **Hosting** | **Firebase Hosting o Vercel/Netlify** *(rivisto)* | GitHub Pages è sconsigliato per un e-commerce (vedi §6.4). Firebase Hosting si integra nativamente col backend; Vercel/Netlify offrono SSR/prerendering per la SEO. |
| **Pagamenti** | PayPal, Stripe o Nexi, Satispay, BNPL | Gateway con tokenizzazione e conformità PCI-DSS *(dettagli nella Parte 2)*. |
| **Sicurezza client↔server** | Firebase App Check | Garantisce che solo l'app autentica invochi backend/proxy e servizi Firebase. |

---

## 4. Architettura dei Progetti (Frontend + Backend)

Il sistema è composto da **due progetti** (`app/` Flutter e `firebase/` Firebase), indipendenti tra loro ma mantenuti in un unico **monorepo** Git (decisione di progetto: vedi README).

### 4.1 Progetto Frontend (Flutter) — architettura Feature-First
Ogni funzionalità ha il proprio ecosistema isolato, anziché la classica divisione orizzontale in `ui/` e `models/`.

```
app/ (Flutter)
└── lib/
    ├── core/                   # Temi, design tokens, costanti, router, i18n, client Firebase, utility
    ├── l10n/                   # File ARB: app_it.arb, app_en.arb
    ├── features/
    │   ├── auth/               # Login/registrazione, gestione ruolo
    │   ├── home/               # Home (bento grid, caroselli)
    │   ├── catalog/            # Lista, filtri, ricerca, scanner barcode
    │   ├── product/            # Dettaglio prodotto (bilingue)
    │   ├── cart/               # Carrello e checkout
    │   ├── assistant/          # Chat AI cliente: widget web + pannello 70/30, tab mobile (§12.6)
    │   ├── account/            # Ordini, indirizzi, consensi, abbonamenti
    │   ├── consultations/      # Prenotazione e chat/video
    │   ├── admin/              # Dashboard: aggiunta prodotto (AI), validazione, ordini, audit chat AI
    │   └── content/            # Blog/guide alla salute (E-E-A-T)
    └── main.dart               # Entry point, init Firebase + App Check
```

### 4.2 Progetto Backend (Firebase / Cloud Functions)
Backend "thin" ma necessario: ospita chiavi e logica AI, webhook di pagamento, sincronizzazione ricerca, regole.

```
firebase/ (Firebase)
├── functions/
│   └── src/
│       ├── ai/                 # Pipeline admin: vision (Photoroom) + generazione testi LLM (IT/EN), grounding, guardrail
│       ├── assistant/          # Chat AI cliente: endpoint chat (streaming), retrieval RAG, red-flag triage, moderazione, sessioni (§12)
│       ├── catalog/            # Trigger onProductDraftCreated; workflow di pubblicazione; embedding alla pubblicazione (§12.3)
│       ├── orders/             # Creazione ordine, calcolo totali/IVA, email transazionali
│       ├── payments/           # Webhook gateway (Stripe/PayPal/Satispay), idempotenza
│       ├── search/             # Sync prodotti pubblicati verso Algolia/Typesense
│       ├── consultations/      # Gestione slot e stato consulenze
│       └── index.ts            # Export delle funzioni
├── firestore.rules             # Regole di sicurezza Firestore
├── storage.rules               # Regole Cloud Storage
├── firestore.indexes.json      # Indici compositi
└── firebase.json               # Config hosting/functions/emulators
```

### 4.3 Schema dei livelli (logico)
```
[ Client Flutter (PWA / iOS / Android / Windows) ]
        │  (Firebase SDK + App Check)
        ▼
[ Firebase: Auth · Firestore · Storage ]
        │
        ▼
[ Cloud Functions (logica server, chiavi API, pipeline AI, webhook pagamenti) ]
        │
        ├──► API LLM (es. GPT-4o)        → testi IT/EN (pipeline admin, §10)
        ├──► LLM open-weights su hosting EU (Qwen/Mistral/DeepSeek) → chat AI cliente (§12)
        ├──► API Immagini (es. Photoroom)→ scontorno + WebP
        ├──► Motore di ricerca (Algolia/Typesense) + indice vettoriale (RAG chat, §12.3)
        └──► Gateway di pagamento (Stripe/PayPal/Satispay)
```

### 4.4 Superfici client: una base di codice, quattro superfici *(decisione di sostenibilità)*

Il sistema serve pubblici e contesti d'uso diversi. Per restare sostenibile con un team piccolo, la regola è: **un solo codice Flutter adattivo + uno storefront SSR leggero**, mai tre frontend paralleli.

| Superficie | Utente principale | Tecnologia | Ruolo |
|---|---|---|---|
| **Storefront pubblico (SEO)** | Visitatori e crawler di Google | HTML **SSR/prerender** (§6.2) | Catalogo, schede prodotto, blog, pagine sedi/servizi. È l'unica superficie che Google indicizza. |
| **Web app mobile (PWA)** | Clienti da smartphone | **Flutter Web** (breakpoint compact) | Flussi autenticati: carrello, checkout, account, chat AI (tab), prenotazioni. Installabile (manifest + service worker). |
| **Portale web desktop** | Clienti da PC + **admin/farmacista** | **Flutter Web** (breakpoint expanded, stesso codice) | Stessa app con layout desktop: navigazione a rail/menu orizzontale, griglie multi-colonna, chat 70/30 (§12.6), **dashboard admin**. |
| **App Windows** | Admin/farmacista al banco/back-office | **Flutter Windows** (stesso codice, target già abilitato in `app/windows/`) | Uso quotidiano del pannello admin senza browser: inserimento prodotti AI, ordini, prenotazioni, audit chat. Distribuzione MSIX (post-MVP; il portale web desktop copre lo stesso ruolo dal giorno 1). |

**Regole di adattività (vincolanti per ogni nuova schermata):**
- **Breakpoint token** in `core/theme` (allineati a Material 3): `compact` < 600 px · `medium` 600–1024 px · `expanded` ≥ 1024 px. Nessun breakpoint hardcoded nelle feature.
- **Navigazione adattiva:** bottom bar 5 voci su `compact` (§7.3); `NavigationRail`/menu orizzontale su `expanded`; la chat AI passa da tab full-screen a pannello 70/30 (§12.6). Una sola sorgente di rotte (`go_router`), il layout wrapper decide la shell.
- **Contenuti fluidi:** griglie con `SliverGrid`/`maxCrossAxisExtent` (mai conteggi di colonne fissi), form con larghezza massima leggibile (~640 px) centrata su desktop.
- **Guardie di piattaforma** in `core/utils` (`kIsWeb`, `Platform.isWindows`, …): scanner barcode e push **solo mobile** (su desktop: input EAN manuale e email/nessuna notifica); pagamenti su web via redirect/checkout hosted; nessun plugin mobile-only importato senza fallback. Ogni feature dichiara la propria **matrice di supporto** nel piano (Per step).
- **Parità di test:** la CI compila **web + Android + Windows**; una rottura del target Windows è una rottura di build, non un problema "da vedere poi".

> **Perché non un progetto separato per il portale?** Il portale desktop è la stessa app con più spazio: duplicarlo (es. React admin) raddoppierebbe modelli, regole, i18n e manutenzione. L'unica cosa che resta fuori da Flutter è lo storefront SEO (§6), che è un problema di *rendering per i crawler*, non di UI applicativa.

---

## 5. Modello Dati (entità, campi, schema Firestore)

**Principio bilingue:** i campi testuali destinati all'utente sono **mappe localizzate** `{ "it": "...", "en": "..." }`, così lo stesso documento serve entrambe le lingue. Gli importi sono in **centesimi** (interi) per evitare errori di arrotondamento.

### 5.1 Entità principali e campi

**`Product` (collezione `products`)**
`id`, `sku`, `barcode` (EAN), `categoryRef`, `type` (`SOP|OTC|parafarmaco|integratore|cosmetico|dispositivo_medico`), `isMedicine` (bool → governa separazione pagina e logo), `name{it,en}`, `shortDescription{it,en}`, `description{it,en}`, `activeIngredient{it,en}`, `posology{it,en}`, `contraindications{it,en}`, `warnings{it,en}`, `ceMarking` (bool, per dispositivi), `priceList` (int, cent), `priceSale` (int, cent), `currency` (`EUR`), `vatRate` (es. 4, 10, 22), `stockQty` (int), `available` (bool), `images[]` (`{url, alt{it,en}}`), `seo{slug{it,en}, title{it,en}, metaDescription{it,en}}`, `status` (`draft|pending_review|published|archived`), `aiGenerated` (bool), `reviewedBy` (ref adminUser), `reviewedAt`, `publishedAt`, `createdAt`, `updatedAt`, `embedding` (vettore multilingue generato **alla pubblicazione** per il retrieval della chat AI, §12.3 — non serializzato verso il client), `assistantEligible` (bool, default true: il farmacista può escludere un prodotto dai suggerimenti della chat).

**`Category` (collezione `categories`)**
`id`, `name{it,en}`, `slug{it,en}`, `parentRef` (nullable), `isMedicineCategory` (bool), `order` (int).

**`User` (collezione `users`, doc = `uid` di Firebase Auth)**
`uid`, `role` (`customer|pharmacist|admin`), `email`, `displayName`, `phone`, `locale` (`it|en`), `addresses[]` (`{label, recipient, street, city, zip, province, country, phone}`), `consents{marketing(bool), medicineDataProcessing(bool), aiAssistant(bool → consenso esplicito art. 9 GDPR per i dati sanitari digitati in chat, §12.5), updatedAt}`, `loyaltyPoints` (int), `createdAt`.

**`Cart` (collezione `carts`, doc = `uid`)**
`userRef`, `items[]` (`{productRef, qty, priceSnapshot}`), `updatedAt`. *(La modifica richiede connessione: §9.)*

**`Order` (collezione `orders`)**
`id`, `orderNumber`, `userRef`, `items[]` (`{productRef, nameSnapshot, qty, unitPrice, vatRate}`), `totals{subtotal, shipping, vat, total}`, `shippingAddress{}`, `billingAddress{}`, `paymentMethod`, `paymentStatus` (`pending|paid|failed|refunded`), `paymentRef`, `shippingStatus` (`processing|shipped|delivered|returned`), `carrier`, `trackingNumber`, `status` (`created|confirmed|preparing|shipped|delivered|cancelled`), `recessoRequested` (bool, per art. 54-bis), `createdAt`, `updatedAt`.

**`Consultation` (collezione `consultations`)**
`id`, `userRef`, `kind` (`farmacista|cosmetologo`), `channel` (`chat|video`), `slotStart`, `slotEnd`, `status` (`requested|confirmed|completed|cancelled`), `notesEncrypted`, `createdAt`.

**`Subscription` (collezione `subscriptions`)**
`id`, `userRef`, `productRef`, `frequencyDays` (int), `nextRun`, `discountPct`, `status` (`active|paused|cancelled`).

**`ChatSession` (collezione `chatSessions` — assistente AI cliente, §12)**
`id`, `userRef` (nullable per guest → `anonId` di sessione), `locale` (`it|en`), `consentAt` (timestamp del consenso art. 9, obbligatorio prima del primo messaggio), `status` (`active|closed|escalated`), `escalation{requested(bool), handledBy(ref), handledAt}`, `redFlagTriggered` (bool), `flaggedForReview` (bool), `reviewedBy` (nullable), `startedAt`, `lastMessageAt`, `purgeAt` (retention breve, es. +90 giorni, §12.5).

**`ChatMessage` (sub-collezione `chatSessions/{id}/messages`)**
`id`, `role` (`user|assistant`), `text`, `suggestedProducts[]` (`{productRef, reason}` — solo prodotti `published` e `assistantEligible`), `redFlag` (bool), `moderation{inputFlagged, outputFlagged, categories[]}`, `modelInfo{provider, model, promptVersion}` (log di provenienza), `createdAt`. *(Scrittura **solo** via Cloud Function: il client non scrive mai direttamente i messaggi dell'assistente — §5.5, §12.3.)*

**`Article` (collezione `articles` — blog/E-E-A-T)**
`id`, `slug{it,en}`, `title{it,en}`, `body{it,en}`, `authorRef` (farmacista), `reviewedBy`, `lastReviewedAt`, `status` (`draft|published`).

**`Config` (collezione `config`)**
parametri operativi (es. `freeShippingThreshold`, costi di spedizione, aliquote IVA di default).

### 5.2 Esempio JSON — `products/{id}`
```json
{
  "id": "prod_00123",
  "sku": "OKI-TASK-10",
  "barcode": "8052827950017",
  "categoryRef": "categories/analgesici",
  "type": "SOP",
  "isMedicine": true,
  "name": { "it": "Oki Task 10 bustine", "en": "Oki Task 10 sachets" },
  "shortDescription": { "it": "Analgesico per mal di testa", "en": "Pain reliever for headache" },
  "description": { "it": "…", "en": "…" },
  "activeIngredient": { "it": "Ketoprofene sale di lisina", "en": "Ketoprofen lysine salt" },
  "posology": { "it": "1 bustina fino a 3 volte/die", "en": "1 sachet up to 3 times/day" },
  "contraindications": { "it": "…", "en": "…" },
  "warnings": { "it": "…", "en": "…" },
  "ceMarking": false,
  "priceList": 999,
  "priceSale": 699,
  "currency": "EUR",
  "vatRate": 10,
  "stockQty": 42,
  "available": true,
  "images": [{ "url": "https://…/prod_00123.webp", "alt": { "it": "Oki Task", "en": "Oki Task" } }],
  "seo": { "slug": { "it": "oki-task-10-bustine", "en": "oki-task-10-sachets" }, "title": { "it": "…", "en": "…" }, "metaDescription": { "it": "…", "en": "…" } },
  "status": "published",
  "aiGenerated": true,
  "reviewedBy": "users/uid_admin_01",
  "reviewedAt": "2026-06-20T10:15:00Z",
  "publishedAt": "2026-06-20T10:16:00Z",
  "createdAt": "2026-06-20T10:00:00Z",
  "updatedAt": "2026-06-20T10:16:00Z"
}
```

### 5.3 Esempio JSON — `orders/{id}`
```json
{
  "orderNumber": "2026-000128",
  "userRef": "users/uid_cliente_77",
  "items": [
    { "productRef": "products/prod_00123", "nameSnapshot": "Oki Task 10 bustine", "qty": 2, "unitPrice": 699, "vatRate": 10 }
  ],
  "totals": { "subtotal": 1398, "shipping": 0, "vat": 127, "total": 1398 },
  "shippingAddress": { "recipient": "Mario Rossi", "street": "Via Roma 1", "city": "Parma", "zip": "43100", "province": "PR", "country": "IT" },
  "paymentMethod": "paypal",
  "paymentStatus": "paid",
  "shippingStatus": "processing",
  "status": "confirmed",
  "recessoRequested": false,
  "createdAt": "2026-06-26T09:00:00Z"
}
```

### 5.4 Struttura Firestore (sintesi)
```
/products/{productId}
/categories/{categoryId}
/users/{uid}
/carts/{uid}
/orders/{orderId}
/consultations/{consultationId}
/subscriptions/{subscriptionId}
/chatSessions/{sessionId}/messages/{messageId}
/articles/{articleId}
/config/{docId}
```

### 5.5 Sicurezza dei dati (riepilogo regole)
- **`products`/`categories`/`articles`:** lettura pubblica **solo per `status == "published"`**; le bozze (`draft`/`pending_review`) sono leggibili solo da `admin`/`pharmacist`. Scrittura/pubblicazione **solo** `admin`/`pharmacist`.
- **`users`:** ogni utente legge/scrive **solo** il proprio documento; il campo `role` non è modificabile dal client.
- **`carts`/`orders`/`subscriptions`/`consultations`:** accessibili **solo** al proprietario (`userRef == uid`); creazione ordini e cambi di stato sensibili passano da Cloud Functions. Le note di consulenza sono **cifrate** e accessibili solo al personale autorizzato.
- **`chatSessions` (+ `messages`):** lettura **solo** proprietario (o `anonId` di sessione per i guest) e `admin`/`pharmacist` (audit); **scrittura esclusivamente via Cloud Function** — il client non crea/modifica messaggi direttamente, così la pipeline guardrail (§12.3–12.4) non è aggirabile. Il campo `products.embedding` non è esposto nelle letture client.
- **Chiavi API e segreti:** mai in Firestore né nel client → **Secret Manager**, usate solo dalle Cloud Functions (vedi §10–§11).

---

## 6. SEO, Indicizzazione e Architettura di Rendering *(critica)*

> **Nota terminologica (per evitare un equivoco ricorrente):**
> - **SEO** (*Search Engine Optimization*) = far **trovare il catalogo nelle ricerche di Google**. È l'oggetto di questa sezione e della Fase 2 del piano (step 2.7). Non richiede alcun account Google dell'utente: riguarda ciò che il **crawler** di Google riesce a leggere.
> - **SSO** (*Single Sign-On*, es. "Accedi con Google") = permettere all'utente di **fare login** con il proprio account Google invece di email+password. È una comodità di autenticazione (Firebase Auth con provider `google.com`), indipendente dalla SEO: attivarla non aiuta in alcun modo l'indicizzazione. Nel piano è lo step 1.5.
>
> Le due cose condividono solo la parola "Google": la SEO decide **se i clienti vi trovano**, l'SSO decide **quanto è comodo entrare**.

### 6.1 Il problema: Flutter Web e l'indicizzazione
Flutter Web in modalità **CanvasKit** disegna l'interfaccia su una *canvas* WebGL: la pagina è **priva di DOM testuale indicizzabile** (nessun testo semantico/heading/link leggibile dal crawler). Una PWA Flutter "pura" è quindi **quasi invisibile a Google**. Anche il renderer HTML produce testo frammentato ed è in via di deprioritizzazione; il **peso del bundle** (JS/WASM) penalizza i Core Web Vitals.

### 6.2 La raccomandazione: disaccoppiare il rendering
- **Catalogo, schede prodotto e blog** serviti come **HTML pre-renderizzato / SSR** (storefront statico o SSR con Next.js o equivalente; in alternativa prerender per i bot via Rendertron/Prerender.io).
- **Flutter** per i flussi "app-like" autenticati (carrello, checkout, account, admin) — vedi le superfici del §4.4.
- Routing **basato su path**, `<title>`/meta/OpenGraph per pagina, **JSON-LD** (`Product`, `FAQPage`, `BreadcrumbList`), `robots.txt`, `sitemap.xml`. Le pagine SEO sono **bilingui** con URL e `hreflang` per IT/EN.

**Architettura di riferimento (un dominio, due renderer):**
```
www.farmaciabaganza.it
├── /            /prodotti/... /p/{slug} /blog/... /sedi /servizi   → STOREFRONT SSR (HTML reale)
│     legge Firestore lato server (solo `published`) · JSON-LD · hreflang IT/EN
│     ogni pagina ha CTA "Aggiungi al carrello / Apri nell'app" → deep-link alla PWA
└── /app/...                                                        → PWA FLUTTER
      carrello, checkout, account, chat AI, prenotazioni, admin
```
- **Un solo dominio** (niente sottodominio `shop.`): l'autorità SEO si accumula su un host unico e i cookie/sessione Firebase valgono per entrambi i renderer.
- **Stessa fonte dati:** lo storefront SSR legge le **stesse collezioni Firestore** dell'app (prodotti `published`, articoli, sedi, servizi) — zero duplicazione di contenuto, la validazione del farmacista (§10) copre automaticamente anche le pagine SEO.
- **Sitemap generata dal dato:** una Cloud Function rigenera `sitemap.xml` (IT+EN) alla pubblicazione/archiviazione di prodotti e articoli; `robots.txt` esclude `/app/`.
- **Risorse di radice — proprietà che migra:** `robots.txt`, `sitemap.xml` e il JSON-LD di sito (`Pharmacy`) valgono solo alla **radice del dominio**. Finché la PWA Flutter è servita a `/`, li ospita lo shell (`app/web/` — fondamenta già presenti, ADR 0001); **alla messa in linea dello storefront la proprietà passa allo storefront** e le rewrite di hosting devono continuare a servirli dalla radice (la PWA si sposta sotto `/app/` e non li porta con sé).
- **Scelta implementativa — decisa (ADR 0001, `docs/adr/`):** opzione **(a) Next.js/Astro su Firebase Hosting + Cloud Functions/Cloud Run** — integrazione nativa, un solo fornitore. Scartate: (b) Vercel (fornitore in più, sessione Firebase su due host), (c) prerender dei bot (fragile, Core Web Vitals scarsi — ammesso solo come ponte). Il gate resta aperto finché l'Ispezione URL non è verde.
- **Oltre la ricerca organica:** con lo storefront in piedi, il feed prodotti può alimentare **Google Merchant Center (schede gratuite / Shopping)** — per una farmacia locale è spesso il canale con più resa; richiede JSON-LD `Product` corretto (prezzo, disponibilità, GTIN/EAN già nel modello dati §5.1).

> **Gate di validazione:** l'**Ispezione URL di Google Search Console** deve mostrare testo e link reali su schede e blog prima di investire in traffico. La proprietà Search Console e l'invio della sitemap fanno parte dello step 2.7, non del lancio.

### 6.3 Contenuti, E-E-A-T e YMYL
Contenuti sanitari = **YMYL**: vanno **firmati e revisionati dal farmacista** (autore con credenziali), con citazioni, data di revisione, trasparenza su azienda/contatti, HTTPS. L'AI supera l'E-E-A-T **solo** con revisione umana responsabile.

### 6.4 Hosting: perché non GitHub Pages
Le condizioni d'uso di GitHub **vietano** l'uso di GitHub Pages per gestire un'attività commerciale o un sito e-commerce; è inoltre **solo statico** (niente SSR), con limiti di spazio/banda. → **Firebase Hosting** (integrazione nativa col backend) **o Vercel/Netlify** (SSR/prerendering). Entrambi con SSL e dominio personalizzato.

---

## 7. User Experience (UX), Design System e Flusso di Navigazione

### 7.1 Pubblico e principio guida
Pubblico tendenzialmente **maturo** → **accessibilità = conversione**: caratteri grandi, navigazione semplice, alto contrasto, aree tattili ampie. Riferimento **WCAG 2.2** (testo 4,5:1; componenti UI 3:1).

### 7.2 Linguaggio visivo — moderno, pulito, effetti misurati *(specifica di implementazione)*

**Direzione confermata:** UI **molto pulita** (poche informazioni per schermata) con un linguaggio 2026: **sfondi ambientali azzurro→bianco** (ispirazione apple.com), **glassmorphism** sulle superfici di navigazione, **card 3D** per i prodotti, **motion system** a molla. Gli effetti sono il condimento, non il piatto: al massimo **un elemento "wow" per viewport**.

#### 7.2.1 Pulizia prima di tutto (regole di densità)
- **Una sola azione primaria per schermata** (CTA verde); le secondarie sono testuali/outline.
- **Progressive disclosure:** la card mostra solo foto, nome, prezzo, "+"; tutto il resto (posologia, avvertenze, dettagli) vive nella scheda. Niente badge, etichette o contatori che non siano azionabili o essenziali.
- **Massimo 2 livelli tipografici per vista** (titolo + corpo) oltre a prezzo/CTA; spazio bianco generoso (spaziatura base 8 px, sezioni separate da 32–48 px, mai da linee/box).
- Se una schermata ha bisogno di una spiegazione, si toglie contenuto — non si aggiunge testo.

#### 7.2.2 Sfondo ambientale azzurro→bianco (ispirazione Apple)
- **Token:** `ambientAzure` `#EAF4FE` (azzurro ghiaccio) che sfuma **verticalmente** in `#FFFFFF` (stop ~55–70% dell'altezza); variante appena più satura `#DDEEFC` per l'hero della Home.
- **Dove:** hero della Home, testata delle sezioni (Negozio, Servizi), sfondo della parte alta della scheda prodotto, empty state. **Non invadente per costruzione:** il gradiente sta **dietro** i contenuti, il testo lungo poggia sempre sulla zona bianca o su superficie solida.
- **Cosa NON è:** l'azzurro non è un colore d'azione né di testo — il **verde `#1E7A3C` resta l'unico colore interattivo** (un secondo colore cliccabile confonderebbe). L'azzurro freddo fa anche da contrappunto neutro che valorizza oro/verde/cremisi del logo (§16.2) senza competere.
- Contrasto: su `#EAF4FE` il testo scuro `#14532D`/`#1F2A24` supera comodamente 4,5:1 — verificare comunque nella style page.

#### 7.2.3 Glassmorphism (dove sì, dove mai)
- **Superfici ammesse (chrome di navigazione e overlay):** app bar/bottom bar sticky durante lo scroll, `NavigationRail` desktop, pannello chat AI 70/30 (header), bottom-sheet filtri, dialog.
- **Spec:** blur `σ 20–24` (`BackdropFilter` / `backdrop-filter` CSS), riempimento bianco **70–75%** di opacità, bordo 1 px bianco 45%, raggio **20–24 px**, ombra morbida a bassa opacità. Il testo sopra il vetro deve mantenere **≥ 4,5:1 rispetto al caso peggiore** di ciò che può scorrervi sotto.
- **Vietato dietro contenuti critici:** posologia, controindicazioni, prezzo, totali del checkout, logo ministeriale — sempre su superficie **solida**.
- **Fallback solido obbligatorio:** su dispositivi a basse prestazioni (o dove il blur costa troppo) la stessa superficie rende bianco pieno 96% senza blur — il layout non cambia.

#### 7.2.4 Card prodotto 3D
Costruzione **a livelli**, non finto rilievo (il neumorphism resta vietato sui controlli):
- **Livelli:** superficie card bianca (raggio 20–24) → **foto scontornata "sollevata"** che sborda leggermente dal bordo superiore, con **ombra propria** sotto il prodotto → testo e prezzo in basso, CTA "+" verde.
- **Profondità:** ombra a **due strati** — ambientale (`y 2, blur 8, nero 5%`) + direzionale (`y 12, blur 24, nero 8%` con **tinta verde 10%**: le ombre colorate sono ciò che rende "moderna" la profondità).
- **Desktop (hover):** tilt prospettico **max 6°** che segue il puntatore (`Matrix4` con `perspective 0.0015`), la foto trasla di 2–4 px in senso opposto (parallasse interna), **sheen** radiale bianco ~8% che segue il cursore; rientro a molla al leave.
- **Touch (mobile):** niente tilt — **press: scale 0.97** + ombra compressa (spring, ~180 ms), rilascio con overshoot leggero.
- **Entrata in lista:** fade + slide-up 24 px, **stagger 40 ms** tra card, solo al primo build (non a ogni scroll).

#### 7.2.5 Motion system (tendenza 2026: fisica, non easing lineari)
- **Curve:** spring/`Curves.easeOutBack` leggero per gli elementi che "arrivano"; `emphasized` Material 3 per i cambi di layout. **Durate:** micro-interazioni 150–200 ms · standard 250–300 ms · transizioni di pagina/layout 400–500 ms. Mai animazioni in loop.
- **Hero transition** card → scheda prodotto: l'immagine del prodotto è l'elemento condiviso (`Hero` + `CustomTransitionPage` su go_router); il resto della scheda entra in fade+slide.
- **Skeleton shimmer** al caricamento (card fantasma con shimmer diagonale), **mai spinner a pagina intera**.
- **Micro-interazioni:** "+" che spara un pallino verso il carrello + badge che rimbalza; toggle e chip con transizione di colore 150 ms; pull-to-refresh brandizzato (anello oro che si disegna, richiamo dello splash §16.3).
- **Storefront SSR (§6):** stessi principi via CSS — reveal delle sezioni allo scroll (`IntersectionObserver` / scroll-driven animations come progressive enhancement), parallasse **leggero** solo sull'hero. Gli effetti non devono costare Core Web Vitals: niente blur full-page, immagini `loading="lazy"`.
- **`prefers-reduced-motion`:** ovunque (app e storefront) — transizioni istantanee, shimmer sostituito da placeholder statico (già obbligatorio per la chat, §12.6).

#### 7.2.6 Implementazione Flutter (riferimento per lo sviluppo)
| Cosa | Come | Note |
|---|---|---|
| **Token effetti** | `ThemeExtension` `BaganzaEffects` in `core/theme`: gradienti ambientali, spec glass (blur/fill/bordo), ombre a 2 strati, durate e curve | Un'unica fonte; le feature non hardcodano valori |
| **Vetro** | Widget riusabile `GlassSurface` (`ClipRRect` + `BackdropFilter`) con flag `solidFallback` | Max **2 `BackdropFilter` per schermata**; `RepaintBoundary` intorno |
| **Card 3D** | Widget `TiltCard`: `MouseRegion` + `AnimatedBuilder` + `Transform(Matrix4)`; tilt disattivo su touch | Il tilt è solo percettivo: hit-area e semantica invariate |
| **Motion** | `flutter_animate` (fade/slide/scale/shimmer/stagger, `animate().shimmer()` per gli skeleton) + `Hero`; splash animato con Rive (§16.3) | Rispettare `MediaQuery.disableAnimations` |
| **Transizioni rotta** | `CustomTransitionPage` su go_router (fade-through di default, hero per il prodotto) | Coerenti tra web e desktop |
| **Performance** | Test raster su fascia bassa e web CanvasKit (DevTools → raster stats); gli effetti si degradano, non si portano il frame-rate sotto i 60 fps | Il fallback solido/statico è parte della spec, non un ripiego |
| **Storefront SSR** | Gli stessi token esportati come **CSS custom properties** (file JSON di design token condiviso in `core/theme/tokens.json`) | Un solo vocabolario visivo su Flutter e HTML |

**Cosa resta vietato:** neumorphism sui controlli; testo oro su bianco (§16.2); glass dietro contenuti critici; più effetti sovrapposti nello stesso viewport; qualunque animazione che ritardi un'azione dell'utente.

### 7.3 Bottom Navigation Bar (mobile)
5 sezioni sempre visibili: **Home** · **Negozio** (catalogo, filtri, ricerca) · **Chat AI** (assistente, §12.6 — voce centrale evidenziata) · **Carrello** (badge) · **Profilo** (switch Cliente/Admin).
> "Servizi" non è una tab: è la **card hero della Home** (alternativa già prevista in §16.7), per non superare le 5 voci raccomandate da Material. Su **web desktop** la chat non è una tab ma un **widget flottante + pannello 70/30** (specifica completa in §12.6).

### 7.4 Schermate principali e flusso
```
Splash → Home
Home ├─ Negozio → (ricerca | scanner barcode | filtri) → Dettaglio prodotto → Aggiungi al carrello
     ├─ Offerte / Più richiesti → Dettaglio prodotto
     ├─ Chat AI (widget web / tab mobile) → consenso → conversazione → card prodotti → Dettaglio/Carrello
     │                                                              └─ escalation → Farmacista (chat/WhatsApp)
     └─ Consulenza → Prenota slot → Chat/Video

Carrello → Checkout → Pagamento → Conferma ordine

Profilo
 ├─ (se non loggato) Login / Registrazione
 ├─ (Cliente) Ordini · Indirizzi · Consensi · Abbonamenti · Consulenze
 └─ (Admin)  Dashboard → Aggiungi prodotto (foto+descrizione)
                        → [AI genera scheda + immagine]
                        → Anteprima/Validazione → Pubblica
                        → Gestione ordini · Gestione consulenze
```

### 7.5 Segnali di fiducia
Logo ministeriale + link di verifica, credenziali/foto del farmacista, recensioni, prezzo e spedizione mostrati presto, badge di pagamento sicuro, informazioni chiare su reso e recesso.

---

## 8. Internazionalizzazione (i18n) — Italiano & Inglese

- **Stringhe UI:** esternalizzate in file **ARB** (`app_it.arb`, `app_en.arb`) con `flutter_localizations` + `intl`; **nessuna stringa hardcoded** nelle schermate principali.
- **Contenuti di catalogo/blog:** **bilingui nel dato** (mappe `{it,en}`, vedi §5). La pipeline AI genera entrambe le lingue; la validazione del farmacista copre **entrambe**.
- **Selezione lingua:** automatica dal dispositivo, con override manuale salvato in `users.locale`.
- **SEO multilingua:** URL distinti per lingua + `hreflang` (vedi §6.2).
- **Formattazione:** numeri, valuta (EUR) e date localizzate; default IT.

---

## 9. Funzionamento Offline e Casi Limite

### 9.1 Offline (ambito confermato: solo consultazione catalogo)
- **Disponibile offline:** sfogliare il **catalogo già scaricato** (prodotti pubblicati e relative immagini) tramite **persistenza offline di Firestore** + cache immagini; ricerca limitata ai dati in cache.
- **Richiede connessione (bloccato con messaggio chiaro se offline):** login/registrazione, carrello e checkout, pagamenti, prenotazione consulenze, **chat con l'assistente AI** (§12), area amministrativa e pipeline AI.
- **Comportamento:** banner non invasivo "Sei offline: puoi sfogliare il catalogo, ma per acquistare serve la connessione". Nessuna coda di transazioni offline (fuori scope).

### 9.2 Casi limite
| Situazione | Comportamento atteso |
|---|---|
| **Assenza di connessione** | Catalogo navigabile da cache; azioni transazionali disabilitate con messaggio. |
| **Dato mancante sul prodotto** | Immagine assente → placeholder. Un **medicinale senza posologia/controindicazioni non è pubblicabile** (regola di validazione). |
| **Utente non autorizzato** | Un cliente non accede alle rotte admin (route guard) né può scrivere/pubblicare (security rules). Un admin non verificato non pubblica. |
| **Pagamento fallito** | Ordine in `paymentStatus: failed`; **stock non scalato**; invito a riprovare/cambiare metodo. |
| **Prodotto esaurito al checkout** | Blocco con messaggio; suggerimento di alternative o avviso "avvisami quando disponibile". |
| **Errore/timeout della pipeline AI** | Il prodotto resta in `draft` con stato errore; l'admin può **riprovare** o **compilare manualmente**. Nessuna pubblicazione automatica. |
| **Separazione medicinali / non-medicinali** | Nessuna pagina che mescola medicinali e non-medicinali; il **logo** appare solo sulle pagine dei medicinali (vedi Parte 2, compliance). |
| **Revoca del consenso** | L'utente può revocare i consensi dal profilo; il trattamento per finalità marketing cessa di conseguenza. |
| **Sessione scaduta** | Reindirizzamento al login mantenendo il contesto (es. carrello). |

---

## 10. La prima "Killer Feature": Flusso Admin AI-Driven *(la seconda, lato cliente, è nel §12)*

Il frontend raccoglie i dati grezzi; **tutta la logica di IA avviene nel backend (Cloud Functions)** per sicurezza e tutela legale.

### Pipeline di inserimento
1. **Input Admin:** dal Profilo, "Aggiungi Prodotto".
2. **Raccolta dati rapida:** foto grezza; descrizione minima (es. *"Oki task bustine mal di testa"*); prezzo iniziale; prezzo scontato.
3. **Upload & Trigger:** immagine in Cloud Storage + documento Firestore in stato **`draft`** → attiva una Cloud Function.
4. **Elaborazione AI (backend):**
   - *Vision:* ridimensionamento, rimozione sfondo, sfondo bianco puro, conversione **WebP**.
   - *Testi:* l'LLM genera titolo SEO, descrizione commerciale, principio attivo, posologia, controindicazioni **in IT ed EN**.
5. **Validazione umana (obbligatoria):** notifica all'admin; il farmacista rilegge soprattutto **posologia e controindicazioni** (in entrambe le lingue) e clicca **"Pubblica"**. Solo allora `status: published`.

### Guardrail anti-rischio
- chiavi API **solo lato server**; **validazione/escape** anti *prompt injection*; **grounding** su fonti validate (foglietto illustrativo/RCP) con citazione; **revisione umana obbligatoria**; **log di provenienza** (chi genera/approva); disclaimer visibili.

> Principio cardine: **l'IA è un assistente di redazione, mai l'editore.** Farmacista e titolare restano legalmente responsabili.

---

## 11. Valutazione: eliminare il backend con API Key lato client (modello "BYOK")?

**La proposta.** Rimuovere il backend, far inserire all'utente la **propria API Key**, salvarla su Firebase e far comunicare l'app **direttamente** con il servizio di IA.

**Premessa.** A usare l'IA è l'**amministratore**, non il cliente. La domanda reale: conviene che sia l'app a chiamare l'IA con una chiave su Firebase, invece di una Cloud Function?

### 11.1 Pro
| Pro | Note |
|---|---|
| Meno componenti da costruire | MVP più rapido. |
| Costi infrastrutturali apparentemente nulli | Marginale (vedi §11.4). |
| Modello a consumo dell'utente | Vantaggio quasi nullo: farmacia singola. |
| Architettura concettualmente semplice | Un layer in meno. |

### 11.2 Contro (seri)
1. **Sicurezza della chiave (principale):** una chiave usata dal **client** è **estraibile** (DevTools/bundle nel web; reverse engineering nelle app native). "Salvarla su Firebase" **non protegge**: per usarla il client deve **leggerla** e inviarla → in chiaro su dispositivo e in transito. Chiave rubata = consumo a tuo carico.
2. **Firestore non è un secret manager:** i segreti vanno in **Secret Manager / variabili d'ambiente**, letti **solo dal server**.
3. **CORS:** molte API LLM (**OpenAI inclusa**) **non sono pensate per il browser** e sconsigliano l'uso lato client; nel web la chiamata diretta spesso **non parte** senza proxy.
4. **Perdita del controllo legale/qualità (più grave per una farmacia):** si perde il **punto unico** dove applicare grounding, filtri, logging e il gate `draft → validazione → pubblicazione`.
5. **Prompt/know-how esposti** nel client.
6. **Nessun controllo centralizzato** (rate limiting, quote, retry, caching, fallback, costi).
7. **Aggiornamenti legati ai rilasci** dell'app.
8. **Vision processing** pesante e con chiave Photoroom esposta.

### 11.3 Quando il BYOK ha senso
App **desktop/locali** per utenti tecnici consapevoli; **prototipi interni** non pubblici. Non è il caso di un e-commerce farmaceutico pubblico.

### 11.4 Verdetto: **non consigliabile**
Qui il backend è **necessità di sicurezza e compliance**, non un costo evitabile. "Eliminarlo" **non fa risparmiare quasi nulla** (Cloud Functions è serverless con piano gratuito generoso) ma introduce **furto chiave**, possibile **blocco CORS** nel web e **perdita del controllo legale** sui testi sanitari.

### 11.5 Alternativa consigliata (semplice ma sicura)
- **Backend "thin" come proxy:** una singola Cloud Function verso LLM/Photoroom, chiave in **Secret Manager**, protetta da **App Check**. Pochissimo codice.
- **Firebase AI Logic (Vertex AI in Firebase):** chiama modelli generativi dalle app **senza esporre chiavi**, mediando con App Check; copre **Gemini/Imagen** (per **GPT-4o** serve comunque il proxy).
- **Estensioni Firebase** pronte, chiave lato server.
- Se vuoi davvero "BYOK", fallo sicuro: l'admin incolla la chiave **una volta**, viene **cifrata** e usata **solo dal server** — il client non la legge mai ("key-in-server", non "key-in-client").

> Sintesi: salvare la chiave su Firebase è ragionevole **solo** se a leggerla è una Cloud Function, non l'app.

---

## 12. Assistente AI per il Cliente («Chat AI» — seconda killer feature)

Una chat conversazionale, disponibile su web e mobile, in cui il cliente descrive un **disturbo lieve o un bisogno** ("mi fa male la testa", "ho la pelle secca", "cosa prendo per il raffreddore?") e riceve una **lista di prodotti adatti presi esclusivamente dal catalogo pubblicato** (SOP/OTC, parafarmaci, integratori, cosmetici), con link diretto a scheda e carrello. È il complemento lato cliente della pipeline admin del §10.

### 12.1 Perimetro: cosa fa e cosa NON fa (decisione di design, non solo legale)
| ✅ Fa | ❌ Non fa |
|---|---|
| Ascolta il bisogno espresso e propone **prodotti da banco del catalogo**, come farebbe un commesso esperto | **Diagnosi**, valutazioni cliniche, interpretazione di referti/esami |
| Spiega **a partire dalla scheda prodotto validata** (indicazioni, avvertenze, "leggere il foglietto illustrativo") | Posologie diverse dalla scheda, interazioni farmacologiche personalizzate, consigli su farmaci **con ricetta** |
| Riconosce i **sintomi "red-flag"** e in quel caso **si ferma**: nessun prodotto, invito a contattare medico/112 o il farmacista | Rassicurare su sintomi seri, gestire emergenze, pediatria sotto soglia d'età senza rimando al medico |
| Offre **sempre** l'escalation a un umano ("Parla con il farmacista") | Sostituire il farmacista o presentarsi come "medico virtuale" |

> Questo perimetro non è solo prudenza legale (§12.5): mantiene il sistema nella categoria "**assistente all'acquisto**" (come una ricerca in linguaggio naturale sul catalogo) e fuori dalla categoria "**software con finalità medica**", che farebbe scattare MDR e obblighi da dispositivo medico.

### 12.2 Scelta del modello LLM open-source *(valutazione richiesta: OpenBioLLM vs DeepSeek — esito ricerca 2026)*

**Criterio chiave (contro-intuitivo ma decisivo):** in questo caso d'uso la conoscenza medica "parametrica" del modello conta **meno** della qualità dell'**italiano**, dell'**instruction following** e del **tool use/output strutturato** — perché la verità arriva dal **RAG sul catalogo validato dal farmacista** (§12.3), non dalla memoria del modello. Un modello biomedico che ragiona in inglese è la scelta sbagliata per una chat paziente in italiano.

| Modello (open) | Licenza | Italiano | Dominio medico | Verdetto per questo progetto |
|---|---|---|---|---|
| **Qwen 3** (8B→235B, ottimo 30B‑A3B/32B) | Apache 2.0 | ⭐⭐⭐ — risulta il **miglior open-source per l'italiano** nei benchmark 2025‑26 | Buono (generalista forte) | **Consigliato come primario**, servito da provider EU |
| **Mistral Small 3.x** (24B) | Apache 2.0 | ⭐⭐⭐ | Discreto | **Alternativa "EU-native"**: azienda europea, hosting EU nativo (La Plateforme) — il percorso GDPR più semplice |
| **DeepSeek V3.x / R1** | MIT/permissiva | ⭐⭐⭐ | **Ottimo** nei benchmark clinici (pari o sopra GPT‑4o nel clinical decision support, *Nature Medicine* 2025) | Valido **solo come pesi aperti su hosting EU/occidentale**. ⚠️ **Mai l'API ufficiale**: il Garante ha disposto la **limitazione definitiva** del trattamento per DeepSeek in Italia (provv. 33/2025, trasferimento dati in Cina) — inaccettabile per dati sanitari di utenti italiani |
| **MedGemma 27B** (Google, base Gemma 3) | Gemma (open) | ⭐⭐ (medicale addestrato in EN) | Specializzato, multimodale | Non primario (inglese-centrico, "not clinical-grade out of the box"); possibile **secondo stadio di verifica** opzionale post-MVP |
| **OpenBioLLM 8B/70B** (base Llama 3) | Llama 3 Community | ⭐ — di fatto **solo inglese** | Specializzato (QA biomedico EN) | **Scartato come primario**: niente italiano, base datata (apr 2024), sotto i generalisti nei task lunghi, nessuna validazione clinica reale. Il suo vantaggio (conoscenza biomedica EN) qui non serve: la conoscenza arriva dal catalogo |

**Decisione proposta:**
1. **Primario: Qwen 3 32B** (o 30B‑A3B per costi minori) **oppure Mistral Small 3.x**, servito tramite **provider di inference con data residency EU** (es. Scaleway Generative APIs, OVHcloud AI Endpoints, Mistral La Plateforme; in subordine provider US con region EU). Costi indicativi 2026: **€0,1–0,8 per milione di token** → per una farmacia (migliaia di chat/mese) è una voce di costo **trascurabile** (pochi €/mese).
2. **Alternativa frontier: DeepSeek V3.x open-weights su hosting EU** (Together/Fireworks/DeepInfra con endpoint EU o provider europei che lo servono) se il golden set (v. sotto) mostra un gap di qualità clinica.
3. **Architettura model-agnostic:** il backend parla il **formato OpenAI-compatibile** (tutti i provider citati lo espongono); `baseUrl` + `model` stanno in **config/Secret Manager** → cambiare modello = cambiare una config, zero refactoring. Nessun lock-in.
4. **Selezione empirica, non di catalogo:** prima della scelta definitiva, un **golden set di 50–100 conversazioni in italiano** scritte dal farmacista (sintomi lievi, red-flag, richieste ambigue, tentativi di jailbreak) valuta i 2–3 candidati su: correttezza del rifiuto sui red-flag, aderenza al catalogo (zero prodotti inventati), qualità dell'italiano, latenza e costo. La decisione va registrata (ADR).

> **Perché non self-hosting GPU?** Una VM GPU dedicata costa centinaia di €/mese e va gestita; l'inference serverless a consumo su cloud EU dà lo stesso modello open-weights con GDPR a posto e costi di due ordini di grandezza inferiori a questi volumi. Il self-hosting resta un'opzione futura proprio perché i pesi sono aperti.

### 12.3 Architettura RAG: la chat è ancorata al catalogo

```
[ Widget/Tab Chat (client) ]
   │ 1. consenso art. 9 verificato (§12.5) — poi messaggio utente
   ▼
[ Cloud Function `assistantChat` (App Check · rate-limit per uid/IP · streaming SSE) ]
   ├─ 2. Moderazione input (Llama Guard 3 / filtri provider — supporta l'italiano)
   ├─ 3. Triage red-flag (lista curata dal farmacista: dolore toracico, dispnea,
   │      sanguinamento, gravidanza/allattamento, età pediatrica, febbre alta persistente…)
   │      → se red-flag: STOP prodotti, messaggio di rinvio a medico/112/farmacista
   ├─ 4. Retrieval: embedding della richiesta → top-k prodotti dal catalogo
   │      (filtri rigidi: status==published · available==true · assistantEligible==true)
   ├─ 5. LLM (EU-hosted) con prompt vincolato: "proponi SOLO tra i prodotti forniti,
   │      cita indicazioni/avvertenze dalla scheda, max 3–5 prodotti, tono empatico,
   │      lingua dell'utente (IT/EN), chiudi sempre con disclaimer + opzione farmacista"
   ├─ 6. Validazione output: JSON strutturato {messaggio, prodotti[], escalation} —
   │      gli ID prodotto vengono verificati contro il catalogo (zero allucinazioni),
   │      moderazione output
   └─ 7. Log su `chatSessions` (provenienza modello/prompt) → risposta al client
```

- **Indice vettoriale:** embedding **multilingue** open (es. `bge-m3` o `multilingual-e5`) generato **alla pubblicazione** del prodotto (trigger già esistente in `catalog/`); ricerca con **Firestore Vector Search** (nativo, zero componenti nuovi) **oppure Typesense ibrido** se Typesense è già stato scelto per la fuzzy search (§13.1) — un solo motore per entrambe. La scelta si fa nello spike (Per step, Fase 4B).
- **Perché le card prodotto sono "vere":** il client riceve **riferimenti** (`productRef`) verificati, non testo libero — la UI renderizza le card dal dato Firestore reale (prezzo, foto, stato stock aggiornati).
- **Fallback:** provider LLM giù o timeout → messaggio cortese + scorciatoie ("Cerca nel catalogo", "Scrivi al farmacista su WhatsApp"). La chat **degrada, non blocca** il resto dell'app.
- **Costi sotto controllo:** limite di messaggi per sessione e per utente/giorno, contesto troncato alle ultime N battute + riassunto, cache dei suggerimenti per le richieste più frequenti.

### 12.4 Guardrail clinici e supervisione del farmacista
- **Doppio filtro AI** (input e output) + **lista red-flag deterministica** (regex/classificatore leggero) che scatta **prima** dell'LLM: sui casi seri non si lascia decidere al modello.
- **Prompt "a gabbia":** il modello non può proporre prodotti fuori lista, non può indicare dosaggi diversi dalla scheda, non può nominare farmaci Rx; le risposte citano il campo scheda da cui provengono (grounding §10).
- **Trasparenza:** header della chat con badge "Assistente AI" + disclaimer fisso ("Non sono un medico né un farmacista. Per casi seri rivolgiti al 112 o al tuo medico"); primo messaggio di benvenuto che lo ripete.
- **Escalation sempre a un tap:** pulsante "Parla con il farmacista" in ogni risposta → apre consulenza (§13.3) o WhatsApp della sede; le sessioni `escalated` finiscono nella inbox admin.
- **Supervisione (human oversight):** dashboard admin con **registro conversazioni** (pseudonimizzate), filtro per `redFlagTriggered`/`flaggedForReview`, pulsante "risposta scorretta" che alimenta la revisione di prompt e lista red-flag. Il farmacista **mantiene** la lista red-flag e può **escludere prodotti** dai suggerimenti (`assistantEligible`).
- **Red-team pre-lancio:** batteria di test su casi pericolosi (emergenze, pediatria, gravidanza, autolesionismo, richieste di Rx, prompt injection "ignora le istruzioni") — **gate di lancio**, come la SEO per il §6.

### 12.5 Compliance specifica della chat *(da validare con il legale prima del lancio)*
- **GDPR art. 9 (dato sanitario):** i sintomi digitati sono **categorie particolari di dati** → **consenso esplicito** prima del primo messaggio (nuovo consenso `aiAssistant` su `users.consents`, o consenso di sessione per i guest), **finalità limitata** (niente marketing/profilazione sui contenuti chat), **retention breve** (es. 90 giorni, campo `purgeAt` + job di purge), pseudonimizzazione nel registro admin, **DPIA** documentata. **Tutta l'elaborazione resta in EU** (inference EU — motivo per cui l'API ufficiale DeepSeek è esclusa, §12.2).
- **AI Act:** obbligo di **trasparenza** (l'utente sa di parlare con un'AI — badge e benvenuto, art. 50). Mantenendo il perimetro §12.1 (orientamento all'acquisto + rinvio al professionista, nessuna finalità diagnostica/terapeutica) il sistema **non** è progettato come dispositivo medico; se il perimetro si allargasse (triage, diagnosi, consigli clinici personalizzati) scatterebbero **MDR (SaMD, verosimilmente classe IIa)** e la qualifica **high-risk** dell'AI Act — da evitare esplicitamente in v1.
- **Coerenza col §11:** chiavi e logica **solo lato server** (proxy Cloud Function, Secret Manager, App Check); vale l'intero verdetto anti-BYOK.

### 12.6 UI/UX della chat *(specifica confermata)*

**Web desktop (breakpoint ≥ 1024 px) — pagine Home e Catalogo:**
- **Widget flottante in basso al centro**: pill arrotondata con icona assistente e testo invitante — IT: *"Sono il tuo assistente AI: dimmi cosa ti fa male o cosa cerchi"* / EN: *"I'm your AI assistant: tell me what hurts or what you're looking for"* (stringhe in ARB, §8). Stile: fondo bianco, bordo/icona **verde azione** `#1E7A3C`, ombra leggera; **non copre** contenuti critici né i pulsanti di acquisto; resta visibile allo scroll.
- **Apertura:** al click (o appena l'utente inizia a digitare nel campo del widget) parte un'**animazione di 250–300 ms (ease-in-out)**: il contenuto della pagina si **restringe al 70%** della larghezza ancorandosi **a sinistra**, e nel **30% a destra** (larghezza minima 360 px) si apre il **pannello chat** a tutta altezza: header (nome assistente + badge "AI" + ✕), cronologia messaggi, **disclaimer fisso**, card prodotto suggerite (tap → scheda/carrello), input in basso con invio.
- **Chiusura:** ✕ o tasto **ESC** → animazione inversa al 100%; la conversazione **resta viva** nella sessione (il widget mostra un badge "1" se ci sono risposte non lette).
- **Qualità/accessibilità:** il contenuto al 70% deve **restare usabile** (griglie responsive che ricalcolano le colonne, niente scroll orizzontale); `prefers-reduced-motion` → transizione istantanea senza animazione; **focus trap** nel pannello, `aria-live="polite"` sui messaggi, contrasto testo ≥ 4,5:1 (§7.2).
- **Nota di architettura (conseguenza del §6):** Home e Catalogo web pubblici sono **SSR/prerender**, non Flutter → il widget va costruito come **componente web leggero** (JS/TS, pochi KB) incluso nelle pagine SSR, che parla con lo **stesso endpoint** `assistantChat`; dentro la PWA/app Flutter la stessa esperienza è resa nativamente (Row 70/30 con `AnimatedContainer`). **Un solo backend e un solo "contratto" di conversazione, due superfici di UI.**

**Mobile (app iOS/Android e web < 1024 px):**
- **Nessun widget flottante.** La chat è una **voce della BottomNavigationBar**: **Home · Negozio · Chat AI · Carrello · Profilo** (§7.3; "Servizi" diventa card hero della Home come da alternativa §16.7). Icona assistente, posizione **centrale** evidenziata.
- La tab apre la chat **a schermo intero**: stesso componente conversazione (header con badge AI, disclaimer, card prodotto, input) + **chip di avvio rapido** ("Mal di testa", "Raffreddore", "Consiglio pelle", "Parla col farmacista").
- **Primo utilizzo:** una schermata di onboarding (cosa fa/cosa non fa l'assistente) con **consenso esplicito** (§12.5) prima del primo messaggio; il consenso non viene richiesto di nuovo.

### 12.7 Altre funzionalità AI (post-MVP)
- **Raccomandazioni di prodotto** (su dati commerciali, non sanitari).
- **FAQ operative nella stessa chat** (stato ordine, resi, orari sedi) — estensione naturale dell'assistente.
- **Previsione della domanda** per il riassortimento.
- **Secondo stadio di verifica medica** (es. MedGemma come "revisore" delle risposte) se l'audit del farmacista ne mostra il bisogno.

Tutte seguono il principio del §11: **logica e chiavi lato server**, contenuti sensibili sotto controllo umano.

---

## 13. Funzionalità di Prodotto

### 13.1 Ricerca intelligente & barcode scanner
- **Fuzzy search** con tolleranza ai refusi: per l'MVP è **client-side** (`core/utils/fuzzy.dart` — decisione registrata in **ADR 0002**, `docs/adr/`); la migrazione a **Typesense** (fuzzy + vettoriale per la chat §12.3, sync via Cloud Function) scatta quando il catalogo cresce oltre il "piccolo/medio" o allo step 4B.2 — a contratto app invariato.
- **Nota per lo storefront SSR (§6):** la fuzzy client-side vive nella PWA; se lo storefront pubblico avrà una propria ricerca, userà query Firestore semplici (prefisso/categoria) finché non arriva Typesense, che a quel punto serve entrambe le superfici.
- **Scansione del codice a barre** (fotocamera, solo mobile — su desktop/Windows fallback a inserimento EAN manuale, §4.4) per trovare e **riordinare** in un tap.

### 13.2 Abbonamenti e riacquisto (funzione)
Opzione **"Acquisto Ricorrente"** (integratori, cosmetici, OTC a uso cronico) con sconto. *(Strategia di retention nella Parte 2.)*

### 13.3 Consulenza come servizio (funzione)
Chat e **video-consulenza** con farmacista e cosmetologo, con **prenotazione a slot**. *(Valore competitivo e operatività nella Parte 2.)*

### 13.4 Capacità PWA
**Service worker** per cache catalogo e scanner; **HTTPS**, installabilità, primo caricamento rapido (code splitting / componenti differiti).

---

## 14. Scope e Fuori-Scope (MVP)

### 14.1 In scope (versione 1)
Catalogo bilingue con ricerca e scanner; dettaglio prodotto; carrello e checkout con pagamento (PayPal + carte + Satispay); account cliente (auth, indirizzi, ordini, consensi); **pannello admin AI con validazione e pubblicazione**; **assistente AI cliente (§12)**: chat sintomi lievi→prodotti dal catalogo con guardrail, consenso art. 9, escalation al farmacista, **widget web 70/30 + tab mobile** e registro conversazioni lato admin; consultazione catalogo **offline**; SEO in SSR/prerender per catalogo e blog; compliance di base (logo, separazione medicinali/non-medicinali, consenso dati medicinali, pulsante recesso). **Personalizzazione Baganza (§16):** brand e **logo rifinito con splash animato**, **modulo Servizi + Prenotazioni** (autoanalisi, telemedicina, consulenze), **selettore di sede** (3 farmacie) e **deep-link ai sistemi regionali** (CUPWeb/ER Salute) per CUP e referti.

### 14.2 Fuori scope (per ora)
Farmaci con prescrizione; **marketplace multi-farmacia**; **video-consulenza** avanzata (può seguire dopo la chat); **abbonamenti** e **loyalty** avanzati (fase successiva); raccomandazioni AI proattive e **qualunque "check sintomi" con finalità diagnostica/triage clinico** (l'assistente §12 resta orientamento all'acquisto — il confine è vincolante, §12.1/§12.5); FAQ operative in chat (stato ordine/resi, §12.7); coda transazioni offline; distribuzione su store desktop. *(Allineato alla roadmap della Parte 2.)*

---

## 15. Criteri di Accettazione (Definition of Done)

**Funzionali**
- Il cliente può **trovare** un prodotto (ricerca + barcode), **vederne la scheda bilingue**, **aggiungerlo al carrello**, **pagare** (ambiente sandbox) e **ricevere conferma** ordine.
- **Offline**, il catalogo già scaricato è navigabile; le azioni transazionali sono bloccate con messaggio chiaro.
- L'admin può creare un prodotto da **foto + descrizione**, il backend genera **immagine WebP + testi IT/EN**, e il prodotto diventa visibile **solo dopo** il clic "Pubblica" del farmacista.
- Un utente **non autorizzato** non raggiunge l'area admin e non può pubblicare.

**Assistente AI cliente (§12)**
- A un sintomo lieve ("mal di testa") la chat risponde in italiano con **massimo 3–5 prodotti, tutti esistenti nel catalogo pubblicato** (card reali con prezzo/foto); a un **red-flag** (es. "dolore al petto") **non propone prodotti** e rimanda a medico/112/farmacista.
- La chat **non parte senza consenso esplicito** (art. 9); il badge/disclaimer AI è sempre visibile; il pulsante "Parla con il farmacista" è presente in ogni risposta.
- **Web ≥1024 px:** su Home e Catalogo il widget flottante in basso al centro apre il pannello con l'animazione **70/30** (contenuto a sinistra, chat a destra), ESC/✕ la chiude, `prefers-reduced-motion` rispettato. **Mobile:** la chat è la **tab centrale** della bottom bar, a schermo intero.
- Il farmacista vede il **registro conversazioni** (pseudonimizzato) e la inbox delle **escalation**; la batteria di **red-team clinico** (emergenze, pediatria, Rx, prompt injection) passa prima del lancio.
- Il modello è **open-weights su inference EU**; nessuna chiamata a endpoint extra-UE per i messaggi chat (verificato dai log).

**Compliance**
- Logo ministeriale presente sulle pagine dei **medicinali**; **separazione** medicinali/non-medicinali rispettata; **consenso esplicito** per i dati d'ordine dei medicinali raccolto; **pulsante di recesso** presente.

**Tecnici / qualità**
- Le pagine SEO rendono **HTML reale** (Ispezione URL di Search Console superata).
- **Contrasto WCAG 2.2** rispettato sui flussi chiave.
- **Nessuna chiave API nel client** (verificato); **App Check** attivo; le **security rules** negano accessi incrociati tra utenti.
- **i18n:** tutte le stringhe UI esternalizzate; lo switch IT/EN funziona; nessuna stringa hardcoded sulle schermate principali.
- **Test** unitari/widget/integrazione superati; build funzionante per **Web + Android + iOS**.

---

## 16. Personalizzazione: Farmacia Baganza

Questa sezione adatta il progetto generico alla **Farmacia Baganza** e ne fa l'**evoluzione** dei suoi siti attuali. *(I dati su sedi, servizi e prezzi sono quelli pubblicati a giugno 2026 e vanno confermati con la farmacia — vedi §16.9.)*

### 16.1 Identità del cliente e consolidamento
- **Chi è:** "Baganza Farmacie", gruppo indipendente di Parma (Emilia-Romagna), titolare **Dr. Marco Barbieri**; payoff **"Non solo farmaci"**.
- **Tre sedi:**
  1. **Farmacia Baganza** — Via Baganza 11/E, 43125 Parma — tel. 0521 964022 — Lun–Sab 08:00–22:00.
  2. **Farmacia Baganza2** — Via Gramsci 1/E, 43126 Parma — tel. 0521 292905 — *hub dei servizi*.
  3. **Farmacia Baganza3** — Via Garibaldi 28, 43121 Parma — tel. 0521 233178.
- **Contatti:** info@farmaciabaganza.com · ordini@farmaciabaganza.com · WhatsApp 331 1532690 · Facebook `facebook.com/baganzafarmacia`.
- **Punto di partenza digitale:** un **sito vetrina** (`farmaciabaganza.it`, piattaforma Italiaonline/Duda: 3 pagine, nessun login/shop/prenotazione) e un **e-commerce separato** (`benesserefarmacia.it`, piattaforma "Migliorshop", che già propone OTC/SOP e parafarmaci). **L'app li unifica**: vetrina + servizi + shop in un'unica esperienza con account unico.

### 16.2 Logo ufficiale e palette
> **Aggiornamento:** il logo è stato **fornito dal cliente** (`Baganza_Logo_Ufficiale.png`) e **sostituisce** la precedente proposta. Lo stile è **classico/lusso**, non minimalista.

- **Descrizione del marchio:** **caduceo dorato** (asta con sfera apicale, due **ali** spiegate, due **serpenti verdi** intrecciati) con una grande **"S" cremisi** serif tridimensionale al centro e una **maschera barbuta dorata** alla base, racchiuso in un **anello d'oro**. Sotto, il wordmark **"BAGANZA / FARMACIE"** in oro con due trattini laterali. Fondo bianco.
- **Palette reale (oro · verde · cremisi):**

| Token | Valore (≈) | Uso |
|---|---|---|
| `brandGold` | `#C9A227` (chiaro `#E6C76A`, scuro `#8A6D1B`) | Identità: emblema, anello, wordmark, dettagli decorativi |
| `brandGreen` | `#1E7A3C` | **Colore d'azione primario** UI (CTA, link, stati attivi): buon contrasto su bianco |
| `brandGreenDark` | `#14532D` | **Testo** e intestazioni (contrasto elevato) |
| `brandCrimson` | `#9E1B32` | Accento prestigio (richiamo della "S"); **uso parco** |
| `background` | `#FFFFFF` | Sfondo principale |
| `ambientAzure` | `#EAF4FE` (hero `#DDEEFC`) → sfuma in `#FFFFFF` | **Gradiente ambientale** di sfondo (hero, testate di sezione, scheda prodotto — §7.2.2). Mai per testo, mai per elementi interattivi |
| `textPrimary` | `#14532D` / `#1F2A24` | Testo corpo |
| `alert` | rosso `#C62828` | **Solo** errori/urgenze (distinto dal cremisi del brand) |

> **Due note di accessibilità/usabilità importanti (palette ornata):**
> 1. **L'oro su bianco non è leggibile** (fallisce il contrasto WCAG): va usato **solo** per il logo e per grandi elementi decorativi, **mai** per testo di servizio o pulsanti. Per testo e azioni usare **verde scuro/verde** (`#14532D` / `#1E7A3C`).
> 2. **Il cremisi del brand può confondersi con un colore di "errore".** Tenerlo come accento raro e usare un rosso **diverso e dedicato** (`#C62828`) per gli stati di errore, così l'utente non scambia un elemento di marca per un avviso.
> In pratica: **logo sfarzoso così com'è**, ma **UI guidata dal verde** (azione) con testo scuro; oro e cremisi come accenti misurati.

- **Tipografia:** il wordmark usa un **serif maiuscolo** elegante; per i titoli si può richiamare un serif coordinato, mantenendo però un **sans-serif leggibile** per il testo dell'interfaccia. Da definire come token.
- **Asset da produrre dal logo:** **ricostruzione vettoriale** (SVG) per scalabilità e per l'animazione (§16.3); **app icon** e **favicon**/`maskable` PWA (192/512px) — per l'icona conviene una **versione semplificata** (es. solo caduceo entro l'anello, senza wordmark, perché a 48px il dettaglio di ali/serpenti/maschera diventa illeggibile); versioni mono e su fondo scuro.

> **Nota pratica (onesta):** il file fornito è un'immagine **raster generata con AI**, molto dettagliata. Per stamparlo, usarlo come icona app nitida e soprattutto **animarlo come vettoriale**, va **ricostruito in vettoriale** da un designer/illustratore (le immagini AI possono avere piccole imperfezioni e non scalano). *(Aside, non vincolante: il simbolo raffigurato è un **caduceo** — due serpenti + ali, storicamente legato a Hermes/commercio — mentre i simboli "medici" sono il bastone di Asclepio a un serpente o la coppa di Igea; molte farmacie usano questi ultimi. È una scelta di brand: procedo con il tuo logo così com'è, lo segnalo solo nel caso ti interessi.)*

### 16.3 Splash screen con animazione vettoriale
Architettura **a due stadi** per evitare il "doppio splash" e restare conformi alle regole degli store.

1. **Splash nativo (statico):** via **`flutter_native_splash`** — sfondo **bianco** (il logo è ricco e va isolato) con l'**emblema** statico al centro; configurare il blocco **Android 12+** (icona 1152×1152 entro cerchio da 768px), storyboard iOS e tema per il loader web. Rimuovere eventuali Activity di splash legacy; su Android 12+ disattivare il fade di sistema per evitare flicker.
2. **Reveal animato in-app:** un widget mostrato sul primo frame. **Durata ≤ 1,2–1,8 s, non in loop.** Coreografia adatta a questo logo (elegante, "prestigio", calma): l'**anello d'oro** si disegna (stroke 0→100%) → le **ali** si schiudono con leggero *fade + scale* → i **serpenti** appaiono lungo l'asta → la **"S" cremisi** entra in *scale + fade* → il **wordmark "BAGANZA"** sale in *fade* → micro-luccichio dorato (shimmer) di chiusura. Nessun contatore, nessun caricamento "finto".

> **Realtà tecnica (importante).** Il logo fornito è **raster**: per animarlo **come vettoriale** (Rive/Lottie) va prima **ricostruito in vettoriale** con gli elementi su layer separati (anello, ali, serpenti, asta, "S", maschera, wordmark). Due strade concrete:

| Strada | Come | Risultato |
|---|---|---|
| **A — Vettoriale completo (consigliata se c'è budget design)** | Un illustratore ridisegna il logo in SVG a layer → **Rive** (file `.riv`, 60fps, ricolorabile) o **Lottie** (After Effects + Bodymovin/LottieFiles) → animazione del reveal sopra descritto | Splash animato premium, scalabile e nitido su ogni schermo |
| **B — Raster "elegante" (rapida, low-cost)** | Si usa il PNG ad alta risoluzione e si anima con **`flutter_animate`**: *fade + scale* dell'emblema, comparsa del wordmark, leggero **shimmer** dorato; opzionale: ridisegnare in vettoriale **solo l'anello** per l'effetto "disegno" sopra il raster | Splash curato senza rifare tutto il logo in vettoriale |

**Indicazione:** se l'animazione di marca è una priorità, **Strada A con Rive**; per partire subito, **Strada B**. In entrambi i casi serve comunque la **ricostruzione vettoriale del solo emblema** per app icon/favicon nitidi (§16.2).

**Regola di performance:** lo splash **nasconde** il tempo di avvio, non lo allunga. L'hand-off alla Home avviene **appena pronti** init Firebase + primi dati; il drop-off utente cresce sensibilmente oltre i ~2 s.

### 16.4 Modulo "Servizi" e "Prenotazioni" (servizi principali, con priorità)
Selezione dei servizi a **maggiore richiesta** (priorità basata sui dati di settore Cittadinanzattiva-Federfarma 2024 e sull'offerta reale della farmacia). **Non tutti** i servizi del sito vengono portati in app: si parte dai principali.

**Priorità 1 (hero dell'app):**
- **Prenotazioni CUP & ritiro referti (info + deep-link):** l'app **non** sostituisce il CUP (vedi §16.6) ma guida l'utente, mostra orari per sede e fa da deep-link a CUPWeb/ER Salute.
- **Autoanalisi del sangue** (es. glicemia €6, colesterolo €6): accesso libero + prenotazione slot.
- **Telemedicina** (alla sede Baganza2): **ECG con refertazione €35**, **Holter cardiaco 24/48/72h €75**, **Holter pressorio 24h €50**, **Dermatoscopia €55**, **MOC calcaneare €15** — su prenotazione.

**Priorità 2:**
- **Automisurazione pressione €1** e **Tampone Covid antigenico €15**.
- **Consulenze**: **dietologica** (gratuita), **psicologo in farmacia** (Baganza2, prima seduta gratuita poi €60), analisi pelle/cuoio capelluto, test udito, test vista — richiesta appuntamento.

**Priorità 3:**
- **Consegna a domicilio / click-&-collect** (ponte verso il catalogo prodotti) e **calendario eventi/campagne**; **fidelity/loyalty** (nuova) trattata nella Parte 2.

**Funzionamento del modulo:** ogni servizio ha scheda (descrizione, **prezzo**, sede/i, **istruzioni di preparazione** es. digiuno, modalità: accesso libero / appuntamento / link esterno). Le prenotazioni interne sono **richieste di slot** gestite dal personale (stessa logica delle consulenze, §13.3), per non sottrarre tempo al banco.

### 16.5 Modello dati aggiuntivo (estende il §5)
Nuove entità per multi-sede e servizi.

**`Location` (collezione `locations`)** — `id`, `name` ("Baganza", "Baganza2", "Baganza3"), `address`, `city`, `province`, `zip`, `phone`, `whatsapp`, `email`, `geo{lat,lng}`, `openingHours[]` (per giorno), `isCupPoint` (bool), `services[]` (ref), `order`.

**`Service` (collezione `services`)** — `id`, `slug{it,en}`, `name{it,en}`, `description{it,en}`, `category` (`autoanalisi|telemedicina|consulenza|tampone|cup|altro`), `price` (int cent, nullable se gratuito/su preventivo), `bookingType` (`free_access|appointment|external_link`), `externalUrl` (per CUPWeb/ER Salute), `availableAt[]` (ref `locations`), `prep{it,en}`, `durationMin`, `requiresFasting` (bool), `active`.

**`Appointment` (collezione `appointments`)** — `id`, `userRef`, `serviceRef`, `locationRef`, `slotStart`, `slotEnd`, `status` (`requested|confirmed|completed|cancelled|no_show`), `contactPhone`, `notes`, `createdAt`.

Esempio JSON — `services/{id}`:
```json
{
  "slug": { "it": "ecg-refertazione", "en": "ecg-with-report" },
  "name": { "it": "Elettrocardiogramma con refertazione", "en": "ECG with report" },
  "category": "telemedicina",
  "price": 3500,
  "bookingType": "appointment",
  "availableAt": ["locations/baganza2"],
  "prep": { "it": "Presentarsi a riposo; portare eventuali ECG precedenti.", "en": "Come rested; bring previous ECGs if any." },
  "durationMin": 20,
  "requiresFasting": false,
  "active": true
}
```

### 16.6 Integrazione con i sistemi sanitari regionali (Emilia-Romagna)
- **Cosa può fare l'app:** mostrare dove e quando si prenota tramite **FarmaCUP** nelle 3 sedi; **deep-link** a **CUPWeb** (`cupweb.it`) e all'app/servizio **ER Salute** e al **Fascicolo Sanitario Elettronico (FSE)** per prenotazioni, disdette, pagamento ticket, **referti** e **promemoria/codici dei farmaci** da ritirare in farmacia; aiutare l'utente a **preparare i documenti** (ricetta/NRE, tessera sanitaria, esenzione).
- **Cosa NON può fare:** **prenotare nativamente il CUP**. CUPWeb/ER Salute sono **sistemi statali con accesso SPID** e non espongono un'integrazione per app private. Niente promesse di prenotazione "dentro" l'app per le prestazioni SSN.

### 16.7 Navigazione aggiornata
Con l'introduzione della **Chat AI come tab mobile** (§12.6) le voci candidate diventano 6: per restare nel limite delle **5 voci** raccomandate, la bottom nav definitiva è **Home · Negozio · Chat AI · Carrello · Profilo**, e **"Servizi e Prenotazioni" diventa la card principale (hero) della Home** — l'alternativa già prevista in questa sezione, ora promossa a scelta. La Home mostra anche il **selettore di sede** (con orari e "apri in mappa"/chiama). Su **web desktop** la chat non occupa la navigazione: è il **widget flottante + pannello 70/30** (§12.6), mentre "Servizi" resta voce del menu orizzontale.
> Se dai dati d'uso emergesse che "Servizi" merita la tab più della chat, lo scambio è a basso costo: entrambe le destinazioni esistono comunque come route.

### 16.8 Compliance e accessibilità specifiche
- **Vendita online dei medicinali:** dato che `benesserefarmacia.it` propone già OTC/SOP, **verificare l'autorizzazione** del Ministero della Salute e la presenza del **logo identificativo nazionale** prima di abilitare la vendita SOP/OTC in app. Se l'autorizzazione non c'è (o finché non c'è), partire con **parafarmaci/cosmetici/integratori** (che non la richiedono) e aggiungere SOP/OTC dopo. *(Regole complete nella Parte 2.)*
- **European Accessibility Act (EAA):** l'azienda risulta avere ~13 dipendenti, quindi **l'accessibilità WCAG è verosimilmente obbligatoria** (non rientra nell'esenzione microimprese). Da trattare come requisito di legge, non opzionale (coerente con §7.2).

### 16.9 Da verificare con la farmacia (assunzioni aperte)
- **Logo:** ricevuto (`Baganza_Logo_Ufficiale.png`). Resta da produrre la **ricostruzione vettoriale** (per icona/favicon nitidi e per l'animazione, §16.2–16.3) e la **versione semplificata** per l'app icon.
- **Stato dell'autorizzazione** alla vendita online e display del logo ministeriale (§16.8).
- **Prezzi, orari e disponibilità** dei servizi per sede (qui come da sito, giugno 2026).
- **Font istituzionale** e eventuali colori secondari ufficiali (oltre al verde confermato).
- Quali servizi di **Priorità 2/3** includere già nella v1.
- **Chat AI (§12):** lista dei **sintomi red-flag** e golden set di prova da redigere **col farmacista**; canale preferito per l'escalation (consulenza in-app vs WhatsApp per sede); validazione legale del perimetro (§12.5) prima del lancio.

---

> **Continua nella Parte 2 di 2 — Documento business/operativo:** mercato e concorrenza, conversione (CRO), pagamenti, fidelizzazione e CRM, logistica e gestionale, compliance legale, modello di business, KPI, roadmap, considerazioni finali e fonti. *(La personalizzazione commerciale per Baganza — servizi come leva di posizionamento, multi-sede, loyalty — può essere riportata anche lì su richiesta.)*
