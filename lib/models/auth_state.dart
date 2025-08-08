enum AuthStatus {
  initial,
  loading,
  authenticated,
  emailVerificationPending,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? pendingVerificationEmail;
  final bool isResendingEmail;
  final String? userRole;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.pendingVerificationEmail,
    this.isResendingEmail = false,
    this.userRole,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? pendingVerificationEmail,
    bool? isResendingEmail,
    String? userRole,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingVerificationEmail: pendingVerificationEmail ?? this.pendingVerificationEmail,
      isResendingEmail: isResendingEmail ?? this.isResendingEmail,
      userRole: userRole ?? this.userRole,
    );
  }
}
