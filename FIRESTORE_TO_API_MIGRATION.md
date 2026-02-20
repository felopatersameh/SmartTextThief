# Firestore Current Contract (Pre-API Migration)

Generated from code inspection in `lib/**` on 2026-02-18.
This file documents what is currently stored and mutated in Cloud Firestore.

## 1) Active Firestore Paths

- `Users/{userId}`
- `Subjects/{subjectId}`
- `Subjects/{subjectId}/Exams/{examId}`
- `Notification/{notificationId}`

## 2) `Users/{userId}`

### Stored fields

| Key | Type in code | Notes |
|---|---|---|
| `user_id` | `String` | Usually same as doc id for Google sign-in flow. |
| `photo` | `String` | Google profile image URL or empty. |
| `user_tokensFCM` | `List<String>` | Appends using `arrayUnion`. |
| `user_name` | `String` | |
| `user_email` | `String` | |
| `user_password` | `String` | Kept empty in Google flow. |
| `user_geminiApiKey` | `String` | User-specific Gemini key. |
| `user_phone` | `String` | |
| `user_type` | `String` | `student`, `teacher`, `admin`, `non`. |
| `user_createdAt` | `DateTime` at write time | Firestore stores timestamp; parser currently does not handle `Timestamp` explicitly. |
| `subscribedTopics` | `List<String>` | Contains topics like `allUsers`, `{subjectId}`, `{subjectId}_admin`. |

### Main writes

- Create user at first Google login:
  - `lib/Features/login/Data/authentication_source.dart`
- Append FCM token:
  - `lib/Features/login/Data/authentication_source.dart`
- Append topic to `subscribedTopics`:
  - `lib/Core/Services/Notifications/notification_services.dart`
- Update `user_type` / `user_geminiApiKey`:
  - `lib/Features/Profile/Data/profile_source.dart`
- Remove user document on account deletion:
  - `lib/Features/Profile/Data/profile_source.dart`

### Main reads/queries

- Fetch current user by id:
  - `lib/Features/Profile/Data/profile_source.dart`
- Query users containing topic (cleanup flow):
  - `lib/Features/Subjects/Data/datasources/subjects_remote_data_source.dart`

## 3) `Subjects/{subjectId}`

### Stored fields

| Key | Type in code | Notes |
|---|---|---|
| `subject_idSubject` | `String` | Subject id. |
| `subject_codeSub` | `String` | Join code. |
| `subject_nameSubject` | `String` | |
| `subject_teacher` | `Map<String,dynamic>` | `{ teacher_email, teacher_name }`. |
| `subject_emailSts` | `List<String>` | Student emails in subject. |
| `subject_isOpen` | `bool` | Join enabled/disabled. |
| `subject_createdAt` | `int` | Milliseconds since epoch. |

### Main writes

- Create subject:
  - `lib/Features/Subjects/Data/datasources/subjects_remote_data_source.dart`
- Update full subject payload:
  - `lib/Features/Subjects/Data/datasources/subjects_remote_data_source.dart`
- Toggle open/closed:
  - `lib/Features/Subjects/Data/datasources/subjects_remote_data_source.dart`
- Join/leave student (`arrayUnion` / `arrayRemove` on `subject_emailSts`):
  - `lib/Features/Subjects/Data/datasources/subjects_remote_data_source.dart`
- Delete subject document:
  - `lib/Features/Subjects/Data/datasources/subjects_remote_data_source.dart`
  - `lib/Features/Profile/Data/profile_source.dart`

### Main reads/queries

- Student subjects: `arrayContains` on `subject_emailSts`.
- Teacher subjects: equality on nested field `subject_teacher.teacher_email`.
- Join by code: equality on `subject_codeSub`.

## 4) `Subjects/{subjectId}/Exams/{examId}`

### Exam document fields

| Key | Type in code | Notes |
|---|---|---|
| `exam_id` | `String` | Usually same as sub-doc id. |
| `exam_idSubject` | `String` | Parent subject id. |
| `exam_idTeacher` | `String` | Teacher user id. |
| `exam_ExamResult` | `List<Map>` | Student submissions snapshot. |
| `exam_static` | `Map` | Exam template/questions/settings. |
| `exam_createdAt` | `int` | Milliseconds since epoch. |
| `exam_FinishAt` | `int` | Milliseconds since epoch. |
| `startedAt` | `int` | Milliseconds since epoch. |

### `exam_static` fields

| Key | Type |
|---|---|
| `examResult_Q&A` | `List<Map>` |
| `levelExam` | `String` (`easy`/`normal`/`hard`) |
| `numberOfQuestions` | `int` |
| `randomQuestions` | `bool` |
| `typeExam` | `String` |
| `time` | `String` |
| `geminiModel` | `String` |

### `examResult_Q&A` item fields

| Key | Type in code |
|---|---|
| `questionId` | `String` |
| `questionType` | `String` |
| `questionText` | `String` |
| `options` | `List<String>` |
| `correctAnswer` | `String` |
| `studentAnswer` | `String` |
| `score` | Mixed (`String` default, later numeric in submit payload) |
| `evaluated` | `bool` (added during submit flow) |

### `exam_ExamResult` item fields

| Key | Type |
|---|---|
| `examResult_emailSt` | `String` |
| `examResult_degree` | `String` |
| `examResult_Q&A` | `List<Map>` |
| `levelExam` | `String` |
| `numberOfQuestions` | `int` |
| `randomQuestions` | `bool` |
| `typeExam` | `String` |

### Main writes

- Save exam document:
  - `lib/Features/Exams/view_exam/data/datasources/view_exam_remote_data_source.dart`
- Add default result with `arrayUnion`:
  - `lib/Features/Exams/view_exam/data/datasources/view_exam_remote_data_source.dart`
- Submit exam: overwrite full `exam_ExamResult` list:
  - `lib/Features/Exams/do_exam/data/datasources/do_exam_remote_data_source.dart`
- Remove exam docs on subject/user cleanup:
  - `lib/Features/Subjects/Data/datasources/subjects_remote_data_source.dart`
  - `lib/Features/Profile/Data/profile_source.dart`

## 5) `Notification/{notificationId}`

### Stored fields

| Key | Type |
|---|---|
| `id` | `String` |
| `topicId` | `String` |
| `titleTopic` | `String` (enum name) |
| `body` | `String` |
| `createdAt` | `int` (ms epoch) |
| `updatedAt` | `int` (ms epoch) |
| `readOut` | `List<String>` |
| `readIn` | `List<String>` |

### Main writes

- Create notification document after FCM send:
  - `lib/Core/Services/Notifications/notification_services.dart`
- Mark read out (`arrayUnion` email):
  - `lib/Features/Notifications/Data/notification_source.dart`
- Mark read in (`arrayUnion` email):
  - `lib/Features/Notifications/Data/notification_source.dart`
- Delete by topic during cleanup:
  - `lib/Features/Subjects/Data/datasources/subjects_remote_data_source.dart`
  - `lib/Features/Profile/Data/profile_source.dart`

### Main reads/queries

- Stream notifications by `topicId` equality per subscribed topic:
  - `lib/Features/Notifications/Data/notification_source.dart`

## 6) Data Risks To Resolve During API Migration

- Mixed time representations:
  - `user_createdAt` written as timestamp-like value, while other time fields are integer milliseconds.
- `UserModel.fromJson` does not parse Firestore `Timestamp` explicitly for `user_createdAt`.
- `score` in question payload is not consistently typed (`String` vs numeric).
- `exam_ExamResult` is updated as a whole array in submit flow, which is race-prone under concurrent writes.
- Notification id is duplicated (document id and `id` field).

## 7) Suggested API Mapping (for upcoming model changes)

- Split into explicit DTOs/contracts:
  - `UserDto`
  - `SubjectDto`
  - `ExamDto`
  - `ExamQuestionDto`
  - `ExamSubmissionDto` (prefer separate resource, not embedded unbounded array)
  - `NotificationDto`
- Standardize all datetime fields to one format (recommended: ISO-8601 UTC string).
- Enforce stable scalar types (`score` as number, not string).
- Keep `topicId` logic explicit in backend (`subjectId`, `subjectId_admin`, `allUsers`).

## 8) Realtime DB Note (Not Firestore)

Live exam state currently exists in Realtime Database under:
- `Exam_Live/{specialId}`

Key fields include:
- `start_time`, `time`, `dispose_exam`, `id_live_exam`, plus per-question nodes.

