import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/features/auth/presentation/providers/auth_guard_provider.dart';
import 'package:flutter_elitesync/features/auth/presentation/state/register_form_state.dart';

class RegisterFormNotifier extends Notifier<RegisterFormState> {
  @override
  RegisterFormState build() => const RegisterFormState();

  void onPhoneChanged(String value) {
    state = state.copyWith(
      phone: value.trim(),
      clearError: true,
      clearSuccess: true,
    );
  }

  void onPasswordChanged(String value) {
    state = state.copyWith(
      password: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  void onNicknameChanged(String value) {
    state = state.copyWith(
      nickname: value.trim(),
      clearError: true,
      clearSuccess: true,
    );
  }

  void onAgreementChanged(bool value) {
    state = state.copyWith(
      isAgreementAccepted: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<bool> submit() async {
    if (!state.canSubmit) {
      state = state.copyWith(submitError: '请先填写正确手机号、密码并勾选协议');
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await ref
          .read(registerUseCaseProvider)
          .call(
            phone: state.phone,
            password: state.password,
            nickname: state.nickname.isEmpty ? null : state.nickname,
          );

      state = state.copyWith(isSubmitting: false, successMessage: '注册成功，请返回登录');
      return true;
    } catch (e) {
      final msg = ref.read(authErrorMapperProvider).mapToUserMessage(e);
      state = state.copyWith(isSubmitting: false, submitError: msg);
      return false;
    }
  }
}

final registerFormProvider =
    NotifierProvider<RegisterFormNotifier, RegisterFormState>(
      RegisterFormNotifier.new,
    );
