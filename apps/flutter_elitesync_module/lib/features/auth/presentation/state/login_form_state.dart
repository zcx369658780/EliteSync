class LoginFormState {
  const LoginFormState({
    this.phone = '',
    this.password = '',
    this.isAgreementAccepted = false,
    this.isSubmitting = false,
    this.submitError,
  });

  final String phone;
  final String password;
  final bool isAgreementAccepted;
  final bool isSubmitting;
  final String? submitError;

  bool get isPhoneValid => RegExp(r'^1\d{10}$').hasMatch(phone);
  bool get isPasswordValid => password.length >= 8;
  bool get canSubmit =>
      isPhoneValid && isPasswordValid && isAgreementAccepted && !isSubmitting;

  LoginFormState copyWith({
    String? phone,
    String? password,
    bool? isAgreementAccepted,
    bool? isSubmitting,
    String? submitError,
    bool clearError = false,
  }) {
    return LoginFormState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      isAgreementAccepted: isAgreementAccepted ?? this.isAgreementAccepted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearError ? null : (submitError ?? this.submitError),
    );
  }
}
