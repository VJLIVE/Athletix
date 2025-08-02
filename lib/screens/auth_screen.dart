import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'athlete/athlete_dashboard.dart';
import 'coach/coach_dashboard.dart';
import 'doctor/doctor_dashboard.dart';
import 'organization/organization_dashboard.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Authentication screen for login and signup, including role selection and email verification.
class AuthScreen extends StatefulWidget {
  /// Creates an [AuthScreen].
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

/// State for [AuthScreen] that manages authentication logic, form validation, and navigation.
class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;
  bool isEmailVerificationPending = false;
  bool isResendingEmail = false;
  Timer? _emailVerificationTimer;
  String? pendingVerificationEmail;

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

  // Responsive helper methods
  bool get isSmallScreen => MediaQuery.of(context).size.width < 600;
  bool get isMediumScreen =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;
  bool get isLargeScreen => MediaQuery.of(context).size.width >= 1024;

  double get responsiveWidth {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isLargeScreen) return screenWidth * 0.4;
    if (isMediumScreen) return screenWidth * 0.6;
    return screenWidth * 0.9;
  }

  double get responsivePadding {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isLargeScreen) return screenWidth * 0.05;
    if (isMediumScreen) return screenWidth * 0.06;
    return screenWidth * 0.08;
  }

  /// Checks the initial authentication state and navigates accordingly.
  @override
  void initState() {
    super.initState();
    _checkInitialAuthState();
  }

  /// Disposes controllers and timers to free resources.
  @override
  void dispose() {
    _debounce?.cancel();
    _emailVerificationTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _sportController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  /// Checks the initial authentication state and user data in Firestore.
  Future<void> _checkInitialAuthState() async {
    final user = _auth.currentUser;
    if (user != null) {
      // User is signed in, check if user data exists in Firestore first
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        // User data doesn't exist in Firestore, sign out
        await _auth.signOut();
        debugPrint('User signed out due to missing Firestore data');
        return;
      }

      final userData = userDoc.data()!;
      // Check Firestore emailVerified status first (this allows manual override)
      bool isEmailVerifiedInFirestore = userData['emailVerified'] == true;

      // For organization role, prioritize Firestore verification status
      if (userData['role'] == 'Organization' && isEmailVerifiedInFirestore) {
        // Organization with manual verification - proceed directly
        await _navigateBasedOnRole(user.uid);
        return;
      }

      // For other roles, check both Firebase Auth and Firestore
      await user.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser != null &&
          (refreshedUser.emailVerified || isEmailVerifiedInFirestore)) {
        // Either Firebase Auth or Firestore shows verified status
        if (!isEmailVerifiedInFirestore) {
          // Update Firestore to match Firebase Auth status
          await _updateEmailVerificationStatus(refreshedUser.uid, true);
        }
        await _navigateBasedOnRole(refreshedUser.uid);
      } else {
        // Email is not verified, sign out the user
        await _auth.signOut();
        debugPrint('User was signed out due to unverified email');
      }
    }
  }

  /// Debounces input changes to reduce unnecessary state updates.
  void _debounceInput(VoidCallback callback) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(callback);
      }
    });
  }

  /// Toggles between login and signup modes, resetting relevant state.
  void toggle(bool login) {
    setState(() {
      isLogin = login;
      isEmailVerificationPending = false;
      pendingVerificationEmail = null;
      _emailVerificationTimer?.cancel();
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

  /// Stores user data in Firestore during signup.
  Future<void> _storeUserDataInFirestore(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'name': _nameController.text.trim(),
      'sport': _sportController.text.trim(),
      'dob': dob!.toIso8601String(),
      'email': _emailController.text.trim(),
      'role': selectedRole,
      'createdAt': Timestamp.now(),
      'emailVerified': false, // Initially false
      'signupCompleted': true,
    });
  }

  /// Updates the email verification status in Firestore.
  Future<void> _updateEmailVerificationStatus(
    String uid,
    bool isVerified,
  ) async {
    await _firestore.collection('users').doc(uid).update({
      'emailVerified': isVerified,
    });
  }

  /// Check if user exists and get verification status from Firestore.
  Future<Map<String, dynamic>?> _getUserData(String email) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  /// FIXED: Start checking for email verification with user signed in.
  void _startEmailVerificationCheck() {
    _emailVerificationTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      try {
        final user = _auth.currentUser;
        if (user == null) {
          timer.cancel();
          return;
        }
        await user.reload();
        final refreshedUser = _auth.currentUser;
        if (refreshedUser != null && refreshedUser.emailVerified) {
          timer.cancel();
          // Update verification status in Firestore
          await _updateEmailVerificationStatus(refreshedUser.uid, true);
          if (mounted) {
            setState(() {
              isEmailVerificationPending = false;
              isLoading = false;
            });
            await _proceedAfterVerification(refreshedUser);
          }
        }
      } catch (e) {
        debugPrint('Error checking email verification: $e');
      }
    });
  }

  /// Proceed after email verification.
  Future<void> _proceedAfterVerification(User user) async {
    try {
      setState(() => isLoading = true);
      // Navigate to appropriate dashboard
      await _navigateBasedOnRole(user.uid);
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error proceeding after verification: $e')),
        );
      }
    }
  }

  /// Navigate based on user role.
  Future<void> _navigateBasedOnRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
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
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Navigation error: $e')));
      }
    }
  }

  void _showSignupSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Verify Your Email'),
            content: Text(
              'Account created successfully! A verification email has been sent to ${pendingVerificationEmail}. Please check your inbox and spam folder, then click the verification link to complete your registration.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// FIXED: Resend verification email (keep user signed in).
  Future<void> _resendVerificationEmail() async {
    if (isResendingEmail) return;
    setState(() => isResendingEmail = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        final refreshedUser = _auth.currentUser;
        if (refreshedUser != null && !refreshedUser.emailVerified) {
          await refreshedUser.sendEmailVerification();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Verification email sent! Please check your inbox and spam folder.',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (refreshedUser != null && refreshedUser.emailVerified) {
          // User is already verified
          await _updateEmailVerificationStatus(refreshedUser.uid, true);
          setState(() {
            isEmailVerificationPending = false;
            isLoading = false;
          });
          await _proceedAfterVerification(refreshedUser);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please try signing up again or contact support.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error sending verification email';
        if (e.toString().contains('too-many-requests')) {
          errorMessage =
              'Too many requests. Please wait a moment before trying again.';
        } else if (e.toString().contains('network')) {
          errorMessage =
              'Network error. Please check your connection and try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isResendingEmail = false);
    }
  }

  /// Show verification required dialog for login attempts.
  void _showVerificationRequiredDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Email Verification Required'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mark_email_unread,
                  color: Colors.orange,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'A verification email was sent to $email. Please check your inbox and spam folder, then verify your email to continue.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed:
                    isResendingEmail
                        ? null
                        : () async {
                          Navigator.of(context).pop();
                          await _resendVerificationEmailForLogin(email);
                        },
                child:
                    isResendingEmail
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Resend Email'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// FIXED: Resend verification email for login attempts.
  Future<void> _resendVerificationEmailForLogin(String email) async {
    setState(() => isResendingEmail = true);
    try {
      // Get user data from Firestore to verify they exist
      final userData = await _getUserData(email);
      if (userData != null) {
        _showPasswordForResendDialog(email);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not found. Please sign up first.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resending verification email: $e')),
        );
      }
    } finally {
      setState(() => isResendingEmail = false);
    }
  }

  /// Show password dialog for resending verification email.
  void _showPasswordForResendDialog(String email) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Resend Verification Email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please enter your password to resend the verification email:',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  passwordController.dispose();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    Navigator.of(context).pop();
                    setState(() => isResendingEmail = true);
                    // Sign in to send verification email
                    UserCredential userCredential = await _auth
                        .signInWithEmailAndPassword(
                          email: email,
                          password: passwordController.text,
                        );
                    if (!userCredential.user!.emailVerified) {
                      await userCredential.user!.sendEmailVerification();
                      // Keep user signed in for verification checking
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Verification email sent! Please check your inbox and spam folder.',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      // User is already verified, proceed to dashboard
                      await _updateEmailVerificationStatus(
                        userCredential.user!.uid,
                        true,
                      );
                      await _navigateBasedOnRole(userCredential.user!.uid);
                    }
                  } catch (e) {
                    await _auth.signOut(); // Sign out on error
                    if (mounted) {
                      String errorMessage = 'Invalid password or network error';
                      if (e.toString().contains('wrong-password')) {
                        errorMessage = 'Incorrect password. Please try again.';
                      } else if (e.toString().contains('too-many-requests')) {
                        errorMessage =
                            'Too many attempts. Please try again later.';
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    setState(() => isResendingEmail = false);
                    passwordController.dispose();
                  }
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  /// Validation functions.
  String? _validateEmail(String email, {bool forceValidate = false}) {
    if (email.isEmpty && (forceValidate || _tappedFields['email']!)) {
      return "Email is required";
    } else if (email.isNotEmpty) {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@(gmail\.com|yahoo\.com|outlook\.com)$',
      );
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
        if (!hasUppercase)
          return "Password must contain at least one uppercase letter";
        if (!hasLowercase)
          return "Password must contain at least one lowercase letter";
        if (!hasNumber) return "Password must contain at least one number";
      }
    } else {
      // Login just requires a password to be present
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
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name))
        return "Name can only contain letters and spaces";
    }
    return null;
  }

  String? _validateSport(String sport, {bool forceValidate = false}) {
    if (sport.isEmpty && (forceValidate || _tappedFields['sport']!)) {
      return selectedRole == 'Doctor'
          ? "Specialization is required"
          : "Sport is required";
    }
    return null;
  }

  String? _validateDob(DateTime? dob, {bool forceValidate = false}) {
    if (dob == null && (forceValidate || _tappedFields['dob']!)) {
      return "Date of birth is required";
    } else if (dob != null) {
      final now = DateTime.now();
      final age =
          now.year -
          dob.year -
          (now.month > dob.month ||
                  (now.month == dob.month && now.day >= dob.day)
              ? 0
              : 1);
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

  /// Main authentication handler.
  Future<void> handleAuth() async {
    if (isLoading) return;
    // Mark all relevant fields as tapped and validate
    setState(() {
      _tappedFields['email'] = true;
      _tappedFields['password'] = true;
      _fieldErrors['email'] = _validateEmail(
        _emailController.text.trim(),
        forceValidate: true,
      );
      _fieldErrors['password'] = _validatePassword(
        _passwordController.text,
        forceValidate: true,
      );
      if (!isLogin) {
        _tappedFields['name'] = true;
        _tappedFields['sport'] = true;
        _tappedFields['dob'] = true;
        _fieldErrors['name'] = _validateName(
          _nameController.text.trim(),
          forceValidate: true,
        );
        _fieldErrors['sport'] = _validateSport(
          _sportController.text.trim(),
          forceValidate: true,
        );
        _fieldErrors['dob'] = _validateDob(dob, forceValidate: true);
      }
    });

    // Check for errors
    final activeErrors =
        isLogin
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

    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await _handleLogin();
      } else {
        await _handleSignup();
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    }
  }

  /// Handles the login process with improved verification checking.
  Future<void> _handleLogin() async {
    try {
      final email = _emailController.text.trim();
      // First, try to sign in to get the most up-to-date user information
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      // Get user data from Firestore
      final userDoc =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();
      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('User data not found');
      }

      final userData = userDoc.data()!;
      bool isEmailVerifiedInFirestore = userData['emailVerified'] == true;

      // For organization role, prioritize Firestore verification status
      if (userData['role'] == 'Organization' && isEmailVerifiedInFirestore) {
        // Organization with manual verification - proceed directly
        await _navigateBasedOnRole(userCredential.user!.uid);
        return;
      }

      // For other roles, check Firebase Auth verification
      await userCredential.user!.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null) {
        throw Exception('User not found after login');
      }

      // Check email verification status - use Firestore first, then Firebase Auth
      if (!isEmailVerifiedInFirestore && !refreshedUser.emailVerified) {
        setState(() => isLoading = false);
        // Don't sign out - keep user signed in for verification
        _showVerificationRequiredDialog(email);
        return;
      }

      // If either source shows verified, update both to be consistent
      if (refreshedUser.emailVerified && !isEmailVerifiedInFirestore) {
        await _updateEmailVerificationStatus(refreshedUser.uid, true);
      }

      // Proceed to dashboard
      await _navigateBasedOnRole(refreshedUser.uid);
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
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
        case 'invalid-credential':
          errorMessage =
              "Invalid email or password. Please check your credentials.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many failed attempts. Please try again later.";
          break;
        default:
          errorMessage =
              e.message ?? "An unknown error occurred. Please try again.";
      }
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Login Error'),
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
  }

  /// Handles the signup process - keep user signed in after creation.
  Future<void> _handleSignup() async {
    try {
      final email = _emailController.text.trim();
      // Check if user already exists
      List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(
        email,
      );
      if (signInMethods.isNotEmpty) {
        setState(() => isLoading = false);
        // Check if this user exists in our Firestore and is unverified
        final userData = await _getUserData(email);
        if (userData != null && userData['emailVerified'] == false) {
          _showExistingUnverifiedUserDialog(email);
          return;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email already registered. Please try logging in or verify your email if not done already.',
              ),
            ),
          );
        }
        return;
      }

      // Create user account
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email,
            password: _passwordController.text,
          );

      // Store user data in Firestore immediately after account creation
      await _storeUserDataInFirestore(userCredential.user!);

      // Send verification email
      await userCredential.user!.sendEmailVerification();

      // Keep user signed in and start verification checking
      setState(() {
        isLoading = false;
        isEmailVerificationPending = true;
        pendingVerificationEmail = email;
      });

      _showSignupSuccessDialog();
      _startEmailVerificationCheck(); // Start checking for verification
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          // Check if this is an unverified user
          final userData = await _getUserData(_emailController.text.trim());
          if (userData != null && userData['emailVerified'] == false) {
            _showExistingUnverifiedUserDialog(_emailController.text.trim());
            return;
          }
          errorMessage =
              "This email is already registered. Please try logging in or verify your email if not done already.";
          break;
        case 'weak-password':
          errorMessage =
              "Your password must be at least 8 characters and contain a number.";
          break;
        case 'operation-not-allowed':
          errorMessage =
              "This operation is not allowed. Please contact support.";
          break;
        default:
          errorMessage =
              e.message ?? "An unknown error occurred. Please try again.";
      }
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Signup Error'),
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
  }

  /// Show dialog for existing unverified users during signup.
  void _showExistingUnverifiedUserDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Email Already Registered'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mark_email_unread,
                  color: Colors.orange,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'This email is already registered but not verified. A verification email was previously sent to $email.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please check your inbox and spam folder, or resend the verification email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed:
                    isResendingEmail
                        ? null
                        : () async {
                          Navigator.of(context).pop();
                          await _resendVerificationForSignup(email);
                        },
                child:
                    isResendingEmail
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Resend Email'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// FIXED: Resend verification email for signup attempts with existing unverified users.
  Future<void> _resendVerificationForSignup(String email) async {
    setState(() => isResendingEmail = true);
    try {
      // We need to sign in the user temporarily to send verification email
      _showPasswordForResendSignupDialog(email);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => isResendingEmail = false);
    }
  }

  /// Show password dialog for resending verification email during signup.
  void _showPasswordForResendSignupDialog(String email) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Resend Verification Email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please enter your password to resend the verification email:',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  passwordController.dispose();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    Navigator.of(context).pop();
                    setState(() => isResendingEmail = true);
                    // Sign in to send verification email
                    UserCredential userCredential = await _auth
                        .signInWithEmailAndPassword(
                          email: email,
                          password: passwordController.text,
                        );
                    if (!userCredential.user!.emailVerified) {
                      await userCredential.user!.sendEmailVerification();
                      // Go to verification pending screen and start checking
                      setState(() {
                        isEmailVerificationPending = true;
                        pendingVerificationEmail = email;
                      });
                      _startEmailVerificationCheck();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Verification email sent! Please check your inbox and spam folder.',
                            ),
                          ),
                        );
                      }
                    } else {
                      // User is already verified, navigate to dashboard
                      await _updateEmailVerificationStatus(
                        userCredential.user!.uid,
                        true,
                      );
                      await _navigateBasedOnRole(userCredential.user!.uid);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  } finally {
                    setState(() => isResendingEmail = false);
                    passwordController.dispose();
                  }
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  /// Saves the Firebase Cloud Messaging (FCM) token to the user's document in Firestore.
  Future<void> saveFcmToken() async {
    await FirebaseMessaging.instance.requestPermission();
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

  /// Password checklist widget.
  Widget _buildPasswordChecklist() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChecklistItem("At least 8 characters", hasMinLength, screenWidth),
        _buildChecklistItem(
          "Contains uppercase letter",
          hasUppercase,
          screenWidth,
        ),
        _buildChecklistItem(
          "Contains lowercase letter",
          hasLowercase,
          screenWidth,
        ),
        _buildChecklistItem("Contains a number", hasNumber, screenWidth),
      ],
    );
  }

  Widget _buildChecklistItem(String text, bool isValid, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.005),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size:
                isSmallScreen
                    ? 18
                    : isMediumScreen
                    ? 20
                    : 22,
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isValid ? Colors.green : Colors.red,
                fontSize:
                    isSmallScreen
                        ? 12
                        : isMediumScreen
                        ? 14
                        : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// FIXED: Email verification pending widget - fully responsive.
  Widget _buildEmailVerificationPending() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: isLargeScreen ? 600 : double.infinity,
      ),
      padding: EdgeInsets.all(
        isSmallScreen
            ? 16
            : isMediumScreen
            ? 20
            : 24,
      ),
      margin: EdgeInsets.symmetric(
        vertical: screenHeight * (isSmallScreen ? 0.02 : 0.03),
        horizontal: isLargeScreen ? screenWidth * 0.1 : 0,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.mark_email_unread,
            color: Colors.orange,
            size:
                isSmallScreen
                    ? 40
                    : isMediumScreen
                    ? 48
                    : 56,
          ),
          SizedBox(height: screenHeight * 0.015),
          Text(
            'Email Verification Required',
            style: TextStyle(
              fontSize:
                  isSmallScreen
                      ? 16
                      : isMediumScreen
                      ? 18
                      : 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'We\'ve sent a verification email to\n${pendingVerificationEmail ?? _emailController.text.trim()}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:
                  isSmallScreen
                      ? 12
                      : isMediumScreen
                      ? 14
                      : 16,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          Text(
            'Please check your inbox and spam folder, then click the verification link. Once verified, click "I\'ve Verified" to continue.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:
                  isSmallScreen
                      ? 10
                      : isMediumScreen
                      ? 12
                      : 14,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          // Responsive button layout
          if (isSmallScreen) ...[
            // Stack buttons vertically on small screens
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed:
                        isResendingEmail
                            ? null
                            : () async {
                              await _resendVerificationEmailForPending();
                            },
                    icon:
                        isResendingEmail
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.refresh),
                    label: Text(
                      isResendingEmail ? 'Sending...' : 'Resend Email',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              await _checkVerificationManually();
                            },
                    icon:
                        isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.check),
                    label: Text(
                      isLoading ? 'Checking...' : 'I\'ve Verified',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed:
                      () => setState(() {
                        isEmailVerificationPending = false;
                        _emailVerificationTimer?.cancel();
                      }),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ] else ...[
            // Side by side layout for larger screens
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed:
                        isResendingEmail
                            ? null
                            : () async {
                              await _resendVerificationEmailForPending();
                            },
                    icon:
                        isResendingEmail
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.refresh),
                    label: Text(
                      isResendingEmail ? 'Sending...' : 'Resend Email',
                      style: TextStyle(fontSize: isMediumScreen ? 12 : 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              await _checkVerificationManually();
                            },
                    icon:
                        isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.check),
                    label: Text(
                      isLoading ? 'Checking...' : 'I\'ve Verified',
                      style: TextStyle(fontSize: isMediumScreen ? 12 : 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed:
                  () => setState(() {
                    isEmailVerificationPending = false;
                    _emailVerificationTimer?.cancel();
                  }),
              icon: const Icon(Icons.arrow_back),
              label: Text(
                'Go Back',
                style: TextStyle(fontSize: isMediumScreen ? 12 : 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// FIXED: Resend verification email when user is on pending screen.
  Future<void> _resendVerificationEmailForPending() async {
    if (isResendingEmail) return;
    setState(() => isResendingEmail = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        final refreshedUser = _auth.currentUser;
        if (refreshedUser != null && !refreshedUser.emailVerified) {
          await refreshedUser.sendEmailVerification();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Verification email sent! Please check your inbox and spam folder.',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (refreshedUser != null && refreshedUser.emailVerified) {
          // User is already verified
          await _updateEmailVerificationStatus(refreshedUser.uid, true);
          setState(() {
            isEmailVerificationPending = false;
            isLoading = false;
          });
          await _proceedAfterVerification(refreshedUser);
        }
      } else {
        // User not signed in, ask for password
        final email = pendingVerificationEmail ?? _emailController.text.trim();
        _showPasswordForResendSignupDialog(email);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error sending verification email';
        if (e.toString().contains('too-many-requests')) {
          errorMessage =
              'Too many requests. Please wait a moment before trying again.';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      setState(() => isResendingEmail = false);
    }
  }

  /// FIXED: Manual verification check when user clicks "I've Verified".
  Future<void> _checkVerificationManually() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // User is signed in, check verification directly
        await user.reload();
        final refreshedUser = _auth.currentUser;
        if (refreshedUser != null && refreshedUser.emailVerified) {
          // Email is verified, update Firestore and navigate
          await _updateEmailVerificationStatus(refreshedUser.uid, true);
          setState(() {
            isEmailVerificationPending = false;
            isLoading = false;
          });
          await _navigateBasedOnRole(refreshedUser.uid);
        } else {
          // Still not verified
          setState(() => isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Email is still not verified. Please check your inbox and click the verification link first.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        // User not signed in, ask for password
        setState(() => isLoading = false);
        final email = pendingVerificationEmail ?? _emailController.text.trim();
        _showPasswordForVerificationCheckDialog(email);
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  /// Show password dialog for manual verification check.
  void _showPasswordForVerificationCheckDialog(String email) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Verify Login'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please enter your password to check verification status:',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  passwordController.dispose();
                  setState(() => isLoading = false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    Navigator.of(context).pop();
                    // Sign in to check verification status
                    UserCredential userCredential = await _auth
                        .signInWithEmailAndPassword(
                          email: email,
                          password: passwordController.text,
                        );
                    // Reload user to get latest verification status
                    await userCredential.user!.reload();
                    final refreshedUser = _auth.currentUser;
                    if (refreshedUser != null && refreshedUser.emailVerified) {
                      // Email is verified, update Firestore and navigate
                      await _updateEmailVerificationStatus(
                        refreshedUser.uid,
                        true,
                      );
                      setState(() {
                        isEmailVerificationPending = false;
                        isLoading = false;
                      });
                      await _navigateBasedOnRole(refreshedUser.uid);
                    } else {
                      // Still not verified
                      setState(() => isLoading = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Email is still not verified. Please check your inbox and click the verification link first.',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    setState(() => isLoading = false);
                    if (mounted) {
                      String errorMessage = 'Invalid password or network error';
                      if (e.toString().contains('wrong-password')) {
                        errorMessage = 'Incorrect password. Please try again.';
                      } else if (e.toString().contains('too-many-requests')) {
                        errorMessage =
                            'Too many attempts. Please try again later.';
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    passwordController.dispose();
                  }
                },
                child: const Text('Check'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: isLargeScreen ? 800 : double.infinity,
                minHeight: screenHeight,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: responsivePadding,
                vertical: screenHeight * (isSmallScreen ? 0.03 : 0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Basketball Logo - Responsive
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image(
                        image: const AssetImage("assets/logo_png.png"),
                        width: screenWidth * 0.15,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * (isSmallScreen ? 0.03 : 0.04),
                  ),
                  if (isEmailVerificationPending) ...[
                    _buildEmailVerificationPending(),
                  ] else ...[
                    // Welcome Text - Responsive
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          isLogin ? 'Welcome Back,' : 'Create Account,',
                          style: TextStyle(
                            fontSize:
                                isSmallScreen
                                    ? screenWidth * 0.07
                                    : isMediumScreen
                                    ? screenWidth * 0.06
                                    : screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          isLogin
                              ? 'Sign in to continue'
                              : 'Sign up to get started',
                          style: TextStyle(
                            fontSize:
                                isSmallScreen
                                    ? screenWidth * 0.035
                                    : isMediumScreen
                                    ? screenWidth * 0.03
                                    : screenWidth * 0.025,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenHeight * (isSmallScreen ? 0.04 : 0.05),
                    ),
                    // Main Form Container - Responsive
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: responsiveWidth),
                      padding: EdgeInsets.all(
                        isSmallScreen
                            ? screenWidth * 0.04
                            : isMediumScreen
                            ? screenWidth * 0.045
                            : screenWidth * 0.05,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 16 : 20,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: isSmallScreen ? 8 : 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (!isLogin) ...[
                            // Full Name Field (Signup only)
                            _buildInputField(
                              controller: _nameController,
                              label: "Full Name",
                              fieldKey: 'name',
                              validator: (value) => _validateName(value ?? ''),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            // Date of Birth Field (Signup only)
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
                                    _dobController.text =
                                        dob!.toLocal().toString().split(' ')[0];
                                    _validateField('dob', dob);
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                child: _buildInputField(
                                  controller: _dobController,
                                  label: "Date of Birth",
                                  fieldKey: 'dob',
                                  validator: (value) => _validateDob(dob),
                                  suffixIcon: Icons.calendar_today,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            // Role Dropdown (Signup only) - Responsive
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  isSmallScreen ? 10 : 12,
                                ),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: selectedRole,
                                decoration: InputDecoration(
                                  labelText: "Role",
                                  labelStyle: TextStyle(
                                    fontSize:
                                        isSmallScreen
                                            ? screenWidth * 0.035
                                            : isMediumScreen
                                            ? screenWidth * 0.03
                                            : screenWidth * 0.025,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                    vertical: screenHeight * 0.01,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize:
                                      isSmallScreen
                                          ? screenWidth * 0.035
                                          : isMediumScreen
                                          ? screenWidth * 0.03
                                          : screenWidth * 0.025,
                                  color: Colors.black87,
                                ),
                                items:
                                    roles
                                        .map(
                                          (role) => DropdownMenuItem(
                                            value: role,
                                            child: Text(role),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    (value) => setState(() {
                                      selectedRole = value!;
                                    }),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            // Sport/Specialization Field (Signup only)
                            if (selectedRole == 'Doctor')
                              _buildInputField(
                                controller: _sportController,
                                label: "Specialization",
                                fieldKey: 'sport',
                                validator:
                                    (value) => _validateSport(value ?? ''),
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    isSmallScreen ? 10 : 12,
                                  ),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value:
                                      _sportController.text.isNotEmpty
                                          ? _sportController.text
                                          : null,
                                  decoration: InputDecoration(
                                    labelText: "Sport",
                                    labelStyle: TextStyle(
                                      fontSize:
                                          isSmallScreen
                                              ? screenWidth * 0.035
                                              : isMediumScreen
                                              ? screenWidth * 0.03
                                              : screenWidth * 0.025,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04,
                                      vertical: screenHeight * 0.01,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize:
                                        isSmallScreen
                                            ? screenWidth * 0.035
                                            : isMediumScreen
                                            ? screenWidth * 0.03
                                            : screenWidth * 0.025,
                                    color: Colors.black87,
                                  ),
                                  items:
                                      [
                                            'Football',
                                            'Basketball',
                                            'Cricket',
                                            'Tennis',
                                            'Athletics',
                                            'Swimming',
                                          ]
                                          .map(
                                            (sport) => DropdownMenuItem(
                                              value: sport,
                                              child: Text(sport),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    _debounceInput(() {
                                      _sportController.text = value ?? '';
                                      _tappedFields['sport'] = true;
                                      _validateField('sport', value);
                                    });
                                  },
                                ),
                              ),
                            SizedBox(height: screenHeight * 0.02),
                          ],
                          // Email/Mobile Field
                          _buildInputField(
                            controller: _emailController,
                            label: "Email",
                            fieldKey: 'email',
                            validator: (value) => _validateEmail(value ?? ''),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Password Field
                          _buildInputField(
                            controller: _passwordController,
                            label: "Password",
                            fieldKey: 'password',
                            validator:
                                (value) => _validatePassword(value ?? ''),
                            obscureText: true,
                            suffixIcon: Icons.visibility_off,
                          ),
                          if (!isLogin && _tappedFields['password']!) ...[
                            SizedBox(height: screenHeight * 0.02),
                            _buildPasswordChecklist(),
                          ],
                          if (isLogin) ...[
                            SizedBox(height: screenHeight * 0.005),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Handle forgot password
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize:
                                        isSmallScreen
                                            ? screenWidth * 0.03
                                            : isMediumScreen
                                            ? screenWidth * 0.025
                                            : screenWidth * 0.02,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: screenHeight * 0.02),
                          // Login/Signup Button - Responsive
                          Container(
                            width: double.infinity,
                            height:
                                isSmallScreen
                                    ? screenHeight * 0.06
                                    : isMediumScreen
                                    ? screenHeight * 0.065
                                    : screenHeight * 0.07,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : handleAuth,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B6B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    isSmallScreen ? 10 : 12,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  isLoading
                                      ? SizedBox(
                                        height: isSmallScreen ? 18 : 20,
                                        width: isSmallScreen ? 18 : 20,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        isLogin ? "Login" : "Signup",
                                        style: TextStyle(
                                          fontSize:
                                              isSmallScreen
                                                  ? screenWidth * 0.04
                                                  : isMediumScreen
                                                  ? screenWidth * 0.035
                                                  : screenWidth * 0.03,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                          SizedBox(
                            height:
                                screenHeight * (isSmallScreen ? 0.025 : 0.03),
                          ),
                          // Toggle Login/Signup - Responsive
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLogin
                                    ? 'New user? '
                                    : 'Already have an account? ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize:
                                      isSmallScreen
                                          ? screenWidth * 0.03
                                          : isMediumScreen
                                          ? screenWidth * 0.025
                                          : screenWidth * 0.02,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => toggle(!isLogin),
                                child: Text(
                                  isLogin ? 'Signup' : 'Login',
                                  style: TextStyle(
                                    color: const Color(0xFFFF6B6B),
                                    fontSize:
                                        isSmallScreen
                                            ? screenWidth * 0.03
                                            : isMediumScreen
                                            ? screenWidth * 0.025
                                            : screenWidth * 0.02,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String fieldKey,
    required String? Function(String?) validator,
    bool obscureText = false,
    IconData? suffixIcon,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        border: Border.all(
          color: _getBorderColor(fieldKey, hasText: controller.text.isNotEmpty),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onTap: () => setState(() => _tappedFields[fieldKey] = true),
        onChanged: (value) => _validateField(fieldKey, value),
        style: TextStyle(
          fontSize:
              isSmallScreen
                  ? screenWidth * 0.035
                  : isMediumScreen
                  ? screenWidth * 0.03
                  : screenWidth * 0.025,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize:
                isSmallScreen
                    ? screenWidth * 0.035
                    : isMediumScreen
                    ? screenWidth * 0.03
                    : screenWidth * 0.025,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.001,
          ),
          suffixIcon:
              suffixIcon != null
                  ? Icon(
                    suffixIcon,
                    color: Colors.grey[600],
                    size:
                        isSmallScreen
                            ? screenWidth * 0.045
                            : isMediumScreen
                            ? screenWidth * 0.04
                            : screenWidth * 0.035,
                  )
                  : null,
          errorText:
              (!isLogin && _tappedFields[fieldKey]!)
                  ? _fieldErrors[fieldKey]
                  : null,
          errorStyle: TextStyle(fontSize: isSmallScreen ? 10 : 12),
        ),
      ),
    );
  }
}
