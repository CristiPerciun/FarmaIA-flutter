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

---

## 1. Executive Summary (tecnico)

La soluzione è una **PWA (Progressive Web App)** e un'app per iOS, Android e Windows, costruita con **Flutter** (codice unico multipiattaforma) e backend **Firebase**, per **Farmacia Baganza** (gruppo con 3 sedi a Parma) come **evoluzione** dei suoi attuali siti, operante in **Italia**, con e-commerce limitato a **SOP, OTC, parafarmaci, integratori, cosmetici e dispositivi medici** (no farmaci con obbligo di prescrizione).

Oltre all'e-commerce, l'app integra i **servizi in farmacia** (prenotazione di autoanalisi, telemedicina, consulenze, info CUP e ritiro referti) e la **scelta della sede**, che per questa farmacia sono il vero elemento differenziante — vedi **§16**.

L'elemento tecnico distintivo è un **pannello di amministrazione "AI-Driven"** che automatizza l'inserimento del catalogo: da una foto grezza e da una descrizione minima, il sistema genera immagine ottimizzata e scheda prodotto **bilingue (IT/EN)**. Per **sicurezza e tutela legale**, tutta la logica di IA risiede nel backend e ogni contenuto sanitario passa per la **validazione umana obbligatoria del farmacista** prima della pubblicazione.

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

**Amministratore / Farmacista — deve poter:**
1. **Aggiungere un prodotto** inserendo solo foto + descrizione minima + prezzo iniziale + prezzo scontato.
2. **Ricevere** dal sistema la scheda completa generata dall'AI (immagine ottimizzata + testi IT/EN).
3. **Validare e pubblicare**: rivedere i contenuti sanitari e pubblicare; finché non pubblica, il prodotto resta invisibile ai clienti.
4. **Gestire ordini** (stato, spedizione/tracking) e **gestire le richieste di consulenza** (slot, completamento).
5. **Gestire il catalogo** (modifica, disattivazione, gestione stock).

### 2.4 Le 3 cose che rendono il progetto distintivo
Pipeline **AI per il data-entry**, **consulenza professionale** integrata, **bilinguismo IT/EN** del catalogo. *(Il posizionamento commerciale è nella Parte 2.)*

---

## 3. Stack Tecnologico

| Componente | Tecnologia scelta | Motivazione & best practice |
|---|---|---|
| **Frontend & UI** | Flutter | Singolo codice base per Web, iOS, Android e Desktop. |
| **State Management** | Riverpod + Hooks | Riverpod (con `riverpod_generator`) per logica di business e chiamate API; `flutter_hooks` per stati effimeri della UI (animazioni, form), evitando il boilerplate del `setState`. |
| **Backend & Database** | Firebase | Cloud Firestore (NoSQL flessibile), Cloud Storage (immagini), Firebase Auth (autenticazione). |
| **Logica server** | Firebase Cloud Functions | Ambiente serverless Node.js/TypeScript: indispensabile per nascondere le chiavi API e processare i dati AI in sicurezza (vedi §10–§11). |
| **Integrazioni AI** | API immagini + LLM | API per scontorno/ottimizzazione immagini (es. Photoroom) + LLM (es. GPT-4o) per testi commerciali e sanitari, generati in **IT ed EN**. |
| **Routing** | go_router | Navigazione nativa e web; routing **basato su path** (non hash) per favorire l'indicizzazione e prevenire 404 sulla PWA. |
| **Ricerca** | Algolia / Typesense / estensione Firebase | Fuzzy search con tolleranza ai refusi. Algolia premium; Typesense (self-hosted) o l'estensione Firebase più economiche per cataloghi piccoli/medi. |
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
    │   ├── account/            # Ordini, indirizzi, consensi, abbonamenti
    │   ├── consultations/      # Prenotazione e chat/video
    │   ├── admin/              # Dashboard: aggiunta prodotto (AI), validazione, ordini
    │   └── content/            # Blog/guide alla salute (E-E-A-T)
    └── main.dart               # Entry point, init Firebase + App Check
```

### 4.2 Progetto Backend (Firebase / Cloud Functions)
Backend "thin" ma necessario: ospita chiavi e logica AI, webhook di pagamento, sincronizzazione ricerca, regole.

```
firebase/ (Firebase)
├── functions/
│   └── src/
│       ├── ai/                 # Pipeline: vision (Photoroom) + generazione testi LLM (IT/EN), grounding, guardrail
│       ├── catalog/            # Trigger onProductDraftCreated; workflow di pubblicazione
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
        ├──► API LLM (es. GPT-4o)        → testi IT/EN
        ├──► API Immagini (es. Photoroom)→ scontorno + WebP
        ├──► Motore di ricerca (Algolia/Typesense)
        └──► Gateway di pagamento (Stripe/PayPal/Satispay)
```

---

## 5. Modello Dati (entità, campi, schema Firestore)

**Principio bilingue:** i campi testuali destinati all'utente sono **mappe localizzate** `{ "it": "...", "en": "..." }`, così lo stesso documento serve entrambe le lingue. Gli importi sono in **centesimi** (interi) per evitare errori di arrotondamento.

### 5.1 Entità principali e campi

**`Product` (collezione `products`)**
`id`, `sku`, `barcode` (EAN), `categoryRef`, `type` (`SOP|OTC|parafarmaco|integratore|cosmetico|dispositivo_medico`), `isMedicine` (bool → governa separazione pagina e logo), `name{it,en}`, `shortDescription{it,en}`, `description{it,en}`, `activeIngredient{it,en}`, `posology{it,en}`, `contraindications{it,en}`, `warnings{it,en}`, `ceMarking` (bool, per dispositivi), `priceList` (int, cent), `priceSale` (int, cent), `currency` (`EUR`), `vatRate` (es. 4, 10, 22), `stockQty` (int), `available` (bool), `images[]` (`{url, alt{it,en}}`), `seo{slug{it,en}, title{it,en}, metaDescription{it,en}}`, `status` (`draft|pending_review|published|archived`), `aiGenerated` (bool), `reviewedBy` (ref adminUser), `reviewedAt`, `publishedAt`, `createdAt`, `updatedAt`.

**`Category` (collezione `categories`)**
`id`, `name{it,en}`, `slug{it,en}`, `parentRef` (nullable), `isMedicineCategory` (bool), `order` (int).

**`User` (collezione `users`, doc = `uid` di Firebase Auth)**
`uid`, `role` (`customer|pharmacist|admin`), `email`, `displayName`, `phone`, `locale` (`it|en`), `addresses[]` (`{label, recipient, street, city, zip, province, country, phone}`), `consents{marketing(bool), medicineDataProcessing(bool), updatedAt}`, `loyaltyPoints` (int), `createdAt`.

**`Cart` (collezione `carts`, doc = `uid`)**
`userRef`, `items[]` (`{productRef, qty, priceSnapshot}`), `updatedAt`. *(La modifica richiede connessione: §9.)*

**`Order` (collezione `orders`)**
`id`, `orderNumber`, `userRef`, `items[]` (`{productRef, nameSnapshot, qty, unitPrice, vatRate}`), `totals{subtotal, shipping, vat, total}`, `shippingAddress{}`, `billingAddress{}`, `paymentMethod`, `paymentStatus` (`pending|paid|failed|refunded`), `paymentRef`, `shippingStatus` (`processing|shipped|delivered|returned`), `carrier`, `trackingNumber`, `status` (`created|confirmed|preparing|shipped|delivered|cancelled`), `recessoRequested` (bool, per art. 54-bis), `createdAt`, `updatedAt`.

**`Consultation` (collezione `consultations`)**
`id`, `userRef`, `kind` (`farmacista|cosmetologo`), `channel` (`chat|video`), `slotStart`, `slotEnd`, `status` (`requested|confirmed|completed|cancelled`), `notesEncrypted`, `createdAt`.

**`Subscription` (collezione `subscriptions`)**
`id`, `userRef`, `productRef`, `frequencyDays` (int), `nextRun`, `discountPct`, `status` (`active|paused|cancelled`).

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
/articles/{articleId}
/config/{docId}
```

### 5.5 Sicurezza dei dati (riepilogo regole)
- **`products`/`categories`/`articles`:** lettura pubblica **solo per `status == "published"`**; le bozze (`draft`/`pending_review`) sono leggibili solo da `admin`/`pharmacist`. Scrittura/pubblicazione **solo** `admin`/`pharmacist`.
- **`users`:** ogni utente legge/scrive **solo** il proprio documento; il campo `role` non è modificabile dal client.
- **`carts`/`orders`/`subscriptions`/`consultations`:** accessibili **solo** al proprietario (`userRef == uid`); creazione ordini e cambi di stato sensibili passano da Cloud Functions. Le note di consulenza sono **cifrate** e accessibili solo al personale autorizzato.
- **Chiavi API e segreti:** mai in Firestore né nel client → **Secret Manager**, usate solo dalle Cloud Functions (vedi §10–§11).

---

## 6. SEO, Indicizzazione e Architettura di Rendering *(critica)*

### 6.1 Il problema: Flutter Web e l'indicizzazione
Flutter Web in modalità **CanvasKit** disegna l'interfaccia su una *canvas* WebGL: la pagina è **priva di DOM testuale indicizzabile** (nessun testo semantico/heading/link leggibile dal crawler). Una PWA Flutter "pura" è quindi **quasi invisibile a Google**. Anche il renderer HTML produce testo frammentato ed è in via di deprioritizzazione; il **peso del bundle** (JS/WASM) penalizza i Core Web Vitals.

### 6.2 La raccomandazione: disaccoppiare il rendering
- **Catalogo, schede prodotto e blog** serviti come **HTML pre-renderizzato / SSR** (storefront statico o SSR con Next.js o equivalente; in alternativa prerender per i bot via Rendertron/Prerender.io).
- **Flutter** per i flussi "app-like" autenticati (carrello, checkout, account, admin).
- Routing **basato su path**, `<title>`/meta/OpenGraph per pagina, **JSON-LD** (`Product`, `FAQPage`, `BreadcrumbList`), `robots.txt`, `sitemap.xml`. Le pagine SEO sono **bilingui** con URL e `hreflang` per IT/EN.

> **Gate di validazione:** l'**Ispezione URL di Google Search Console** deve mostrare testo e link reali su schede e blog prima di investire in traffico.

### 6.3 Contenuti, E-E-A-T e YMYL
Contenuti sanitari = **YMYL**: vanno **firmati e revisionati dal farmacista** (autore con credenziali), con citazioni, data di revisione, trasparenza su azienda/contatti, HTTPS. L'AI supera l'E-E-A-T **solo** con revisione umana responsabile.

### 6.4 Hosting: perché non GitHub Pages
Le condizioni d'uso di GitHub **vietano** l'uso di GitHub Pages per gestire un'attività commerciale o un sito e-commerce; è inoltre **solo statico** (niente SSR), con limiti di spazio/banda. → **Firebase Hosting** (integrazione nativa col backend) **o Vercel/Netlify** (SSR/prerendering). Entrambi con SSL e dominio personalizzato.

---

## 7. User Experience (UX), Design System e Flusso di Navigazione

### 7.1 Pubblico e principio guida
Pubblico tendenzialmente **maturo** → **accessibilità = conversione**: caratteri grandi, navigazione semplice, alto contrasto, aree tattili ampie. Riferimento **WCAG 2.2** (testo 4,5:1; componenti UI 3:1).

### 7.2 Revisione critica delle scelte estetiche
- **Neumorphism — da evitare come default:** contrasti troppo bassi (~1,1:1, sotto il minimo WCAG di 3:1), pulsanti poco distinguibili.
- **Glassmorphism — solo decorativo:** ammesso se lo sfondo solido garantisce testo ≥4,5:1; **mai dietro** posologia, controindicazioni, prezzo o logo ministeriale.
- **Bento grid** — ok, se rispetta contrasto e dimensioni target.

**Raccomandazione:** base **flat/Material ad alto contrasto**, palette calma (verde smeraldo o blu ospedaliero), ampio spazio bianco; glassmorphism solo su superfici decorative; niente neumorfismo sui controlli.

### 7.3 Bottom Navigation Bar
4 sezioni sempre visibili: **Home** · **Negozio** (catalogo, filtri, ricerca) · **Carrello** (badge) · **Profilo** (switch Cliente/Admin).

### 7.4 Schermate principali e flusso
```
Splash → Home
Home ├─ Negozio → (ricerca | scanner barcode | filtri) → Dettaglio prodotto → Aggiungi al carrello
     ├─ Offerte / Più richiesti → Dettaglio prodotto
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
- **Richiede connessione (bloccato con messaggio chiaro se offline):** login/registrazione, carrello e checkout, pagamenti, prenotazione consulenze, area amministrativa e pipeline AI.
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

## 10. La "Killer Feature": Flusso Admin AI-Driven

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

## 12. Funzionalità AI Aggiuntive

- **Raccomandazioni di prodotto** (su dati commerciali, non sanitari).
- **Chatbot di assistenza** (FAQ, stato ordine, reso) con escalation al farmacista.
- **Previsione della domanda** per il riassortimento.
- *(Opzionale, alto rischio)* **"check sintomi"** sconsigliato; se offerto, fortemente disclaimerizzato, su fonti validate e **mediato dal farmacista**.

Tutte seguono il principio del §11: **logica e chiavi lato server**, contenuti sensibili sotto controllo umano.

---

## 13. Funzionalità di Prodotto

### 13.1 Ricerca intelligente & barcode scanner
- **Fuzzy search** (Algolia/Typesense/estensione Firebase) per correggere i refusi.
- **Scansione del codice a barre** (fotocamera) per trovare e **riordinare** in un tap.

### 13.2 Abbonamenti e riacquisto (funzione)
Opzione **"Acquisto Ricorrente"** (integratori, cosmetici, OTC a uso cronico) con sconto. *(Strategia di retention nella Parte 2.)*

### 13.3 Consulenza come servizio (funzione)
Chat e **video-consulenza** con farmacista e cosmetologo, con **prenotazione a slot**. *(Valore competitivo e operatività nella Parte 2.)*

### 13.4 Capacità PWA
**Service worker** per cache catalogo e scanner; **HTTPS**, installabilità, primo caricamento rapido (code splitting / componenti differiti).

---

## 14. Scope e Fuori-Scope (MVP)

### 14.1 In scope (versione 1)
Catalogo bilingue con ricerca e scanner; dettaglio prodotto; carrello e checkout con pagamento (PayPal + carte + Satispay); account cliente (auth, indirizzi, ordini, consensi); **pannello admin AI con validazione e pubblicazione**; consultazione catalogo **offline**; SEO in SSR/prerender per catalogo e blog; compliance di base (logo, separazione medicinali/non-medicinali, consenso dati medicinali, pulsante recesso). **Personalizzazione Baganza (§16):** brand e **logo rifinito con splash animato**, **modulo Servizi + Prenotazioni** (autoanalisi, telemedicina, consulenze), **selettore di sede** (3 farmacie) e **deep-link ai sistemi regionali** (CUPWeb/ER Salute) per CUP e referti.

### 14.2 Fuori scope (per ora)
Farmaci con prescrizione; **marketplace multi-farmacia**; **video-consulenza** avanzata (può seguire dopo la chat); **abbonamenti** e **loyalty** avanzati (fase successiva); raccomandazioni AI e check sintomi; coda transazioni offline; distribuzione su store desktop. *(Allineato alla roadmap della Parte 2.)*

---

## 15. Criteri di Accettazione (Definition of Done)

**Funzionali**
- Il cliente può **trovare** un prodotto (ricerca + barcode), **vederne la scheda bilingue**, **aggiungerlo al carrello**, **pagare** (ambiente sandbox) e **ricevere conferma** ordine.
- **Offline**, il catalogo già scaricato è navigabile; le azioni transazionali sono bloccate con messaggio chiaro.
- L'admin può creare un prodotto da **foto + descrizione**, il backend genera **immagine WebP + testi IT/EN**, e il prodotto diventa visibile **solo dopo** il clic "Pubblica" del farmacista.
- Un utente **non autorizzato** non raggiunge l'area admin e non può pubblicare.

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
Aggiunta della destinazione **"Servizi"** come voce di primo livello. Bottom nav consigliata a **5 voci**: **Home · Negozio · Servizi · Carrello · Profilo** (in alternativa, mantenere 4 voci e rendere "Servizi e Prenotazioni" la **card principale** della Home). La Home mostra anche il **selettore di sede** (con orari e "apri in mappa"/chiama).

### 16.8 Compliance e accessibilità specifiche
- **Vendita online dei medicinali:** dato che `benesserefarmacia.it` propone già OTC/SOP, **verificare l'autorizzazione** del Ministero della Salute e la presenza del **logo identificativo nazionale** prima di abilitare la vendita SOP/OTC in app. Se l'autorizzazione non c'è (o finché non c'è), partire con **parafarmaci/cosmetici/integratori** (che non la richiedono) e aggiungere SOP/OTC dopo. *(Regole complete nella Parte 2.)*
- **European Accessibility Act (EAA):** l'azienda risulta avere ~13 dipendenti, quindi **l'accessibilità WCAG è verosimilmente obbligatoria** (non rientra nell'esenzione microimprese). Da trattare come requisito di legge, non opzionale (coerente con §7.2).

### 16.9 Da verificare con la farmacia (assunzioni aperte)
- **Logo:** ricevuto (`Baganza_Logo_Ufficiale.png`). Resta da produrre la **ricostruzione vettoriale** (per icona/favicon nitidi e per l'animazione, §16.2–16.3) e la **versione semplificata** per l'app icon.
- **Stato dell'autorizzazione** alla vendita online e display del logo ministeriale (§16.8).
- **Prezzi, orari e disponibilità** dei servizi per sede (qui come da sito, giugno 2026).
- **Font istituzionale** e eventuali colori secondari ufficiali (oltre al verde confermato).
- Quali servizi di **Priorità 2/3** includere già nella v1.

---

> **Continua nella Parte 2 di 2 — Documento business/operativo:** mercato e concorrenza, conversione (CRO), pagamenti, fidelizzazione e CRM, logistica e gestionale, compliance legale, modello di business, KPI, roadmap, considerazioni finali e fonti. *(La personalizzazione commerciale per Baganza — servizi come leva di posizionamento, multi-sede, loyalty — può essere riportata anche lì su richiesta.)*
