# ADR 0004 — Pipeline Admin AI (Vision + Testi) — step 4.2–4.3

- **Stato:** Accettata (MVP con mock; provider reali da integrare)
- **Data:** 2026-07-05
- **Contesto:** §10, §11.2/11.5, step 4.2–4.3 di `Per step.md`

## Problema

Il data-entry assistito dall'AI (§10) richiede due servizi esterni:
- **Vision** (§4.2): scontorno immagine → sfondo bianco → WebP (Photoroom).
- **Testi LLM** (§4.3): generazione IT+EN di titolo SEO, descrizione, principio
  attivo, posologia, controindicazioni, con **grounding** su fonti validate e
  **guardrail** anti prompt-injection.

Entrambi richiedono chiavi/account non ancora disponibili; le chiavi non devono
mai stare nel client (§11.5).

## Decisione

Struttura server definitiva ora, provider esterni dietro un interruttore a
chiave, con **fallback mock** che rende l'intero flusso admin testabile:

- `processProductImage` (trigger Firestore su `products/{id}`): agisce quando
  `aiImage.status == 'pending'` e c'è `rawImagePath`; **loop-safe** (agisce solo
  su `pending`, poi flippa lo stato). Con `PHOTOROOM_API_KEY` esegue la
  pipeline reale; senza, mock (mantiene l'immagine grezza, `aiImage.mock=true`).
- `generateProductTexts` (callable, **staff-only** via claim `role`): genera i
  testi bilingui e li scrive **per la revisione del farmacista** (mai pubblica);
  registra la **provenienza** (`aiTextProvenance`: mode, guardrails, sourceNote,
  timestamp). Con `OPENAI_API_KEY` (endpoint OpenAI-compatibile, base URL +
  chiave in Secret Manager) userebbe un prompt "a gabbia" grounded su RCP/
  foglietto; senza, mock deterministico.

**Validazione umana (4.4).** Nessuna pubblicazione automatica: `publish`
registra approvatore/timestamp e la regola medicinali (`meetsMedicinePublishing
Rule`) blocca la pubblicazione se posologia/controindicazioni IT+EN mancano.

## Cosa manca (prima della produzione)

1. **Photoroom reale**: fetch bytes → API scontorno/bianco → conversione WebP →
   upload asset ottimizzato → swap `images[0].url`; chiave in Secret Manager.
2. **LLM reale**: chiamata all'endpoint OpenAI-compatibile EU (§12.2 usa gli
   stessi provider), parsing JSON strutturato, retry/timeout, moderazione
   output; chiave in Secret Manager.
3. **App Check** in enforcement sulle callable/trigger (§8.4).
4. Golden-set di verifica dei testi (qualità italiano, rifiuti, aderenza).

Finché 1–2 non sono integrati, `mode` resta `mock`; la UI e il ciclo
draft → genera → revisiona → pubblica sono però già quelli definitivi.
