import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/features/auth/presentation/providers/auth_guard_provider.dart';
import 'package:flutter_elitesync/features/auth/presentation/state/login_form_state.dart';
import 'package:flutter_elitesync/shared/models/user_summary.dart';
import 'package:flutter_elitesync/shared/providers/session_provider.dart';

class LoginFormNotifier extends Notifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormState();

  void onPhoneChanged(String value) {
    state = state.copyWith(phone: value.trim(), clearError: true);
  }

  void onPasswordChanged(String value) {
    state = state.copyWith(password: value, clearError: true);
  }

  void onAgreementChanged(bool value) {
    state = state.copyWith(isAgreementAccepted: value, clearError: true);
  }

  Future<bool> submit() async {
    if (!state.canSubmit) {
      state = state.copyWith(submitError: '请先填写正确手机号、密码并勾选协议');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final session = await ref
          .read(loginUseCaseProvider)
          .call(phone: state.phone, password: state.password);

      await ref
          .read(sessionProvider.notifier)
          .setAuthenticated(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            user: UserSummary(
              id: session.user.id,
              phone: session.user.phone,
              nickname: session.user.nickname,
              city: session.user.city,
              avatarUrl: session.user.avatarUrl,
              verified: session.user.verified,
            ),
          );

      state = state.copyWith(isSubmitting: false, clearError: true);
      return true;
    } catch (e) {
      final msg = ref.read(authErrorMapperProvider).mapToUserMessage(e);
      state = state.copyWith(isSubmitting: false, submitError: msg);
      return false;
    }
  }
}

final loginFormProvider = NotifierProvider<LoginFormNotifier, LoginFormState>(
  LoginFormNotifier.new,
);
