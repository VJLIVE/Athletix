import 'package:flutter/material.dart';
import 'package:athletix/l10n/app_localizations.dart';

class ManagePlayersScreen extends StatelessWidget {
  const ManagePlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.managePlayersTitle)),
      body: Center(child: Text(localizations.managePlayersScreenContent)),
    );
  }
}
