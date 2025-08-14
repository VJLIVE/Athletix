import 'package:athletix/components/alertDialog_signOut_confitmation.dart';
import 'package:athletix/views/screens/privacy_terms_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:athletix/l10n/app_localizations.dart';
import 'package:athletix/l10n/language_dropdown.dart'; // 1. Add the import for your LanguageDropdown

class ProfileScreen extends StatefulWidget {
  // 2. Add the setLocale function to the constructor
  final Function(Locale) setLocale;
  const ProfileScreen({super.key, required this.setLocale});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          localizations.profileTitle,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          // 3. Add the LanguageDropdown here
          LanguageDropdown(
            onLanguageChanged: widget.setLocale,
            currentLocale: Localizations.localeOf(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red), // 🔴 Red icon
            tooltip: localizations.logoutTooltip,
            onPressed: () async {
              // Fix: Pass the setLocale function to the dialog
              await signoutConfirmation(context, setLocale: widget.setLocale);
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: userDoc.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text(localizations.userProfileNotFound));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final role = (data['role'] ?? 'N/A').toString().toLowerCase();
          String? extraFieldLabel;
          String? extraFieldValue;

          if (role == 'doctor') {
            extraFieldLabel = localizations.specializationLabel;
            extraFieldValue =
                data['specialization'] ??
                localizations.notAvailableAbbreviation;
          } else if (role == 'athlete' || role == 'coach') {
            extraFieldLabel = localizations.sportLabel;
            extraFieldValue =
                data['sport'] ?? localizations.notAvailableAbbreviation;
          }

          final dobRaw = data['dob'];
          final createdAtRaw = data['createdAt'];

          final dobFormatted =
              dobRaw != null
                  ? _formatDate(
                    DateTime.tryParse(dobRaw) ?? DateTime.now(),
                    localizations,
                  )
                  : localizations.notAvailableAbbreviation;

          final createdAtFormatted =
              createdAtRaw != null
                  ? _formatDate(
                    (createdAtRaw as Timestamp).toDate(),
                    localizations,
                  )
                  : localizations.notAvailableAbbreviation;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              data['name'] ??
                                  localizations.notAvailableAbbreviation,
                              style: Theme.of(context).textTheme.headlineSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(role.toUpperCase()),
                              backgroundColor: Colors.blue.shade50,
                              labelStyle: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoRow(
                              localizations.emailLabel,
                              data['email'] ??
                                  localizations.notAvailableAbbreviation,
                            ),
                            const Divider(),
                            if (extraFieldLabel != null &&
                                extraFieldValue != null)
                              _buildInfoRow(extraFieldLabel, extraFieldValue),
                            const Divider(),
                            _buildInfoRow(localizations.dobLabel, dobFormatted),
                            const Divider(),
                            _buildInfoRow(
                              localizations.joinedAtLabel,
                              createdAtFormatted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyTermsPage(),
                      ),
                    );
                  },
                  child: Text(
                    localizations.privacyTermsLink,
                    style: const TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _formatDate(DateTime date, AppLocalizations localizations) {
    return DateFormat.yMMMMd(
      localizations.localeName,
    ).format(date); // e.g., July 21, 2025
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
