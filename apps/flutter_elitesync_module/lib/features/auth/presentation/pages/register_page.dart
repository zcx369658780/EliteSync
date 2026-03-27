import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_password_field.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/providers/register_form_provider.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/widgets/auth_agreement_row.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/widgets/immersive_auth_background.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nicknameController;
  bool _performanceLiteMode = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _nicknameController = TextEditingController();
    _loadPerformanceMode();
  }

  Future<void> _loadPerformanceMode() async {
    final local = ref.read(localStorageProvider);
    final value = await local.getBool(CacheKeys.performanceLiteMode);
    if (!mounted) return;
    setState(() => _performanceLiteMode = value ?? false);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(registerFormProvider.notifier).submit();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final state = ref.watch(registerFormProvider);

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
                Text(
                  '创建账号',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                SizedBox(height: t.spacing.xs),
                Text(
                  '注册后即可进入资料与匹配流程',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: t.textSecondary),
                ),
                SizedBox(height: t.spacing.xl),
                Container(
                  padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                  decoration: BoxDecoration(
                    color: t.surface.withValues(alpha: 0.80),
                    borderRadius: BorderRadius.circular(t.radius.xl),
                    border: Border.all(color: t.overlay.withValues(alpha: 0.72)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: _phoneController,
                        label: '手机号',
                        hint: '请输入 11 位手机号',
                        keyboardType: TextInputType.phone,
                        onChanged: ref.read(registerFormProvider.notifier).onPhoneChanged,
                      ),
                      SizedBox(height: t.spacing.md),
                      AppPasswordField(
                        controller: _passwordController,
                        label: '密码',
                        hint: '请输入密码',
                        helperText: '密码规则：至少 8 位，建议字母+数字',
                        onChanged: ref.read(registerFormProvider.notifier).onPasswordChanged,
                      ),
                      SizedBox(height: t.spacing.md),
                      AppTextField(
                        controller: _nicknameController,
                        label: '昵称（可选）',
                        hint: '请输入你的昵称',
                        onChanged: ref.read(registerFormProvider.notifier).onNicknameChanged,
                      ),
                      SizedBox(height: t.spacing.sm),
                      AuthAgreementRow(
                        value: state.isAgreementAccepted,
                        onChanged: ref.read(registerFormProvider.notifier).onAgreementChanged,
                      ),
                      if ((state.submitError ?? '').isNotEmpty) ...[
                        SizedBox(height: t.spacing.sm),
                        Text(
                          state.submitError!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.error),
                        ),
                      ],
                      if ((state.successMessage ?? '').isNotEmpty) ...[
                        SizedBox(height: t.spacing.sm),
                        Text(
                          state.successMessage!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.success),
                        ),
                      ],
                      SizedBox(height: t.spacing.lg),
                      AppPrimaryButton(
                        label: '完成注册',
                        isLoading: state.isSubmitting,
                        onPressed: state.canSubmit ? _submit : null,
                      ),
                      SizedBox(height: t.spacing.sm),
                      AppSecondaryButton(
                        label: '返回登录',
                        fullWidth: true,
                        onPressed: () => context.pop(),
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
