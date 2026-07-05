# ADR 0002 — Motore di ricerca catalogo (step 2.4)

- **Stato:** Accettata (MVP)
- **Data:** 2026-07-05
- **Contesto:** §13.1, step 2.4 di `Per step.md`

## Problema

La ricerca deve tollerare i refusi (✓ "okitask" trova "Oki Task"). Le opzioni
del doc sono Algolia, Typesense (self-hosted) o l'estensione Firebase.

## Decisione

Per l'MVP: **ricerca fuzzy client-side** (`app/lib/core/utils/fuzzy.dart`) sul
catalogo pubblicato già caricato in memoria.

**Perché:**

- Costo zero e nessuna infrastruttura aggiuntiva da gestire ora.
- Funziona **offline** (§9.1), coerente con lo step 2.6.
- Adeguata a un catalogo piccolo/medio di farmacia.
- La normalizzazione (rimozione diacritici/spazi + Levenshtein) soddisfa il
  criterio "okitask → Oki Task".

## Migrazione futura

Quando il catalogo cresce o serve il vettoriale per la chat AI (§12.3),
migrare a **Typesense** (copre fuzzy **e** vettoriale, §4B.2) con una Cloud
Function `products/onWrite → sync` che indicizza solo i prodotti `published`.
Il contratto pubblico lato app (`Fuzzy.fuzzyScore` / `filteredProductsProvider`)
resta stabile: cambia solo la sorgente dei risultati.

## Addendum 2026-07-05 — indice vettoriale per la chat (step 4B.2)

Lo step 4B.2 richiedeva di decidere qui tra Firestore Vector Search e
Typesense ibrido. **Decisione: Firestore Vector Search** (nessun componente
nuovo); la fuzzy **resta client-side** come da MVP.

- **Perché:** a questo volume di catalogo Typesense aggiungerebbe un servizio
  da gestire solo per unificare due ricerche che funzionano già; Firestore
  Vector Search riusa il database esistente e il trigger di pubblicazione.
- **Implementato:** trigger `syncProductEmbedding`
  (`functions/src/ai/product_embeddings.ts`) — embedding multilingue della
  scheda validata alla pubblicazione (provider OpenAI-compatibile, es.
  `bge-m3`; mock deterministico senza chiave); retrieval top-k
  (`functions/src/ai/retrieval.ts`) con filtri rigidi
  `status==published · available==true · assistantEligible==true`, indice
  vettoriale composito in `firestore.indexes.json` (dimensione 1024, COSINE)
  e fallback in-memory per emulatore/mock.
- **Il porting server del fuzzy** (`functions/src/ai/fuzzy.ts`) serve il
  router pre-LLM (§12.6) e mantiene la stessa semantica del Dart
  (`okitask → Oki Task`): tenere i due file allineati.
- La migrazione a Typesense resta il percorso quando il catalogo crescerà:
  questo addendum non la esclude, la rimanda.
