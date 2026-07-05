# ADR 0001 — Piattaforma storefront SEO (step 2.7)

- **Stato:** Proposta (decisione registrata; gate **non** ancora chiuso)
- **Data:** 2026-07-05
- **Contesto:** §6.1–6.2 (Documento Tecnico), step 2.7 di `Per step.md`

## Problema

Flutter Web (CanvasKit) disegna su canvas WebGL: niente DOM testuale, quindi il
crawler di Google **non vede testo né link** (§6.1). Le pagine pubbliche
(catalogo, schede prodotto, blog, sedi/servizi) devono essere servite come
**HTML SSR/prerender** su un solo dominio, mentre la PWA Flutter resta per i
flussi autenticati (`/app/...`, §6.2).

## Opzioni

- **(a) Next.js/Astro su Firebase Hosting + Cloud Functions/Cloud Run** —
  integrazione nativa col backend Firebase, **un solo fornitore**, stessa fonte
  dati Firestore. *Consigliata.*
- **(b) Next.js su Vercel** — migliore DX per SSR, ma un fornitore in più e
  sessione/cookie Firebase da coordinare su due host.
- **(c) Prerender dei bot** (Rendertron/Prerender.io) sulla PWA — solo come
  **ponte**: fragile, Core Web Vitals scarsi, non è una soluzione definitiva.

## Decisione

Adottare l'opzione **(a)**: storefront SSR (Next.js o Astro) su **Firebase
Hosting + Cloud Functions/Cloud Run**, che legge le **stesse collezioni
Firestore** dell'app (solo `published`). Un dominio, due renderer:
`/`, `/prodotti`, `/p/{slug}`, `/blog/...`, `/sedi`, `/servizi` → storefront;
`/app/...` → PWA Flutter.

## Cosa è stato realizzato in questo step (fondamenta)

Nel repo dell'app (`app/web/`) sono presenti le fondamenta SEO servibili dallo
shell e riusabili dallo storefront:

- `robots.txt` — consente `/`, esclude `/app/`, indica la sitemap.
- `sitemap.xml` — pagine top-level con **hreflang IT/EN** + `x-default`
  (le URL prodotto/articolo le appende la Cloud Function alla
  pubblicazione/archiviazione).
- `index.html` — `canonical`, OpenGraph/Twitter, **JSON-LD `Pharmacy`**
  a livello di sito, `lang="it"`.
- `lib/core/theme/tokens.json` — design token condivisi, da esportare come CSS
  custom properties nello storefront (§7.2.6): un solo vocabolario visivo.

## Limitazione esplicita (il gate resta aperto)

Queste fondamenta **non chiudono** il gate critico del §6.2. La `<title>`/meta
**per pagina**, il JSON-LD `Product`/`FAQPage`/`BreadcrumbList` e l'HTML reale
di schede e articoli richiedono lo **storefront SSR** sopra descritto, che è un
progetto di rendering separato dall'app Flutter. Restano da fare:

1. Scaffolding del progetto storefront (Next.js/Astro) sull'hosting scelto.
2. Rendering server delle pagine pubbliche dai dati Firestore `published`.
3. Cloud Function di (ri)generazione `sitemap.xml` su publish/archive.
4. Search Console: verifica proprietà, invio sitemap, **Ispezione URL** su una
   scheda prodotto e un articolo in IT e EN.

**Finché il punto 4 non è verde, non si investe in traffico/marketing** (§6.2).
