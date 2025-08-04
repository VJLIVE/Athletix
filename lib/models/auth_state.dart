enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailVerificationPending,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? pendingVerificationEmail;
  final bool isResendingEmail;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.pendingVerificationEmail,
    this.isResendingEmail = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? pendingVerificationEmail,
    bool? isResendingEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      pendingVerificationEmail:
          pendingVerificationEmail ?? this.pendingVerificationEmail,
      isResendingEmail: isResendingEmail ?? this.isResendingEmail,
    );
  }
}
