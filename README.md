# Asthma Passport

A Flutter app for tracking asthma control — daily diary, peak flow measurements, asthma control tests, an emergency contact card, and a digital health passport.

## Getting started

```bash
flutter pub get
flutter run
```

## Environments

The app has two build flavors, `prod` and `staging`, each with its own application ID/bundle ID and app name so both can be installed on the same device at once:

| Flavor    | App name                     | Android application ID                 | iOS bundle ID                          |
|-----------|-------------------------------|-----------------------------------------|------------------------------------------|
| `prod`    | Asthma Passport               | `com.example.asthma_passport_app`        | `com.example.asthmaPassportApp`          |
| `staging` | Asthma Passport (Staging)      | `com.example.asthma_passport_app.staging`| `com.example.asthmaPassportApp.staging`  |

The flavor also drives the API base URL configured in [`lib/config/api_config.dart`](lib/config/api_config.dart) — no separate flag needed.

```bash
# Run
flutter run --flavor prod       # or --flavor staging

# Build
flutter build apk --flavor staging
flutter build appbundle --flavor staging
flutter build ios --flavor staging
flutter build ipa --flavor staging
```

Add the same `--flavor` flag to your IDE's run/debug configuration. Running/building without `--flavor` (e.g. `flutter test`) defaults to prod.

## Project structure

```
lib/
  config/     # Environment/API configuration
  components/ # Shared reusable widgets (buttons, text fields, dialogs, forms, ...)
  pages/      # App screens, grouped by feature (asthma_diary, peak_flow, health_passport, ...)
  services/   # API/data access layer (auth, api, emergency contact)
  theme/      # Colors, typography, and shared styling
```

## Services

- `AuthService` — login/register/session persistence. `login` calls the real backend (`POST /user/login`); `register` is still mocked pending a backend endpoint. `loginWithGoogle`/`loginWithLine` call `POST /user/login/google`/`POST /user/login/line` (see below).
- `ApiService` — app data (weather, tests, passport, history, etc.). Currently mocked; endpoints will be wired up as they become available.

## Third-party login

- **Google Sign-In** — the "使用 Google 登入" button uses the `google_sign_in` package, backed by OAuth clients in a dedicated Google Cloud Console project (iOS + Android, no Web client). See [`docs/google-sign-in.md`](docs/google-sign-in.md) for setup steps, current client IDs/config, and outstanding items (backend endpoint, release-build SHA-1, publishing).
- **LINE Login** — the "使用 LINE 登入" button uses the `flutter_line_sdk` package, backed by a single LINE Login channel shared across platforms. See [`docs/line-login.md`](docs/line-login.md) for setup steps and outstanding items (email permission application, backend endpoint).
