# Features Documentation

Last Updated: 2026-03-06

## Purpose
This document explains each feature module in practical, implementation-level detail for onboarding, maintenance, and planning.

## Table of Contents
- [Feature Inventory](#feature-inventory)
- [Conventions](#conventions)
- [Exams](#exams)
- [Subjects](#subjects)
- [Login](#login)
- [Profile](#profile)
- [Notifications](#notifications)
- [Splash](#splash)
- [Main](#main)
- [Update Policy](#update-policy)

## Feature Inventory

| Feature | Primary Goal | Main Folder |
|---|---|---|
| Exams | Create, run, and review exams | `lib/Features/Exams` |
| Subjects | Manage subjects and exam access | `lib/Features/Subjects` |
| Login | Authentication and role selection | `lib/Features/login` |
| Profile | User profile and app settings pages | `lib/Features/Profile` |
| Notifications | Display and acknowledge notifications | `lib/Features/Notifications` |
| Splash | Startup/entry transition | `lib/Features/Splash` |
| Main | App shell and bottom navigation | `lib/Features/Main` |

## Conventions
- State management: `Cubit` + immutable `State` classes.
- Routing: `go_router` with route classes in `lib/Config/Routes/Routes`.
- DI: `GetIt` in `lib/Config/di/service_locator.dart`.
- Folder naming note: some modules use `Persentation` (typo) instead of `Presentation`. Keep this in mind when navigating the repo.

## Exams

### Overview
Lifecycle coverage:
- Create exam (AI generation + manual settings)
- Preview exam before publish
- Do exam (student attempt with timer/lifecycle rules)
- Student result view
- Teacher result view with analysis

### Screens
- `CreateExamScreen`
- `PreviewExamScreen`
- `DoExam`
- `StudentResultScreen`
- `TeacherResultScreen`
- Shared template UI: `shared/Template/exam_view.dart`

### State Management
- `CreateExamCubit` / `CreateExamState`
- `SolveExamCubit` / `SolveExamState`
- `StudentResultCubit` / `StudentResultState`
- `TeacherResultCubit` / `TeacherResultState`

### Data Flow
- UI -> Cubit -> Repository -> RemoteDataSource -> API/local storage -> Cubit state -> UI
- Major repositories:
  - `CreateExamRepository`
  - `DoExamRepository`
  - `ViewExamRepository`

### Rules/Validation
- Minimum exam duration enforced.
- Start/end date required and end must be after start.
- Validate uploaded source (file/text) before generation.
- During exam:
  - Timer-based completion.
  - Background grace period handling.
  - Connectivity-loss handling.
  - Submission status history tracked.
- Result mode:
  - Student level classification in `shared/Enums/student_result_level.dart`.
  - Teacher can select student via bottom sheet selector.

### Known Issues
- Some logic still lives in UI page level (example: start exam API call in `details_screen.dart`).
- Mixed route naming/history from earlier view/result refactors.

### Next Improvements
- Move start-exam call into exams domain/repository for consistency.
- Add dedicated tests for lifecycle and connectivity edge cases.
- Normalize old/shared template placement and naming.

## Subjects

### Overview
Manages subject list/detail/dashboard and exam entry points.

### Screens
- `SubjectPage`
- `DetailsScreen`
- `DashboardScreen`

### State Management
- `SubjectCubit` / `SubjectState`

### Data Flow
- UI -> `SubjectCubit` -> `SubjectRepository` -> `SubjectsRemoteDataSource` -> API.
- Pulls exams and analytics for subject dashboard.

### Rules/Validation
- Create/join subject validation.
- Subject open/close status update.
- Subject deletion support.
- Leave subject currently not supported by API contract.

### Known Issues
- `leaveSubject` returns not-supported error by design in remote data source.

### Next Improvements
- Add backend support for leave-subject flow.
- Separate dashboard chart logic into dedicated widgets/services.

## Login

### Overview
Google-based authentication and role selection.

### Screens
- `LoginScreen`
- `ChooseRoleScreen`

### State Management
- `AuthenticationCubit` / `AuthenticationState`

### Data Flow
- UI -> `AuthenticationCubit` -> `AuthenticationSource` -> Google Sign-In + API auth endpoint.
- Token persisted in local storage and used by interceptor.

### Rules/Validation
- Uses optional web client ID from env.
- Role must be selected for complete profile flow.
- Backend device/session policy: max **3 concurrent devices** per account.
- Login payload includes:
  - `deviceInfo` from `DeviceInfoService` (Android/iOS metadata).
  - `deviceId` (Android ID or iOS identifierForVendor).
  - `clientProfile` from Google account (`googleId`, `email`, `name`, `photoUrl`).

### Known Issues
- Error messaging can be backend-message dependent and may need normalization.

### Next Improvements
- Add token refresh strategy if backend introduces expiring tokens.

## Profile

### Overview
Displays user information and app-level pages (About, Help), role/profile updates, and account actions.

### Screens
- `ProfileScreen`
- `AboutScreen`
- `HelpScreen`

### State Management
- `ProfileCubit` / `ProfileState`

### Data Flow
- UI -> `ProfileCubit` -> `ProfileSource` -> API.
- Also fetches dashboard/analysis summary for profile context.

### Rules/Validation
- Profile update + role submission.
- Account deletion call available.

### Known Issues
- About/help content is app-local and should be synced with legal hosted docs when updated.

### Next Improvements
- Link Privacy/Terms URLs directly from About/Help actions.

## Notifications

### Overview
Combines push stream updates with API fetching and stateful read/open actions.

### Screens
- `NotificationPage`

### State Management
- `NotificationsCubit` / `NotificationsState`

### Data Flow
- FCM stream -> `NotificationSource.listenNotificationsForTopics()`
- API sync via `NotificationSource.fetchFromApi()`
- Mark read/open via API PUT endpoints.

### Rules/Validation
- Deduplicate notifications by ID.
- Keep latest update by timestamp.

### Known Issues
- Merge strategy depends on timestamp consistency from backend.

### Next Improvements
- Add paginated notifications if backend volume grows.

## Splash

### Overview
Initial transition screen before routing into auth/main flows.

### Screens
- `SplashScreen`

### State Management
- Local widget state (no dedicated cubit).

### Data Flow
- Startup checks -> navigation decision.

### Rules/Validation
- Must remain lightweight and deterministic to avoid startup delays.

### Known Issues
- None critical.

### Next Improvements
- Add explicit startup diagnostics logging.

## Main

### Overview
Shell wrapper for app sections with bottom navigation and exam-screen special handling.

### Screens
- `MainScreen` (shell body container)

### State Management
- `MainCubit` / `MainState`

### Data Flow
- Route location -> selected tab behavior.
- Hides bottom nav in exam-related routes.

### Rules/Validation
- Detect exam routes and disable bottom bar there.
- Apply status bar style overlay across shell.

### Known Issues
- Route list for “exam screens” is maintained manually.

### Next Improvements
- Move route visibility rules to centralized route metadata.

## Update Policy
- Update this file whenever:
  - A feature adds/removes a screen.
  - A cubit/repository/data source contract changes.
  - Business rules or known limitations change.
- Suggested owner: feature maintainer in the same PR.
