<p align="center">
  <img src="web/athletix_banner.png" alt="Athletix Banner" width="100%">
</p>

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
## 🧩 Troubleshooting
### 1. 🔥 Firebase Configuration Missing
**Issue**: App throws Firebase initialization error.
**Solution:**
-Download your google-services.json file from Firebase Console.
-Place it in android/app/ directory.

### 2. 📦 Plugin Issues
**Issue**: Plugin not found or version mismatch.
**Solution:**
-Run flutter pub get to reinstall dependencies.
-Check for version conflicts in pubspec.yaml.

### 3. 🗺️ Google Maps Not Showing
**Issue**: Map doesn't load or crashes.
**Solution:**
-Ensure you've added your Google Maps API key in the android/app/src/main/AndroidManifest.xml.
-Enable Maps SDK in your Google Cloud console.

### 4. 🚫 Emulator Permission Issues
**Issue**: Notifications or Maps don't work on emulator.
**Solution:**
-Use a real device when possible.
-Emulators may lack Play Services or required permissions.

## 🧪 How to Run Tests

To run the Flutter tests:

```bash
flutter test
```

This will execute all unit and widget tests in the `test/` directory.

---

## 🤝 How to Contribute

### 🌍 Contributing Translations

We welcome contributions to make Athletix accessible to more users worldwide! If you'd like to add a new language or improve existing translations, please follow these steps.

Athletix uses Flutter's built-in internationalization (i18n) system based on `flutter_localizations` and Application Resource Bundle (`.arb`) files.

#### Adding a New Language

1.  **Create a new `.arb` file**: In the `lib/l10n/` directory, create a new file named `app_<your_language_code>.arb`. For example, for French, create `app_fr.arb`.
2.  **Copy existing keys**: Copy all key-value pairs from `lib/l10n/app_en.arb` into your new `app_<your_language_code>.arb` file.
3.  **Translate the strings**: For each key in your new file, translate the corresponding English string into your target language. Make sure to keep the keys exactly as they are in `app_en.arb`.
    ```json
    // Example for app_fr.arb
    {
      "@@locale": "fr",
      "financialTrackerTitle": "Suivi Financier",
      // ... more translated strings
    }
    ```
4.  **Update `pubspec.yaml`**: Add your new language code to the `generate` section under `flutter_localization` in `pubspec.yaml`.
    ```yaml
    flutter:
      generate: true
      # ... other flutter settings
    flutter_localizations:
      # These are the languages your app will support.
      # Add your new locale here.
      supported_locales:
        - en
        - hi
        - <your_language_code> # e.g., fr
    ```

#### Updating Existing Translations

1.  **Locate the `.arb` file**: Navigate to `lib/l10n/` and find the `app_<language_code>.arb` file for the language you wish to update (e.g., `app_hi.arb`).
2.  **Modify strings**: Update the translated strings for any keys that need improvement or new translations for recently added features.

#### Generating Localization Code

After creating new `.arb` files or modifying existing ones, you **must** run the localization code generator:

```bash
flutter gen-l10n
```

This command will update the `lib/generated/app_localizations.dart` file, which is used by the app to access the translated strings.

#### Testing Your Translations

To test your new or updated translations, you can change your device's language settings to the language you've added. Alternatively, you can temporarily modify `main.dart` to force a specific locale for testing purposes:

```dart
// In lib/main.dart, within your MaterialApp widget:
MaterialApp(
  // ... other properties
  locale: const Locale('<your_language_code>'), // e.g., const Locale('fr')
  // ...
);
```

Remember to revert this change before committing your code.

### Submitting Your Contribution

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
