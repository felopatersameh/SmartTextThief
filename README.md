# Smart Text Thief

AI-powered exam management app for teachers and students.

## Current Status

- App is in a stable handover/sale-ready state.
- Current app version: `1.4.0+1`.
- Scope is intentionally frozen right now (no roadmap/future-plan section).

## What the app does now

### Teacher workflow

1. Sign in with Google and choose role.
2. Create subjects and get join codes.
3. Open/close subject join access.
4. Create AI exams from:
   - PDF files
   - Images (`jpg/jpeg/png`) via OCR
   - Direct text input
5. Configure exam:
   - Difficulty (`easy`, `normal`, `hard`)
   - Question count by type (MCQ, True/False, Short answer)
   - Start/end date
   - Duration
   - Optional question shuffling
   - Content context prompt
6. Review generated questions before publish:
   - Edit question text/options/answer
   - Delete questions
7. Publish exam to students.
8. View results and export exam + answer key as PDF.
9. Open subject dashboard with analytics:
   - Overview metrics
   - Difficulty distribution
   - Question performance
   - Topic/lesson analysis
   - Time trend
   - Student performance split
   - Exam-to-exam comparison
   - Student score matrix with flagged missing/zero exams

### Student workflow

1. Sign in with Google and choose role.
2. Join subjects with code (if subject is open).
3. View exam status (upcoming/live/ended).
4. Take live exam with:
   - Timer
   - Question navigation timeline
   - Answer autosave to Realtime Database
   - Full-screen immersive mode
   - Screenshot protection
   - Auto-finish if app stays in background for more than 2 minutes
5. Submit and view results according to exam timing/rules.
6. Leave subject when needed.

### Account/Profile features

- Profile analytics cards (teacher/student specific).
- Save personal Gemini API key from profile.
- Logout.
- Delete account with related data cleanup.

### Notifications

- FCM topic-based notifications for:
  - Subject join events
  - Exam creation
  - Exam submission
  - Other app notifications
- In-app notifications list with read-in/read-out states and badge count.

## Technical Stack

- Flutter + Dart
- State management: `flutter_bloc` / Cubit
- Routing: `go_router`
- Cloud:
  - Firestore (users, subjects, exams, notifications)
  - Realtime Database (live exam session state)
  - Firebase Messaging (push notifications)
- AI:
  - Gemini (`google_generative_ai`)
  - OCR (`google_mlkit_text_recognition`)
- Local storage: Hive
- PDF export: `pdf` + `syncfusion_flutter_pdf`
- Charts/analytics UI: `fl_chart`

## Project Structure (high level)

- `lib/Features/login`: auth and role selection
- `lib/Features/Subjects`: subjects listing/details/dashboard
- `lib/Features/Exams/create_exam`: AI exam generation
- `lib/Features/Exams/view_exam`: exam review/results view
- `lib/Features/Exams/do_exam`: live exam runtime
- `lib/Features/Notifications`: notifications page + cubit
- `lib/Features/Profile`: profile, help, about, account actions
- `lib/Core`: shared models, services, widgets, enums, storage
- `lib/Config`: routes, themes, app/env config

## Setup

### Prerequisites

- Flutter SDK compatible with Dart `>=3.2.0 <4.0.0`
- Firebase project (Firestore, Realtime Database, Messaging, Auth)
- Android environment (project is currently configured for Android only)

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Create environment file

Copy `.env.example` to `.env` and fill values:

```env
GOOGLE_WEB_CLIENT_ID=
FCM_PROJECT_ID=
FCM_SERVICE_ACCOUNT_PATH=assets/service_account.json
GEMINI_FALLBACK_API_KEY=
```

### 3) Firebase configuration

- Ensure `lib/firebase_options.dart` matches your Firebase project.
- Add service account JSON file at `assets/service_account.json` (or update the env path).
- Ensure Google Sign-In is enabled in Firebase/Auth and Android SHA keys are configured.

### 4) Run app

```bash
flutter run
```

### 5) Release build (Android)

```bash
flutter build apk --release
```

## Data Collections (Firestore)

- `Users`
- `Subjects`
- `Subjects/{subjectId}/Exams`
- `Notification`

## Rebranding / resale quick-edit points

- App name: `lib/Config/app_config.dart` and `android/app/src/main/AndroidManifest.xml`
- Theme/colors: `lib/Core/Resources/app_colors.dart`
- Typography/icons: `lib/Core/Resources/app_fonts.dart`, `lib/Core/Resources/app_icons.dart`
- Routes/navigation: `lib/Config/Routes/*`
- Static app text: `lib/Core/Resources/strings.dart`

## Current Scope Notes

- Supported roles now: Teacher and Student.
- Google sign-in is the active login flow.
- Firebase options for iOS/web/desktop are not configured in this repo.
