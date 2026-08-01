# Google Sign-In Setup

How Google Sign-In is wired up for this app, and the exact steps taken in Google Cloud Console so this can be reproduced or handed off.

## 1. Google Cloud Console project

Created a new, dedicated Google Cloud project for this app (not shared with an unrelated project) — this is what backs both the OAuth consent screen and the OAuth client IDs below. A Firebase project would also have worked (Firebase projects are GCP projects underneath), but we used plain Cloud Console since the app doesn't otherwise use Firebase.

## 2. OAuth consent screen ("Branding")

Under **Google Auth Platform → Branding**:

- **App name**: the app's display name (shown to users on the consent screen).
- **User support email**: a support email tied to the Google account/org.
- **Audience**: set to **External** (any Google account, not restricted to a Workspace org) — appropriate since this app's users are the general public. This starts the app in **Testing** status.
- **Contact information**: a developer contact email.

These fields are all editable later from the same page. The one thing that isn't a quick edit is moving from Testing → Production publishing status, which can trigger Google's verification review for apps requesting sensitive scopes — not a concern here since we only request the `email` scope.

## 3. OAuth client IDs

Created under **Google Auth Platform → Clients → Create OAuth client ID**. iOS and Android clients were created, plus a **Web application** client ("Asthma Passport Website", added 2026-07-23) used purely as the `serverClientId` Android needs to mint an ID token — see the caveat below. The ID token's `aud` (audience) claim is the iOS client ID on iOS, and the Web client ID on Android; the backend must accept either as valid.

| Platform | Name                | Identifier used                              | Notes |
|----------|----------------------|-----------------------------------------------|-------|
| iOS      | Asthma Passport iOS  | Bundle ID `com.example.asthmaPassportApp`     | Reversed client ID copied into [`ios/Runner/Info.plist`](../ios/Runner/Info.plist) `CFBundleURLTypes` so the sign-in redirect returns to the app. The plain (non-reversed) client ID is also required as the `GIDClientID` key in the same `Info.plist` — without it, iOS throws `No active configuration. Make sure GIDClientID is set in Info.plist.` at sign-in time. |
| Android  | Asthma Passport Android | Package `com.example.asthma_passport_app`, SHA-1 of the local `~/.android/debug.keystore` | Package name + SHA-1 is enough for Android to complete sign-in, but **not** enough to get a non-null `idToken` — the Android Sign-In SDK only mints an ID token when a web-application-type client is passed as `serverClientId` (see the Web client above and §5). Without it, sign-in silently succeeds but `idToken` is `null`. |

Both use the placeholder `com.example.*` identifiers currently in the Xcode project / `build.gradle`. If these are renamed to real production identifiers before release, both OAuth clients need to be re-created (or edited, where the console allows it) to match — an OAuth client's bundle ID/package name isn't just cosmetic, sign-in fails if it doesn't match exactly.

**Android SHA-1 caveats:**
- The debug keystore is machine-specific. Every developer testing Google Sign-In locally needs to add *their own* debug SHA-1 to the Android client (the console supports multiple fingerprints per client).
- A release build (e.g. via Play App Signing) uses a different signing key with its own SHA-1 — that fingerprint must also be added before Google Sign-In works in release/production builds.

**App Check**: skipped when creating the iOS client. It's an optional anti-abuse hardening layer requiring the Firebase App Check SDK; not needed to get sign-in working.

**Verify app ownership**: skipped when creating the Android client — optional Play Console domain verification, not required for development.

## 4. Test users

While the consent screen is in **Testing** status, only Google accounts explicitly added under **Audience → Test users** can complete sign-in (anyone else sees an "access blocked" error). The developer's own Google account was added here first, for local testing. Add teammates' accounts the same way as they start testing.

## 5. Flutter/code changes

- **`pubspec.yaml`** — added the `google_sign_in: ^6.2.1` dependency.
- **[`lib/services/auth_service.dart`](../lib/services/auth_service.dart)** — added `loginWithGoogle(idToken)`, parallel to the existing `login()`: posts to `POST /user/login/google`, reuses `LoginResult.fromJson` and the existing token/username storage helpers.
- **[`lib/components/login_form.dart`](../lib/components/login_form.dart)** — the "使用 Google 登入" button now runs `GoogleSignIn(scopes: ['email']).signIn()` after the terms bottom sheet is confirmed (same terms-first flow as the LINE button), sends the resulting ID token to `AuthService.loginWithGoogle`, and navigates to `HomePage` on success or shows a `SnackBar` on failure. Has its own `isGoogleLoading` spinner state, independent of the password login button's loading state.
- **[`ios/Runner/Info.plist`](../ios/Runner/Info.plist)** — added the `CFBundleURLTypes` entry with the iOS client's reversed client ID, required so iOS can hand control back to the app after the Google sign-in web view/redirect.
- `serverClientId` **is** passed to `GoogleSignIn()`, set to the Web client's ID — required on Android to get a non-null `idToken` (see §3). Doesn't change iOS's `idToken` audience, which stays the iOS client ID regardless of `serverClientId`.

## 6. What's left

- **Backend**: implement `POST /user/login/google`.
  - Request: `{ "id_token": "<Google ID token>" }`
  - Verify the token's signature against Google's public keys and accept either the iOS client ID or the Web client ID as a valid `aud` (pass both as an array to the verifier — see §3; Android's `aud` is the Web client ID, not the Android client ID, since that's what `serverClientId` is set to). Google's own guide for this, with official library snippets per language (Node.js, Java, PHP, Python): https://developers.google.com/identity/sign-in/web/backend-auth#node.js
  - Look up the user by the token's verified email; auto-create the account on first sign-in (same `is_first_login` semantics as password signup). Google's guide notes `sub` (the account's stable Google ID) is a more robust lookup key than email, since email can change — worth considering if the user table isn't already keyed by email.
  - Response: same shape as `/user/login` — `{ access_token, user_name, is_first_login }`.
- **Add more test users** as teammates/QA start testing, and each of their local debug-keystore SHA-1s to the Android client.
- **Register the release-build SHA-1** on the Android client before shipping a signed build.
- **Decide on real Android `applicationId` / iOS bundle ID** before release, then update both OAuth clients (and `Info.plist`) to match.
- **Publish the OAuth consent screen** (move off Testing status) once ready for the general public to sign in.
