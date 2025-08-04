import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_state.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'responsive_helper.dart';

class EmailVerificationPending extends StatelessWidget {
  const EmailVerificationPending({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth:
                ResponsiveHelper.isLargeScreen(context) ? 600 : double.infinity,
          ),
          padding: EdgeInsets.all(
            ResponsiveHelper.isSmallScreen(context)
                ? 16
                : ResponsiveHelper.isMediumScreen(context)
                ? 20
                : 24,
          ),
          margin: EdgeInsets.symmetric(
            vertical:
                screenHeight *
                (ResponsiveHelper.isSmallScreen(context) ? 0.02 : 0.03),
            horizontal:
                ResponsiveHelper.isLargeScreen(context) ? screenWidth * 0.1 : 0,
          ),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.isSmallScreen(context) ? 12 : 16,
            ),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.mark_email_unread,
                color: Colors.orange,
                size:
                    ResponsiveHelper.isSmallScreen(context)
                        ? 40
                        : ResponsiveHelper.isMediumScreen(context)
                        ? 48
                        : 56,
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                'Email Verification Required',
                style: TextStyle(
                  fontSize:
                      ResponsiveHelper.isSmallScreen(context)
                          ? 16
                          : ResponsiveHelper.isMediumScreen(context)
                          ? 18
                          : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'We\'ve sent a verification email to\n${viewModel.authState.pendingVerificationEmail ?? viewModel.emailController.text.trim()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize:
                      ResponsiveHelper.isSmallScreen(context)
                          ? 12
                          : ResponsiveHelper.isMediumScreen(context)
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
                      ResponsiveHelper.isSmallScreen(context)
                          ? 10
                          : ResponsiveHelper.isMediumScreen(context)
                          ? 12
                          : 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Responsive button layout
              if (ResponsiveHelper.isSmallScreen(context)) ...[
                // Stack buttons vertically on small screens
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed:
                            viewModel.authState.isResendingEmail
                                ? null
                                : viewModel.resendVerificationEmail,
                        icon:
                            viewModel.authState.isResendingEmail
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.refresh),
                        label: Text(
                          viewModel.authState.isResendingEmail
                              ? 'Sending...'
                              : 'Resend Email',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            viewModel.authState.status == AuthStatus.loading
                                ? null
                                : viewModel.checkVerificationManually,
                        icon:
                            viewModel.authState.status == AuthStatus.loading
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.check),
                        label: Text(
                          viewModel.authState.status == AuthStatus.loading
                              ? 'Checking...'
                              : 'I\'ve Verified',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: viewModel.goBackFromVerification,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text(
                        'Go Back',
                        style: TextStyle(fontSize: 12),
                      ),
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
                            viewModel.authState.isResendingEmail
                                ? null
                                : viewModel.resendVerificationEmail,
                        icon:
                            viewModel.authState.isResendingEmail
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.refresh),
                        label: Text(
                          viewModel.authState.isResendingEmail
                              ? 'Sending...'
                              : 'Resend Email',
                          style: TextStyle(
                            fontSize:
                                ResponsiveHelper.isMediumScreen(context)
                                    ? 12
                                    : 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            viewModel.authState.status == AuthStatus.loading
                                ? null
                                : viewModel.checkVerificationManually,
                        icon:
                            viewModel.authState.status == AuthStatus.loading
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.check),
                        label: Text(
                          viewModel.authState.status == AuthStatus.loading
                              ? 'Checking...'
                              : 'I\'ve Verified',
                          style: TextStyle(
                            fontSize:
                                ResponsiveHelper.isMediumScreen(context)
                                    ? 12
                                    : 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: viewModel.goBackFromVerification,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(
                    'Go Back',
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.isMediumScreen(context) ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
