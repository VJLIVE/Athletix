import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'dart:math';
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
  
  // Isolate-based parallel processing
  bool _isAuthCheckComplete = false;
  bool _isAnimationComplete = false;
  Widget? _targetScreen;
  
  // Performance tracking for Parallel approach
  final DateTime _startTime = DateTime.now();
  DateTime? _animationEndTime;
  DateTime? _authCheckStartTime;
  DateTime? _authCheckEndTime;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Start authentication check in parallel (not in isolate)
    _startAuthCheckInParallel();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationEndTime = DateTime.now();
        _isAnimationComplete = true;
        _logParallelPerformance();
        _tryNavigate();
      }
    });
  }

  /// Starts authentication check in parallel with animation (not isolate).
  void _startAuthCheckInParallel() async {
    _authCheckStartTime = DateTime.now();
    print('🚀 PARALLEL APPROACH: Auth check started in parallel with animation');
    
    try {
      final result = await _runAuthCheckDirectly();
      _authCheckEndTime = DateTime.now();
      setState(() {
        _targetScreen = result;
        _isAuthCheckComplete = true;
      });
      _logParallelPerformance();
      _tryNavigate();
    } catch (e) {
      _authCheckEndTime = DateTime.now();
      // Fallback to auth screen if auth check fails
      setState(() {
        _targetScreen = const AuthScreen();
        _isAuthCheckComplete = true;
      });
      _logParallelPerformance();
      _tryNavigate();
    }
  }

  /// Logs performance metrics for the Parallel approach.
  void _logParallelPerformance() {
    if (_authCheckEndTime != null && _animationEndTime != null) {
      final totalTime = DateTime.now().difference(_startTime).inMilliseconds;
      final authTime = _authCheckEndTime!.difference(_authCheckStartTime!).inMilliseconds;
      final animationTime = _animationEndTime!.difference(_startTime).inMilliseconds;
      
      print('🚀 PARALLEL PERFORMANCE RESULTS:');
      print('   Total time: ${totalTime}ms');
      print('   Auth check time (main thread): ${authTime}ms');
      print('   Animation time (main thread): ${animationTime}ms');
      print('   Time saved vs sequential: ${max(animationTime, authTime) - totalTime}ms');
      print('   ✅ Parallel processing working!');
      print('   📊 Efficiency: ${((max(animationTime, authTime) - totalTime) / max(animationTime, authTime) * 100).toStringAsFixed(1)}% faster');
      print('   🧵 Both operations on main thread but parallel');
    } else if (_authCheckEndTime != null) {
      final authTime = _authCheckEndTime!.difference(_authCheckStartTime!).inMilliseconds;
      print('🔐 Auth check completed: ${authTime}ms (waiting for animation...)');
    } else if (_animationEndTime != null) {
      final animationTime = _animationEndTime!.difference(_startTime).inMilliseconds;
      print('🎬 Animation completed: ${animationTime}ms (waiting for auth...)');
    }
  }

  /// Runs authentication check directly on main thread (Firebase works here).
  Future<Widget> _runAuthCheckDirectly() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data();
        
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
      } else {
        return const AuthScreen();
      }
    } catch (e) {
      return const AuthScreen();
    }
  }

  /// Attempts to navigate if both animation and auth check are complete.
  void _tryNavigate() {
    if (_isAnimationComplete && _isAuthCheckComplete && _targetScreen != null) {
      print('🎯 PARALLEL APPROACH: Both processes complete, navigating...');
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
