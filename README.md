# Baganza Farmacie 3.0 (eFarm)

Monorepo per l'app PWA/e-commerce **Baganza Farmacie** — Parma, Italia.

## Struttura

| Cartella | Stack | Descrizione |
|---|---|---|
| [`app/`](app/) | Flutter | Client PWA + iOS/Android/Windows |
| [`firebase/`](firebase/) | Firebase | Firestore, Functions, Storage, Hosting |

> **Nota struttura repo:** il documento tecnico (§4) prevedeva due repository separati.
> Si è scelto un **monorepo** (un unico repo Git con le due cartelle `app/` e `firebase/`):
> più semplice da clonare, versionare e mantenere allineato per un team piccolo, con un
> solo storico e una sola pipeline CI. La separazione resta possibile in futuro senza
> impatti sul codice (le due cartelle sono già autonome).

## Prerequisiti

- Flutter SDK ≥ 3.22 (Dart ≥ 3.12)
- Node.js ≥ 20
- Firebase CLI (`npm install -g firebase-tools`)

## Avvio rapido

### Firebase (emulatori)

```bash
cd firebase
npm install --prefix functions
firebase emulators:start
```

Emulator UI: http://localhost:4000

### App

```bash
cd app
flutter pub get
flutter run -d chrome --dart-define=ENV=dev
```

## Comandi utili

```bash
# App Flutter
cd app && dart format . && flutter analyze && flutter test

# Firebase Functions
cd firebase/functions && npm run lint && npm run build
```

## Documentazione

- [Piano di sviluppo a step](Per%20step.md)
- [Documento tecnico Parte 1](Farmacia_3.0_Parte1_Tecnico.md)

## Branching

- `main` — stabile
- `step/0.x-descrizione` — feature branch per ogni step di sviluppo
