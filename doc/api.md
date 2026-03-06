# API Integration Documentation

Last Updated: 2026-03-06

## Purpose

Defines how the Flutter app integrates with backend APIs: endpoint inventory, auth behavior, payload contracts, and implementation notes.

## Table of Contents

- [API Integration Documentation](#api-integration-documentation)
  - [Purpose](#purpose)
  - [Table of Contents](#table-of-contents)
  - [Base Configuration](#base-configuration)
  - [Authentication](#authentication)
  - [Endpoints by Feature](#endpoints-by-feature)
  - [Auth](#auth)
  - [User/Profile](#userprofile)
  - [Subjects](#subjects)
  - [Exams](#exams)
  - [Notifications](#notifications)
  - [Request/Response Models](#requestresponse-models)
  - [Common envelope](#common-envelope)
  - [Auth login request (simplified)](#auth-login-request-simplified)
  - [Auth login response expectation](#auth-login-response-expectation)
  - [Create/Save exam payload](#createsave-exam-payload)
  - [Submit exam payload](#submit-exam-payload)
  - [Result response parsing](#result-response-parsing)
  - [Errors \& Status Codes](#errors--status-codes)
  - [Timeouts / Retries](#timeouts--retries)
  - [Contract Notes](#contract-notes)
  - [Update Policy](#update-policy)

## Base Configuration

Source of truth:

- `lib/Core/Services/Api/api_endpoints.dart`
- `lib/Core/Services/Api/api_service.dart`

Current base URL:

- `https://apitextthief-production.up.railway.app/`

Transport:

- `Dio` via `DioHelper`.

Default headers:

- `Content-Type: application/json`
- `Accept: application/json`

Response envelope model:

- `ApiResponseModel<T>`:
  - `status: bool`
  - `message: String`
  - `data: T?`

## Authentication

Source:

- `lib/Core/Services/Api/api_interceptor.dart`
- `lib/Features/login/Data/authentication_source.dart`

Behavior:

1. Google Sign-In account is authenticated in app.
2. App sends payload to `auth/google`.
3. Receives backend token in `data.token`.
4. Token stored in local storage.
5. `ApiInterceptor` adds `Authorization: Bearer <token>` for every request if token exists.

Session/device control (backend policy):
- Maximum concurrent login devices per account: **3 devices**.
- Device fingerprint and profile payload are used to identify and control active tokens.

Error handling note:

- On HTTP 404 in interceptor, token/login flags are removed from local storage.

## Endpoints by Feature

## Auth

| Method | Endpoint | Purpose | Used In |
|---|---|---|---|
| POST | `auth/google` | Exchange Google identity for backend token | `AuthenticationSource.loginWithGoogle` |

## User/Profile

| Method | Endpoint | Purpose | Used In |
|---|---|---|---|
| GET | `v1/user` | Load user profile | `ProfileSource.getDataUser` |
| GET | `v1/user/dashboard` | Load user dashboard summary | `ProfileSource.analyzeUser` |
| POST | `v1/user/logout` | Logout session | `AuthenticationSource.logout` |
| POST | `v1/user/submitRole` | Submit selected role | `ProfileSource.updateType` |
| DELETE | `v1/user/remove` | Delete current user data | `ProfileSource.deleteCurrentUserData` |

## Subjects

| Method | Endpoint | Purpose | Used In |
|---|---|---|---|
| GET | `v1/subject` | Fetch subjects | `SubjectsRemoteDataSource.getSubjects` |
| POST | `v1/subject/create` | Create subject | `SubjectsRemoteDataSource.addSubject` |
| POST | `v1/subject/join` | Join subject by code | `SubjectsRemoteDataSource.joinSubject` |
| PUT | `v1/subject/{id}/update_status` | Open/close subject | `SubjectsRemoteDataSource.toggleSubjectOpen` |
| DELETE | `v1/subject/{id}/remove` | Delete subject | `SubjectsRemoteDataSource.deleteSubjectCompletely` |
| GET | `v1/subject/{id}/get_exams` | Get exams for subject | `SubjectsRemoteDataSource.getExams` |
| GET | `v1/subject/{id}/analytics` | Subject analytics | `SubjectsRemoteDataSource.getAnalyticsSubjects` |

## Exams

| Method | Endpoint | Purpose | Used In |
|---|---|---|---|
| POST | `v1/subject/{id}/create_exam` | Create/save exam | `ViewExamRemoteDataSource.saveExam` |
| POST | `v1/subject/{id}/exam/{idExam}/start_exam` | Start student exam attempt | `details_screen.dart` |
| POST | `v1/subject/{id}/exam/{idExam}/submit_exam` | Submit student answers | `DoExamRemoteDataSource.submitExam` |
| GET | `v1/subject/{id}/exam/{examId}/get_result` | Get exam result(s) | `ViewExamRemoteDataSource.getResult` |

## Notifications

| Method | Endpoint | Purpose | Used In |
|---|---|---|---|
| GET | `v1/notifications` | Fetch notifications | `NotificationSource.fetchFromApi` |
| PUT | `v1/notifications/read` | Mark notifications as read | `NotificationSource.markReadByIds` |
| PUT | `v1/notifications/open` | Mark notifications as opened | `NotificationSource.markOpenedByIds` |

## Request/Response Models

## Common envelope

```json
{
  "status": true,
  "message": "ok",
  "data": {}
}
```

## Auth login request (simplified)

`POST auth/google`

```json
{
  "deviceId": "platform-device-id",
  "deviceInfo": {
    "platform": "android|ios",
    "manufacturer": "...",
    "model": "...",
    "brand": "...",
    "osVersion": "...",
    "device": "...",
    "product": "...",
    "name": "...",
    "systemName": "..."
  },
  "clientProfile": {
    "googleId": "...",
    "email": "...",
    "name": "...",
    "photoUrl": "..."
  }
}
```

Device info source:
- `lib/Core/Services/Device/device_info_service.dart`
- Android currently sends: `platform`, `manufacturer`, `model`, `brand`, `osVersion`, `device`, `product`, plus `android.id` as `deviceId`.
- iOS currently sends: `platform`, `manufacturer`, `model`, `brand`, `osVersion`, `name`, `systemName`, plus `identifierForVendor` as `deviceId`.

## Auth login response expectation

```json
{
  "status": true,
  "message": "Authenticated",
  "data": {
    "token": "jwt-or-session-token"
  }
}
```

## Create/Save exam payload

Model:

- `CreateExamRequestModel` (`lib/Features/Exams/Data/DTO/Requests/create_exam_request_model.dart`)

Includes:

- name, levelExam, isRandom
- questionCount, timeMinutes
- startAt, endAt
- questions[] (QuestionModel)

## Submit exam payload

Model:

- `SubmitExamRequestModel` (`lib/Features/Exams/Data/DTO/Requests/submit_exam_request_model.dart`)

Includes:

- `status`
- `answers[]` from `StudentAnswerModel.toSubmitJson()`

## Result response parsing

Models:

- `StudentResultResponseModel`
- `ExamResultModel`
- `StudentAnswerModel`
- `ScoreModel`

Supports:

- single result object
- list of results

## Errors & Status Codes

Observed handling patterns:

- `response.status == false` -> handled as business failure with `response.message`.
- `DioException` -> converted to failure model/string in each data source.
- Interceptor behavior:
  - debug logs request/response/error in debug mode.
  - 404 triggers token/login cleanup in local storage.

Recommended API error semantics (future hardening):

- 400: validation failure
- 401/403: auth/permission
- 404: not found
- 409: conflict (already started/already submitted scenarios)
- 500: server error

## Timeouts / Retries

Current status:

- `connectTimeout` and `receiveTimeout` are present but commented out in `DioHelper`.
- No centralized retry policy.

Recommended non-breaking defaults (future):

- connect timeout: 12s
- receive timeout: 12s
- retry only idempotent requests (`GET`), with capped attempts and backoff.

## Contract Notes

1. AI generation path:

- Exam generation (`CreateExamRemoteDataSource`) is Gemini-driven and not part of app backend REST endpoints.

1. Leave-subject:

- `leaveSubject` currently returns not-supported error from app data source by design.

1. Parsing resilience:

- Some models support flexible response shapes (map/list/null) and defensive conversion.

1. Start exam flow:

- Start-exam call currently performed in UI page (`details_screen.dart`), not yet centralized in a repository.

1. Nullability:

- Ensure backend preserves required fields for strict client mappings (IDs, status, dates, score payloads).

## Update Policy

- Update this file whenever:
  - `api_endpoints.dart` changes.
  - Request/response DTOs change.
  - Auth/header/interceptor behavior changes.
  - Error/timeouts policy changes.
