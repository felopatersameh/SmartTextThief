# Deployment Runbook

Last Updated: 2026-03-06

## Purpose
Manual release and deployment guide for Examora across mobile/web targets, with Firebase Hosting support for static/legal pages.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Environment Variables](#environment-variables)
- [Build Commands](#build-commands)
- [Release Steps](#release-steps)
- [Firebase Hosting](#firebase-hosting)
- [Post-Deploy Verification](#post-deploy-verification)
- [Rollback](#rollback)
- [CI/CD Status](#cicd-status)
- [Update Policy](#update-policy)

## Prerequisites

### Tooling
- Flutter SDK compatible with project (`pubspec.yaml` currently: Dart `>=3.2.0 <4.0.0`).
- Android Studio / Android SDK.
- Xcode + CocoaPods (for iOS).
- Firebase CLI (`firebase-tools`) for hosting deployment.
- Git + access to repository and Firebase project.

### Project Setup
- Configure Firebase files:
  - `android/app/google-services.json`
  - `lib/firebase_options.dart` (already generated in repo)
- Ensure `.env` exists (do not commit secrets).

## Environment Variables
Reference: `.env.example`

Required/expected:
- `GOOGLE_WEB_CLIENT_ID`
- `FCM_PROJECT_ID`
- `FCM_SERVICE_ACCOUNT_PATH`
- `GEMINI_FALLBACK_API_KEY` (optional fallback but recommended for AI flow)

Policy:
- Never commit real secrets.
- Keep `.env.example` up to date with key names only.
- Rotate keys if exposed.

## Build Commands

### 1) Dependency + validation
```bash
flutter pub get
dart analyze
```

### 2) Android
APK:
```bash
flutter build apk --release
```

App Bundle (Play Store):
```bash
flutter build appbundle --release
```

Output:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

### 3) iOS
```bash
flutter build ios --release
```
Then archive/sign from Xcode for App Store/TestFlight.

### 4) Web (if needed)
```bash
flutter build web --release
```
Output:
- `build/web`

Note: current Firebase Hosting config serves from `public/`, so legal/static hosting is independent from Flutter web artifact by default.

## Release Steps

### Pre-release
1. Update version in `pubspec.yaml`.
2. Ensure docs/legal files are updated.
3. Run:
   - `flutter pub get`
   - `dart analyze`
4. Smoke-test critical flows locally:
   - Login
   - Subject list/details
   - Create exam
   - Do exam
   - Results (student/teacher)
   - Notifications

### Build and package
1. Generate target artifacts (APK/AAB/iOS archive).
2. Validate app launch on physical device.
3. Verify API connectivity to production backend.

### Distribution
- Android: upload `.aab` to Google Play Console.
- iOS: upload archive via Xcode Organizer to TestFlight/App Store.
- Web/legal: deploy via Firebase Hosting commands below.

## Firebase Hosting
Reference: `firebase.json`
- Hosting public directory: `public`
- Ignore list includes `node_modules`, dotfiles, and `firebase.json`.

### Deploy static pages (e.g., privacy/terms)
1. Put files in:
   - `public/privacy.html`
   - `public/terms.html`
2. Deploy:
```bash
firebase login
firebase use smarttextthief
firebase deploy --only hosting
```

Expected URLs (project default domain):
- `https://smarttextthief.web.app/privacy.html`
- `https://smarttextthief.web.app/terms.html`

## Post-Deploy Verification

Checklist:
1. App login works with Google sign-in.
2. Token-authenticated API calls succeed.
3. Subject listing + join/create actions work.
4. Exam lifecycle:
   - Create/preview
   - Start/do/submit
   - Student and teacher result pages
5. Notifications:
   - list fetch
   - mark read/open operations
6. Legal links open hosted pages:
   - Privacy Policy
   - Terms
7. Status bar/visual shell behavior remains correct on main screens.

## Rollback

### Mobile rollback
- Re-publish previous stable build/version from store console.
- Update release notes to indicate rollback reason.

### Hosting rollback
Options:
1. Redeploy previous known-good `public/` content from git tag/commit.
2. Use Firebase Hosting rollback if version history is available in console/CLI workflow.

### API incident fallback
- If backend contract breaks, lock release and revert app rollout percentage (store staged rollout).

## CI/CD Status
- Current repository has Firebase Hosting PR preview workflow:
  - `.github/workflows/firebase-hosting-pull-request.yml`
- Full mobile CI/CD pipeline is **not currently configured** in this repo.

Future recommendation:
- Add GitHub Actions pipeline for:
  - `flutter pub get`
  - `dart analyze`
  - test suite
  - optional signed artifact generation in protected environments.

## Update Policy
- Update this runbook whenever:
  - Build commands/signing process changes.
  - Firebase hosting setup changes.
  - Release checklist or rollback strategy changes.



