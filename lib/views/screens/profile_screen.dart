import 'package:athletix/components/alertDialog_signOut_confitmation.dart';
import 'package:athletix/views/screens/privacy_terms_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red), // 🔴 Red icon
            tooltip: 'Logout',
            onPressed: () async {
              await signoutConfirmation(context);
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
            return const Center(child: Text("User profile not found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final role = (data['role'] ?? 'N/A').toString().toLowerCase();
          String? extraFieldLabel;
          String? extraFieldValue;

          if (role == 'doctor') {
            extraFieldLabel = 'Specialization';
            extraFieldValue = data['specialization'] ?? 'N/A';
          } else if (role == 'athlete' || role == 'coach') {
            extraFieldLabel = 'Sport';
            extraFieldValue = data['sport'] ?? 'N/A';
          }

          final dobRaw = data['dob'];
          final createdAtRaw = data['createdAt'];

          final dobFormatted =
              dobRaw != null
                  ? _formatDate(DateTime.tryParse(dobRaw) ?? DateTime.now())
                  : 'N/A';

          final createdAtFormatted =
              createdAtRaw != null
                  ? _formatDate((createdAtRaw as Timestamp).toDate())
                  : 'N/A';

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
                              data['name'] ?? 'N/A',
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
                            _buildInfoRow("Email", data['email'] ?? 'N/A'),
                            const Divider(),
                            if (extraFieldLabel != null &&
                                extraFieldValue != null)
                              _buildInfoRow(extraFieldLabel, extraFieldValue),
                            const Divider(),
                            _buildInfoRow("Date of Birth", dobFormatted),
                            const Divider(),
                            _buildInfoRow("Joined At", createdAtFormatted),
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
                  child: const Text(
                    'Privacy Policy & Terms',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return DateFormat.yMMMMd().format(date); // e.g., July 21, 2025
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
