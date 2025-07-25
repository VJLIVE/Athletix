import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
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

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _sportController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? dob;

  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Role selection
  final List<String> roles = ['Athlete', 'Coach', 'Doctor'];
  String selectedRole = 'Athlete';

  // Password checklist states
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasMinLength = false;

  // Track field interaction and errors
  final Map<String, bool> _tappedFields = {
    'email': false,
    'password': false,
    'name': false,
    'sport': false,
    'dob': false,
  };
  final Map<String, String?> _fieldErrors = {
    'email': null,
    'password': null,
    'name': null,
    'sport': null,
    'dob': null,
  };

  // Debounce timer
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _sportController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _debounceInput(VoidCallback callback) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(callback);
      }
    });
  }

  void toggle(bool login) {
    setState(() {
      isLogin = login;
      // Reset all states when toggling
      _tappedFields.updateAll((key, value) => false);
      _fieldErrors.updateAll((key, value) => null);
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
      _sportController.clear();
      _dobController.clear();
      dob = null;
      hasUppercase = false;
      hasLowercase = false;
      hasNumber = false;
      hasMinLength = false;
    });
  }

  // Validation functions
  String? _validateEmail(String email, {bool forceValidate = false}) {
    if (email.isEmpty && (forceValidate || _tappedFields['email']!)) {
      return "Email is required";
    } else if (email.isNotEmpty) {
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@(gmail\.com|yahoo\.com|outlook\.com)$');
      if (!emailRegex.hasMatch(email)) {
        return "Use a valid email (e.g., @gmail.com, @yahoo.com, @outlook.com)";
      }
    }
    return null;
  }

  String? _validatePassword(String password, {bool forceValidate = false}) {
    // Signup has strict password rules
    if (!isLogin) {
      hasUppercase = RegExp(r'(?=.*[A-Z])').hasMatch(password);
      hasLowercase = RegExp(r'(?=.*[a-z])').hasMatch(password);
      hasNumber = RegExp(r'(?=.*\d)').hasMatch(password);
      hasMinLength = password.length >= 8;

      if (password.isEmpty && (forceValidate || _tappedFields['password']!)) {
        return "Password is required";
      } else if (password.isNotEmpty) {
        if (!hasMinLength) return "Password must be at least 8 characters long";
        if (!hasUppercase) return "Password must contain at least one uppercase letter";
        if (!hasLowercase) return "Password must contain at least one lowercase letter";
        if (!hasNumber) return "Password must contain at least one number";
      }
    } else { // Login just requires a password to be present
      if (password.isEmpty && (forceValidate || _tappedFields['password']!)) {
        return "Password is required";
      }
    }
    return null;
  }

  String? _validateName(String name, {bool forceValidate = false}) {
    if (name.isEmpty && (forceValidate || _tappedFields['name']!)) {
      return "Full name is required";
    } else if (name.isNotEmpty) {
      if (name.length < 4) return "Name must be at least 4 characters long";
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) return "Name can only contain letters and spaces";
    }
    return null;
  }

  String? _validateSport(String sport, {bool forceValidate = false}) {
    if (sport.isEmpty && (forceValidate || _tappedFields['sport']!)) {
      return selectedRole == 'Doctor' ? "Specialization is required" : "Sport is required";
    }
    return null;
  }

  String? _validateDob(DateTime? dob, {bool forceValidate = false}) {
    if (dob == null && (forceValidate || _tappedFields['dob']!)) {
      return "Date of birth is required";
    } else if (dob != null) {
      final now = DateTime.now();
      final age = now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1);
      if (age < 13) return "You must be at least 13 years old";
    }
    return null;
  }

  void _validateField(String fieldKey, dynamic value) {
    _debounceInput(() {
      // Only validate if the field has been tapped
      if (_tappedFields[fieldKey]!) {
        switch (fieldKey) {
          case 'email':
            _fieldErrors['email'] = _validateEmail(value as String);
            break;
          case 'password':
            _fieldErrors['password'] = _validatePassword(value as String);
            break;
          case 'name':
            _fieldErrors['name'] = _validateName(value as String);
            break;
          case 'sport':
            _fieldErrors['sport'] = _validateSport(value as String);
            break;
          case 'dob':
            _fieldErrors['dob'] = _validateDob(value as DateTime?);
            break;
        }
      }
    });
  }

  Color _getBorderColor(String fieldKey, {bool hasText = false}) {
    // 1. If the field has not been touched, always show grey.
    if (!_tappedFields[fieldKey]!) {
      return Colors.grey;
    }
    // 2. If the field has been touched and has an error, always show red.
    if (_fieldErrors[fieldKey] != null) {
      return Colors.red;
    }
    // 3. If it has been touched, has no error, has text, and we are on the SIGNUP page, show green.
    if (hasText && !isLogin) {
      return Colors.green;
    }
    // 4. Otherwise (e.g., on Login page), just show grey.
    return Colors.grey;
  }


  Future<void> handleAuth() async {
    // Mark all relevant fields as tapped and validate
    setState(() {
      _tappedFields['email'] = true;
      _tappedFields['password'] = true;
      _fieldErrors['email'] = _validateEmail(_emailController.text.trim(), forceValidate: true);
      _fieldErrors['password'] = _validatePassword(_passwordController.text, forceValidate: true);
      
      if (!isLogin) {
        _tappedFields['name'] = true;
        _tappedFields['sport'] = true;
        _tappedFields['dob'] = true;
        _fieldErrors['name'] = _validateName(_nameController.text.trim(), forceValidate: true);
        _fieldErrors['sport'] = _validateSport(_sportController.text.trim(), forceValidate: true);
        _fieldErrors['dob'] = _validateDob(dob, forceValidate: true);
      }
    });

    // Check for errors
    final activeErrors = isLogin
        ? [_fieldErrors['email'], _fieldErrors['password']]
        : _fieldErrors.values;

    final errors = activeErrors.where((error) => error != null).toList();
    if (errors.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errors.first ?? "Please fix the errors")),
        );
      }
      return;
    }

    try {
      UserCredential userCredential;
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _nameController.text.trim(),
          'sport': _sportController.text.trim(),
          'dob': dob!.toIso8601String(),
          'email': _emailController.text.trim(),
          'role': selectedRole,
          'createdAt': Timestamp.now(),
        });
      }

      // Fetch role and navigate
      final doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
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
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => targetScreen),
        );
      }
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

  // Password checklist widget
  Widget _buildPasswordChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChecklistItem("At least 8 characters", hasMinLength),
        _buildChecklistItem("Contains uppercase letter", hasUppercase),
        _buildChecklistItem("Contains lowercase letter", hasLowercase),
        _buildChecklistItem("Contains a number", hasNumber),
      ],
    );
  }

  Widget _buildChecklistItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.red,
            fontSize: 14,
          ),
        ),
      ],
    );
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
                    ),
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
                        onTap: () => setState(() => _tappedFields['name'] = true),
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _getBorderColor('name', hasText: _nameController.text.isNotEmpty),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _getBorderColor('name', hasText: _nameController.text.isNotEmpty),
                              width: 1,
                            ),
                          ),
                          errorText: _tappedFields['name']! ? _fieldErrors['name'] : null,
                        ),
                        onChanged: (value) => _validateField('name', value),
                      ),
                      const SizedBox(height: 12),
                      
                      // DOB
                      GestureDetector(
                        onTap: () async {
                          setState(() => _tappedFields['dob'] = true);
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dob ?? DateTime(2000),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              dob = picked;
                              _dobController.text = dob!.toLocal().toString().split(' ')[0];
                              _validateField('dob', dob);
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _dobController,
                            decoration: InputDecoration(
                              labelText: "Date of Birth",
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.calendar_today),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: _getBorderColor('dob', hasText: dob != null),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: _getBorderColor('dob', hasText: dob != null),
                                  width: 1,
                                ),
                              ),
                              errorText: _tappedFields['dob']! ? _fieldErrors['dob'] : null,
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
                        onChanged: (value) => setState(() {
                          selectedRole = value!;
                        }),
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
                              onTap: () => setState(() => _tappedFields['sport'] = true),
                              decoration: InputDecoration(
                                labelText: "Specialization",
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _getBorderColor('sport', hasText: _sportController.text.isNotEmpty),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _getBorderColor('sport', hasText: _sportController.text.isNotEmpty),
                                    width: 1,
                                  ),
                                ),
                                errorText: _tappedFields['sport']! ? _fieldErrors['sport'] : null,
                              ),
                              onChanged: (value) => _validateField('sport', value),
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
                                _debounceInput(() {
                                  _sportController.text = value ?? '';
                                  _tappedFields['sport'] = true;
                                  _validateField('sport', value);
                                });
                              },
                              decoration: InputDecoration(
                                labelText: "Sport",
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _getBorderColor('sport', hasText: _sportController.text.isNotEmpty),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _getBorderColor('sport', hasText: _sportController.text.isNotEmpty),
                                    width: 1,
                                  ),
                                ),
                                errorText: _tappedFields['sport']! ? _fieldErrors['sport'] : null,
                              ),
                            ),
                      const SizedBox(height: 12),
                    ],
                    
                    // EMAIL
                    TextField(
                      controller: _emailController,
                      onTap: () => setState(() => _tappedFields['email'] = true),
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _getBorderColor('email', hasText: _emailController.text.isNotEmpty),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _getBorderColor('email', hasText: _emailController.text.isNotEmpty),
                            width: 1,
                          ),
                        ),
                        errorText: (!isLogin && _tappedFields['email']!) ? _fieldErrors['email'] : null,
                      ),
                      onChanged: (value) => _validateField('email', value),
                    ),
                    const SizedBox(height: 12),
                    
                    // PASSWORD
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      onTap: () => setState(() => _tappedFields['password'] = true),
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _getBorderColor('password', hasText: _passwordController.text.isNotEmpty),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _getBorderColor('password', hasText: _passwordController.text.isNotEmpty),
                            width: 1,
                          ),
                        ),
                        errorText: (!isLogin && _tappedFields['password']!)  ? _fieldErrors['password'] : null,
                      ),
                      onChanged: (value) => _validateField('password', value),
                    ),
                    if (!isLogin && _tappedFields['password']!) ...[
                      const SizedBox(height: 12),
                      _buildPasswordChecklist(),
                    ],
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