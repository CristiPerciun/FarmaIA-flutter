# DPIA — Assistente AI cliente (bozza tecnica, step 4B.4)

> **Stato: BOZZA.** Questo documento raccoglie i fatti tecnici già
> implementati e le decisioni di design; va completato e validato con il
> DPO/legale **prima del lancio pubblico** (gate 4B.8). Le sezioni marcate
> ☐ richiedono input non tecnico.

- **Data:** 2026-07-05
- **Trattamento:** chat conversazionale "assistente all'acquisto" (§12 del
  Documento Tecnico) — l'utente descrive un bisogno/disturbo lieve e riceve
  prodotti da banco dal catalogo pubblicato.
- **Titolare:** Farmacia Baganza (Parma) ☐ *(dati societari da completare)*
- **Base giuridica:** consenso esplicito art. 9(2)(a) GDPR per i dati
  sanitari digitati in chat.

## 1. Natura del trattamento (implementato)

| Aspetto | Implementazione |
|---|---|
| Dati trattati | Testo libero della chat (può contenere dati sulla salute), locale, superficie (mobile/desktop), riferimenti prodotto suggeriti |
| Consenso | `users.consents.aiAssistant` (account) o consenso **di sessione** per ospiti; raccolto da onboarding dedicato PRIMA del primo messaggio; revocabile dal profilo. Senza consenso la ricerca resta in modalità "solo risultati" (fuzzy locale, nessun invio all'LLM) |
| Query di catalogo | Router pre-LLM: nomi prodotto/EAN rispondono senza LLM — **nessun dato sanitario trattato** e nessuna persistenza senza consenso |
| Minimizzazione | Contesto troncato alle ultime 6 battute; messaggi max 500 caratteri; rate-limit per utente (40/giorno, 30/sessione) |
| Conservazione | `purgeAt` = ultimo messaggio + **90 giorni**; job giornaliero `purgeChatSessions` (03:30 Europe/Rome) cancella sessioni e messaggi |
| Pseudonimizzazione | Il registro admin mostra un codice breve, non l'identità; scritture solo via Cloud Functions (audit log); accesso staff con ruolo verificato |
| Residenza EU | Provider di inference OpenAI-compatibile con data residency EU (ADR 0005); l'host dell'endpoint è registrato in `provenance.endpointHost` per ogni sessione — verificabile a posteriori |
| Sicurezza | Regole Firestore deny-by-default; chiavi solo server-side (Secret Manager/.env, §11.5); niente riuso marketing/profilazione dei contenuti chat |
| Supervisione umana | Dashboard farmacista: registro, filtri red-flag/segnalate, inbox escalation, liste red-flag curabili senza deploy |

## 2. Necessità e proporzionalità

- Perimetro **non diagnostico** (§12.1): orientamento all'acquisto; i casi
  seri sono intercettati da triage deterministico PRIMA del modello e
  rinviati a medico/112/farmacista.
- Alternative considerate: ricerca classica senza AI (resta disponibile come
  degradazione permanente); BYOK lato client (scartato, §11).

## 3. Rischi e misure

| Rischio | Misura |
|---|---|
| Risposta clinicamente scorretta | Prompt a gabbia + product-ref verificati + red-team gate 4B.8 + pulsante "risposta scorretta" che alimenta la revisione |
| Trattamento oltre finalità | Finalità limitata nel consenso; niente marketing sui contenuti; retention 90 gg |
| Accesso non autorizzato | Rules function-only sulle sessioni; staff via claim ruolo; report solo staff |
| Trasferimento extra-UE | Solo endpoint EU (config controllata; host loggato); API DeepSeek ufficiale esclusa (provv. Garante 33/2025) |
| Uso da parte di minori/soggetti fragili | Red-flag pediatrici/gravidanza/allattamento → stop prodotti + rinvio |

## 4. Da completare prima del lancio (☐)

- ☐ Parere legale su perimetro AI Act (trasparenza art. 50 — badge e
  benvenuto già implementati) e non-qualificazione MDR.
- ☐ Informativa privacy dedicata pubblicata e linkata dall'onboarding.
- ☐ Nomina/verifica del sub-responsabile (provider di inference) e DPA.
- ☐ Registro dei trattamenti aggiornato; consultazione DPO.
- ☐ Esecuzione red-team clinico col farmacista (gate 4B.8) e verbale.
