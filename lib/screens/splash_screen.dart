import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
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
  
  bool _isAuthCheckComplete = false;
  bool _isAnimationComplete = false;
  Widget? _targetScreen;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _startOptimizedParallelOperations();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimationComplete = true;
        _tryNavigate();
      }
    });
  }

  void _startOptimizedParallelOperations() async {
    try {
      final results = await Future.wait([
        _runOptimizedAuthCheck(),
        _simulateMinimumSplashTime(),
      ]);
      
      setState(() {
        _targetScreen = results[0] as Widget;
        _isAuthCheckComplete = true;
      });
      _tryNavigate();
    } catch (e) {
      setState(() {
        _targetScreen = const AuthScreen();
        _isAuthCheckComplete = true;
      });
      _tryNavigate();
    }
  }

  Future<void> _simulateMinimumSplashTime() async {
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  Future<Widget> _runOptimizedAuthCheck() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        return const AuthScreen();
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.cache));
      
      final data = doc.exists 
          ? doc.data() 
          : (await FirebaseFirestore.instance.collection('users').doc(user.uid).get()).data();
      
      if (data != null && data['role'] != null) {
        final role = data['role'] as String;
        switch (role) {
          case 'Athlete':
            return const DashboardScreen();
          case 'Coach':
            return const CoachDashboardScreen();
          case 'Doctor':
            return const DoctorDashboardScreen();
          case 'Organization':
            return const OrganizationDashboardScreen();
          default:
            return const AuthScreen();
        }
      } else {
        return const AuthScreen();
      }
    } catch (e) {
      return const AuthScreen();
    }
  }

  void _tryNavigate() {
    if (_isAnimationComplete && _isAuthCheckComplete && _targetScreen != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => _targetScreen!),
      );
    }
  }

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
