import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:athletix/models/auth_state.dart';
import 'package:athletix/viewmodels/auth_viewmodel.dart';
import 'package:athletix/views/widgets/auth_form.dart';
import 'package:athletix/views/widgets/email_verification_pending.dart';
import 'package:athletix/views/widgets/responsive_helper.dart';
import 'athlete/athlete_dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthViewModel _viewModel;

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
    switch (authState.status) {
      case AuthStatus.authenticated:
        _navigateToUserDashboard();
        break;
      case AuthStatus.error:
        if (authState.errorMessage != null) {
          _showErrorDialog(authState.errorMessage!);
        }
        break;
      default:
        break;
    }
  }

  void _navigateToUserDashboard() async {
    // This would typically get the user role from the viewmodel
    // For now, we'll navigate to athlete dashboard as default
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthViewModel>.value(
      value: _viewModel,
      child: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
          // Listen to auth state changes
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
