import 'package:athletix/components/alertDialog_signOut_confitmation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:athletix/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'package:athletix/components/bottom_nav_bar.dart';
import 'package:lottie/lottie.dart';
import 'injury_tracker_screen.dart';
import 'performance_logs_screen.dart';
import 'calendar_screen.dart';
import 'tournaments_screen.dart';
import '../profile_screen.dart';
import 'package:athletix/components/fcm_listener.dart';
import 'financial_tracker_screen.dart';

class DashboardScreen extends StatefulWidget {
  // 1. Add the setLocale function to the constructor
  final Function(Locale) setLocale;
  const DashboardScreen({super.key, required this.setLocale});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List quotes = [];
  late int number_;

  Future<void> Fetchquotes() async {
    final response = await http.get(
      Uri.parse(
        'https://raw.githubusercontent.com/Keshav8605/Athletix/refs/heads/motivation_quote_feature_add/assets/motivational_quotes.json',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      quotes = data;
    } else {
      throw Exception('Failed to load quotes');
    }
  }

  @override
  void initState() {
    super.initState();
    number_ = Random().nextInt(100) + 1;
    Fetchquotes();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeTab(),
      const CalendarScreen(),
      const TournamentsScreen(),
      // 2. Pass the setLocale function to the ProfileScreen
      ProfileScreen(setLocale: widget.setLocale),
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
          role: 'Athlete',
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),

          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: _getUserData(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _buildLoadingState(localizations);
                  }
                  final data = snapshot.data!.data();
                  if (data == null) {
                    return _buildErrorState(localizations);
                  }

                  final name =
                      data['name'] ?? localizations.notAvailableAbbreviation;
                  final sport =
                      data['sport'] ?? localizations.notAvailableAbbreviation;
                  final dob =
                      data['dob']?.toString().split('T').first ??
                      localizations.notAvailableAbbreviation;

                  return _buildDashboardContent(
                    name,
                    sport,
                    dob,
                    localizations,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final localizations = AppLocalizations.of(context)!;
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
          ),
        ),
        title: Text(
          localizations.athleteDashboardTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () async {
              // 3. Pass the setLocale function to the signoutConfirmation dialog
              await signoutConfirmation(context, setLocale: widget.setLocale);
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: localizations.logoutTooltip,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(AppLocalizations localizations) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.loadingDashboard,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations localizations) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.userDataNotFound,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.refreshPrompt,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              label: Text(localizations.refreshButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    String name,
    String sport,
    String dob,
    AppLocalizations localizations,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(name, sport, dob, localizations),
          const SizedBox(height: 32),
          _buildQuickActionsSection(localizations),
          const SizedBox(height: 32),
          _buildStatsOverview(localizations),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(
    String name,
    String sport,
    String dob,
    AppLocalizations localizations,
  ) {
    final hour = DateTime.now().hour;
    String greeting =
        hour < 12
            ? localizations.greetingMorning
            : hour < 17
            ? localizations.greetingAfternoon
            : localizations.greetingEvening;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text("Todays Quote"),
            SizedBox(height: 5),
            Text(
              "${quotes[number_]['quote']}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Lottie.asset(
              'assets/Athlete.json',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.sports_rounded,
                            localizations.sportLabel,
                            sport,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            Icons.cake_rounded,
                            localizations.dobLabel,
                            _formatDate(dob, localizations),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF667EEA).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF667EEA)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF667EEA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              localizations.quickActionsTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildEnhancedActionCard(
              icon: Icons.healing_rounded,
              label: localizations.injuryTrackerLabel,
              subtitle: localizations.monitorHealthSubtitle,
              gradient: const [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InjuryTrackerScreen(),
                  ),
                );
              },
            ),
            _buildEnhancedActionCard(
              icon: Icons.show_chart_rounded,
              label: localizations.performanceLabel,
              subtitle: localizations.trackProgressSubtitle,
              gradient: const [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PerformanceLogScreen(),
                  ),
                );
              },
            ),
            _buildEnhancedActionCard(
              icon: Icons.account_balance_wallet_rounded,
              label: localizations.financesLabel,
              subtitle: localizations.manageExpensesSubtitle,
              gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FinancialTrackerPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedActionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              localizations.thisWeekTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: localizations.trainingSessionsTitle,
                value:
                    '8', // This is a hardcoded placeholder value. It should be replaced with a dynamic value from your app state.
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFF4ECDC4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: localizations.hoursTrainedTitle,
                value:
                    '12.5', // This is a hardcoded placeholder value. It should be replaced with a dynamic value from your app state.
                icon: Icons.timer_rounded,
                color: const Color(0xFFFF6B6B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr, AppLocalizations localizations) {
    if (dateStr.isEmpty) {
      return localizations.notSetLabel;
    }
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat.yMMMd(localizations.localeName).format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance.collection('users').doc(uid).get();
  }
}
