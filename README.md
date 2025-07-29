
# Don't forget to star our repository

# 🏋️ Athletix

**Athletix** is a Flutter-based mobile application designed to streamline collaboration between athletes, coaches, doctors, and sports organizations. It offers a centralized platform to manage tournaments, track performance and injuries, maintain schedules, and facilitate communication while respecting user roles.

---

## 🚀 Features

### 🔐 Authentication & Role-based Access

- **Firebase Authentication**: Secure login for all users.
- **Role-based Access (RBA)**:
  - Four user roles: **Athletes**, **Doctors**, **Coaches**, and **Organizations**
  - Each role has a distinct dashboard with specific permissions.
  - Role checked via Firestore `role` field, redirecting users post-login.
- **Signup & Login**:
  - Separate signup and login flows for Athletes, Doctors, and Coaches.
  - Login-only access for Organizations.

### 📋 Profiles

- **Athletes**: Includes personal details and their sport.
- **Doctors**: Includes personal details and specialization.
- **Coaches**: Includes their sport.
- **Organizations**: Associated with a specific sport.

### 🗓️ Timetable & Notifications

- Users can create and save activity timetables in Firestore.
- Push notifications sent via **Firebase Cloud Messaging (FCM)** at the start of each activity.

### 📈 Injury & Performance Logs

- **Athletes** can log:
  - **Injury logs**: Details for doctors and monitoring.
  - **Performance logs**: Track progress over time.
- Logs are securely stored in **Firestore** and accessible to doctors and coaches.

### 🗺️ Tournaments with Google Maps

- **Organizations** can create tournaments with:
  - Name, level (District, State, National, International), date, time, and location using **Google Maps SDK**.
  - Data stored in Firestore under the `tournaments` collection.
- **Athletes** can:
  - View upcoming tournaments filtered by their sport.
  - See tournaments as markers on an interactive map.
  - Tap markers to view tournament details (level, date, time, address) in a modal.

---

## 🛠️ Setup Guide

### ✅ Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Git](https://git-scm.com/downloads)
- A physical Android device (recommended)

---

### 📥 Clone Your Fork

```bash
git clone https://github.com/<your-username>/Athletix.git
cd Athletix
```

### 📦 Install Dependencies

```bash
flutter pub get
```

### ▶️ Run the App

```bash
flutter run
```

> 📱 **Tip**: It's recommended to use a physical Android device for better performance during development.

---

### 🧱 Tech Stack

| Technology                | Description                               |
|--------------------------|-------------------------------------------|
| 📱 Flutter                | Cross-platform UI toolkit                  |
| 🔥 Firebase              | Auth \| Firestore \| FCM (notifications)   |
| 🗺️ Google Maps SDK        | Interactive maps for tournaments           |
| 📦 Flutter Local Notifications | For scheduling reminders            |

---

## 🗂️ Project Structure

```
Athletix/
├── android/
├── assets/
│   ├── applogo.png
│   └── Running_Boy.json
├── functions/
├── ios/
├── lib/
│   ├── components/
│   │   ├── bottom_nav_bar.dart
│   │   └── fcm_listener.dart
│   ├── screens/
│   │   ├── athlete/
│   │   │   ├── athlete_dashboard.dart
│   │   │   ├── calendar_screen.dart
│   │   │   ├── injury_tracker_screen.dart
│   │   │   ├── performance_logs_screen.dart
│   │   │   └── tournaments_screen.dart
│   │   ├── coach/
│   │   │   └── coach_dashboard.dart
│   │   ├── doctor/
│   │   │   └── doctor_dashboard.dart
│   │   ├── organization/
│   │   │   ├── add_tournament_screen.dart
│   │   │   ├── manage_players_screen.dart
│   │   │   └── organization_dashboard.dart
│   │   ├── auth_screen.dart
│   │   ├── profile_screen.dart
│   │   └── splash_screen.dart
│   └── main.dart
├── linux/
├── macos/
├── test/
├── web/
├── windows/
├── .firebaserc
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── CODE_OF_CONDUCT.md
├── DEVELOPMENT.md
├── CONTRIBUTING.md
├── firebase.json
├── LICENSE
├── pubspec.lock
├── pubspec.yaml
└── README.md
```

---

## 🧪 How to Run Tests

To run the Flutter tests:

```bash
flutter test
```

This will execute all unit and widget tests in the `test/` directory.

---

## 🤝 How to Contribute

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to get started, report issues, or submit pull requests.

---

## 📫 Contact / Support

For questions, suggestions, or support, please open an issue on GitHub or contact the maintainers via the repository.

## 📜 License

This project is licensed under the **MIT License**

<p align="center">
  <a href="#top" style="font-size: 18px; padding: 8px 16px; display: inline-block; border: 1px solid #ccc; border-radius: 6px; text-decoration: none;">
    ⬆️ Back to Top
  </a>
</p>
