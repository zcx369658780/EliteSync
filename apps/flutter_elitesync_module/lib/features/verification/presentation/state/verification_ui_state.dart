import 'package:flutter_elitesync_module/features/verification/domain/entities/verification_state_entity.dart';

class VerificationUiState {
  const VerificationUiState({
    this.status,
    this.isLoading = false,
    this.isSubmitting = false,
    this.message,
    this.error,
  });

  final VerificationStateEntity? status;
  final bool isLoading;
  final bool isSubmitting;
  final String? message;
  final String? error;

  VerificationUiState copyWith({
    VerificationStateEntity? status,
    bool? isLoading,
    bool? isSubmitting,
    String? message,
    String? error,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return VerificationUiState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: clearMessage ? null : (message ?? this.message),
      error: clearError ? null : (error ?? this.error),
    );
  }
}
