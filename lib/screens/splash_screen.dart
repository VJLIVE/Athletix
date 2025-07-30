import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'organization/organization_dashboard.dart';
import 'auth_screen.dart';
import 'athlete/athlete_dashboard.dart';
import 'coach/coach_dashboard.dart';
import 'doctor/doctor_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  
  // Parallel processing flags
  bool _isAuthCheckComplete = false;
  bool _isAnimationComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Start authentication check immediately in background (PARALLEL)
    _checkAuthenticationInBackground();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimationComplete = true;
        _tryNavigate();
      }
    });
  }

  /// Checks authentication in the background while animation is running.
  Future<void> _checkAuthenticationInBackground() async {
    await _performAuthCheck();
    _isAuthCheckComplete = true;
    _tryNavigate();
  }

  /// Performs the actual authentication check logic.
  Future<void> _performAuthCheck() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data();
        if (data == null || data['role'] == null) {
          throw Exception("User role not found");
        }

        final role = data['role'] as String;
        Widget targetScreen;

        switch (role) {
          case 'Athlete':
            targetScreen = const DashboardScreen();
            break;
          case 'Coach':
            targetScreen = const CoachDashboardScreen();
            break;
          case 'Doctor':
            targetScreen = const DoctorDashboardScreen();
            break;
          case 'Organization':
            targetScreen = const OrganizationDashboardScreen();
            break;
          default:
            targetScreen = const AuthScreen();
        }

        // Store the target screen for navigation
        _targetScreen = targetScreen;
      } catch (e) {
        _targetScreen = const AuthScreen();
      }
    } else {
      _targetScreen = const AuthScreen();
    }
  }

  /// Attempts to navigate if both animation and auth check are complete.
  void _tryNavigate() {
    if (_isAnimationComplete && _isAuthCheckComplete) {
      _navigateToTarget();
    }
  }

  /// Navigates to the stored target screen.
  void _navigateToTarget() {
    if (mounted && _targetScreen != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => _targetScreen!),
      );
    }
  }

  // Store the target screen for navigation
  Widget? _targetScreen;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/Running_Boy.json',
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller.duration = composition.duration;
                    _controller.forward();
                  },
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Athletix',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your Sports Journey Starts Here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
