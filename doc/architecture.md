# Project Architecture

## 1) High-level Overview

This project is a Flutter application organized around:

- `Config`: app bootstrap configuration (DI, routing, themes, settings).
- `Core`: reusable cross-cutting utilities/services (API, local storage, resources, notifications, widgets).
- `Features`: business features (Exams, Subjects, Login, Profile, Notifications, Splash, Main).

The dominant architecture style is **Feature-first + Layered (Data/Domain/Presentation)** with **Cubit/BLoC** for state management.

---

## 2) Source Tree (Core Structure)

Main codebase:

- `lib/main.dart`
- `lib/Config/`
- `lib/Core/`
- `lib/Features/`

Feature pattern (example: `Exams`):

- `Data/` (DTOs + remote/local sources)
- `Domain/` (repositories/use-cases interfaces and orchestration)
- `Presentation/` (screens, widgets, cubits)
- `shared/` (feature models/enums/templates used across layers)

---

## 3) App Startup Flow

Entry point: `lib/main.dart`

Boot sequence:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `setupDependencies()` from GetIt service locator.
3. Load environment from `.env`.
4. Initialize Firebase + local storage.
5. Initialize FCM + Dio API service.
6. Register background notification handler.
7. Run `MyApp`.

UI bootstrap:

- `ScreenUtilInit` for responsive scaling.
- `MultiBlocProvider` injects app-level cubits (`Settings`, `Profile`, `Subjects`, `Notifications`).
- `MaterialApp.router` with `GoRouter`.

---

## 4) Routing Architecture

Router file: `lib/Config/Routes/app_router.dart`

Routing model:

- Root routes: splash, login, choose-role.
- Shell route wraps main app pages with `MainScreen`.
- Nested feature routes under subject/details and exams (create/do/view/result).

Current exam result routing is separated by mode:

- preview route
- student result route
- teacher result route

This keeps each behavior isolated and reduces screen-level branching.

---

## 5) Dependency Injection (DI)

DI file: `lib/Config/di/service_locator.dart`

Uses `GetIt` with:

- `registerLazySingleton` for data sources, repositories, long-lived cubits.
- `registerFactory` for short-lived cubits (for example `MainCubit`, `AuthenticationCubit`).

DI wiring includes:

- Subjects data source + repository + search use case.
- Exams data sources (create/do/view) + repositories.
- App-level cubits (settings/profile/subjects/notifications).

---

## 6) State Management

State management is based on `flutter_bloc`:

- Each feature has dedicated cubits and immutable state models.
- UI updates through `BlocBuilder`/`BlocProvider`.
- Side effects (API calls, local cache updates, notifications) are triggered from cubits/repositories.

Examples:

- `SolveExamCubit` for exam-taking lifecycle.
- `TeacherResultCubit` / `StudentResultCubit` for result flows.
- `SubjectCubit` for subject dashboard/list.

---

## 7) Feature Architecture Summary

## Exams

Most advanced feature in app; includes full exam lifecycle:

- Create exam
- Preview/edit exam
- Do exam (timer, lifecycle checks, connectivity checks)
- Student result
- Teacher result + analytics

Data layer uses DTO models and remote data sources.

Shared models/enums provide common contracts for:

- exam model
- question/option/result models
- status/level/mode enums

## Subjects

Subject listing/details/dashboard and exam entry points.

Follows layered structure:

- data source -> repository -> use case -> cubit -> UI

## Login / Profile / Notifications / Splash / Main

Feature-scoped presentation with supporting services from `Core`.

`MainScreen` handles shell navigation and global bottom navigation behavior.

---

## 8) Core Layer Responsibilities

`lib/Core` contains generic platform/application services:

- `Services/Api`: networking (`DioHelper`, endpoints).
- `Services/Notifications`: FCM + local notifications.
- `LocalStorage`: persistent key/value storage access.
- `Resources`: constants, colors, strings, icons, text styles.
- `Utils`: shared widgets, helpers, extensions, enums.

This layer should remain feature-agnostic.

---

## 9) Data Flow Pattern (Typical)

Typical request flow:

1. UI triggers Cubit action.
2. Cubit calls Repository.
3. Repository delegates to DataSource.
4. DataSource calls API/local storage and maps DTO/model.
5. Repository returns result to Cubit.
6. Cubit emits new immutable state.
7. UI rebuilds from state.

---

## 10) Architectural Strengths

- Clear feature isolation.
- Good layering in major modules (especially Exams/Subjects).
- Scalable route + DI setup.
- Reusable shared/core modules reduce duplication.

---

## 11) Known Technical Notes

- Some folders use typo naming (`Persentation` vs `Presentation`).
- There is mixed placement for some shared templates; standardization can improve discoverability.
- Route/data classes are growing; consider route grouping by feature module.

---

## 12) Suggested Next Architecture Improvements

1. Standardize folder naming (`Presentation` everywhere).
2. Define strict boundaries for `shared/` vs `Core/`.
3. Add architecture decision records (ADRs) under `doc/`.
4. Add feature-level README files (`Features/*/README.md`) with data-flow diagrams.
5. Add test architecture map (unit/widget/integration ownership by layer).

