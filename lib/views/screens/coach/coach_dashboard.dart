import 'package:athletix/components/alertDialog_signOut_confitmation.dart';
import 'package:flutter/material.dart';
import 'package:athletix/l10n/app_localizations.dart';

class CoachDashboardScreen extends StatelessWidget {
  // 1. Add the setLocale function to the constructor
  final Function(Locale) setLocale;
  const CoachDashboardScreen({super.key, required this.setLocale});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.coachDashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: localizations.logoutTooltip,
            onPressed: () async {
              await signoutConfirmation(context, setLocale: setLocale);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          localizations.welcomeCoachMessage,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
