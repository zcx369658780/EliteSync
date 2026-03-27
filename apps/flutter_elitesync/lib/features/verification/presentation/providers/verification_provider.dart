import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/features/verification/data/datasource/verification_remote_data_source.dart';
import 'package:flutter_elitesync/features/verification/data/mapper/verification_mapper.dart';
import 'package:flutter_elitesync/features/verification/data/repository/verification_repository_impl.dart';
import 'package:flutter_elitesync/features/verification/domain/repository/verification_repository.dart';
import 'package:flutter_elitesync/features/verification/domain/usecases/get_verification_status_usecase.dart';
import 'package:flutter_elitesync/features/verification/domain/usecases/submit_verification_usecase.dart';
import 'package:flutter_elitesync/features/verification/presentation/state/verification_ui_state.dart';
import 'package:flutter_elitesync/shared/providers/app_providers.dart';

final verificationRemoteDataSourceProvider = Provider<VerificationRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return VerificationRemoteDataSource(apiClient: ref.watch(apiClientProvider), useMock: env.useMockData);
});

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepositoryImpl(
    remote: ref.watch(verificationRemoteDataSourceProvider),
    mapper: const VerificationMapper(),
  );
});

final getVerificationStatusUseCaseProvider = Provider<GetVerificationStatusUseCase>((ref) {
  return GetVerificationStatusUseCase(ref.watch(verificationRepositoryProvider));
});

final submitVerificationUseCaseProvider = Provider<SubmitVerificationUseCase>((ref) {
  return SubmitVerificationUseCase(ref.watch(verificationRepositoryProvider));
});

class VerificationNotifier extends AsyncNotifier<VerificationUiState> {
  @override
  Future<VerificationUiState> build() async {
    final status = await ref.read(getVerificationStatusUseCaseProvider).call();
    return VerificationUiState(status: status);
  }

  Future<void> refresh() async {
    final current = state.asData?.value ?? const VerificationUiState();
    state = AsyncData(current.copyWith(isLoading: true, clearError: true, clearMessage: true));
    try {
      final status = await ref.read(getVerificationStatusUseCaseProvider).call();
      state = AsyncData(current.copyWith(status: status, isLoading: false));
    } catch (e) {
      state = AsyncData(current.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> submit({required String realName, required String idNumber}) async {
    final current = state.asData?.value ?? const VerificationUiState();
    state = AsyncData(current.copyWith(isSubmitting: true, clearError: true, clearMessage: true));
    try {
      await ref.read(submitVerificationUseCaseProvider).call(realName: realName, idNumber: idNumber);
      final status = await ref.read(getVerificationStatusUseCaseProvider).call();
      state = AsyncData(current.copyWith(
        status: status,
        isSubmitting: false,
        message: '提交成功，等待审核',
      ));
    } catch (e) {
      state = AsyncData(current.copyWith(isSubmitting: false, error: e.toString()));
    }
  }
}

final verificationProvider = AsyncNotifierProvider<VerificationNotifier, VerificationUiState>(
  VerificationNotifier.new,
);
