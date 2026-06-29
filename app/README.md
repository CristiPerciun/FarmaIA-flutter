# App — Baganza Farmacie 3.0

App Flutter multipiattaforma (Web PWA, iOS, Android, Windows).

## Prerequisiti

- Flutter SDK ≥ 3.22 (Dart ≥ 3.12)
- Chrome (per sviluppo web)

## Avvio

```bash
flutter pub get
flutter run -d chrome --dart-define=ENV=dev
```

Con emulatori Firebase attivi (`cd ../firebase && firebase emulators:start`).

## Comandi

```bash
dart format .
flutter analyze
flutter test
flutter build web --dart-define=ENV=dev
```

## Struttura

```
lib/
├── core/           # Router, theme, Firebase, i18n providers
├── features/       # Feature-first modules
├── l10n/           # ARB files IT/EN
└── main.dart
```

## Configurazione Firebase

Eseguire una volta (richiede login Firebase):

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=dbfarmacia
```

Aggiorna `lib/firebase_options.dart` con le credenziali reali del progetto.

## Ambienti

Gli ambienti sono selezionati a runtime via `--dart-define=ENV` (non Gradle flavor):
una scelta più semplice per commutare emulatori/Firebase live e provider App Check senza
binari separati. La logica è in `core/config/app_env.dart` + `core/firebase/firebase_init.dart`.

| ENV | Descrizione |
|---|---|
| `dev` | Emulatori Firebase + App Check debug |
| `prod` | Firebase live + App Check enforcement |

Passare con `--dart-define=ENV=dev` o `--dart-define=ENV=prod`.
