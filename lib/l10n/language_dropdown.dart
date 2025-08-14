// lib/l10n/language_dropdown.dart
import 'package:flutter/material.dart';

class LanguageDropdown extends StatelessWidget {
  final Function(Locale) onLanguageChanged;
  final Locale? currentLocale;

  const LanguageDropdown({
    super.key,
    required this.onLanguageChanged,
    this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: currentLocale?.languageCode ?? 'en',
      icon: const Icon(Icons.language),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onLanguageChanged(Locale(newValue));
        }
      },
      items: const [
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
      ],
    );
  }
}
