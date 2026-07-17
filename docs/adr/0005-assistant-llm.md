# ADR 0005 — LLM e proxy dell'assistente cliente (step 4B.1)

- **Stato:** Proposta (architettura decisa e implementata; **modello finale da
  selezionare sul golden set validato dal farmacista**)
- **Data:** 2026-07-05
- **Contesto:** §12.2–12.3 (Documento Tecnico), step 4B.1 di `Per step.md`

## Problema

La chat cliente (§12) richiede un LLM open-source servito con **data residency
EU** (art. 9 GDPR — il Garante ha escluso l'API ufficiale DeepSeek, provv.
33/2025), buon **italiano**, instruction following e output strutturato. La
conoscenza clinica pesa meno: la verità arriva dal RAG sul catalogo validato.

## Decisione (architettura)

1. **Proxy OpenAI-compatibile** in Cloud Functions
   (`functions/src/ai/llm_client.ts`): `LLM_BASE_URL` + `LLM_MODEL` +
   `LLM_API_KEY` in config/Secret Manager → **modello swappabile via config,
   zero refactoring**. Tutti i provider candidati espongono questo formato.
2. **Candidati** (da §12.2): **Qwen 3 32B / 30B-A3B** (primario atteso) e
   **Mistral Small 3.x** (percorso GDPR più semplice: La Plateforme EU), su
   provider EU (Scaleway Generative APIs / OVHcloud AI Endpoints);
   **DeepSeek V3.x solo open-weights su hosting EU** come alternativa
   frontier. OpenBioLLM scartato (solo EN, §12.2).
3. **Modalità mock deterministica** senza chiave (convenzione del repo): tutta
   la pipeline (router → triage → retrieval → risposta → log) gira negli
   emulatori senza provider esterno; il red-team harness è già eseguibile.
4. **Niente streaming SSE in v1** *(divergenza motivata dal piano)*: la
   risposta è un **JSON strutturato** con `productRef` verificati contro il
   catalogo (§12.3 passo 6) — lo streaming di un JSON parziale non è
   renderizzabile in card e complica la validazione. Con risposte brevi
   (max ~120 parole) la latenza percepita è gestita dal typing indicator.
   Riaperto se il golden set mostrasse latenze inaccettabili.

## Selezione empirica (da completare — attività aperta di 4B.1)

- Il **golden set** iniziale (~45 casi tecnici, `functions/test-assets/
  golden_set.json`) va **esteso e validato col farmacista** fino a 50–100
  conversazioni.
- Harness: `npm run eval:assistant` (emulatori) — misura pass-rate per
  categoria (red-flag/rx/injection = gate al 100%) e latenza p50/p95.
- Procedura di confronto: configurare un candidato in `functions/.env`,
  rieseguire l'harness, confrontare qualità dell'italiano (giudizio del
  farmacista sui transcript), rifiuti corretti, aderenza al catalogo, latenza
  e costo. **Registrare qui l'esito e passare lo stato ad "Accettata".**

## Addendum 2026-07-06 — prima run empirica (Scaleway)

Account **Scaleway Generative APIs** attivo (endpoint di progetto
`api.scaleway.ai/<project-id>/v1`). Il listino attuale ha cambiato i candidati
disponibili:

- **Qwen 3 32B non è più a listino** → i candidati Qwen reali sono
  `qwen3.6-35b-a3b` e `qwen3-235b-a22b-instruct-2507`.
- **`bge-m3` non è più a listino** → embeddings su **`qwen3-embedding-8b`**
  (Matryoshka) **troncato a 1024 dimensioni** via parametro `dimensions`
  (supporto aggiunto a `embeddings.ts`, `EMBEDDING_DIMENSIONS=1024`), così
  l'indice vettoriale Firestore (dim 1024, limite hard 2048) resta invariato.

Prima run del golden set (44 casi) con
**`mistral-small-3.2-24b-instruct-2506`** + embeddings reali sugli emulatori:
**44/44**, categorie gate 100%, latenza p50=97ms / p95≈1,7s (il p95 sono i
turni che raggiungono l'LLM; i p50 sono router/guardrail deterministici).
JSON sempre valido con `response_format: json_object`.

Nota operativa: dopo il seed servono ~45s perché i trigger di embedding
completino prima di lanciare l'harness (altrimenti il retrieval vede un
catalogo parziale).

**Comportamento fail-safe verificato** (osservato durante un'interruzione di
connettività verso il provider): quando l'endpoint di inference è
irraggiungibile, le chiamate LLM degradano a `mode:"fallback"` e le categorie
gate deterministiche restano verdi (red_flag 15/15, rx 5/5, moderazione 3/3) —
nessun consiglio clinico viene emesso senza LLM. Le categorie che richiedono
l'LLM (sintomi lievi, ambigue) semplicemente non producono suggerimenti in
quello stato, come atteso: il sistema non "inventa" mai risposte offline.

**La selezione resta aperta**: confronto con i candidati Qwen
(`qwen3.6-35b-a3b`, `qwen3-235b-a22b-instruct-2507`, entrambi tuttora a
listino) e giudizio del farmacista sui transcript ancora da fare.

## Conseguenze

- Il costo del modello è trascurabile ai volumi di una farmacia (€/mese a una
  cifra, §12.2); nessun lock-in.
- L'endpoint host è loggato in `chatSessions.provenance.endpointHost` per
  l'audit di residenza EU (step 4B.4).
