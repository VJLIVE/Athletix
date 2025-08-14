import 'package:athletix/components/alertDialog_signOut_confitmation.dart';
import 'package:flutter/material.dart';
import 'package:athletix/l10n/app_localizations.dart';
import 'package:athletix/components/bottom_nav_bar.dart';
import 'manage_players_screen.dart';
import 'add_tournament_screen.dart';
import 'view_tournaments_screen.dart';
import '../profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth_screen.dart';

class OrganizationDashboardScreen extends StatefulWidget {
  // 1. Add the setLocale function to the constructor
  final Function(Locale) setLocale;
  const OrganizationDashboardScreen({super.key, required this.setLocale});

  @override
  State<OrganizationDashboardScreen> createState() =>
      _OrganizationDashboardScreenState();
}

class _OrganizationDashboardScreenState
    extends State<OrganizationDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeTab(),
      const ManagePlayersScreen(),
      const AddTournamentScreen(),
      // 2. Correctly pass setLocale to ProfileScreen
      ProfileScreen(setLocale: widget.setLocale),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        role: 'Organization',
      ),
    );
  }

  /// Home Tab Content
  Widget _buildHomeTab() {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          localizations.organizationDashboardTitle,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                // 3. Ensure AuthScreen also receives the setLocale function
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AuthScreen(setLocale: widget.setLocale),
                  ),
                );
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: localizations.logoutTooltip,
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text(localizations.userDataNotFound));
          }

          final data = snapshot.data!.data()!;
          final name = data['name'] ?? '';
          final sport = data['sport'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.business,
                      color: Colors.blue,
                      size: 40,
                    ),
                    title: Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text("${localizations.sportLabel}: $sport"),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  localizations.quickActionsTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  children: [
                    _buildActionCard(
                      icon: Icons.people,
                      label: localizations.managePlayersTitle,
                      color: Colors.deepPurple,
                      onTap: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                    ),
                    _buildActionCard(
                      icon: Icons.event,
                      label: localizations.addTournamentTitle,
                      color: Colors.teal,
                      onTap: () {
                        setState(() {
                          _currentIndex = 2;
                        });
                      },
                    ),
                    _buildActionCard(
                      icon: Icons.visibility,
                      label: localizations.viewTournamentsLabel,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ViewTournamentsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Fetch user data from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  /// Reusable Quick Action Card
  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
