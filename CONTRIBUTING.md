# ✨ Contributing to Athletix

First off, thank you for considering contributing to Athletix! 🙌

---

## 🚀 Getting Started

1. **Fork the repository**: [Fork the repo from here](https://github.com/vjlive/athletix/fork)

2. **Clone your fork into your system**

```bash
git clone [https://github.com/](https://github.com/)<your-username>/athletix.git
cd athletix
````

3.  **Set up the project**

      * Follow the [Development Guide](https://www.google.com/search?q=./DEVELOPMENT.md) to install and run locally.

-----

### 🙋‍♀️ How to Get Assigned

To start working on an issue:

1.  Go through the [Issues](https://github.com/vjlive/athletix/issues) tab.
2.  If you find an unassigned issue you’d like to work on, **comment below the issue** asking to be assigned (mention that you are a GSSoC'25 contributor if applicable).
3.  Wait until a maintainer assigns you the issue.
4.  Do not start working on any issue unless you are assigned to it.

## Contributing Guidelines

### 🏗️ Project Setup Instructions

  * Install dependencies:

<!-- end list -->

```bash
flutter pub get
```

  * Run the application:

<!-- end list -->

```bash
flutter run
```

  - It is recommended to use your physical mobile for development.

### 🌱 Branching Strategy

  * Always branch out from `main`:

<!-- end list -->

```bash
git checkout -b feat/your-feature-name
```

  * Use these prefixes for your branches:

| Type    | Prefix   |
| ------- | -------- |
| Feature | `feat/`  |
| Fix     | `fix/`   |
| Docs    | `docs/`  |
| Chore   | `chore/` |

**Examples:**

  - `feat/login-screen`
  - `fix/navbar-overlap`
  - `docs/update-contributing-guide`

### ✍️ Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```bash
git commit -m "feat(component): add navbar component"
```

### 📬 Pull Request Process

  * Ensure your PR includes a clear title and description.

  * Link to any relevant issues.

  * Add screenshots or demos if applicable.

  * PRs should:

      * Be reviewed by at least one maintainer
      * Be rebased or merged cleanly with `main`

-----

### 🔍 Code Review Process

Once you open a PR:

1.  A maintainer will review it and may suggest changes or improvements.
2.  Be prompt and respectful in responding to feedback.
3.  If requested, make the necessary changes and push them to the same branch.
4.  Once approved, your PR will be merged into the `main` branch.

Maintainers may also tag your PR with relevant labels like `gssoc`, `enhancement`, or `documentation`.

-----

## 🌍 Contributing Translations

We welcome contributions to make Athletix accessible to more users worldwide\! If you'd like to add a new language or improve existing translations, please follow these steps.

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

-----

## 🐛 How to File a Bug

  * Open an [issue](https://github.com/vjlive/athletix/issues)

  * Choose **Bug Report** template

  * Include:

      * Steps to reproduce
      * Expected vs actual behavior
      * Screenshots or logs if helpful

-----

## ✅ Pull Request Checklist

Before submitting your pull request, please ensure the following:

  * [ ] **Clear title and description** that explain what the PR does
  * [ ] **Follows the branching strategy** (`feat/`, `fix/`, etc.) and **uses Conventional Commits**
  * [ ] Includes **tests** or **relevant usage examples**, if applicable
  * [ ] All **new/updated components are documented**
  * [ ] Screenshots/demos included (for UI changes)
  * [ ] Linked to a related **issue** (if one exists)
  * [ ] PR is up-to-date with the `main` branch (`git pull origin main` before pushing)
  * [ ] Ready for review: tagged with appropriate labels (e.g., `enhancement`, `bug`, `docs`)
  * [ ] Reviewed and approved by at least one maintainer

-----

## 📚 Useful Resources

  * [Flutter Documentation](https://docs.flutter.dev/)
  * [Firebase Documentation](https://firebase.google.com/docs)
  * [Conventional Commits Guide](https://www.conventionalcommits.org/en/v1.0.0/)
  * [Open Source Guide](https://opensource.guide/how-to-contribute/)

-----

### 🛠️ Troubleshooting

If you face issues during setup or development, here are some common solutions:

  - ❗ **Firebase Configuration Missing**

      - Ensure you have your `google-services.json` and Firebase setup correctly.
      - Refer to the `DEVELOPMENT.md` file for setup instructions.

  - ❗ **Plugin Compatibility Errors**

      - Run `flutter pub upgrade` to refresh dependencies.
      - Check if any Flutter or plugin versions need to be updated.

  - ❗ **Google Maps API Not Working**

      - Make sure the correct API key is set in your `AndroidManifest.xml` or `AppDelegate.swift`.
      - API key must have proper permissions in the Google Cloud console.

## 📜 Code of Conduct

We follow the [Contributor Covenant Code of Conduct](https://www.google.com/search?q=./CODE_OF_CONDUCT.md). Be respectful, inclusive, and collaborative in all contributions.

-----

Let’s build something great together\!

