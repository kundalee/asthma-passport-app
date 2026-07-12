# LINE Login Setup

How LINE Login is wired up for this app, mirroring [`docs/google-sign-in.md`](google-sign-in.md)'s structure. Based on LINE/LY Corporation's official Flutter SDK (`flutter_line_sdk`, https://github.com/line/flutter_line_sdk) and LINE Developers docs (https://developers.line.biz/en/docs/line-login/).

## 1. LINE Developers Console setup

Unlike Google, LINE Login uses **one Channel ID** shared across iOS and Android — no separate client per platform.

Steps taken:

1. Created a Provider (`Asthma Passport`, region **Taiwan** — matches the `itroll.com.tw` backend domain and the app's Traditional Chinese UI) via a LINE Business ID (not a personal LINE account, so ownership isn't tied to one person).
2. Created a **LINE Login** channel under it, named `Asthma Passport`, app type **Mobile app**.
3. Under the channel's **LINE Login** tab → app settings, registered **both** the prod and staging identifiers (one per line — the field supports multiple):
   - iOS bundle ID: `com.example.asthmaPassportApp`, `com.example.asthmaPassportApp.staging`
   - Android package names: `com.example.asthma_passport_app`, `com.example.asthma_passport_app.staging`
   - iOS universal link and Android package signatures left blank — both optional for LINE (unlike Google's mandatory SHA-1); package signature to be added before a release build.
4. **Channel ID: `2010677656`** — already in [`lib/config/line_auth_config.dart`](../lib/config/line_auth_config.dart).
5. Applied for email permission: Basic settings → OpenID Connect → Apply. This app's account model is email-centric (see `UserProfile`, and how both Google login and password signup resolve accounts by email), so this permission is worth having — but login works without it, `email` is simply absent from the token until approved (review is in progress).

**Channel status / Roles**: a new channel starts in **Developing** status (LINE's equivalent of Google's "Testing" status) — only LINE accounts explicitly given a role on the channel (**Roles** tab → add as Tester/Admin) can complete login. Discovered this via a `400 This channel is now developing status. User need to have developer role.` error on first test; added the test LINE account as a Tester to unblock. Same category of step as Google's test-user allow-list.

## 2. Client changes

- **`pubspec.yaml`** — added `flutter_line_sdk: ^2.6.2` (pinned below the latest 2.7.x, which requires Dart ≥3.8.0; this project's Flutter 3.27.3 ships Dart 3.6.1 — upgrading the whole toolchain was out of scope for this feature).
- **[`lib/config/line_auth_config.dart`](../lib/config/line_auth_config.dart)** — placeholder `channelId`, same pattern as `GoogleAuthConfig` was for Google.
- **[`lib/main.dart`](../lib/main.dart)** — calls `LineSDK.instance.setup(LineAuthConfig.channelId)` before `runApp`.
- **[`lib/services/auth_service.dart`](../lib/services/auth_service.dart)** — `loginWithLine(idToken)`, parallel to `loginWithGoogle`: posts to `POST /user/login/line`, reuses `LoginResult.fromJson` and the existing token/username storage.
- **[`lib/components/login_form.dart`](../lib/components/login_form.dart)** — the "使用 LINE 登入" button runs `LineSDK.instance.login(scopes: ['profile', 'openid', 'email'])` after the terms sheet is confirmed, sends `result.accessToken.idTokenRaw` to `AuthService.loginWithLine`, navigates to `HomePage` on success or shows a `SnackBar` on failure. Has its own `isLineLoading` spinner state. `PlatformException` is caught generically (covers both user cancellation and native SDK errors) since LINE's error codes differ between iOS and Android with no single reliable "cancelled" code to special-case.
- **[`ios/Runner/Info.plist`](../ios/Runner/Info.plist)** — added a second `CFBundleURLTypes` entry with scheme `line3rdp.$(PRODUCT_BUNDLE_IDENTIFIER)`, and `LSApplicationQueriesSchemes: [lineauth2]` so the app can detect/launch the LINE app.
- **iOS deployment target** — bumped from 12.0 to 13.0 (`ios/Runner.xcodeproj/project.pbxproj`, all targets) and set `platform :ios, '13.0'` in `ios/Podfile` — required by the LINE SDK.
- **`android/app/build.gradle`** — `minSdk` explicitly raised to at least 24 (`Math.max(flutter.minSdkVersion, 24)`) — required by the LINE SDK.
- Universal Links (an alternative iOS callback mechanism) were **not** configured — LINE documents them as optional; the custom URL scheme above is sufficient.

## 3. What's left

- **Email-permission application** — awaiting LINE's review.
- **Backend**: implement `POST /user/login/line`.
  - Request: `{ "id_token": "<LINE ID token>" }`
  - Verify via `POST https://api.line.me/oauth2/v2.1/verify` with `id_token` and `client_id=2010677656`. Reference: https://developers.line.biz/en/docs/line-login/verify-id-token/#get-profile-info-from-id-token
  - Extract `email` (once the permission above is approved and granted by the user) and `name`/`sub` from the verified payload.
  - Look up/create the user by email, same `is_first_login` semantics as the Google and password flows.
  - Response: same shape as `/user/login` — `{ access_token, user_name, is_first_login }`.
  - Until email permission is approved, `email` may be absent from the token — same `sub`-vs-email lookup consideration already flagged for Google applies here too.
- **Add more testers** as teammates/QA start testing (Roles tab), and **publish the channel** (move off Developing status) once ready for the general public.
- **Register the Android package signature** before a release build (optional today, but worth doing alongside the release-build SHA-1 already needed for Google).
- **Decide on real Android `applicationId` / iOS bundle ID** before release, then update the LINE channel's app settings to match.
