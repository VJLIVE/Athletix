import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:athletix/models/auth_state.dart';
import 'package:athletix/viewmodels/auth_viewmodel.dart';
import 'package:athletix/views/widgets/auth_form.dart';
import 'package:athletix/views/widgets/email_verification_pending.dart';
import 'package:athletix/views/widgets/responsive_helper.dart';
import 'athlete/athlete_dashboard.dart';
import 'coach/coach_dashboard.dart';
import 'doctor/doctor_dashboard.dart';
import 'package:athletix/l10n/app_localizations.dart';
import 'organization/organization_dashboard.dart';

class AuthScreen extends StatefulWidget {
  // 1. Add the setLocale function to the constructor
  final Function(Locale) setLocale;
  const AuthScreen({super.key, required this.setLocale});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthViewModel _viewModel;
  AuthStatus? _lastAuthStatus;

  @override
  void initState() {
    super.initState();
    _viewModel = AuthViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.checkInitialAuthState();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _handleAuthStateChange(AuthState authState) {
    if (_lastAuthStatus == authState.status) return;

    _lastAuthStatus = authState.status;

    switch (authState.status) {
      case AuthStatus.authenticated:
        _navigateToUserDashboard();
        break;
      case AuthStatus.error:
        if (authState.errorMessage != null) {
          _showErrorSnackBar(authState.errorMessage!);
        }
        break;
      default:
        break;
    }
  }

  void _navigateToUserDashboard() async {
    final userRole = _viewModel.authState.userRole ?? 'Athlete';

    Widget destinationScreen;
    switch (userRole) {
      // 2. Pass the setLocale function to the dashboard screens
      case 'Coach':
        destinationScreen = CoachDashboardScreen(setLocale: widget.setLocale);
        break;
      case 'Doctor':
        destinationScreen = DoctorDashboardScreen(setLocale: widget.setLocale);
        break;
      case 'Organization':
        // 3. This line was missing the setLocale parameter. It's now corrected.
        destinationScreen = OrganizationDashboardScreen(
          setLocale: widget.setLocale,
        );
        break;
      case 'Athlete':
      default:
        destinationScreen = DashboardScreen(setLocale: widget.setLocale);
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destinationScreen),
    );
  }

  void _showErrorSnackBar(String message) {
    final localizations = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: localizations.dismissButton,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthViewModel>.value(
      value: _viewModel,
      child: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleAuthStateChange(viewModel.authState);
          });

          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth:
                          ResponsiveHelper.isLargeScreen(context)
                              ? 800
                              : double.infinity,
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getResponsivePadding(
                        context,
                      ),
                      vertical:
                          MediaQuery.of(context).size.height *
                          (ResponsiveHelper.isSmallScreen(context)
                              ? 0.03
                              : 0.05),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image(
                              image: const AssetImage("assets/logo_png.png"),
                              width: MediaQuery.of(context).size.width * 0.15,
                            ),
                          ],
                        ),
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height *
                              (ResponsiveHelper.isSmallScreen(context)
                                  ? 0.03
                                  : 0.04),
                        ),
                        // Main content based on auth state
                        if (viewModel.authState.status ==
                            AuthStatus.emailVerificationPending)
                          const EmailVerificationPending()
                        else
                          const AuthForm(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
