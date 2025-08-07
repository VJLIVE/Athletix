import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_state.dart';
import '../models/form_validation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/validation_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sportController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  // State
  AuthState _authState = const AuthState();
  FormValidation _formValidation = FormValidation.initial();
  bool _isLogin = true;
  DateTime? _dob;
  String _selectedRole = 'Athlete';
  Timer? _emailVerificationTimer;
  Timer? _debounce;

  // Getters
  AuthState get authState => _authState;
  FormValidation get formValidation => _formValidation;
  bool get isLogin => _isLogin;
  DateTime? get dob => _dob;
  String get selectedRole => _selectedRole;
  List<String> get roles => ['Athlete', 'Coach', 'Doctor'];
  List<String> get sports => [
    'Football',
    'Basketball',
    'Cricket',
    'Tennis',
    'Athletics',
    'Swimming',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _emailVerificationTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    sportController.dispose();
    dobController.dispose();
    super.dispose();
  }

  void setAuthState(AuthState newState) {
    _authState = newState;
    notifyListeners();
  }

  void setFormValidation(FormValidation newValidation) {
    _formValidation = newValidation;
    notifyListeners();
  }

  void toggleAuthMode() {
    _isLogin = !_isLogin;
    _resetForm();
    setAuthState(const AuthState(status: AuthStatus.initial));
    notifyListeners();
  }

  void setSelectedRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setDob(DateTime? date) {
    _dob = date;
    if (date != null) {
      dobController.text = date.toLocal().toString().split(' ')[0];
      _validateField('dob', date);
    }
    notifyListeners();
  }

  void setSport(String sport) {
    sportController.text = sport;
    _markFieldAsTapped('sport');
    _validateField('sport', sport);
  }

  void _resetForm() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    sportController.clear();
    dobController.clear();
    _dob = null;
    _formValidation = FormValidation.initial();
  }

  void _markFieldAsTapped(String fieldKey) {
    final updatedTappedFields = Map<String, bool>.from(
      _formValidation.tappedFields,
    );
    updatedTappedFields[fieldKey] = true;
    setFormValidation(
      _formValidation.copyWith(tappedFields: updatedTappedFields),
    );
  }

  void _debounceInput(VoidCallback callback) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), callback);
  }

  void _validateField(String fieldKey, dynamic value) {
    _debounceInput(() {
      if (_formValidation.tappedFields[fieldKey]!) {
        final updatedErrors = Map<String, String?>.from(
          _formValidation.fieldErrors,
        );

        switch (fieldKey) {
          case 'email':
            updatedErrors['email'] = ValidationService.validateEmail(
              value as String,
              fieldTapped: _formValidation.tappedFields['email']!,
            );
            break;
          case 'password':
            updatedErrors['password'] = ValidationService.validatePassword(
              value as String,
              isLogin: _isLogin,
              fieldTapped: _formValidation.tappedFields['password']!,
            );
            if (!_isLogin) {
              final checklist = ValidationService.getPasswordChecklist(
                value as String,
              );
              setFormValidation(
                _formValidation.copyWith(
                  fieldErrors: updatedErrors,
                  hasUppercase: checklist['hasUppercase']!,
                  hasLowercase: checklist['hasLowercase']!,
                  hasNumber: checklist['hasNumber']!,
                  hasMinLength: checklist['hasMinLength']!,
                ),
              );
              return;
            }
            break;
          case 'name':
            updatedErrors['name'] = ValidationService.validateName(
              value as String,
              fieldTapped: _formValidation.tappedFields['name']!,
            );
            break;
          case 'sport':
            updatedErrors['sport'] = ValidationService.validateSport(
              value as String,
              _selectedRole,
              fieldTapped: _formValidation.tappedFields['sport']!,
            );
            break;
          case 'dob':
            updatedErrors['dob'] = ValidationService.validateDob(
              value as DateTime?,
              fieldTapped: _formValidation.tappedFields['dob']!,
            );
            break;
        }
        setFormValidation(_formValidation.copyWith(fieldErrors: updatedErrors));
      }
    });
  }

  void onFieldTapped(String fieldKey) {
    _markFieldAsTapped(fieldKey);
  }

  void onFieldChanged(String fieldKey, String value) {
    _validateField(fieldKey, value);
  }

  Color getBorderColor(String fieldKey, {bool hasText = false}) {
    if (!_formValidation.tappedFields[fieldKey]!) {
      return Colors.grey;
    }
    if (_formValidation.fieldErrors[fieldKey] != null) {
      return Colors.red;
    }
    if (hasText && !_isLogin) {
      return Colors.green;
    }
    return Colors.grey;
  }

  Future<void> checkInitialAuthState() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      if (userData == null) {
        await _authService.signOut();
        debugPrint('User signed out due to missing Firestore data');
        return;
      }

      bool isEmailVerifiedInFirestore = userData.emailVerified;
      if (userData.role == 'Organization' && isEmailVerifiedInFirestore) {
        await _navigateBasedOnRole(user.uid);
        return;
      }

      await _authService.reloadUser();
      final refreshedUser = _authService.currentUser;
      if (refreshedUser != null &&
          (refreshedUser.emailVerified || isEmailVerifiedInFirestore)) {
        if (!isEmailVerifiedInFirestore) {
          await _authService.updateEmailVerificationStatus(
            refreshedUser.uid,
            true,
          );
        }
        await _navigateBasedOnRole(refreshedUser.uid);
      } else {
        await _authService.signOut();
        debugPrint('User was signed out due to unverified email');
      }
    }
  }

  Future<void> handleAuth() async {
    if (_authState.status == AuthStatus.loading) return;

    // Validate all fields
    final updatedTappedFields = Map<String, bool>.from(
      _formValidation.tappedFields,
    );
    final updatedErrors = Map<String, String?>.from(
      _formValidation.fieldErrors,
    );

    updatedTappedFields['email'] = true;
    updatedTappedFields['password'] = true;

    updatedErrors['email'] = ValidationService.validateEmail(
      emailController.text.trim(),
      forceValidate: true,
    );
    updatedErrors['password'] = ValidationService.validatePassword(
      passwordController.text,
      isLogin: _isLogin,
      forceValidate: true,
    );

    if (!_isLogin) {
      updatedTappedFields['name'] = true;
      updatedTappedFields['sport'] = true;
      updatedTappedFields['dob'] = true;

      updatedErrors['name'] = ValidationService.validateName(
        nameController.text.trim(),
        forceValidate: true,
      );
      updatedErrors['sport'] = ValidationService.validateSport(
        sportController.text.trim(),
        _selectedRole,
        forceValidate: true,
      );
      updatedErrors['dob'] = ValidationService.validateDob(
        _dob,
        forceValidate: true,
      );
    }

    setFormValidation(
      _formValidation.copyWith(
        tappedFields: updatedTappedFields,
        fieldErrors: updatedErrors,
      ),
    );

    final activeErrors =
    _isLogin
        ? [updatedErrors['email'], updatedErrors['password']]
        : updatedErrors.values;

    final errors = activeErrors.where((error) => error != null).toList();
    if (errors.isNotEmpty) {
      setAuthState(
        AuthState(status: AuthStatus.error, errorMessage: errors.first),
      );
      return;
    }

    setAuthState(const AuthState(status: AuthStatus.loading));

    try {
      if (_isLogin) {
        await _handleLogin();
      } else {
        await _handleSignup();
      }
    } catch (e) {
      setAuthState(
        AuthState(
          status: AuthStatus.error,
          errorMessage: 'An error occurred: $e',
        ),
      );
    }
  }

  Future<void> _handleLogin() async {
    try {
      final email = emailController.text.trim();
      final userCredential = await _authService.signInWithEmailAndPassword(
        email,
        passwordController.text,
      );

      final userData = await _authService.getUserData(userCredential.user!.uid);
      if (userData == null) {
        await _authService.signOut();
        throw Exception('User data not found');
      }

      bool isEmailVerifiedInFirestore = userData.emailVerified;
      if (userData.role == 'Organization' && isEmailVerifiedInFirestore) {
        await _navigateBasedOnRole(userCredential.user!.uid);
        return;
      }

      await _authService.reloadUser();
      final refreshedUser = _authService.currentUser;
      if (refreshedUser == null) {
        throw Exception('User not found after login');
      }

      if (!isEmailVerifiedInFirestore && !refreshedUser.emailVerified) {
        setAuthState(
          AuthState(
            status: AuthStatus.emailVerificationPending,
            pendingVerificationEmail: email,
          ),
        );
        return;
      }

      if (refreshedUser.emailVerified && !isEmailVerifiedInFirestore) {
        await _authService.updateEmailVerificationStatus(
          refreshedUser.uid,
          true,
        );
      }

      await _navigateBasedOnRole(refreshedUser.uid);
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
      setAuthState(
        AuthState(status: AuthStatus.error, errorMessage: errorMessage),
      );
    }
  }

  Future<void> _handleSignup() async {
    try {
      final email = emailController.text.trim();
      final signInMethods = await _authService.fetchSignInMethodsForEmail(
        email,
      );

      if (signInMethods.isNotEmpty) {
        final userData = await _authService.getUserDataByEmail(email);
        if (userData != null && !userData.emailVerified) {
          setAuthState(
            AuthState(
              status: AuthStatus.error,
              errorMessage:
              'Email already registered but not verified. Please check your inbox or resend verification email.',
            ),
          );
          return;
        }

        setAuthState(
          const AuthState(
            status: AuthStatus.error,
            errorMessage: 'Email already registered. Please try logging in.',
          ),
        );
        return;
      }

      final userCredential = await _authService.createUserWithEmailAndPassword(
        email,
        passwordController.text,
      );

      final userModel = UserModel(
        uid: userCredential.user!.uid,
        name: nameController.text.trim(),
        email: email,
        role: _selectedRole,
        sport: sportController.text.trim(),
        dob: _dob!,
        emailVerified: false,
        signupCompleted: true,
        createdAt: DateTime.now(),
      );

      await _authService.storeUserDataInFirestore(userModel);
      await _authService.sendEmailVerification(userCredential.user!);

      setAuthState(
        AuthState(
          status: AuthStatus.emailVerificationPending,
          pendingVerificationEmail: email,
        ),
      );

      _startEmailVerificationCheck();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          final userData = await _authService.getUserDataByEmail(
            emailController.text.trim(),
          );
          if (userData != null && !userData.emailVerified) {
            errorMessage =
            'This email is already registered but not verified. Please check your inbox.';
          } else {
            errorMessage =
            'This email is already registered. Please try logging in.';
          }
          break;
        case 'weak-password':
          errorMessage =
          'Your password must be at least 8 characters and contain a number.';
          break;
        case 'operation-not-allowed':
          errorMessage =
          'This operation is not allowed. Please contact support.';
          break;
        default:
          errorMessage =
              e.message ?? 'An unknown error occurred. Please try again.';
      }
      setAuthState(
        AuthState(status: AuthStatus.error, errorMessage: errorMessage),
      );
    }
  }

  void _startEmailVerificationCheck() {
    _emailVerificationTimer = Timer.periodic(const Duration(seconds: 3), (
        timer,
        ) async {
      try {
        final user = _authService.currentUser;
        if (user == null) {
          timer.cancel();
          return;
        }

        await _authService.reloadUser();
        final refreshedUser = _authService.currentUser;
        if (refreshedUser != null && refreshedUser.emailVerified) {
          timer.cancel();
          await _authService.updateEmailVerificationStatus(
            refreshedUser.uid,
            true,
          );
          setAuthState(const AuthState(status: AuthStatus.authenticated));
          await _proceedAfterVerification(refreshedUser);
        }
      } catch (e) {
        debugPrint('Error checking email verification: $e');
      }
    });
  }

  Future<void> _proceedAfterVerification(User user) async {
    try {
      await _navigateBasedOnRole(user.uid);
    } catch (e) {
      setAuthState(
        AuthState(
          status: AuthStatus.error,
          errorMessage: 'Error proceeding after verification: $e',
        ),
      );
    }
  }

  Future<void> _navigateBasedOnRole(String uid) async {
    try {
      await _authService.saveFcmToken();

      // Get user data to determine role
      final userData = await _authService.getUserData(uid);
      if (userData == null) {
        setAuthState(
          const AuthState(
            status: AuthStatus.error,
            errorMessage: 'User data not found',
          ),
        );
        return;
      }

      // Set auth state with user role for navigation
      setAuthState(AuthState(
        status: AuthStatus.authenticated,
        userRole: userData.role,
      ));
    } catch (e) {
      setAuthState(
        AuthState(
          status: AuthStatus.error,
          errorMessage: 'Navigation error: $e',
        ),
      );
    }
  }

  Future<void> resendVerificationEmail() async {
    if (_authState.isResendingEmail) return;

    setAuthState(_authState.copyWith(isResendingEmail: true));

    try {
      final user = _authService.currentUser;
      if (user != null) {
        await _authService.reloadUser();
        final refreshedUser = _authService.currentUser;
        if (refreshedUser != null && !refreshedUser.emailVerified) {
          await _authService.sendEmailVerification(refreshedUser);
        } else if (refreshedUser != null && refreshedUser.emailVerified) {
          await _authService.updateEmailVerificationStatus(
            refreshedUser.uid,
            true,
          );
          setAuthState(const AuthState(status: AuthStatus.authenticated));
          await _proceedAfterVerification(refreshedUser);
        }
      }
    } catch (e) {
      String errorMessage = 'Error sending verification email';
      if (e.toString().contains('too-many-requests')) {
        errorMessage =
        'Too many requests. Please wait a moment before trying again.';
      } else if (e.toString().contains('network')) {
        errorMessage =
        'Network error. Please check your connection and try again.';
      }
      setAuthState(
        AuthState(status: AuthStatus.error, errorMessage: errorMessage),
      );
    } finally {
      setAuthState(_authState.copyWith(isResendingEmail: false));
    }
  }

  Future<void> checkVerificationManually() async {
    if (_authState.status == AuthStatus.loading) return;

    setAuthState(const AuthState(status: AuthStatus.loading));

    try {
      final user = _authService.currentUser;
      if (user != null) {
        await _authService.reloadUser();
        final refreshedUser = _authService.currentUser;
        if (refreshedUser != null && refreshedUser.emailVerified) {
          await _authService.updateEmailVerificationStatus(
            refreshedUser.uid,
            true,
          );
          setAuthState(const AuthState(status: AuthStatus.authenticated));
          await _navigateBasedOnRole(refreshedUser.uid);
        } else {
          setAuthState(
            const AuthState(
              status: AuthStatus.emailVerificationPending,
              errorMessage:
              'Email is still not verified. Please check your inbox and click the verification link first.',
            ),
          );
        }
      }
    } catch (e) {
      setAuthState(
        AuthState(status: AuthStatus.error, errorMessage: 'Error: $e'),
      );
    }
  }

  void goBackFromVerification() {
    _emailVerificationTimer?.cancel();
    setAuthState(const AuthState(status: AuthStatus.initial));
  }
}
