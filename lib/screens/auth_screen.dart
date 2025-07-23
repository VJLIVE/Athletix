import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'athlete/athlete_dashboard.dart';
import 'coach/coach_dashboard.dart';
import 'doctor/doctor_dashboard.dart';
import 'organization/organization_dashboard.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _sportController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? dob;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final List<String> roles = ['Athlete', 'Coach', 'Doctor'];
  String selectedRole = 'Athlete';

  void toggle(bool login) => setState(() => isLogin = login);

  Future<void> handleAuth() async {
    if (!isLogin &&
        (dob == null || _nameController.text.isEmpty || _sportController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      UserCredential userCredential;
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _nameController.text,
          'sport': _sportController.text,
          'dob': dob!.toIso8601String(),
          'email': _emailController.text,
          'role': selectedRole,
          'createdAt': Timestamp.now(),
        });
      }

      // fetch role
      final doc =
      await _firestore.collection('users').doc(userCredential.user!.uid).get();
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
          targetScreen = const DashboardScreen();
      }
      await saveFcmToken();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
          errorMessage = "Email or password is incorrect. Please try again.";
          break;
        case 'invalid-email':
          errorMessage = "The email address is not valid.";
          break;
        case 'user-disabled':
          errorMessage = "This user account has been disabled.";
          break;
        case 'email-already-in-use':
          errorMessage = "This email is already registered. Try logging in.";
          break;
        case 'weak-password':
          errorMessage = "Your password must be at least 8 characters and contain a number.";
          break;
        case 'operation-not-allowed':
          errorMessage = "This operation is not allowed. Please contact support.";
          break;
        default:
          errorMessage = e.message ?? "An unknown error occurred. Please try again.";
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Authentication Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> saveFcmToken() async {
    await FirebaseMessaging.instance.requestPermission(); // 🪄 Ask permission

    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM Token: $token');

    if (token == null) {
      debugPrint('Failed to get FCM token');
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('No user logged in');
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fcmToken': token,
    }, SetOptions(merge: true));

    debugPrint('FCM Token saved to Firestore');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/applogo.png',
                height: 80,
              ),
              const SizedBox(height: 16),
              Text(
                isLogin ? 'Welcome Back' : 'Create an Account',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isLogin ? 'Log in to continue' : 'Sign up to get started',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => toggle(true),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isLogin ? Colors.blue : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Login",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isLogin ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => toggle(false),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: !isLogin ? Colors.blue : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Signup",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !isLogin ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (!isLogin) ...[
                      // FULL NAME
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // DOB
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              dob = picked;
                              _dobController.text = "${dob!.toLocal().toString().split(' ')[0]}";
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _dobController,
                            decoration: const InputDecoration(
                              labelText: "Date of Birth",
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ROLE
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        items: roles
                            .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Role",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // SPORT/SPECIALIZATION
                      (selectedRole == 'Doctor')
                          ? TextField(
                        controller: _sportController,
                        decoration: const InputDecoration(
                          labelText: "Specialization",
                          border: OutlineInputBorder(),
                        ),
                      )
                          : DropdownButtonFormField<String>(
                        value: _sportController.text.isNotEmpty ? _sportController.text : null,
                        items: [
                          'Football',
                          'Basketball',
                          'Cricket',
                          'Tennis',
                          'Athletics',
                          'Swimming',
                        ].map((sport) => DropdownMenuItem(
                          value: sport,
                          child: Text(sport),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _sportController.text = value ?? '';
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Sport",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // EMAIL
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // PASSWORD
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: handleAuth,
                        child: Text(
                          isLogin ? "Login" : "Signup",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
