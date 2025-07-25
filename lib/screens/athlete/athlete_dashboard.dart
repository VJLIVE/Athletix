import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/bottom_nav_bar.dart';
import '../auth_screen.dart';
import 'injury_tracker_screen.dart';
import 'performance_logs_screen.dart';
import 'calendar_screen.dart';
import 'tournaments_screen.dart';
import '../profile_screen.dart';
import '../../components/fcm_listener.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeTab(),
      const CalendarScreen(),
      const TournamentsScreen(),
      const ProfileScreen(),
    ];

    return FcmListener(
      child: Scaffold(
        body: screens[_currentIndex],
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          role: 'Athlete', // 👈 Pass role here
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Dashboard', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data();
          if (data == null) {
            return const Center(child: Text("User data not found"));
          }

          final name = data['name'] ?? '';
          final sport = data['sport'] ?? '';
          final dob = data['dob']?.toString().split('T').first ?? '';

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
                      Icons.person,
                      color: Colors.blue,
                      size: 40,
                    ),
                    title: Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text("Sport: $sport\nDOB: $dob"),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Quick Actions',
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
                      context,
                      icon: Icons.healing,
                      label: "Injury Tracker",
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InjuryTrackerScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.show_chart,
                      label: "Performance Logs",
                      color: Colors.green,
                      onTap: () {
                        Navigator.pushNamed(context, '/performance-logs');
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

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Widget _buildActionCard(
    BuildContext context, {
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
