import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:athletix/l10n/app_localizations.dart';
import 'dart:async';
import 'organization/organization_dashboard.dart';
import 'auth_screen.dart';
import 'athlete/athlete_dashboard.dart';
import 'coach/coach_dashboard.dart';
import 'doctor/doctor_dashboard.dart';

/// Splash screen that shows an animation and navigates based on user authentication state.
class SplashScreen extends StatefulWidget {
  // Add the setLocale function to the constructor
  final Function(Locale) setLocale;

  /// Creates a [SplashScreen] widget.
  const SplashScreen({super.key, required this.setLocale});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// State for [SplashScreen] that manages animation and navigation logic.
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });
  }

  Future<void> _navigateToNextScreen() async {
    // Ensure the animation has completed and we haven't already navigated.
    if (_controller.isCompleted) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        Widget targetScreen;

        if (user == null) {
          targetScreen = AuthScreen(setLocale: widget.setLocale);
        } else {
          final doc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get();
          final data = doc.data();

          if (data != null && data['role'] != null) {
            final role = data['role'] as String;
            switch (role) {
              case 'Athlete':
                targetScreen = DashboardScreen(setLocale: widget.setLocale);
                break;
              case 'Coach':
                targetScreen = CoachDashboardScreen(
                  setLocale: widget.setLocale,
                );
                break;
              case 'Doctor':
                targetScreen = DoctorDashboardScreen(
                  setLocale: widget.setLocale,
                );
                break;
              case 'Organization':
                targetScreen = OrganizationDashboardScreen(
                  setLocale: widget.setLocale,
                );
                break;
              default:
                targetScreen = AuthScreen(setLocale: widget.setLocale);
            }
          } else {
            // No role found, redirect to auth screen.
            targetScreen = AuthScreen(setLocale: widget.setLocale);
          }
        }

        // Navigate after the animation is complete and the user's role is determined.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => targetScreen),
        );
      } catch (e) {
        // Handle any errors during auth or firestore fetch by redirecting to auth screen.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AuthScreen(setLocale: widget.setLocale),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                Text(
                  localizations.appName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  localizations.appTagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
