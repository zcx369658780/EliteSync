import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_password_field.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/providers/login_form_provider.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/widgets/auth_agreement_row.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/widgets/immersive_auth_background.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  bool _performanceLiteMode = false;
  bool _debugAutoLoginQueued = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _loadPerformanceMode();
    _scheduleDebugAutoLogin();
  }

  Future<void> _loadPerformanceMode() async {
    final local = ref.read(localStorageProvider);
    final value = await local.getBool(CacheKeys.performanceLiteMode);
    if (!mounted) return;
    setState(() => _performanceLiteMode = value ?? false);
  }

  void _scheduleDebugAutoLogin() {
    final env = ref.read(appEnvProvider);
    final phone = env.debugAutoLoginPhone.trim();
    final password = env.debugAutoLoginPassword.trim();
    if (phone.isEmpty || password.isEmpty || _debugAutoLoginQueued) return;
    // ignore: avoid_print
    print('LOGIN_DEBUG_AUTOSUBMIT queued phone=${phone.isNotEmpty} pwd=${password.isNotEmpty}');
    _debugAutoLoginQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _phoneController.text = phone;
      _passwordController.text = password;
      ref.read(loginFormProvider.notifier).onPhoneChanged(phone);
      ref.read(loginFormProvider.notifier).onPasswordChanged(password);
      ref.read(loginFormProvider.notifier).onAgreementChanged(true);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      await _submit();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await ref.read(loginFormProvider.notifier).submit();
    if (!mounted || !ok) return;
    final env = ref.read(appEnvProvider);
    final target = env.initialRoute?.trim();
    if (target != null && target.isNotEmpty) {
      context.go(target);
      return;
    }
    context.go(AppRouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final state = ref.watch(loginFormProvider);

    return Scaffold(
      body: ImmersiveAuthBackground(
        performanceLiteMode: _performanceLiteMode,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              t.spacing.pageHorizontal,
              t.spacing.xl,
              t.spacing.pageHorizontal,
              t.spacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: const SizedBox.shrink(),
                ),
                SizedBox(height: t.spacing.lg),
                Text(
                  '慢约会',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: t.spacing.xs),
                Text(
                  '在同一片星空下，认真认识一个人',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: t.textSecondary),
                ),
                SizedBox(height: t.spacing.xl),
                Container(
                  padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                  decoration: BoxDecoration(
                    color: t.surface.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(t.radius.xl),
                    border: Border.all(color: t.overlay.withValues(alpha: 0.7)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.20),
                        blurRadius: 26,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '账号登录',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: t.spacing.xs),
                      Text(
                        '登录后继续匹配与聊天',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: t.textSecondary,
                        ),
                      ),
                      SizedBox(height: t.spacing.lg),
                      AppTextField(
                        controller: _phoneController,
                        label: '手机号',
                        hint: '请输入 11 位手机号',
                        keyboardType: TextInputType.phone,
                        onChanged: ref
                            .read(loginFormProvider.notifier)
                            .onPhoneChanged,
                      ),
                      SizedBox(height: t.spacing.md),
                      AppPasswordField(
                        controller: _passwordController,
                        label: '密码',
                        hint: '请输入密码',
                        helperText: '密码规则：至少 8 位，建议字母+数字',
                        onChanged: ref
                            .read(loginFormProvider.notifier)
                            .onPasswordChanged,
                      ),
                      SizedBox(height: t.spacing.sm),
                      AuthAgreementRow(
                        value: state.isAgreementAccepted,
                        onChanged: ref
                            .read(loginFormProvider.notifier)
                            .onAgreementChanged,
                      ),
                      if ((state.submitError ?? '').isNotEmpty) ...[
                        SizedBox(height: t.spacing.sm),
                        Text(
                          state.submitError!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: t.error),
                        ),
                      ],
                      SizedBox(height: t.spacing.lg),
                      AppPrimaryButton(
                        label: '进入慢约会',
                        isLoading: state.isSubmitting,
                        onPressed: state.canSubmit ? _submit : null,
                      ),
                      SizedBox(height: t.spacing.sm),
                      AppSecondaryButton(
                        label: '还没有账号，去注册',
                        fullWidth: true,
                        onPressed: () => context.push(AppRouteNames.register),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
