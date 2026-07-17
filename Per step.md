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
- **Adaptive-first (una base di codice, quattro superfici — §4.4):** ogni schermata nasce per i breakpoint `compact` (web app mobile/PWA) **e** `expanded` (portale web desktop; stessa base per l'app Windows). Niente breakpoint hardcoded nelle feature, navigazione adattiva (bottom bar ↔ rail/menu), guardie di piattaforma per le capacità mobile-only (scanner, push). Il portale desktop/admin **non** è un progetto separato.
- **SEO ≠ SSO:** *SEO* = farsi **trovare su Google** (storefront SSR, Fase 2, step 2.7 — gate critico); *SSO* = **login con Google** (Firebase Auth, step 1.5 — comodità di accesso). Sono indipendenti: solo la SEO porta traffico.
- **UI pulita, effetti misurati (§7.2):** linguaggio visivo moderno — gradiente ambientale azzurro→bianco, glassmorphism con fallback solido, card 3D, motion a molla — ma **un solo effetto "wow" per viewport**, una sola azione primaria per schermata, e i contenuti critici (posologia, prezzi, logo ministeriale) sempre su superficie solida. Gli effetti si degradano con grazia (`prefers-reduced-motion`, dispositivi lenti), mai sotto i 60 fps.
- **Gate critici (non superabili senza):** (a) le pagine SEO devono rendere HTML reale prima di investire in traffico (§6.2); (b) prima del lancio della vendita medicinali servono autorizzazione + logo ministeriale (§16.8, Parte 2); (c) la **Chat AI cliente** non va esposta al pubblico senza **red-team clinico + consenso art. 9 + validazione legale del perimetro** (§12.4–12.5, step 4B.8).

---

## Mappa delle fasi
0. **Fondamenta & Setup** — repo, Firebase, scaffolding, design system, CI.
1. **Dati, Auth & Compliance** — modello dati, regole, ruoli, impianto GDPR/logo, login Google (SSO).
2. **Catalogo, Ricerca & SEO** — parte pubblica (cliente): UI adattiva mobile/desktop, storefront SSR per **farsi trovare su Google** (SEO), verifica multi-superficie (web/Windows).
3. **Carrello, Checkout, Pagamenti, Ordini.**
4. **Pannello Admin AI** — la prima "killer feature".
4B. **Assistente AI Cliente** — la seconda "killer feature": chat sintomi lievi→prodotti (LLM open-source EU, RAG sul catalogo, guardrail, widget web 70/30 + pagina mobile) (§12). **La chat è anche la ricerca**: campo/lente → conversazione (§12.6), con la barra fuzzy di 2.4 come ponte fino al gate 4B.8.
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

### Step 0.4 — Design System & linguaggio visivo ⭐ · M→L ✅
- **Obiettivo:** tema, componenti ed effetti coerenti col brand e col linguaggio visivo §7.2 (pulito + moderno).
- **Attività:**
  - [x] Definisci i **design token** (oro `#C9A227`, verde `#1E7A3C`, verde scuro `#14532D`, cremisi `#9E1B32`, alert `#C62828`, **ambientale `#EAF4FE`→bianco**) in `core/theme`.
  - [x] Imposta **verde = colore d'azione**, testo scuro; oro/cremisi solo accenti; **azzurro solo sfondo ambientale**, mai testo/azioni (regole di §16.2 e §7.2.2).
  - [x] **`ThemeExtension` `BaganzaEffects`** (§7.2.6): gradienti ambientali, spec glass (blur/fill/bordo), ombre a 2 strati con tinta verde, durate/curve del motion system — nessun valore hardcodato nelle feature.
  - [x] Widget riusabili del linguaggio: **`GlassSurface`** (BackdropFilter + fallback solido) e **`TiltCard`** (tilt max 6° su hover desktop, press-scale su touch) — §7.2.3–7.2.4.
  - [x] Componenti base (bottoni, card, input) con **contrasto WCAG 2.2** verificato, incluso testo su gradiente ambientale e su vetro (caso peggiore).
  - [x] Importa il logo (`Baganza_Logo_Ufficiale.png`) come asset temporaneo.
- **✓ Fatto quando:** la "style page" mostra componenti, **gradiente ambientale, una `GlassSurface` e una `TiltCard` funzionanti**, e i contrasti passano (anche con `prefers-reduced-motion` attivo). · **Rif.** §7.2, §16.2
  - **Fatto:** token ambientali in `core/theme/app_colors.dart` (`ambientAzure`/`ambientAzureHero`); `BaganzaEffects` `ThemeExtension` (`core/theme/baganza_effects.dart`) registrata nel tema; widget `AmbientBackground`, `GlassSurface` (blur + `solidFallback`), `TiltCard` (hover-tilt/press-scale, rispetta `disableAnimations`); breakpoint token (`core/theme/breakpoints.dart`); token condivisi con lo storefront in `core/theme/tokens.json`. La style page mostra swatch azzurro, `GlassSurface` e `TiltCard` dal vivo.

### Step 0.5 — i18n IT/EN ⭐ · S
- **Obiettivo:** infrastruttura bilingue.
- **Attività:**
  - [ ] Configura `flutter_localizations` + `intl`, file ARB `app_it.arb`/`app_en.arb`.
  - [ ] Selettore lingua (auto da device + override in `users.locale`).
- **✓ Fatto quando:** una schermata cambia lingua IT↔EN senza stringhe hardcoded. · **Rif.** §8

### Step 0.6 — CI/CD e flavor ⭐ · S
- **Obiettivo:** build automatiche e ambienti separati.
- **Attività:**
  - [ ] Pipeline CI (analyze + test + build **web/Android/Windows** — il target Windows è una superficie di prodotto, §4.4).
  - [ ] **Flavor/ambienti** dev/prod lato app e Functions.
- **✓ Fatto quando:** una PR fa girare lint+test e produce le build dei tre target. · **Rif.** §4, §4.4

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

### Step 1.5 — Login con Google (SSO) ⭐ · S 🟡 (codice fatto; config OAuth in console → attività umana)
- **Obiettivo:** accesso in un tap con l'account Google, accanto a email/password. *(È l'**SSO**: comodità di login. Non c'entra con la SEO/step 2.7, che è farsi trovare su Google.)*
- **Attività:**
  - [ ] Abilita il provider **Google** in Firebase Auth (console dev+prod) e configura gli OAuth client per **web**, **Android** (SHA-1/SHA-256), **iOS** — **attività umana (console)**. *(Windows/desktop: pulsante nascosto via guardia di piattaforma, resta email/password — fallback dichiarato §4.4.)*
  - [x] `signInWithGoogle()` in `AuthRepository`: **web** `signInWithPopup`, **mobile** `signInWithProvider` (flusso OAuth di Firebase, **zero plugin aggiuntivi** — niente `google_sign_in`); primo accesso → crea il doc `users` con `role: customer` (`_ensureProfile`, stesso shape di 1.3), accessi successivi → riusa il doc.
  - [x] **Account linking (base):** con "un account per email" (default Firebase) la stessa email già registrata via password **non viene duplicata** → `account-exists-with-different-credential` mappato a un messaggio localizzato IT/EN che invita ad accedere con la password. *(Auto-relink con prompt password: follow-up.)*
  - [x] Pulsante **"Continua con Google"** (`GoogleSignInButton`, condiviso da login e registrazione), nascosto dove il flusso non è supportato (desktop/Windows). *(Icona `Icons.g_mobiledata`; il logo brand ufficiale resta un asset di design opzionale.)*
- **✓ Fatto quando:** un utente nuovo entra con Google e ottiene il doc `users` corretto; un utente esistente con la stessa email non viene duplicato; il flusso funziona su web mobile, web desktop e (o con fallback dichiarato) Windows. **Codice fatto** (`flutter analyze` pulito, **75 test** verdi); **la verifica end-to-end richiede la config OAuth in console (umana).** · **Rif.** §6 (nota SEO≠SSO) · **Dipende da:** 1.3

> **Fase 1 completata (step 1.1–1.4; step 1.5 codice fatto, resta la config OAuth in console).** Verifiche: `flutter analyze` pulito, **20 test** app verdi, **11 test** regole verdi, `flutter build web` ok, functions `build`+`lint` ok. *(Rimane: config OAuth Google in Firebase Console per attivare l'SSO — il codice del 1.5 è implementato; e, quando disponibili: font istituzionale, asset logo ministeriale reale e conferma autorizzazione §16.8-16.9.)*

---

## FASE 2 — Catalogo, Ricerca & SEO (lato cliente)

> ### ⚠️ Nota — cosa NON è stato fatto in Fase 2
> Gli step 2.1–2.6 sono completi. Restano aperti due punti, elencati qui in modo esplicito per non dare per chiuso ciò che non lo è:
>
> 1. **Gate SEO 2.7 resta APERTO.** Sono state posate le fondamenta servibili dallo shell, ma le pagine HTML reali per pagina (JSON-LD `Product`, meta per-pagina, Ispezione URL Search Console) richiedono lo **storefront SSR** — un progetto di rendering separato dall'app Flutter, dettagliato nell'**ADR 0001** (`docs/adr/0001-storefront-seo.md`). Non è stato inventato uno stack SSR fittizio.
> 2. **Step 2.8 (run su Windows + CI multi-target) è PARZIALE.** Le guardie di piattaforma (`core/utils/platform_support.dart`) e la shell adattiva ci sono, ma la verifica su **Windows reale** (`flutter run -d windows`) e il **target Windows in CI** restano da fare.

### Step 2.1 — Repository & provider Prodotti ⭐ · M ✅
- **Obiettivo:** dati prodotto disponibili nell'app.
- **Attività:**
  - [x] Modelli Dart (Product/Category) + repository Firestore + provider Riverpod.
- **✓ Fatto quando:** la lista prodotti pubblicati si carica da Firestore. · **Rif.** §5 · **Dipende da:** 1.1
  - **Fatto:** `ProductRepository` (`features/catalog/data/`) legge **solo `published`** (rules §5.5), ordinati per `createdAt` desc, con filtri per categoria/tipo + read singola prodotto/categorie; provider Riverpod (`features/catalog/application/catalog_providers.dart`, `autoDispose`). Aggiunto indice composito `status+createdAt` (`firestore.indexes.json`). **7 test** con `fake_cloud_firestore` (`test/product_repository_test.dart`) — draft esclusi, ordinamento e filtri verificati. *(UI griglia/card → Step 2.2.)*

### Step 2.2 — Lista catalogo, categorie e filtri (adattiva) ⭐ · M ✅
- **Attività:**
  - [x] **Breakpoint token** in `core/theme` (`compact` <600 · `medium` 600–1024 · `expanded` ≥1024, §4.4) + **shell adattiva**: bottom bar su mobile, `NavigationRail`/menu orizzontale su desktop — stesse rotte `go_router`, wrapper unico.
  - [x] Schermata Negozio con griglia/card prodotto, categorie e filtri: griglia fluida (`maxCrossAxisExtent`, mai colonne fisse); filtri come bottom-sheet su mobile e **pannello laterale in `GlassSurface`** su desktop; testata con gradiente ambientale (§7.2.2).
  - [x] **Card prodotto 3D** (`TiltCard`, §7.2.4): foto scontornata "sollevata" con ombra propria, prezzo barrato, "+" verde; tilt+sheen su hover desktop, press-scale su touch; **entrata staggered** (fade+slide 24 px, 40 ms).
  - [x] **Skeleton shimmer** durante il caricamento della griglia (niente spinner a pagina intera, §7.2.5).
- **✓ Fatto quando:** navigazione catalogo fluida con filtri funzionanti **sia a 390 px sia a ≥1280 px**, senza scroll orizzontale, a 60 fps sulla griglia (verifica raster, §7.2.6). · **Rif.** §4.4, §7.2–7.4, §13 · **Dipende da:** 2.1, 0.4
  - **Fatto:** `AdaptiveScaffold` (`core/widgets/`) con bottom bar in vetro (compact) e `NavigationRail` in vetro (expanded) sulle 5 voci §7.3 (Chat AI/Carrello → placeholder Fase 4B/3). `CatalogScreen` con testata ambientale + ricerca, chip categorie, griglia `maxCrossAxisExtent`, `CatalogFilterPanel` laterale (desktop) / `CatalogFilterSheet` (mobile). `ProductCard` = `TiltCard` con foto (cached), prezzo barrato in offerta, "+"; entrata staggered per la prima schermata. `ProductCardSkeleton` con shimmer (`flutter_animate`).

### Step 2.3 — Dettaglio prodotto (bilingue) ⭐ · M ✅
- **Attività:**
  - [x] Pagina dettaglio: descrizione, principio attivo, posologia, controindicazioni (IT/EN), prezzo, CE per dispositivi. Parte alta con **gradiente ambientale** dietro la foto; posologia/controindicazioni/prezzo **sempre su superficie solida** (§7.2.3).
  - [x] **Hero transition** dalla card alla scheda (immagine condivisa, `Hero` + `CustomTransitionPage`; resto in fade+slide, §7.2.5).
  - [x] Segnali di fiducia (logo dove medicinale, info reso/recesso).
- **✓ Fatto quando:** scheda completa e corretta in entrambe le lingue, con transizione fluida card→scheda (e istantanea con `prefers-reduced-motion`). · **Rif.** §5, §7.2, §7.5 · **Dipende da:** 2.1
  - **Fatto:** `ProductDetailScreen` (rotta `/product/:id`): foto in `Hero(productHeroTag)` su gradiente ambientale, tutto il resto (prezzo, sezioni, posologia/controindicazioni via `LocalizedText.resolve`) su superficie solida bianca; badge CE per `dispositivoMedico`; `MinisterialLogo` se medicinale + card reso/recesso. Rotta con `fadeSlidePage` (`core/router/transitions.dart`) che rispetta `disableAnimations`. Contenuto centrato ≤820 px su desktop.

### Step 2.4 — Ricerca fuzzy ⭐ · M ✅
- **Attività:**
  - [x] Scegli motore (Algolia / Typesense / estensione Firebase). → **ADR 0002**: fuzzy client-side per l'MVP, migrazione a Typesense quando serve (anche vettoriale, §4B.2).
  - [x] ~~Sync prodotti pubblicati dal backend al motore (Cloud Function).~~ Non necessario per il fuzzy client-side; è il passo di migrazione descritto nell'ADR.
  - [x] UI ricerca con tolleranza ai refusi.
- **✓ Fatto quando:** "okitask" trova "Oki Task". · **Rif.** §3, §13.1 · **Dipende da:** 2.1
  - **Fatto:** `core/utils/fuzzy.dart` (normalizzazione senza diacritici/spazi + Levenshtein) ordina per rilevanza su nome/principio attivo/sku/EAN. Decisione in `docs/adr/0002-search-engine.md`. **9 test** (`test/fuzzy_test.dart`, incl. "okitask"→"Oki Task"; `test/catalog_filter_test.dart` per il ranking).
  - **⚠ Aggiornamento implementato (decisione di prodotto, §12.6 — la ricerca È la chat):** la **barra classica inline è stata rimossa** da Home e Negozio. Ora il campo/lente è un'affordance che **apre la pagina `/assistant`** (`AssistantSearchBar` → `features/assistant/`), stessa destinazione della tab centrale "Chat AI" (bottom nav `chatAi` → `/assistant`). **Cosa NON è ancora fatto (è la Fase 4B):** l'LLM conversazionale. Fino ad allora `/assistant` gira in **modalità "solo risultati"** — ricerca fuzzy a schermo intero (`assistantResultsProvider` + `AssistantScreen`) con banner-ponte onesto ("l'assistente conversazionale arriva nella Fase 4B"). Il motore fuzzy resta comunque come router pre-LLM / fallback offline / ricerche admin (ADR 0002). Lo scambio dietro **feature flag** post-gate 4B.8 è lo step **4B.6b**.

### Step 2.5 — Scanner barcode ⭐ · S ✅
- **Attività:**
  - [x] Scansione EAN da fotocamera → ricerca/riordino del prodotto.
- **✓ Fatto quando:** inquadrando un codice si apre la scheda corretta. · **Rif.** §13.1 · **Dipende da:** 2.3
  - **Fatto:** `ScanScreen` (rotta `/scan`, apribile dall'icona nel Negozio) con `mobile_scanner`; guardia di piattaforma `PlatformSupport.barcodeScanner` (`core/utils/`) → su desktop/web fallback a **inserimento EAN manuale**. `ProductRepository.fetchPublishedProductByBarcode` (solo `published`) → naviga alla scheda o mostra "non trovato". **3 test** repository EAN.

### Step 2.6 — Catalogo offline ⭐ · M ✅
- **Attività:**
  - [x] Persistenza offline Firestore + cache immagini per i prodotti pubblicati.
  - [x] Banner "offline" e disabilitazione azioni transazionali.
- **✓ Fatto quando:** senza rete il catalogo già scaricato resta navigabile. · **Rif.** §9.1 · **Dipende da:** 2.2
  - **Fatto:** persistenza Firestore abilitata in `firebase_init.dart` (anche web, cache illimitata); immagini via `cached_network_image`. `isOnlineProvider` (`connectivity_plus`) → `OfflineBanner` app-wide (overlay in `app.dart`); le azioni transazionali (carrello, in Fase 3) leggeranno lo stato online per disabilitarsi (stringa `offlineActionDisabled` pronta).

### Step 2.7 — SEO: farsi trovare su Google (gate critico) ⭐ · L
- **Obiettivo:** il catalogo e i contenuti compaiono nelle **ricerche di Google** con pagine HTML reali. *(Questo è **SEO** — trovabilità; il login con Google/**SSO** è lo step 1.5. Vedi la nota in §6.)*
- **Perché serve uno storefront a parte:** Flutter Web disegna su canvas → il crawler di Google **non vede testo né link** (§6.1). Quindi le pagine pubbliche (catalogo, schede, blog, sedi/servizi) vanno servite come **HTML SSR/prerender**, mentre la PWA Flutter resta per i flussi autenticati. **Un solo dominio, due renderer** (§6.2): `/`, `/p/{slug}`, `/blog/...` → storefront SSR; `/app/...` → PWA.
- **Attività:**
  - [x] **ADR di piattaforma storefront:** (a) Next.js/Astro su **Firebase Hosting + Cloud Run/Functions** (consigliata: un solo fornitore), (b) Next.js su Vercel, (c) prerender bot (solo come ponte). Decisione registrata → `docs/adr/0001-storefront-seo.md` (scelta **a**).
  - [ ] Storefront che legge **le stesse collezioni Firestore** (solo `published`): lista catalogo, scheda prodotto, blog, pagine sedi/servizi; CTA "Aggiungi al carrello" → deep-link alla PWA (`/app/...`). *(Track SSR separato — vedi ADR.)*
  - [~] `<title>`/meta/OpenGraph **a livello di sito** + **JSON-LD `Pharmacy`** nello shell (`web/index.html`). Il per-pagina (`Product`/`FAQPage`/`BreadcrumbList`) e `hreflang` con URL per lingua li serve lo storefront SSR.
  - [x] **Token visivi condivisi** esportati per lo storefront (`core/theme/tokens.json` → CSS custom properties, §7.2.6).
  - [x] `robots.txt` (esclude `/app/`) + **`sitemap.xml`** seed con hreflang IT/EN; la (ri)generazione dal dato è la Cloud Function del track SSR.
  - [ ] **Search Console:** verifica proprietà, invio sitemap, Ispezione URL su scheda prodotto e articolo. *(Dopo che lo storefront SSR è online.)*
  - [ ] *(Post-gate, opzionale)* feed **Google Merchant Center** (schede gratuite) dal JSON-LD `Product`.
- **✓ Fatto quando:** l'**Ispezione URL di Search Console** mostra testo e link reali su una scheda prodotto e un articolo, in IT e EN, e la sitemap è inviata. **Senza questo gate non si investe in traffico/marketing.** · **Rif.** §6.2 · **Dipende da:** 2.3
  - **Fondamenta fatte (gate ANCORA APERTO):** `web/robots.txt`, `web/sitemap.xml` (hreflang IT/EN + x-default), OpenGraph/Twitter/canonical + JSON-LD `Pharmacy` in `web/index.html`, token condivisi `tokens.json`, ADR `docs/adr/0001-storefront-seo.md`. **Manca lo storefront SSR** (rendering server per-pagina + Cloud Function sitemap + verifica Search Console): è un progetto di rendering separato dall'app Flutter, dettagliato nell'ADR. Il gate §6.2 si chiude solo con quello.

### Step 2.8 — Portale web desktop & app Windows (verifica multi-superficie) ⭐ · S
- **Obiettivo:** la stessa base di codice regge le quattro superfici del §4.4 — web app mobile, portale web desktop, app Windows (l'iOS/Android nativo segue con gli store, Fase 8).
- **Attività:**
  - [ ] Passata di verifica dei flussi Fase 2 su **web desktop ≥1280 px** (shell a rail, griglie, dettaglio) e su **Windows** (`flutter run -d windows`).
  - [x] **Guardie di piattaforma** consolidate in `core/utils`: scanner barcode solo mobile (fallback: campo EAN manuale su desktop/Windows), gestione hover/focus da tastiera sulle card e sui filtri.
  - [ ] **Build Windows in CI** accanto a web/Android: una rottura del target desktop è una rottura di build.
- **✓ Fatto quando:** catalogo, ricerca e dettaglio funzionano su web mobile, web desktop e Windows senza layout rotti; la CI compila i tre target. · **Rif.** §4.4 · **Dipende da:** 2.2, 2.3
  - **Parziale:** guardie di piattaforma in `core/utils/platform_support.dart` (scanner→fallback EAN); shell adattiva rail/bottom-bar e hover-tilt/focus sulle card già presenti da 2.2. `flutter build web` verde. **Restano:** run di verifica su Windows e target Windows in CI.

> **Fase 2 — step 2.1–2.7 completati** (linguaggio visivo §7.2 incluso in 0.4). Verifiche: `flutter analyze` pulito, **44 test** app verdi (+17 da Fase 1), `flutter build web` ok. *(Restano: 2.7 gate SEO = storefront SSR reale — track separato nell'ADR; 2.8 = run Windows + CI multi-target.)*

---

## FASE 3 — Carrello, Checkout, Pagamenti, Ordini

> ### ⚠️ Nota — cosa NON è completo in Fase 3
> Gli step 3.1, 3.2, 3.4 e 3.5 sono completi. Restano aperti (dettaglio in **ADR 0003**, `docs/adr/0003-payments-and-orders.md`):
>
> 1. **Gateway di pagamento reali (3.3) NON integrati.** L'app usa un **provider sandbox** (`confirmMockPayment`) che sostituisce il webhook del gateway: nessun addebito reale. Mancano SDK/redirect di Stripe/Nexi, PayPal, Satispay, BNPL, tokenizzazione PCI-DSS + 3-D Secure, e chiavi in Secret Manager. La logica ordine/stock/idempotenza è però già quella definitiva.
> 2. **Firma webhook** in `paymentWebhook`: oggi valida forma + idempotenza; la verifica della firma per gateway è un TODO segnalato.
> 3. **Email transazionali** sono uno **stub** (`logger`); manca SMTP/SendGrid reale.
> 4. **Guest checkout** usa **Anonymous Auth**, da abilitare in Firebase Auth (dev+prod).

### Step 3.1 — Carrello ⭐ · M ✅
- **Attività:**
  - [x] Stato carrello + persistenza per utente (`carts/{uid}`), snapshot prezzo.
- **✓ Fatto quando:** aggiunta/rimozione e totali corretti, persistenti tra sessioni. · **Rif.** §5 · **Dipende da:** 2.3, 1.3
  - **Fatto:** `CartRepository` (`carts/{uid}`) + `CartController` (`features/cart/application/`): add/incrementa/setQty/remove/clear con **snapshot prezzo** all'aggiunta; persistenza Firestore per utenti loggati e carrello ospite in memoria (unificati da `cartProvider`). `CartScreen` con stepper quantità, totali live e badge sul nav (carrello). Azioni transazionali disabilitate offline. Add-to-cart cablato su card e scheda. **5 test** (`test/cart_controller_test.dart`).

### Step 3.2 — Checkout ⭐ · L ✅
- **Attività:**
  - [x] Indirizzi, riepilogo, **IVA per categoria**, spese di spedizione.
  - [x] **Guest checkout**; spese mostrate presto; campi minimi (CRO §10 Parte 2).
- **✓ Fatto quando:** flusso fino al pagamento, con totali e IVA corretti. · **Rif.** §5, Parte 2 §2 · **Dipende da:** 3.1
  - **Fatto:** `OrderPricing` (pure, testabile): subtotale lordo, **IVA inclusa raggruppata per aliquota**, spedizione da `config/app` (soglia gratis), totale; `OrderSummary` riusabile su carrello e checkout. `CheckoutScreen` con form minimo (nome/email/telefono + indirizzo), nota **guest-friendly**, riepilogo live. **8 test** (`test/order_pricing_test.dart`).

### Step 3.3 — Integrazione pagamenti ⭐ · L 🟡 (sandbox; gateway reali → ADR 0003)
- **Attività:**
  - [x] Scelta metodo in UI: **PayPal**, **Stripe/Nexi**, **Satispay**, **BNPL** (Scalapay/Klarna).
  - [ ] Integrazione gateway reali: tokenizzazione (PCI-DSS), **3-D Secure 2.0**; chiavi lato server. *(Non fatto — vedi nota e ADR 0003.)*
- **✓ Fatto quando:** pagamento in **sandbox** completato per ogni metodo abilitato. · **Rif.** Parte 2 §3 · **Dipende da:** 3.2
  - **Fatto (MVP):** `PaymentScreen` con selezione metodo + avviso sandbox; il pagamento passa dal provider sandbox lato server (`confirmMockPayment`). Chiavi mai nel client. **Gateway reali da integrare (ADR 0003).**

### Step 3.4 — Creazione ordine & webhook (backend) ⭐ · L ✅
- **Attività:**
  - [x] Cloud Function di creazione ordine; **webhook** di pagamento idempotenti.
  - [x] Stati `paymentStatus`/`status`; **stock scalato solo a pagamento confermato**; email transazionali (stub).
- **✓ Fatto quando:** un pagamento sandbox genera un ordine `paid` e l'email parte. · **Rif.** §4.2, §9.2 · **Dipende da:** 3.3
  - **Fatto:** `createOrder` (callable) riprezza dal carrello sui `products` autoritativi (solo `published`), crea ordine `pending`/`created` con `userRef="users/<uid>"`, **senza toccare lo stock**. `markOrderPaid` condivisa da `confirmMockPayment` (callable) e `paymentWebhook` (HTTP, idempotente via `webhookEvents/{eventId}`): transazione che segna `paid`/`confirmed`, **scala lo stock una sola volta**, svuota il carrello, accoda l'email (stub). `firebase/functions` build+lint verdi. *(Firma webhook + email reale → ADR 0003.)*

### Step 3.5 — Area ordini cliente ⭐ · M ✅
- **Attività:**
  - [x] Storico ordini, stato spedizione/tracking, richiesta **recesso**.
- **✓ Fatto quando:** il cliente vede e traccia i propri ordini. · **Rif.** §5, §16.8 · **Dipende da:** 3.4
  - **Fatto:** `OrderRepository` + provider; `OrdersScreen` (storico, chip stato pagamento/ordine, totale) da `/orders` e dal Profilo; `OrderDetailScreen` con articoli, totali, stato pagamento/spedizione, corriere/tracking e `WithdrawalButton` cablato su `requestWithdrawal` (recesso tracciato art. 54-bis).

> **Fase 3 — step 3.1, 3.2, 3.4, 3.5 completati; 3.3 in sandbox.** Verifiche: `flutter analyze` pulito, **56 test** app verdi (+12 da Fase 2), functions `build`+`lint` ok, `flutter build web` ok. *(Restano i gateway di pagamento reali + firma webhook + email reale + Anonymous Auth — ADR 0003.)*

---

## FASE 4 — Pannello Admin AI (killer feature)

> **Superficie primaria: desktop.** Il pannello admin è usato dal farmacista al banco/back-office → si progetta **desktop-first** sul **portale web desktop** e gira identico nell'**app Windows** (stesso codice, §4.4); su mobile resta usabile per le operazioni rapide (foto prodotto dal telefono, conferma ordini). La foto in 4.1 arriva da fotocamera su mobile e da file picker su desktop/Windows.

> ### ⚠️ Nota — cosa NON è completo in Fase 4
> Gli step 4.1, 4.4, 4.5 sono completi. Gli step 4.2 e 4.3 sono in **modalità mock** (dettaglio in **ADR 0004**, `docs/adr/0004-admin-ai-pipeline.md`):
>
> 1. **Vision reale (4.2) NON integrata.** Il trigger `processProductImage` gira in mock (mantiene l'immagine grezza) finché non c'è `PHOTOROOM_API_KEY`; manca lo scontorno/WebP reale e il wiring Secret Manager.
> 2. **LLM reale (4.3) NON integrato.** `generateProductTexts` produce testi **mock deterministici** finché non c'è `OPENAI_API_KEY`; manca la chiamata all'endpoint EU con prompt a gabbia/grounding reale.
> 3. **App Check** in enforcement sulle callable/trigger resta da attivare (§8.4).

### Step 4.1 — UI "Aggiungi Prodotto" ⭐ · M ✅
- **Attività:**
  - [x] Form admin: foto + descrizione minima + prezzo iniziale + scontato → crea documento **`draft`** + upload immagine in Storage.
- **✓ Fatto quando:** il draft compare con immagine caricata. · **Rif.** §10 · **Dipende da:** 1.3
  - **Fatto:** `ProductFormScreen` (rotta `/admin/products/new`) con `image_picker` (fotocamera solo mobile, galleria/file altrove — guardia `PlatformSupport`), campi base (nome IT/EN, tipo, categoria, prezzi, IVA). `AdminProductRepository.createDraft` crea un `draft` nascosto; `uploadRawImage` carica in `products/{id}/raw_*` (Storage rules staff-only) e segna `aiImage.status='pending'`.

### Step 4.2 — Pipeline Vision (backend) ⭐ · M 🟡 (mock; Photoroom reale → ADR 0004)
- **Attività:**
  - [x] Cloud Function (trigger su draft) con orchestrazione loop-safe; scontorno **Photoroom** → sfondo bianco → **WebP** dietro `PHOTOROOM_API_KEY` (mock senza chiave).
- **✓ Fatto quando:** dall'immagine grezza si ottiene la WebP ottimizzata. · **Rif.** §10, §11.5 · **Dipende da:** 4.1
  - **Fatto (MVP):** `processProductImage` (`onDocumentWritten products/{id}`) agisce su `aiImage.status=='pending'`, loop-safe; in mock marca `done` mantenendo l'immagine grezza. **Integrazione Photoroom reale + Secret Manager: ADR 0004.**

### Step 4.3 — Pipeline Testi LLM (backend) ⭐ · L 🟡 (mock; LLM reale → ADR 0004)
- **Attività:**
  - [x] Generazione **IT+EN** di titolo SEO, descrizione, principio attivo, posologia, controindicazioni (callable staff-only).
  - [x] **Guardrail** anti prompt-injection (sanitizzazione seed) + **log provenienza** (`aiTextProvenance`); grounding su fonti validate dietro chiave LLM.
- **✓ Fatto quando:** il draft si popola di testi bilingui tracciati. · **Rif.** §10, §11.2/11.5 · **Dipende da:** 4.1
  - **Fatto (MVP):** `generateProductTexts` (callable, verifica claim `role`) scrive i testi IT+EN **per la revisione** (mai pubblica), con `aiTextProvenance` (mode/guardrails/sourceNote/timestamp). Con `OPENAI_API_KEY` userebbe l'endpoint OpenAI-compatibile EU; senza, mock deterministico. **LLM reale: ADR 0004.**

### Step 4.4 — Validazione umana & pubblicazione ⭐ · M ✅
- **Attività:**
  - [x] Anteprima scheda; **revisione farmacista** (posologia/controindicazioni IT+EN); pulsante **Pubblica** → `published`.
  - [x] Nessuna pubblicazione automatica; registrazione di chi approva.
- **✓ Fatto quando:** il prodotto è visibile ai clienti **solo dopo** "Pubblica". · **Rif.** §10 · **Dipende da:** 4.2, 4.3
  - **Fatto:** editor bilingue (IT/EN) di tutti i campi + badge AI + nota di revisione; **Pubblica** registra `reviewedBy`/`reviewedAt`/`publishedAt` e **blocca** i medicinali senza posologia+controindicazioni IT+EN (`meetsMedicinePublishingRule`). Nessun percorso di pubblicazione automatica.

### Step 4.5 — Gestione catalogo admin ⭐ · M ✅
- **Attività:**
  - [x] Modifica prodotto, gestione **stock**, disattivazione/archiviazione.
- **✓ Fatto quando:** l'admin gestisce ciclo di vita e giacenze. · **Rif.** §5, §13 · **Dipende da:** 4.4
  - **Fatto:** `AdminCatalogScreen` (`/admin/catalog`) elenca **tutti gli stati** raggruppati; il form gestisce giacenza, `available`, `Pubblica`/`Riporta in bozza`/`Archivia`. `adminProductsProvider` legge tutti gli stati (staff). **5 test** (`test/admin_product_repository_test.dart`).

> **Fase 4 — step 4.1, 4.4, 4.5 completati; 4.2/4.3 in mock.** Verifiche: `flutter analyze` pulito, **61 test** app verdi (+5 da Fase 3), functions `build`+`lint` ok, `flutter build web` ok. *(Restano: Photoroom reale, LLM reale, App Check enforcement — ADR 0004.)*

---

## FASE 4B — Assistente AI Cliente (chat sintomi→prodotti)

> La seconda killer feature (§12): il cliente descrive un disturbo lieve e la chat propone **solo prodotti del catalogo pubblicato**, con guardrail clinici e escalation al farmacista. Perimetro vincolante: **orientamento all'acquisto, mai diagnosi** (§12.1).

### Step 4B.1 — Scelta modello LLM & proxy (spike) ⭐ · M
- **Obiettivo:** modello open-source scelto su prove, non su brochure.
- **Attività:**
  - [x] **Golden set** — base tecnica di ~45 conversazioni IT/EN (`firebase/functions/test-assets/golden_set.json`: sintomi lievi, red-flag, Rx, ambiguità, injection, moderazione). **⚠ Aperto:** estensione a 50–100 casi **scritti/validati col farmacista**.
  - [ ] Test comparativo dei candidati (§12.2) su provider **EU** — **⚠ Aperto** (serve una chiave provider); l'harness è pronto: `npm run eval:assistant` misura pass-rate per categoria e latenza p50/p95; per confrontare un candidato basta configurarlo in `functions/.env` e rieseguire.
  - [x] Proxy Cloud Function **OpenAI-compatibile** (`functions/src/ai/llm_client.ts`): `LLM_BASE_URL`+`LLM_MODEL`+`LLM_API_KEY` da config/Secret Manager → modello **swappabile**; mock deterministico senza chiave. *(Streaming SSE rimandato con motivazione: la risposta è JSON strutturato con `productRef` verificati — v. ADR 0005.)*
  - [x] Decisione registrata: **ADR 0005** (stato Proposta — architettura decisa; l'esito della selezione empirica va registrato lì per passare ad "Accettata").
- **✓ Fatto quando:** un modello è scelto sul golden set e risponde via proxy dagli emulatori. **Stato: proxy+harness fatti; selezione del modello aperta.** · **Rif.** §12.2, §11.5 · **Dipende da:** 0.2

### Step 4B.2 — Embeddings & indice vettoriale ⭐ · M ✅
- **Attività:**
  - [x] Embedding **multilingue** generato **alla pubblicazione**: trigger `syncProductEmbedding` (`functions/src/ai/product_embeddings.ts`), loop-safe via hash del testo; endpoint `/embeddings` OpenAI-compatibile (es. `bge-m3`), mock bag-of-words deterministico senza chiave.
  - [x] Indice: **deciso Firestore Vector Search** (nessun componente nuovo; la fuzzy resta client-side) — **ADR 0002 esteso con addendum** come richiesto. Indice vettoriale composito (COSINE, dim 1024) in `firestore.indexes.json`.
  - [x] Query top-k (`functions/src/ai/retrieval.ts`) con filtri rigidi `status==published · available==true · assistantEligible==true`; fallback in-memory per emulatore/mock.
- **✓ Fatto quando:** "mal di testa" restituisce i prodotti pertinenti del catalogo di prova. **Verificato sull'emulatore (caso lieve-01 del golden set).** · **Rif.** §12.3 · **Dipende da:** 2.4, 4.4

### Step 4B.3 — Cloud Function `assistantChat` + guardrail ⭐ · L ✅
- **Attività:**
  - [x] **Router pre-LLM** (`functions/src/ai/assistant_chat.ts` + porting server del fuzzy in `ai/fuzzy.ts`, stessa semantica del Dart): match forte (≥0,8) su nome/SKU/EAN senza contenuto sintomatico → card dirette, zero token, zero dati sanitari; gira **prima** del gate consenso (la ricerca per nome non è mai ostaggio del consenso).
  - [x] Pipeline completa (§12.3): moderazione input (blocklist deterministica; *hook Llama Guard 3/filtri provider quando il provider sarà configurato*) → **triage red-flag deterministico** (default integrati + lista curata dal farmacista in `config/assistant`, scatta prima dell'LLM) → rifiuto richieste Rx → retrieval → prompt "a gabbia" (solo prodotti forniti, no Rx, no dosaggi fuori scheda, IT/EN) → **output JSON** con `productRef` **verificati contro il catalogo** → moderazione output → log sessione con provenienza (modello + endpoint host).
  - [x] Rate-limit per uid (40 msg/giorno, 30 turni/sessione, override in `config/assistant`), troncamento contesto a 6 battute. **⚠ App Check non applicato** (coerente col resto del backend e con la superficie Windows §4.4 che non ha provider App Check) — da rivedere al gate 4B.8.
  - [x] **Fallback**: LLM giù/timeout → messaggio cortese + risultati fuzzy + invito al farmacista (mode `fallback`) — la chat degrada, non blocca.
  - [x] Collezioni `chatSessions`/`messages`: scrittura **solo via function** (rules: owner/staff in lettura, client-write negato — 3 nuovi test rules verdi); indici compositi per registro/filtri.
- **✓ Fatto quando:** sintomo lieve → 3–5 card prodotto reali; red-flag → zero prodotti e rinvio al medico; injection dal golden set respinte. **Verificato: eval 44/44, categorie gate al 100% (mock), p50 91 ms.** · **Rif.** §12.3–12.4, §5.5 · **Dipende da:** 4B.1, 4B.2

### Step 4B.4 — Consenso art. 9 & GDPR chat ⭐ · M ✅ *(resta la validazione legale)*
- **Attività:**
  - [x] **Consenso esplicito** pre-chat: onboarding first-run (cosa fa/cosa non fa + testo consenso art. 9) in `assistant_onboarding.dart`; account → `users.consents.aiAssistant` (via `updateConsents`, non richiesto di nuovo); guest → **consenso di sessione** in memoria, inviato per-richiesta; il server rifiuta senza consenso (`consent-required`). **⚠ Aperto:** informativa privacy dedicata pubblicata (legale).
  - [x] **Retention breve**: `purgeAt` = ultimo messaggio + 90 gg; job schedulato `purgeChatSessions` (03:30 Europe/Rome, `recursiveDelete`); registro admin **pseudonimizzato** (codice breve, mai identità); nessun riuso marketing.
  - [x] **Data residency EU**: host dell'endpoint registrato in `chatSessions.provenance.endpointHost` (auditabile); **DPIA** in bozza tecnica: `docs/compliance/dpia-assistente-ai.md` — **⚠ da completare col DPO/legale** (sezioni ☐).
- **✓ Fatto quando:** senza consenso la chat non parte; il job di purge cancella le sessioni scadute. **Implementato e testato (rules + eval).** · **Rif.** §12.5 · **Dipende da:** 1.4, 4B.3

### Step 4B.5 — UI Web: widget flottante + pannello 70/30 ⭐ · M ✅ *(lato PWA; componente SSR rimandato)*
- **Attività:**
  - [x] **Widget flottante in basso al centro** su Home e Catalogo (≥1024 px): `AssistantPill` (ARB IT/EN "Sono il tuo assistente AI…"), bianco con bordo/icona verde azione, ombra §7.2.4; renderizzato dall'`AdaptiveScaffold` (`showAssistantPill`) e nascosto a pannello aperto.
  - [x] Click → animazione **280 ms** (`durationStandard`, curva emphasized): contenuto al **70%** a sinistra, **pannello 30%** a destra (min 360 px) in `AssistantSidePanel`: header + badge AI + ✕, cronologia, disclaimer fisso, card prodotto→scheda/carrello, input. Griglie che ricalcolano (maxCrossAxisExtent), nessuno scroll orizzontale.
  - [x] **Il campo di ricerca apre la stessa chat**: su desktop `AssistantSearchBar` apre il pannello 70/30 invece di navigare. *(Nota: la barra è un'affordance tap-only, non un campo editabile — non c'è testo da travasare; l'input del pannello riceve l'autofocus.)*
  - [x] ✕/**ESC** (CallbackShortcuts) → ritorno al 100%; conversazione preservata (stato app-level, `chatControllerProvider`); **badge non letti** sulla pill (`assistantPanelProvider`).
  - [x] A11y: `FocusScope` con autofocus (focus trap), `disableAnimations` → switch istantaneo, semantics sulla pill; pannello **solido** (niente vetro dietro prezzi/testi critici, §7.2.3).
  - [ ] **Componente web leggero per le pagine SSR** (§6.2) — **⚠ rimandato**: dipende dallo scaffolding dello storefront (gate 2.7, ADR 0001, ancora aperto). Il contratto è già pronto: stesso endpoint `assistantChat` (callable), stesse degradazioni.
- **✓ Fatto quando:** su desktop l'animazione 70/30 apre/chiude la chat da Home e Catalogo (SSR e PWA) senza rompere il layout. **Fatto nella PWA; SSR segue lo storefront.** · **Rif.** §12.6 · **Dipende da:** 4B.3, 2.2

### Step 4B.6 — UI Mobile: pagina Chat AI (tab + ingresso ricerca) ⭐ · M ✅
- **Attività:**
  - [x] **Nessun widget flottante su mobile**: la pill compare solo su `expanded`; su compact resta la voce **centrale** della bottom nav (già da Fase 2).
  - [x] Chat in **pagina separata a schermo intero** (`/assistant`, `AssistantScreen` riscritta): stesso componente conversazione del pannello (`AssistantConversationView`) + **chip rapidi** ("Mal di testa", "Raffreddore", "Consiglio pelle", "Parla col farmacista"); badge AI in appbar + azione "nuova conversazione"; escalation al farmacista via `assistantEscalate`.
  - [x] **Ricerca → chat:** il tap sul campo/lente di Home/Negozio naviga a `/assistant` con input in autofocus; placeholder ARB IT/EN invariato.
  - [x] **Onboarding first-run** con consenso (4B.4); se rifiutato → **modalità "solo risultati"** (fuzzy locale, banner con CTA "Attiva") — stessa modalità per offline (`isOnlineProvider`), backend giù e flag OFF (`assistantUiStateProvider` risolve la degradazione in quest'ordine: flag → rete → backend → consenso).
- **✓ Fatto quando:** da mobile sia la tab sia il campo di ricerca aprono la pagina chat; il flusso sintomo→card→carrello funziona; con consenso rifiutato o offline "okitask" restituisce comunque le card giuste. **Implementato; `flutter analyze` pulito, 65 test verdi.** · **Rif.** §12.6, §7.3, §12.3 · **Dipende da:** 4B.3, 4B.4

### Step 4B.6b — Scambio ricerca classica → conversazionale (feature flag) ⭐ · S ✅ *(flag implementato, resta OFF fino al gate)*
- **Obiettivo:** ritirare la barra classica dello step 2.4 e promuovere la chat a **unico ingresso della ricerca**, senza rilascio "big bang".
- **Attività:**
  - [x] **Feature flag** `config/app.assistantChatEnabled` (default **OFF**): OFF = `/assistant` in modalità "solo risultati" (fuzzy, com'è oggi) e il backend rifiuta le chiamate chat; ON = campo/lente → conversazione (4B.5 web, 4B.6 mobile). Doppio enforcement client (`assistantChatFlagProvider`) **e** server. **Lo staff vede sempre la chat** (per il red-team 4B.8). Il flag si accende **solo dopo il gate 4B.8**.
  - [x] La UI di ricerca classica inline era già stata ritirata (nota ⚠ step 2.4); il motore fuzzy resta come router pre-LLM (server, `ai/fuzzy.ts`), modalità "solo risultati" (client) e ricerche admin — ADR 0002.
  - [x] Verificato: categorie/filtri del Negozio (2.2) coprono la navigazione senza barra; lo scanner (2.5, `/scan`) resta raggiungibile; nessun flusso del catalogo modificato (65 test verdi).
- **✓ Fatto quando:** con flag ON tutti gli ingressi di ricerca portano alla conversazione, la modalità "solo risultati" copre consenso rifiutato/offline, e nessun flusso del catalogo è regredito. **Pronto: l'accensione del flag è l'ultimo atto post-4B.8.** · **Rif.** §12.6, §13.1 · **Dipende da:** 4B.5, 4B.6, **4B.8 (gate)**

### Step 4B.7 — Supervisione farmacista (audit & escalation) ⭐ · M ✅
- **Attività:**
  - [x] Dashboard admin `/admin/assistant`: **registro conversazioni** pseudonimizzato con filtri (tutte / red-flag / segnalate / escalation da gestire); dettaglio sessione con transcript e azione **"risposta scorretta"** + nota di revisione (alimenta la revisione prompt/red-flag). Tutte le modifiche passano dalla callable `assistantReview` (whitelist di campi: il registro resta un audit log — anche per lo staff).
  - [x] **Inbox escalation**: filtro dedicato + "escalation gestita"; il cliente escala col pulsante "Parla con il farmacista" (callable `assistantEscalate`). *(Aggancio a consulenza §13.3/WhatsApp: Fase 5.)* Report giornaliero `assistantReports/{data}` (job `assistantDailyReport`) con warning su volumi anomali.
  - [x] Gestione liste **red-flag/Rx** su `config/assistant` (`/admin/assistant/guardrails`): i termini si aggiungono senza deploy e si sommano ai default integrati; toggle **`assistantEligible`** nel form prodotto.
- **✓ Fatto quando:** il farmacista vede le conversazioni, riceve le escalation e modifica la lista red-flag senza deploy. **Implementato (rules staff-read testate).** · **Rif.** §12.4 · **Dipende da:** 4B.3, 1.3

### Step 4B.8 — Red-team clinico & gate legale (gate critico) ⭐ · M ⚠ **GATE ANCORA APERTO**
- **Attività:**
  - [x] **Batteria automatizzata** (`npm run eval:assistant`): emergenze, pediatria, gravidanza, autolesionismo, avvelenamento, richieste Rx, prompt injection, moderazione — **oggi al 100%** sulle categorie gate (in modalità mock; lo script esce con errore se anche un solo caso fallisce). **⚠ Aperto:** riesecuzione col **modello reale** configurato + red-team clinico **manuale col farmacista** (verbale).
  - [ ] Verifica del **perimetro non-diagnostico** (§12.1) e parere legale **AI Act/MDR/GDPR** — **⚠ attività umana/legale**; la trasparenza AI (badge + disclaimer fisso + benvenuto) è già implementata; la DPIA in bozza (`docs/compliance/dpia-assistente-ai.md`) elenca i punti ☐ per il legale. Rivalutare qui anche l'**App Check** sulla callable.
  - [x] Monitoraggio post-lancio: `assistantDailyReport` (giornaliero) conta sessioni/red-flag/segnalate/escalation, scrive `assistantReports/` e **logga un warning** su volumi anomali (aggancio per alert Cloud Monitoring).
- **✓ Fatto quando:** il red-team passa al 100% sui red-flag e il legale approva il perimetro. **Senza questo step la chat resta disattivata** (feature flag OFF — già così di default). · **Rif.** §12.4–12.5 · **Dipende da:** 4B.3–4B.7

---

## FASE 5 — Personalizzazione Baganza: Servizi, Multi-sede, Prenotazioni

### Step 5.1 — Multi-sede & selettore ⭐ · M
- **Attività:**
  - [x] Modello `locations` (3 farmacie: indirizzi, orari, geo, `isCupPoint`).
  - [x] **Selettore di sede** con orari, "apri in mappa", "chiama", WhatsApp.
- **✓ Fatto quando:** l'utente sceglie la sede e ne vede contatti/orari. · **Rif.** §16.1, §16.5, §16.7 · **Dipende da:** 1.1

### Step 5.2 — Modulo Servizi ⭐ · M
- **Attività:**
  - [x] Modello `services`; schede con **prezzo**, **sede/i**, **preparazione**, tipo (`free_access`/`appointment`/`external_link`).
  - [x] Servizi di **Priorità 1** (autoanalisi, telemedicina ECG/Holter/dermatoscopia/MOC) + CUP.
- **✓ Fatto quando:** elenco servizi navigabile con dettagli corretti. · **Rif.** §16.4, §16.5 · **Dipende da:** 5.1

### Step 5.3 — Prenotazioni / appuntamenti ⭐ · L
- **Attività:**
  - [x] Modello `appointments`; richiesta **slot** per servizio/sede; gestione lato admin (conferma/annulla/completa).
  - [x] Notifica al personale; nessuna prenotazione che sottrae tempo al banco non gestita.
- **✓ Fatto quando:** un cliente richiede uno slot e l'admin lo conferma. · **Rif.** §16.4–16.5, §13.3 · **Dipende da:** 5.2

### Step 5.4 — Integrazione sistemi regionali ⭐ · S
- **Attività:**
  - [x] **Deep-link** a CUPWeb/ER Salute/FSE; schede informative su CUP e ritiro referti per sede.
  - [x] Nessuna promessa di prenotazione CUP "in-app" (sistemi statali con SPID).
- **✓ Fatto quando:** i link aprono correttamente i servizi regionali. · **Rif.** §16.6 · **Dipende da:** 5.2

### Step 5.5 — Navigazione aggiornata ⭐ · S
- **Attività:**
  - [x] Bottom nav definitiva: **Home · Negozio · Chat AI · Carrello · Profilo**; **"Servizi" = card hero della Home** (decisione §16.7, per non superare 5 voci).
  - [x] Su web desktop "Servizi" resta voce del menu orizzontale; la chat è il widget 70/30 (step 4B.5), non una voce di navigazione.
- **✓ Fatto quando:** "Servizi" è raggiungibile dalla Home/menu e la tab Chat AI è al suo posto su mobile. · **Rif.** §16.7, §12.6 · **Dipende da:** 5.2

> **Fase 5 completata.** Multi-sede, servizi (Priorità 1: autoanalisi ad accesso libero, telemedicina ECG/Holter/dermatoscopia/MOC su appuntamento, CUP via deep-link), prenotazioni cliente + coda di gestione admin, integrazione regionale (CUPWeb/ER Salute/FSE) e navigazione (Servizi = card hero della Home + selettore sede) implementati end-to-end su Firestore (rules + indici già presenti dalla Fase 1). Verifiche: `flutter analyze` pulito, **72 test** app verdi (+11), `flutter build web` ok. Aggiunta dipendenza `url_launcher` per tel/WhatsApp/mappe/portali. Seed esteso con orari sedi e catalogo servizi. *(Restano assunzioni §16.9: prezzi/orari/servizi da confermare con la farmacia; il menu orizzontale desktop resta il rail a 5 voci + card Servizi, non una barra separata.)*

---

## FASE 6 — Branding finale & Splash

### Step 6.1 — Vettorializzazione logo & icone ⭐ · M
- **Attività:**
  - [x] **Ricostruzione vettoriale (SVG)** dell'emblema con elementi su layer separati (anello, ali, serpenti, asta, "S", maschera, wordmark). *(Semplificata, autoriale — `assets/images/emblem.svg` + `emblem_mono.svg`; la versione premium fedele resta opzione da illustratore, nota §16.2.)*
  - [x] **App icon / favicon / maskable** PWA (192/512px) usando una **versione semplificata** (solo emblema). *(Pipeline `tool/branding/generate_icons.py` → web + `flutter_launcher_icons` per Android adaptive/iOS/Windows/macOS.)*
- **✓ Fatto quando:** icone nitide a tutte le misure; SVG pronto per l'animazione. · **Rif.** §16.2 (richiede asset esterno design)

### Step 6.2 — Splash nativo ⭐ · S
- **Attività:**
  - [x] `flutter_native_splash`: sfondo bianco + emblema; blocco **Android 12+** (1152px, cerchio 768px), storyboard iOS, tema web.
  - [x] Niente Activity di splash legacy; il passaggio su Android 12+ è invisibile perché nativo e reveal condividono bianco+emblema (`preserve()`/`remove()`).
- **✓ Fatto quando:** nessun "doppio splash"; avvio pulito su Android/iOS/web. · **Rif.** §16.3 · **Dipende da:** 6.1

### Step 6.3 — Reveal animato ⭐ · M
- **Attività:**
  - [x] **Strada B** (raster ufficiale + anello vettoriale disegnato via `CustomPainter`): coreografia (anello che si disegna → emblema fade+scale → wordmark → shimmer), **~1,75 s, non in loop**; rispetta `disableAnimations`.
  - [x] **Hand-off** alla Home appena pronti init Firebase + primi dati (Firebase inizializza prima di `runApp`; l'overlay sfuma e si rimuove).
- **✓ Fatto quando:** lo splash animato gira fluido e cede il passo senza ritardi. · **Rif.** §16.3 · **Dipende da:** 6.2

> **Fase 6 completata.** Emblema vettoriale semplificato a layer (`emblem.svg`, + mono per fondi scuri) con pipeline icone rigenerabile (`tool/branding/generate_icons.py` → favicon, PWA 192/512 + maskable con safe-zone, master per `flutter_launcher_icons`: Android adaptive, iOS, Windows, macOS); splash nativo `flutter_native_splash` (bianco+emblema, Android 12+, iOS, web) e reveal in-app `SplashReveal` (~1,75 s, una sola volta per avvio, reduce-motion ok) con hand-off senza doppio splash. Verifiche: `flutter analyze` pulito, **75 test** app verdi (+3), `flutter build web` ok. *(Resta opzionale da designer: ricostruzione vettoriale "premium" fedele al raster AI e Strada A/Rive, §16.2–16.3.)*

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
- [ ] Hosting **Firebase/Vercel** (SSR per le pagine pubbliche, secondo l'ADR di 2.7); `manifest.json` (icone, `theme_color`), service worker `offline-first`; build store Android/iOS.
- [ ] *(Opzionale, post-MVP)* pacchetto **MSIX** dell'app Windows per il farmacista (il portale web desktop copre già lo stesso ruolo dal giorno 1, §4.4). · **Rif.** §6.4, §13.4

### Step 8.6 — Gate di lancio (compliance) ⭐ · M
- [ ] **Autorizzazione Ministero** + **logo** prima della vendita medicinali; consensi e **pulsante recesso** attivi; verifica **Criteri di Accettazione** (§15). · **Rif.** §15, §16.8, Parte 2 §5 · **Dipende da:** 8.1–8.5

---

## Milestone

| Milestone | Contenuto | Step |
|---|---|---|
| **M1 — Fondamenta** | Setup, dati, auth, compliance scaffolding | Fase 0–1 |
| **M2 — Catalogo navigabile + SEO** | Negozio adattivo (mobile/desktop/Windows), ricerca, scanner, offline, pagine **trovabili su Google** (SSR) | Fase 2 |
| **M3 — Vendita** | Carrello, checkout, pagamenti, ordini | Fase 3 |
| **M4 — Admin AI** | Pipeline AI + validazione + gestione catalogo | Fase 4 |
| **M4B — Chat AI cliente** | LLM open EU + RAG catalogo + guardrail + UI web 70/30 e pagina mobile + audit farmacista + **scambio ricerca→conversazione** (4B.6b, post-gate) — *implementata end-to-end (mock); restano selezione modello (4B.1), componente SSR (post-2.7) e il **gate 4B.8** (red-team clinico + legale) prima di accendere il flag* | Fase 4B |
| **M5 — Baganza** | Multi-sede, servizi, prenotazioni, CUP — *implementata end-to-end (Fase 5 completata)* | Fase 5 |
| **M6 — Brand & Splash** | Logo vettoriale, icone, splash animato — *implementata (Fase 6 completata; resta opzionale il vettoriale "premium" da illustratore)* | Fase 6 |
| **⭐ MVP (v1)** | M1→M6 (incl. M4B) + Fase 8 (lancio) | tutti gli step ⭐ |
| **v1.1+** | Engagement | Fase 7 |

---

## Ordine consigliato & parallelizzazioni
- **Sequenza portante:** 0 → 1 → 2 → 3 → 8 (lancio).
- **In parallelo** (dopo la Fase 1):
  - lo **step 1.5 (login Google/SSO)** è piccolo e indipendente: si può fare in qualunque momento, non blocca nulla;
  - lo **step 2.8** (verifica desktop/Windows) si fa a valle di 2.2–2.3, prima di iniziare la Fase 4 (che è desktop-first);
  - un profilo **backend** può lavorare alla **Fase 4 (Admin AI)** mentre il frontend fa la **Fase 2**;
  - lo **spike 4B.1** (scelta LLM) non ha dipendenze di prodotto: può partire subito dopo la Fase 0; il resto della **Fase 4B** richiede catalogo e ricerca (2.4) e può procedere in parallelo alle Fasi 3 e 5;
  - la **Fase 5 (Baganza/servizi)** è abbastanza indipendente e può procedere in parallelo alla 3;
  - la **Fase 6 (branding/splash)** dipende dall'asset vettoriale del logo (design): avviarla appena pronto, senza bloccare le altre.
- **Non saltare i tre gate:** SEO reale (2.7) prima del marketing; autorizzazione + logo (8.6) prima di vendere medicinali; **red-team + gate legale (4B.8) prima di esporre la Chat AI**.

---

> Riferimenti: **Documento Tecnico — Parte 1** (architettura, dati, AI, §16 Baganza) e **Documento Business/Operativo — Parte 2** (mercato, CRO, pagamenti, fidelizzazione, logistica, compliance legale, KPI, roadmap, fonti).
