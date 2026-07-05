# Baganza Farmacie 3.0 — Piano di Sviluppo a Step
### Roadmap implementativa derivata dal Documento Tecnico (Parte 1)

> **Cos'è:** la scomposizione del progetto in **step di sviluppo** concreti e ordinati, per costruire l'app passo dopo passo. Ogni step rimanda alla sezione del documento tecnico (`§`).
>
> **Come si legge ogni step:**
> - **Obiettivo** — il risultato dello step in una frase.
> - **Attività** — sotto-task spuntabili `- [ ]`.
> - **✓ Fatto quando** — criterio di completamento.
> - **Rif.** = sezione del doc tecnico · **Dipende da** = step prerequisito.
>
> **Legenda:** ⭐ = incluso nell'MVP (v1) · size indicativa **S**/**M**/**L** (aiuto di pianificazione, non una stima oraria).

---

## Principi di sviluppo
- **Compliance-first:** ruoli, regole di sicurezza e impianto privacy/logo vengono prima delle feature di vendita (Fase 1).
- **Fette verticali:** quando possibile si completa un flusso end-to-end (UI → dato → backend) invece di costruire a strati orizzontali.
- **Un branch per step**, PR piccola, test inclusi; niente chiavi/segreti nel client (sempre lato Cloud Functions).
- **Due progetti in monorepo:** `app/` (Flutter) e `firebase/` (Firebase) — vedi §4.
- **Gate critici (non superabili senza):** (a) le pagine SEO devono rendere HTML reale prima di investire in traffico (§6.2); (b) prima del lancio della vendita medicinali servono autorizzazione + logo ministeriale (§16.8, Parte 2); (c) la **Chat AI cliente** non va esposta al pubblico senza **red-team clinico + consenso art. 9 + validazione legale del perimetro** (§12.4–12.5, step 4B.8).

---

## Mappa delle fasi
0. **Fondamenta & Setup** — repo, Firebase, scaffolding, design system, CI.
1. **Dati, Auth & Compliance** — modello dati, regole, ruoli, impianto GDPR/logo.
2. **Catalogo, Ricerca & SEO** — parte pubblica (cliente).
3. **Carrello, Checkout, Pagamenti, Ordini.**
4. **Pannello Admin AI** — la prima "killer feature".
4B. **Assistente AI Cliente** — la seconda "killer feature": chat sintomi lievi→prodotti (LLM open-source EU, RAG sul catalogo, guardrail, widget web 70/30 + tab mobile) (§12).
5. **Personalizzazione Baganza** — servizi, multi-sede, prenotazioni, CUP.
6. **Branding & Splash** — vettorializzazione logo, app icon, splash animato.
7. **Engagement (post-MVP)** — abbonamenti, loyalty, consulenza, push, contenuti.
8. **Qualità, Accessibilità & Lancio.**

---

## FASE 0 — Fondamenta & Setup

### Step 0.1 — Repository e ambiente ⭐ · S
- **Obiettivo:** due repo pronti e versionati.
- **Attività:**
  - [ ] Crea `app/` (Flutter) e `firebase/` (Firebase) con Git e strategia di branching.
  - [ ] Configura Flutter SDK, linter/analyzer, formattazione.
  - [ ] README con istruzioni di avvio per entrambi i progetti.
- **✓ Fatto quando:** entrambi i repo compilano "a vuoto" e il linter passa. · **Rif.** §4

### Step 0.2 — Progetto Firebase ⭐ · M
- **Obiettivo:** backend cloud attivo.
- **Attività:**
  - [ ] Crea il progetto Firebase (ambienti **dev** e **prod**).
  - [ ] Abilita **Auth, Firestore, Storage, Cloud Functions, Hosting, App Check**.
  - [ ] Configura gli **emulatori** Firebase per lo sviluppo locale.
  - [ ] Predisponi **Secret Manager** per le future chiavi (LLM/Photoroom/pagamenti).
- **✓ Fatto quando:** l'app locale si collega agli emulatori e a Firebase dev. · **Rif.** §3.1, §4.2 · **Dipende da:** 0.1

### Step 0.3 — Scaffolding Flutter (Feature-First) ⭐ · M
- **Obiettivo:** struttura del frontend pronta.
- **Attività:**
  - [ ] Crea `core/` e `features/` come da §4.1.
  - [ ] Integra **Riverpod + Hooks** e **go_router** (routing basato su path).
  - [ ] Inizializza Firebase + **App Check** in `main.dart`.
- **✓ Fatto quando:** navigazione tra 2 schermate placeholder con go_router e provider attivi. · **Rif.** §3, §4.1

### Step 0.4 — Design System & brand di base ⭐ · M
- **Obiettivo:** tema e componenti coerenti col brand.
- **Attività:**
  - [ ] Definisci i **design token** (oro `#C9A227`, verde `#1E7A3C`, verde scuro `#14532D`, cremisi `#9E1B32`, alert `#C62828`) in `core/theme`.
  - [ ] Imposta **verde = colore d'azione**, testo scuro; oro/cremisi solo accenti (regole di §16.2).
  - [ ] Componenti base (bottoni, card, input) con **contrasto WCAG 2.2** verificato.
  - [ ] Importa il logo (`Baganza_Logo_Ufficiale.png`) come asset temporaneo.
- **✓ Fatto quando:** una "style page" mostra i componenti e i contrasti passano. · **Rif.** §7.2, §16.2

### Step 0.5 — i18n IT/EN ⭐ · S
- **Obiettivo:** infrastruttura bilingue.
- **Attività:**
  - [ ] Configura `flutter_localizations` + `intl`, file ARB `app_it.arb`/`app_en.arb`.
  - [ ] Selettore lingua (auto da device + override in `users.locale`).
- **✓ Fatto quando:** una schermata cambia lingua IT↔EN senza stringhe hardcoded. · **Rif.** §8

### Step 0.6 — CI/CD e flavor ⭐ · S
- **Obiettivo:** build automatiche e ambienti separati.
- **Attività:**
  - [ ] Pipeline CI (analyze + test + build web/Android).
  - [ ] **Flavor/ambienti** dev/prod lato app e Functions.
- **✓ Fatto quando:** una PR fa girare lint+test e produce una build. · **Rif.** §4

---

## FASE 1 — Dati, Autenticazione & Compliance

### Step 1.1 — Modello dati Firestore ⭐ · L ✅
- **Obiettivo:** schema dati completo.
- **Attività:**
  - [x] Crea le collezioni: `products`, `categories`, `users`, `carts`, `orders`, `services`, `locations`, `appointments`, `articles`, `config` (campi come §5 e §16.5). → modelli Dart in `app/lib/features/*/domain/` + `core/models/`.
  - [x] Campi testuali utente come **mappe `{it,en}`** (`LocalizedText`); importi in **centesimi** (int).
  - [x] Indici compositi (`firestore.indexes.json`) per liste/filtri (products/orders/appointments/articles).
- **✓ Fatto quando:** documenti di esempio creati e letti via emulatore. · **Rif.** §5, §16.5
  - **Fatto:** seed `firebase/functions/scripts/seed.mjs` (`npm run seed`) → 2 prodotti pubblicati riletti, 1 bozza nascosta; 14 test modelli (`test/models_test.dart`).

### Step 1.2 — Security Rules & Storage Rules ⭐ · L ✅
- **Obiettivo:** accesso ai dati sicuro.
- **Attività:**
  - [x] `products/categories/articles`: lettura pubblica **solo `published`**; scrittura/pubblicazione solo `admin/pharmacist`.
  - [x] `users/carts/orders/subscriptions/appointments`: accesso **solo al proprietario**; `role` non modificabile dal client (create solo `customer`, update a `role` invariato).
  - [x] `storage.rules` per immagini prodotto (staff via custom claim `role`, sincronizzato dalla Cloud Function `syncRoleClaim`); test delle regole.
- **✓ Fatto quando:** i test delle rules negano gli accessi incrociati e le bozze ai non-admin. · **Rif.** §5.5 · **Dipende da:** 1.1
  - **Fatto:** 11 test in `firebase/tests/` (`@firebase/rules-unit-testing`) verdi via `npm run test:emulator` (richiede **JDK ≥ 21**).

### Step 1.3 — Autenticazione & ruoli ⭐ · M ✅
- **Obiettivo:** login e distinzione Cliente/Admin.
- **Attività:**
  - [x] Firebase Auth (email/registrazione); creazione doc `users` con `role: customer` (`features/auth/data/auth_repository.dart`).
  - [x] **Route guard** (cliente non accede alle rotte admin) e **switch** Cliente/Admin nel Profilo (`app_router.dart` redirect + `viewModeProvider`).
  - [x] Gestione sessione scaduta (redirect a `/login?from=…` mantenendo il contesto).
- **✓ Fatto quando:** un cliente e un admin vedono interfacce diverse; le rotte admin sono protette. · **Rif.** §2.2, §7.4, §9.2 · **Dipende da:** 1.2

### Step 1.4 — Impianto Compliance & Privacy ⭐ · L ✅
- **Obiettivo:** scheletro legale pronto (dettagli normativi in Parte 2).
- **Attività:**
  - [x] Slot **logo ministeriale** sulle pagine dei **medicinali** (`MinisterialLogo`, si mostra solo se `isMedicine`) + helper **separazione** medicinali/non-medicinali (`MedicineSeparation`).
  - [x] **Consensi GDPR** (marketing + **trattamento dati medicinali** + **assistente AI art. 9**) su `users.consents` e **cookie banner** app-wide.
  - [x] **Pulsante di recesso** (art. 54-bis) con dialog di **conferma tracciata** (`WithdrawalButton`, si aggancia agli ordini in Fase 3).
- **✓ Fatto quando:** consensi salvati su `users.consents`; logo e separazione presenti dove dovuto. · **Rif.** §9.2, §16.8 + Parte 2 (compliance) · **Dipende da:** 1.1

> **Fase 1 completata.** Verifiche: `flutter analyze` pulito, **20 test** app verdi, **11 test** regole verdi, `flutter build web` ok, functions `build`+`lint` ok. *(Rimane, quando disponibili: font istituzionale, asset logo ministeriale reale e conferma autorizzazione §16.8-16.9.)*

---

## FASE 2 — Catalogo, Ricerca & SEO (lato cliente)

### Step 2.1 — Repository & provider Prodotti ⭐ · M
- **Obiettivo:** dati prodotto disponibili nell'app.
- **Attività:**
  - [ ] Modelli Dart (Product/Category) + repository Firestore + provider Riverpod.
- **✓ Fatto quando:** la lista prodotti pubblicati si carica da Firestore. · **Rif.** §5 · **Dipende da:** 1.1

### Step 2.2 — Lista catalogo, categorie e filtri ⭐ · M
- **Attività:**
  - [ ] Schermata Negozio con griglia/card prodotto, categorie e filtri.
  - [ ] Card prodotto (foto scontornata, prezzo barrato, "+").
- **✓ Fatto quando:** navigazione catalogo fluida con filtri funzionanti. · **Rif.** §7.3–7.4, §13 · **Dipende da:** 2.1

### Step 2.3 — Dettaglio prodotto (bilingue) ⭐ · M
- **Attività:**
  - [ ] Pagina dettaglio: descrizione, principio attivo, posologia, controindicazioni (IT/EN), prezzo, CE per dispositivi.
  - [ ] Segnali di fiducia (logo dove medicinale, info reso/recesso).
- **✓ Fatto quando:** scheda completa e corretta in entrambe le lingue. · **Rif.** §5, §7.5 · **Dipende da:** 2.1

### Step 2.4 — Ricerca fuzzy ⭐ · M
- **Attività:**
  - [ ] Scegli motore (Algolia / Typesense / estensione Firebase).
  - [ ] **Sync prodotti pubblicati** dal backend al motore (Cloud Function).
  - [ ] UI ricerca con tolleranza ai refusi.
- **✓ Fatto quando:** "okitask" trova "Oki Task". · **Rif.** §3, §13.1 · **Dipende da:** 2.1

### Step 2.5 — Scanner barcode ⭐ · S
- **Attività:**
  - [ ] Scansione EAN da fotocamera → ricerca/riordino del prodotto.
- **✓ Fatto quando:** inquadrando un codice si apre la scheda corretta. · **Rif.** §13.1 · **Dipende da:** 2.3

### Step 2.6 — Catalogo offline ⭐ · M
- **Attività:**
  - [ ] Persistenza offline Firestore + cache immagini per i prodotti pubblicati.
  - [ ] Banner "offline" e disabilitazione azioni transazionali.
- **✓ Fatto quando:** senza rete il catalogo già scaricato resta navigabile. · **Rif.** §9.1 · **Dipende da:** 2.2

### Step 2.7 — SEO & rendering (gate critico) ⭐ · L
- **Obiettivo:** pagine pubbliche indicizzabili.
- **Attività:**
  - [ ] Storefront **SSR/prerender** per catalogo + schede + blog (no Flutter "puro" sulle pagine pubbliche).
  - [ ] `<title>`/meta/OpenGraph per pagina, **JSON-LD** (Product/FAQ/Breadcrumb), `sitemap.xml`, `robots.txt`, **hreflang** IT/EN.
- **✓ Fatto quando:** l'**Ispezione URL di Search Console** mostra testo e link reali. · **Rif.** §6.2 · **Dipende da:** 2.3

---

## FASE 3 — Carrello, Checkout, Pagamenti, Ordini

### Step 3.1 — Carrello ⭐ · M
- **Attività:**
  - [ ] Stato carrello + persistenza per utente (`carts/{uid}`), snapshot prezzo.
- **✓ Fatto quando:** aggiunta/rimozione e totali corretti, persistenti tra sessioni. · **Rif.** §5 · **Dipende da:** 2.3, 1.3

### Step 3.2 — Checkout ⭐ · L
- **Attività:**
  - [ ] Indirizzi, riepilogo, **IVA per categoria**, spese di spedizione.
  - [ ] **Guest checkout**; spese mostrate presto; campi minimi (CRO §10 Parte 2).
- **✓ Fatto quando:** flusso fino al pagamento, con totali e IVA corretti. · **Rif.** §5, Parte 2 §2 · **Dipende da:** 3.1

### Step 3.3 — Integrazione pagamenti ⭐ · L
- **Attività:**
  - [ ] Gateway: **PayPal**, **Stripe/Nexi**, **Satispay**, **BNPL** (Scalapay/Klarna).
  - [ ] Tokenizzazione (PCI-DSS), **3-D Secure 2.0**; chiavi lato server.
- **✓ Fatto quando:** pagamento in **sandbox** completato per ogni metodo abilitato. · **Rif.** Parte 2 §3 · **Dipende da:** 3.2

### Step 3.4 — Creazione ordine & webhook (backend) ⭐ · L
- **Attività:**
  - [ ] Cloud Function di creazione ordine; **webhook** di pagamento idempotenti.
  - [ ] Stati `paymentStatus`/`status`; **stock scalato solo a pagamento confermato**; email transazionali.
- **✓ Fatto quando:** un pagamento sandbox genera un ordine `paid` e l'email parte. · **Rif.** §4.2, §9.2 · **Dipende da:** 3.3

### Step 3.5 — Area ordini cliente ⭐ · M
- **Attività:**
  - [ ] Storico ordini, stato spedizione/tracking, richiesta **recesso**.
- **✓ Fatto quando:** il cliente vede e traccia i propri ordini. · **Rif.** §5, §16.8 · **Dipende da:** 3.4

---

## FASE 4 — Pannello Admin AI (killer feature)

### Step 4.1 — UI "Aggiungi Prodotto" ⭐ · M
- **Attività:**
  - [ ] Form admin: foto + descrizione minima + prezzo iniziale + scontato → crea documento **`draft`** + upload immagine in Storage.
- **✓ Fatto quando:** il draft compare con immagine caricata. · **Rif.** §10 · **Dipende da:** 1.3

### Step 4.2 — Pipeline Vision (backend) ⭐ · M
- **Attività:**
  - [ ] Cloud Function (trigger su draft): **Photoroom** scontorno → sfondo bianco → **WebP**; chiave in Secret Manager + App Check.
- **✓ Fatto quando:** dall'immagine grezza si ottiene la WebP ottimizzata. · **Rif.** §10, §11.5 · **Dipende da:** 4.1

### Step 4.3 — Pipeline Testi LLM (backend) ⭐ · L
- **Attività:**
  - [ ] Generazione **IT+EN** di titolo SEO, descrizione, principio attivo, posologia, controindicazioni.
  - [ ] **Grounding** su fonti validate (foglietto/RCP) + **guardrail** anti prompt-injection + log provenienza.
- **✓ Fatto quando:** il draft si popola di testi bilingui tracciati. · **Rif.** §10, §11.2/11.5 · **Dipende da:** 4.1

### Step 4.4 — Validazione umana & pubblicazione ⭐ · M
- **Attività:**
  - [ ] Anteprima scheda; **revisione farmacista** (posologia/controindicazioni IT+EN); pulsante **Pubblica** → `published`.
  - [ ] Nessuna pubblicazione automatica; registrazione di chi approva.
- **✓ Fatto quando:** il prodotto è visibile ai clienti **solo dopo** "Pubblica". · **Rif.** §10 · **Dipende da:** 4.2, 4.3

### Step 4.5 — Gestione catalogo admin ⭐ · M
- **Attività:**
  - [ ] Modifica prodotto, gestione **stock**, disattivazione/archiviazione.
- **✓ Fatto quando:** l'admin gestisce ciclo di vita e giacenze. · **Rif.** §5, §13 · **Dipende da:** 4.4

---

## FASE 4B — Assistente AI Cliente (chat sintomi→prodotti)

> La seconda killer feature (§12): il cliente descrive un disturbo lieve e la chat propone **solo prodotti del catalogo pubblicato**, con guardrail clinici e escalation al farmacista. Perimetro vincolante: **orientamento all'acquisto, mai diagnosi** (§12.1).

### Step 4B.1 — Scelta modello LLM & proxy (spike) ⭐ · M
- **Obiettivo:** modello open-source scelto su prove, non su brochure.
- **Attività:**
  - [ ] **Golden set** di 50–100 conversazioni in italiano scritto col farmacista (sintomi lievi, red-flag, ambiguità, jailbreak).
  - [ ] Test comparativo dei candidati (§12.2): **Qwen 3** e/o **Mistral Small 3.x** su provider **EU** (Scaleway/OVHcloud/La Plateforme); **DeepSeek V3.x solo su hosting EU/occidentale** (mai l'API ufficiale — caso Garante); *(OpenBioLLM scartato: solo EN)*.
  - [ ] Proxy Cloud Function con formato **OpenAI-compatibile** (`baseUrl`+`model` in config/Secret Manager) → modello **swappabile**; streaming SSE.
  - [ ] Decisione registrata (ADR): qualità italiano, rifiuti corretti sui red-flag, aderenza al catalogo, latenza, costo.
- **✓ Fatto quando:** un modello è scelto sul golden set e risponde via proxy dagli emulatori. · **Rif.** §12.2, §11.5 · **Dipende da:** 0.2

### Step 4B.2 — Embeddings & indice vettoriale ⭐ · M
- **Attività:**
  - [ ] Embedding **multilingue** (es. `bge-m3`/`multilingual-e5`) generato **alla pubblicazione** del prodotto (estende il trigger di `catalog/`).
  - [ ] Indice: **Firestore Vector Search** o **Typesense ibrido** (riuso del motore di 2.4 — scegliere qui).
  - [ ] Query top-k con filtri rigidi: `status==published`, `available==true`, `assistantEligible==true`.
- **✓ Fatto quando:** "mal di testa" restituisce i prodotti pertinenti del catalogo di prova. · **Rif.** §12.3 · **Dipende da:** 2.4, 4.4

### Step 4B.3 — Cloud Function `assistantChat` + guardrail ⭐ · L
- **Attività:**
  - [ ] Pipeline completa (§12.3): moderazione input (**Llama Guard 3** o filtri provider) → **triage red-flag deterministico** (lista curata dal farmacista, scatta **prima** dell'LLM) → retrieval → prompt "a gabbia" (solo prodotti forniti, no Rx, no dosaggi fuori scheda, IT/EN) → **output JSON strutturato** con `productRef` **verificati contro il catalogo** → moderazione output → log sessione.
  - [ ] Rate-limit per uid/IP, limite messaggi/sessione e /giorno, troncamento contesto, App Check.
  - [ ] **Fallback**: LLM giù → messaggio cortese + link catalogo/WhatsApp farmacista (la chat degrada, non blocca).
  - [ ] Collezioni `chatSessions`/`messages` con scrittura **solo via function** (rules).
- **✓ Fatto quando:** sintomo lieve → 3–5 card prodotto reali; red-flag → zero prodotti e rinvio al medico; injection dal golden set respinte. · **Rif.** §12.3–12.4, §5.5 · **Dipende da:** 4B.1, 4B.2

### Step 4B.4 — Consenso art. 9 & GDPR chat ⭐ · M
- **Attività:**
  - [ ] **Consenso esplicito** pre-chat (consenso `aiAssistant` su `users.consents`; consenso di sessione per guest) + informativa dedicata.
  - [ ] **Retention breve** (`purgeAt` ~90 gg + job di purge), pseudonimizzazione nel registro, niente riuso marketing/profilazione.
  - [ ] Verifica **data residency EU** dell'inference (log endpoint); **DPIA** documentata.
- **✓ Fatto quando:** senza consenso la chat non parte; il job di purge cancella le sessioni scadute. · **Rif.** §12.5 · **Dipende da:** 1.4, 4B.3

### Step 4B.5 — UI Web: widget flottante + pannello 70/30 ⭐ · M
- **Attività:**
  - [ ] **Widget flottante in basso al centro** su Home e Catalogo (≥1024 px): pill "Sono il tuo assistente AI: dimmi cosa ti fa male o cosa cerchi" (ARB IT/EN), stile §16.2, non copre contenuti critici.
  - [ ] Click/digitazione → animazione **250–300 ms**: contenuto al **70% a sinistra**, **pannello chat 30% a destra** (min 360 px): header + badge AI + ✕, cronologia, disclaimer fisso, card prodotto→scheda/carrello, input.
  - [ ] ✕/**ESC** → ritorno al 100%; conversazione preservata; badge non letti sul widget.
  - [ ] A11y: focus trap, `aria-live`, `prefers-reduced-motion` (switch istantaneo), contenuto al 70% senza scroll orizzontale.
  - [ ] **Due superfici, un contratto:** componente **web leggero** per le pagine SSR (§6.2) + widget **Flutter** (`AnimatedContainer` 70/30) nella PWA, stesso endpoint.
- **✓ Fatto quando:** su desktop l'animazione 70/30 apre/chiude la chat da Home e Catalogo (SSR e PWA) senza rompere il layout. · **Rif.** §12.6 · **Dipende da:** 4B.3, 2.2

### Step 4B.6 — UI Mobile: tab "Chat AI" ⭐ · S
- **Attività:**
  - [ ] **Nessun widget flottante su mobile**: voce **centrale** della bottom nav — **Home · Negozio · Chat AI · Carrello · Profilo** ("Servizi" → card hero della Home, §16.7).
  - [ ] Chat **full-screen**: stesso componente conversazione + **chip rapidi** ("Mal di testa", "Raffreddore", "Consiglio pelle", "Parla col farmacista").
  - [ ] **Onboarding first-run** (cosa fa/cosa non fa) con consenso (da 4B.4).
- **✓ Fatto quando:** da mobile la tab apre la chat e il flusso sintomo→card→carrello funziona. · **Rif.** §12.6, §7.3 · **Dipende da:** 4B.3, 4B.4

### Step 4B.7 — Supervisione farmacista (audit & escalation) ⭐ · M
- **Attività:**
  - [ ] Dashboard admin: **registro conversazioni** (pseudonimizzato), filtri `redFlagTriggered`/`flaggedForReview`, "risposta scorretta" → revisione prompt/red-flag.
  - [ ] **Inbox escalation** ("Parla con il farmacista") → consulenza §13.3 o WhatsApp sede.
  - [ ] Gestione lista **red-flag** e flag `assistantEligible` per prodotto.
- **✓ Fatto quando:** il farmacista vede le conversazioni, riceve le escalation e modifica la lista red-flag senza deploy. · **Rif.** §12.4 · **Dipende da:** 4B.3, 1.3

### Step 4B.8 — Red-team clinico & gate legale (gate critico) ⭐ · M
- **Attività:**
  - [ ] Batteria di test su casi pericolosi: emergenze, pediatria, gravidanza, autolesionismo, richieste Rx, prompt injection — **tutti** devono produrre rifiuto/rinvio corretto.
  - [ ] Verifica del **perimetro non-diagnostico** (§12.1) e parere legale **AI Act/MDR/GDPR** (§12.5); trasparenza AI (badge + benvenuto).
  - [ ] Monitoraggio post-lancio: alert su volumi anomali di red-flag e su risposte segnalate.
- **✓ Fatto quando:** il red-team passa al 100% sui red-flag e il legale approva il perimetro. **Senza questo step la chat resta disattivata** (feature flag). · **Rif.** §12.4–12.5 · **Dipende da:** 4B.3–4B.7

---

## FASE 5 — Personalizzazione Baganza: Servizi, Multi-sede, Prenotazioni

### Step 5.1 — Multi-sede & selettore ⭐ · M
- **Attività:**
  - [ ] Modello `locations` (3 farmacie: indirizzi, orari, geo, `isCupPoint`).
  - [ ] **Selettore di sede** con orari, "apri in mappa", "chiama", WhatsApp.
- **✓ Fatto quando:** l'utente sceglie la sede e ne vede contatti/orari. · **Rif.** §16.1, §16.5, §16.7 · **Dipende da:** 1.1

### Step 5.2 — Modulo Servizi ⭐ · M
- **Attività:**
  - [ ] Modello `services`; schede con **prezzo**, **sede/i**, **preparazione**, tipo (`free_access`/`appointment`/`external_link`).
  - [ ] Servizi di **Priorità 1** (autoanalisi, telemedicina ECG/Holter/dermatoscopia/MOC) + CUP.
- **✓ Fatto quando:** elenco servizi navigabile con dettagli corretti. · **Rif.** §16.4, §16.5 · **Dipende da:** 5.1

### Step 5.3 — Prenotazioni / appuntamenti ⭐ · L
- **Attività:**
  - [ ] Modello `appointments`; richiesta **slot** per servizio/sede; gestione lato admin (conferma/annulla/completa).
  - [ ] Notifica al personale; nessuna prenotazione che sottrae tempo al banco non gestita.
- **✓ Fatto quando:** un cliente richiede uno slot e l'admin lo conferma. · **Rif.** §16.4–16.5, §13.3 · **Dipende da:** 5.2

### Step 5.4 — Integrazione sistemi regionali ⭐ · S
- **Attività:**
  - [ ] **Deep-link** a CUPWeb/ER Salute/FSE; schede informative su CUP e ritiro referti per sede.
  - [ ] Nessuna promessa di prenotazione CUP "in-app" (sistemi statali con SPID).
- **✓ Fatto quando:** i link aprono correttamente i servizi regionali. · **Rif.** §16.6 · **Dipende da:** 5.2

### Step 5.5 — Navigazione aggiornata ⭐ · S
- **Attività:**
  - [ ] Bottom nav definitiva: **Home · Negozio · Chat AI · Carrello · Profilo**; **"Servizi" = card hero della Home** (decisione §16.7, per non superare 5 voci).
  - [ ] Su web desktop "Servizi" resta voce del menu orizzontale; la chat è il widget 70/30 (step 4B.5), non una voce di navigazione.
- **✓ Fatto quando:** "Servizi" è raggiungibile dalla Home/menu e la tab Chat AI è al suo posto su mobile. · **Rif.** §16.7, §12.6 · **Dipende da:** 5.2

---

## FASE 6 — Branding finale & Splash

### Step 6.1 — Vettorializzazione logo & icone ⭐ · M
- **Attività:**
  - [ ] **Ricostruzione vettoriale (SVG)** dell'emblema con elementi su layer separati (anello, ali, serpenti, asta, "S", maschera, wordmark).
  - [ ] **App icon / favicon / maskable** PWA (192/512px) usando una **versione semplificata** (solo emblema).
- **✓ Fatto quando:** icone nitide a tutte le misure; SVG pronto per l'animazione. · **Rif.** §16.2 (richiede asset esterno design)

### Step 6.2 — Splash nativo ⭐ · S
- **Attività:**
  - [ ] `flutter_native_splash`: sfondo bianco + emblema; blocco **Android 12+**, storyboard iOS, tema web.
  - [ ] Niente Activity di splash legacy; disattiva il fade di sistema su Android 12+.
- **✓ Fatto quando:** nessun "doppio splash"; avvio pulito su Android/iOS/web. · **Rif.** §16.3 · **Dipende da:** 6.1

### Step 6.3 — Reveal animato ⭐ · M
- **Attività:**
  - [ ] **Strada A (Rive)** o **B (PNG + `flutter_animate`)**: coreografia (anello che si disegna → ali → serpenti → "S" → wordmark → shimmer), **≤1,2–1,8 s, non in loop**.
  - [ ] **Hand-off** alla Home appena pronti init Firebase + primi dati.
- **✓ Fatto quando:** lo splash animato gira fluido e cede il passo senza ritardi. · **Rif.** §16.3 · **Dipende da:** 6.2

---

## FASE 7 — Engagement (post-MVP, v1.1+)

### Step 7.1 — Abbonamenti / acquisto ricorrente · L
- [ ] Modello `subscriptions`, frequenza, sconto, gestione pause/annulla. · **Rif.** §13.2, Parte 2 §4

### Step 7.2 — Loyalty (GDPR-safe) · M
- [ ] Punti/livelli **solo su dati commerciali** (no dati sanitari), con consenso. · **Rif.** Parte 2 §4

### Step 7.3 — Consulenza chat/video · L
- [ ] Chat/video con farmacista e cosmetologo, prenotazione a slot, note **cifrate**. · **Rif.** §13.3, §16.4

### Step 7.4 — Notifiche push & estensioni AI · M
- [ ] FCM + **web push (VAPID)**; estensioni dell'assistente (FAQ operative: stato ordine/resi/orari in chat); raccomandazioni su dati commerciali. *(La chat AI di base è già in Fase 4B.)* · **Rif.** §12.7

### Step 7.5 — Blog / contenuti E-E-A-T · M
- [ ] Articoli firmati/revisionati dal farmacista, data di revisione, in SSR. · **Rif.** §6.3

---

## FASE 8 — Qualità, Accessibilità & Lancio

### Step 8.1 — Accessibilità (WCAG 2.2 / EAA) ⭐ · M
- [ ] Audit contrasto/tap target/screen reader sui flussi chiave (oro mai su testo). · **Rif.** §7.2, §16.2/16.8

### Step 8.2 — Test ⭐ · L
- [ ] Unit + widget + integrazione; test delle security rules via emulatore. · **Rif.** §15

### Step 8.3 — Analytics & privacy ⭐ · S
- [ ] GA4 con **Consent Mode**; preferibile **tagging server-side**. · **Rif.** §16 / Parte 2 §6.4

### Step 8.4 — Hardening sicurezza ⭐ · M
- [ ] **App Check** in enforcement; verifica **nessuna chiave nel client**; revisione rules. · **Rif.** §11, §5.5

### Step 8.5 — Deploy & PWA ⭐ · M
- [ ] Hosting **Firebase/Vercel** (SSR per le pagine pubbliche); `manifest.json` (icone, `theme_color`), service worker `offline-first`; build store Android/iOS. · **Rif.** §6.4, §13.4

### Step 8.6 — Gate di lancio (compliance) ⭐ · M
- [ ] **Autorizzazione Ministero** + **logo** prima della vendita medicinali; consensi e **pulsante recesso** attivi; verifica **Criteri di Accettazione** (§15). · **Rif.** §15, §16.8, Parte 2 §5 · **Dipende da:** 8.1–8.5

---

## Milestone

| Milestone | Contenuto | Step |
|---|---|---|
| **M1 — Fondamenta** | Setup, dati, auth, compliance scaffolding | Fase 0–1 |
| **M2 — Catalogo navigabile + SEO** | Negozio, ricerca, scanner, offline, pagine indicizzabili | Fase 2 |
| **M3 — Vendita** | Carrello, checkout, pagamenti, ordini | Fase 3 |
| **M4 — Admin AI** | Pipeline AI + validazione + gestione catalogo | Fase 4 |
| **M4B — Chat AI cliente** | LLM open EU + RAG catalogo + guardrail + UI web 70/30 e tab mobile + audit farmacista | Fase 4B |
| **M5 — Baganza** | Multi-sede, servizi, prenotazioni, CUP | Fase 5 |
| **M6 — Brand & Splash** | Logo vettoriale, icone, splash animato | Fase 6 |
| **⭐ MVP (v1)** | M1→M6 (incl. M4B) + Fase 8 (lancio) | tutti gli step ⭐ |
| **v1.1+** | Engagement | Fase 7 |

---

## Ordine consigliato & parallelizzazioni
- **Sequenza portante:** 0 → 1 → 2 → 3 → 8 (lancio).
- **In parallelo** (dopo la Fase 1):
  - un profilo **backend** può lavorare alla **Fase 4 (Admin AI)** mentre il frontend fa la **Fase 2**;
  - lo **spike 4B.1** (scelta LLM) non ha dipendenze di prodotto: può partire subito dopo la Fase 0; il resto della **Fase 4B** richiede catalogo e ricerca (2.4) e può procedere in parallelo alle Fasi 3 e 5;
  - la **Fase 5 (Baganza/servizi)** è abbastanza indipendente e può procedere in parallelo alla 3;
  - la **Fase 6 (branding/splash)** dipende dall'asset vettoriale del logo (design): avviarla appena pronto, senza bloccare le altre.
- **Non saltare i tre gate:** SEO reale (2.7) prima del marketing; autorizzazione + logo (8.6) prima di vendere medicinali; **red-team + gate legale (4B.8) prima di esporre la Chat AI**.

---

> Riferimenti: **Documento Tecnico — Parte 1** (architettura, dati, AI, §16 Baganza) e **Documento Business/Operativo — Parte 2** (mercato, CRO, pagamenti, fidelizzazione, logistica, compliance legale, KPI, roadmap, fonti).
