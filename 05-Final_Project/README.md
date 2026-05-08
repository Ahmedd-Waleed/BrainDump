# BrainDump AI

> **Capture your thoughts instantly. AI organizes them.**

A cross-platform Flutter app that lets you capture fleeting thoughts via voice or text, then automatically categorizes, prioritizes, and extracts deadlines using an **on-device NLP engine** — no APIs required.

---

## Features

- **Instant Capture** — Voice or text in under 3 seconds
- **On-Device AI** — Auto-categorizes thoughts (Task / Idea / Reminder / Note / Errand / Question)
- **Smart Priority** — Detects urgency from your wording
- **Deadline Detection** — Parses natural language ("by Friday", "tomorrow", "in 3 days")
- **Auto-Tagging** — Generates relevant tags (#work, #health, #tech, etc.)
- **Tasks** — Convert captures to actionable tasks (Kanban: To Do / Doing / Done)
- **Insights** — Analytics dashboard with category breakdown, top tags, daily activity
- **Notifications** — Daily review reminders, deadline alerts
- **Authentication** — Email/password sign in & sign up
- **Dark Mode** — Light, dark, and system theme support
- **Cloud Sync** — Real-time data via Firebase Firestore

---

## Architecture

```
lib/
├── main.dart                   # Entry point + Firebase init
├── app.dart                    # MaterialApp + providers
├── firebase_options.dart       # Firebase config (replace via flutterfire)
│
├── config/
│   └── app_theme.dart          # Light + dark themes
│
├── models/
│   ├── capture_model.dart      # Capture entity
│   └── task_model.dart         # Task entity
│
├── services/
│   ├── auth_service.dart       # Firebase Auth wrapper
│   ├── nlp_engine.dart         # ⭐ On-device "AI" engine
│   └── notification_service.dart
│
├── repositories/
│   ├── capture_repository.dart # Firestore CRUD for captures
│   └── task_repository.dart    # Firestore CRUD for tasks
│
├── providers/
│   ├── theme_provider.dart     # Theme state
│   └── settings_provider.dart  # User preferences
│
├── components/
│   ├── primary_button.dart
│   ├── secondary_button.dart
│   ├── outline_button.dart
│   ├── mic_button.dart
│   ├── category_chip.dart
│   ├── priority_badge.dart
│   └── auth/
│       ├── auth_form.dart      # ⭐ Single component for Sign In + Sign Up
│       └── auth_text_field.dart
│
├── screens/
│   ├── auth_gate.dart          # Decides login vs main app
│   ├── main_navigation.dart    # Bottom nav shell
│   ├── capture_screen.dart
│   ├── inbox_screen.dart
│   ├── tasks_screen.dart
│   ├── insights_screen.dart
│   ├── settings_screen.dart
│   ├── capture_detail_screen.dart
│   ├── task_detail_screen.dart
│   ├── auth/auth_screen.dart
│   └── onboarding/onboarding_screen.dart
│
└── utils/
    ├── colors.dart             # Color tokens (light + dark)
    └── text_styles.dart        # Typography
```

---

## Setup Instructions

### Prerequisites

- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- Firebase account (free tier works)
- A code editor (VS Code or Android Studio recommended)

### Step 1: Install dependencies

```bash
cd braindump
flutter pub get
```

### Step 2: Set up Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project (e.g., "braindump-ai")
3. Enable **Authentication** → Email/Password sign-in method
4. Enable **Firestore Database** → Start in test mode
5. Enable **Cloud Messaging** (optional, for push notifications)

### Step 3: Connect your app to Firebase

Install FlutterFire CLI if you haven't:

```bash
dart pub global activate flutterfire_cli
```

Then run:

```bash
flutterfire configure
```

Select your Firebase project. This will overwrite `lib/firebase_options.dart` with real values.

### Step 4: Add the Poppins font

Download Poppins fonts from [Google Fonts](https://fonts.google.com/specimen/Poppins) and place these files in `assets/fonts/`:

- `Poppins-Regular.ttf`
- `Poppins-Medium.ttf`
- `Poppins-SemiBold.ttf`
- `Poppins-Bold.ttf`

### Step 5: Firestore Security Rules

In the Firebase Console → Firestore → Rules, paste:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Step 6: Run the app

```bash
flutter run
```

---

## How the "AI" Works

BrainDump uses an **on-device NLP engine** (`lib/services/nlp_engine.dart`) instead of cloud AI APIs. The engine:

| Feature                | How it works                                                                     |
| ---------------------- | -------------------------------------------------------------------------------- |
| **Category detection** | Weighted keyword scoring across 6 categories (task, idea, reminder, etc.)        |
| **Priority detection** | Counts urgency keywords ("urgent", "asap") vs. casual words ("maybe", "someday") |
| **Deadline parsing**   | Regex + weekday matching ("by Friday", "in 3 days", "tomorrow")                  |
| **Tag generation**     | Domain dictionary lookup (work, health, tech, finance, etc.)                     |
| **Summary**            | First 60 chars truncation                                                        |

### Why no APIs?

- **Privacy** — text never leaves your device
- **Speed** — analysis runs in <50ms vs. 2–3s for cloud calls
- **Offline** — capture and organize without internet
- **Compliance** — meets the "no APIs" requirement

---

## Tech Stack

| Layer            | Technology                                  |
| ---------------- | ------------------------------------------- |
| Framework        | Flutter 3.x / Dart 3.x                      |
| State Management | Provider                                    |
| Auth             | Firebase Authentication                     |
| Database         | Cloud Firestore                             |
| Notifications    | flutter_local_notifications + FCM           |
| Local Storage    | shared_preferences                          |
| Voice (optional) | speech_to_text                              |
| AI               | Custom on-device NLP engine (no API calls)  |

---

## Screens

1. **Onboarding** (3 pages) — First launch only
2. **Auth** — Sign In / Sign Up via single custom component
3. **Capture** — Mic + text input, real-time recent captures
4. **Inbox** — All captures, filterable by category, swipe to convert/archive
5. **Tasks** — Kanban board (To Do / Doing / Done) with manual task creation
6. **Insights** — Real-time stats dashboard
7. **Settings** — Theme, AI preferences, notifications, sign out

---

## Testing the App

After setup, try capturing these to see the NLP engine work:

| Input                                            | Expected output                               |
| ------------------------------------------------ | --------------------------------------------- |
| "Finish report by Friday"                        | Task, High priority, deadline=Friday          |
| "What if we add a dark mode toggle?"             | Idea, Medium priority                         |
| "Buy milk and eggs"                              | Errand, Medium, tag=#shopping                 |
| "Doctor appointment tomorrow"                    | Reminder, High, deadline=tomorrow, tag=#health |
| "Why is the build failing?"                      | Question, Medium, tag=#tech                   |

---

## License

Academic project. All rights reserved.
