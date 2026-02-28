# Exams v3 API Contract

This document covers:
- `POST /v1/subject/{id}/create_exam`
- `GET /v1/subject/{id}/get_exams`
- `POST /v1/subject/{id}/exam/{id_exam}/submit_exam`
- `GET /v1/subject/{id}/exam/{id_exam}/get_result`

## Common

- All endpoints require: `Authorization: Bearer <token>`.
- `id` in routes is the subject id.
- `id_exam` in routes is the exam id.
- Success shape is generally:

```json
{
  "message": "...",
  "data": {}
}
```

- Error shape:

```json
{
  "message": "..."
}
```

---

## 1) Create Exam

### Endpoint
`POST /v1/subject/{id}/create_exam`

### Request JSON

```json
{
  "name": "Midterm 1",
  "levelExam": "easy",
  "isRandom": false,
  "questionCount": 2,
  "timeMinutes": 30,
  "startAt": "2026-02-27T10:00:00.000Z",
  "endAt": "2026-02-27T11:00:00.000Z",
  "questions": [
    {
      "id": "q1",
      "text": "2+2?",
      "type": "mcq",
      "correctAnswer": "4",
      "options": [
        { "id": "a", "choice": "3" },
        { "id": "b", "choice": "4" }
      ]
    },
    {
      "id": "q2",
      "text": "Capital of France?",
      "type": "text",
      "correctAnswer": "paris",
      "options": null
    }
  ]
}
```

### Request Rules

- Role `student` is not allowed to create exam.
- `startAt` must be before `endAt`.
- `questionCount` must equal `questions.length`.

### Success Response (200)

```json
{
  "message": "Added Sucseffuly"
}
```

### Errors

- `400`:
  - `Invalid role`
  - `Invalid request body`
  - `Start date must be before end date`
  - `Question count mismatch`
- `401`: Unauthorized token/session
- `405`: wrong HTTP method
- `500`: Internal Server Error

---

## 2) Get Exams

### Endpoint
`GET /v1/subject/{id}/get_exams`

### Request JSON
No body required.

### Success Response (200)

```json
{
  "message": "Successfully",
  "data": [
    {
      "_id": "67c0f2f8f0f1a6b5e4d3c2b1",
      "name": "Midterm 1",
      "levelExam": "easy",
      "status": "running",
      "score": {
        "total": 10,
        "degree": 7
      },
      "isRandom": false,
      "questionCount": 10,
      "timeMinutes": 30,
      "startAt": "2026-02-27T10:00:00.000Z",
      "endAt": "2026-02-27T11:00:00.000Z",
      "createdAt": "2026-02-26T09:00:00.000Z",
      "questions": [
        {
          "id": "q1",
          "text": "2+2?",
          "type": "mcq",
          "correctAnswer": "4",
          "options": [
            { "id": "a", "choice": "3" },
            { "id": "b", "choice": "4" }
          ]
        }
      ]
    }
  ]
}
```

### Notes

- If no exams exist, `data` is an empty array.
- For non-owner users, `status` and `score` are derived from the user exam result.
- For owner/teacher records, `status` and `score` may be `null`.

### Errors

- `401`: Unauthorized token/session
- `405`: wrong HTTP method

---

## 3) Submit Exam

### Endpoint
`POST /v1/subject/{id}/exam/{id_exam}/submit_exam`

### Request JSON

```json
{
  "status": "finished",
  "answers": [
    {
      "id": "q1",
      "studentAnswer": "4"
    },
    {
      "id": "q2",
      "studentAnswer": "Paris"
    }
  ]
}
```

### Allowed `status` values

- `finished`
- `time_expired`
- `connection_lost`
- `disposed`

### Success Response (200)

`finished` case:

```json
{
  "message": "Exam submitted successfully",
  "data": {
    "status": "finished"
  }
}
```

`time_expired` case:

```json
{
  "message": "Exam time expired",
  "data": {
    "status": "time_expired"
  }
}
```

### Errors

- `400`:
  - `Invalid request body`
  - `status required`
  - `Invalid status`
  - `answers required`
  - `Exam not found`
  - `Exam not started`
  - `Exam already submitted`
- `403`:
  - `User is not in this subject`
- `401`: Unauthorized token/session
- `405`: wrong HTTP method
- `500`: Internal Server Error

---

## 4) Get Result

### Endpoint
`GET /v1/subject/{id}/exam/{id_exam}/get_result`

### Request JSON
No body required.

### Role Behavior

#### Student role (`student`)

- Returns only this student result.
- Available only after exam end time (`exam.endAt`).

Success shape:

```json
{
  "message": "Successfully",
  "data": {
    "student": {
      "id": "67c0f2f8f0f1a6b5e4d3c2b2",
      "name": "Ali",
      "email": "ali@mail.com"
    },
    "answers": [
      {
        "id": "q1",
        "studentAnswer": "4",
        "score": 1
      },
      {
        "id": "q2",
        "studentAnswer": "",
        "score": 0
      }
    ],
    "score": {
      "total": 10,
      "degree": 7
    }
  }
}
```

#### Instructor/Admin role (non-student)

- Returns all active students in this subject.
- List order is by earliest closed attempt end time (`endAt`) first.
- Students without closed submission still appear with empty answers and zero score.

Success shape:

```json
{
  "message": "Successfully",
  "data": [
    {
      "student": {
        "id": "67c0f2f8f0f1a6b5e4d3c2b2",
        "name": "Ali",
        "email": "ali@mail.com"
      },
      "answers": [
        {
          "id": "q1",
          "studentAnswer": "4",
          "score": 1
        }
      ],
      "score": {
        "total": 10,
        "degree": 7
      }
    }
  ]
}
```

### Errors

- `400`:
  - `Result is not available yet` (student before exam end)
  - `Exam not found`
- `403`:
  - `User is not in this subject`
- `401`: Unauthorized token/session
- `405`: wrong HTTP method

---

## Enums Used

### `levelExam`
- `easy`
- `normal`
- `hard`

### result status values
- `running`
- `finished`
- `time_expired`
- `connection_lost`
- `disposed`
- `unknown`
