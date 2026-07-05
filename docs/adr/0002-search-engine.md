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
