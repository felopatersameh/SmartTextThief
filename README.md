<div align="center">

# 📚 Smart Text Thief

### Intelligent SaaS platform for secure online exam creation and management

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Gemini AI](https://img.shields.io/badge/Gemini_AI-8E75B2?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev)

**An educational app focused solely on exams: creation, execution, monitoring, and analysis**

• [Setup](#-quick-setup) • [Screens](#-screens)

</div>

---

## 🎯 What Makes It Different

```
✓ Create exams quickly using artificial intelligence
✓ Simple and straightforward design without complexity
✓ Robust security system during exams
✓ Analytics that help improve assessment quality
```

**Goal:** Deliver a faster experience for teachers, a fair experience for students, and complete administrative control at the platform level.

---

## 👥 User Types

<table>
<tr>
<td width="33%" align="center">

### 👨‍🏫 Teacher

Create courses and exams, manage settings, track results

</td>
<td width="33%" align="center">

### 🎓 Student

Join courses, take exams, track results

</td>
<td width="33%" align="center">

### 👨‍💼 Admin

Manage the system, data, and users at the platform level

</td>
</tr>
</table>

> **Note:** The current app interface supports Teacher/Student selection for end users, while the Admin role exists within the scope of system and platform management.

---

## 👨‍🏫 Teacher Highlights

<details open>
<summary><b>📚 Courses & Exams</b></summary>

- ✅ Create educational subjects (Open / Closed)
- ✅ Create exams and link them to subjects
- ✅ Review and edit questions before first publication only
- ✅ Export exams as PDF

</details>

<details>
<summary><b>⚙️ Flexible Exam Settings</b></summary>

- 🎯 **Difficulty Level:** Easy / Medium / Hard
- ⏰ **Timing:** Start and end time
- 📝 **Questions:** Question types and quantities
- 📎 **Content:** Link exam to content (PDF / Image / Text)

</details>

<details>
<summary><b>📊 Analytics & Notifications</b></summary>

- 📈 Analytical dashboard to track student results and overall performance
- 🔔 Real-time notifications for important events within the course

</details>

---

## 🎓 Student Highlights

### 📚 Exam Experience

- ➕ Quick access to courses and exams
- ⏰ Take exams within the specified time
- 📊 View results according to exam policy

### 📝 Supported Question Types

| Type | Description |
|------|-------------|
| **MCQ** | Multiple choice questions |
| **True/False** | True or false questions |
| **Essay** | Essay questions |

### 🔐 Protection During Testing

```
🚫 Screenshot prevention on Android & iOS
⏱️ 2-minute grace period when exiting the app
⚠️ Automatic exam termination after grace period expires
```

---

## 👨‍💼 Admin Highlights

<div align="center">

| Area | Description |
|------|-------------|
| 👥 **Users** | Manage users and roles |
| 📚 **Content** | Manage subjects and exams |
| 📊 **Data** | Monitor platform-wide data |
| ⚙️ **Settings** | Control system settings and plans |

</div>

---

## 🔐 Security and Authentication

<div align="center">

```mermaid
graph LR
    A[Google Sign-In] --> B[Firebase Auth]
    B --> C[Identity & Data Flow]
    C --> D[Exam Session Protection]
```

</div>

- 🔑 Login via **Google Sign-In**
- 🔥 Firebase-based identity and data flow
- 🛡️ Exam session protection to reduce cheating and leaks

---

## 🤖 AI Engine

<div align="center">

### Powered by **Gemini 2.5 Flash** ⚡

</div>

#### 🎯 Use Cases

- 💡 Support question generation from content
- 📝 Essay answer analysis

#### ⚙️ Flexibility

```yaml
Default Model: gemini-2.5-flash
Custom API: Support for user API Key (from profile)
```

---

## 💎 SaaS Plans

<table>
<tr>
<td width="50%" align="center">

### 🆓 Free Plan

**For Basic Use**

Limited features suitable for personal use

</td>
<td width="50%" align="center">

### 👑 Pro Plan

**For Professional Use**

All advanced features and full support

</td>
</tr>
</table>

---

## 🌐 Web Version

> **Landing Page Only**

<div align="center">

| Features | Description |
|----------|-------------|
| ℹ️ **Introduction** | Introduce the app |
| ✨ **Showcase** | Display features |
| 📱 **Conversion** | Direct users to download the app |

**❌ Does not include exam execution or Dashboard**

</div>

---

## 📱 Screens

<details open>
<summary><b>View All Screens (Click to Expand)</b></summary>

### 🎨 Authentication Flow

<table>
<tr>
<td width="33%" align="center">
<img src="assets/screens/login1.jpg" alt="Login Screen 1" width="250"/>
<br/><b>Login Screen 1</b>
</td>
<td width="33%" align="center">
<img src="assets/screens/login2.jpg" alt="Login Screen 2" width="250"/>
<br/><b>Login Screen 2</b>
</td>
<td width="33%" align="center">
<img src="assets/screens/login3.jpg" alt="Login Screen 3" width="250"/>
<br/><b>Login Screen 3</b>
</td>
</tr>
<tr>
<td align="center" colspan="3">
<img src="assets/screens/choose_role.jpg" alt="Choose Role" width="250"/>
<br/><b>Choose Role</b>
</td>
</tr>
</table>

### 📚 Main Screens

<table>
<tr>
<td width="33%" align="center">
<img src="assets/screens/subjects.jpg" alt="Subjects" width="250"/>
<br/><b>Subjects</b>
</td>
<td width="33%" align="center">
<img src="assets/screens/subject_details.jpg" alt="Subject Details" width="250"/>
<br/><b>Subject Details</b>
</td>
<td width="33%" align="center">
<img src="assets/screens/create_exam.jpg" alt="Create Exam" width="250"/>
<br/><b>Create Exam</b>
</td>
</tr>
</table>

### 🎓 Exam Screens

<table>
<tr>
<td width="50%" align="center">
<img src="assets/screens/do_exam.jpg" alt="Do Exam" width="250"/>
<br/><b>Take Exam</b>
</td>
<td width="50%" align="center">
<img src="assets/screens/exam_result.jpg" alt="Exam Result" width="250"/>
<br/><b>Exam Result</b>
</td>
</tr>
</table>

### ⚙️ Common Screens

<table>
<tr>
<td width="33%" align="center">
<img src="assets/screens/dashboard.jpg" alt="Dashboard" width="250"/>
<br/><b>Dashboard</b>
</td>
<td width="33%" align="center">
<img src="assets/screens/notifications.jpg" alt="Notifications" width="250"/>
<br/><b>Notifications</b>
</td>
<td width="33%" align="center">
<img src="assets/screens/profile.jpg" alt="Profile" width="250"/>
<br/><b>Profile</b>
</td>
</tr>
</table>

</details>

---

## 🛠️ Tech Stack

<div align="center">

### Frontend

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

### Backend & Services

![Firebase Auth](https://img.shields.io/badge/Firebase_Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Firestore](https://img.shields.io/badge/Cloud_Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Realtime DB](https://img.shields.io/badge/Realtime_Database-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![FCM](https://img.shields.io/badge/FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

### State Management

![BLoC](https://img.shields.io/badge/BLoC-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Cubit](https://img.shields.io/badge/Cubit-0175C2?style=for-the-badge&logo=dart&logoColor=white)

### AI & Tools

![Gemini AI](https://img.shields.io/badge/Gemini_API-8E75B2?style=for-the-badge&logo=google&logoColor=white)
![PDF](https://img.shields.io/badge/PDF-FF0000?style=for-the-badge&logo=adobe&logoColor=white)
![OCR](https://img.shields.io/badge/OCR-4285F4?style=for-the-badge&logo=google&logoColor=white)

</div>

---

## 🚀 Quick Setup

### 1️⃣ Requirements

```bash
✓ Flutter 3.38.9 (stable) or compatible
✓ Dart 3.10.x
✓ Firebase project configured
```

### 2️⃣ Install dependencies

```bash
flutter pub get
```

### 3️⃣ Environment file

Copy `.env.example` to `.env` and fill in the values:

```env
GOOGLE_WEB_CLIENT_ID=
FCM_PROJECT_ID=
FCM_SERVICE_ACCOUNT_PATH=
GEMINI_FALLBACK_API_KEY=
```

### 4️⃣ Firebase files

<table>
<tr>
<td width="50%">

**Android**

```
android/app/google-services.json
```

</td>
<td width="50%">

**iOS**

```
ios/Runner/GoogleService-Info.plist
```

</td>
</tr>
</table>

**Generated options:**

```
lib/firebase_options.dart
```

### 5️⃣ Run

```bash
flutter run
```

---

## 📊 Project Status

<div align="center">

### ✅ Ready for Publish

![Progress](https://img.shields.io/badge/Progress-98%25-brightgreen?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Ready-success?style=for-the-badge)

</div>

#### ✔️ Completed

- ✅ All core features implemented
- ✅ Firebase integration complete
- ✅ AI engine integrated
- ✅ Security system active
- ✅ UI/UX finalized

#### 🔄 Remaining Work

- 🔧 Minor polishing
- 📱 Store assets finalization

---

<div align="center">

### ⭐ If you find this project helpful, please give it a star

**Made with ❤️ for Education**

---

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](#)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](#)
[![Twitter](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](#)

</div>
