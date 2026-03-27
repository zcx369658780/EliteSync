import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_password_field.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _nextController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  String _status = '';
  String? _currentError;
  String? _nextError;
  String? _confirmError;

  @override
  void dispose() {
    _currentController.dispose();
    _nextController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _currentError = null;
      _nextError = null;
      _confirmError = null;
    });
    final current = _currentController.text.trim();
    final next = _nextController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty) {
      setState(() => _currentError = '请输入当前密码');
      return false;
    }
    if (next.length < 8) {
      setState(() => _nextError = '新密码至少 8 位');
      return false;
    }
    if (next != confirm) {
      setState(() => _confirmError = '两次输入的新密码不一致');
      return false;
    }
    if (current == next) {
      setState(() => _nextError = '新密码不能与当前密码相同');
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() {
      _loading = true;
      _status = '';
    });
    final api = ref.read(apiClientProvider);
    final result = await api.post('/api/v1/auth/password', body: {
      'current_password': _currentController.text.trim(),
      'new_password': _nextController.text.trim(),
      'new_password_confirmation': _confirmController.text.trim(),
    });
    if (!mounted) return;
    setState(() => _loading = false);

    if (result is NetworkFailure<Map<String, dynamic>>) {
      setState(() => _status = '修改失败: ${result.message}');
      return;
    }
    setState(() => _status = '密码修改成功');
    _currentController.clear();
    _nextController.clear();
    _confirmController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppScaffold(
      appBar: const AppTopBar(title: '修改密码', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, t.spacing.sm, 0, t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(
              title: '账户安全',
              subtitle: '密码建议 8-20 位，包含字母与数字',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 60),
            child: AppPasswordField(
              controller: _currentController,
              label: '当前密码',
              hint: '请输入当前密码',
              errorText: _currentError,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 90),
            child: AppPasswordField(
              controller: _nextController,
              label: '新密码',
              hint: '至少 8 位，建议字母+数字',
              errorText: _nextError,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 120),
            child: AppPasswordField(
              controller: _confirmController,
              label: '确认新密码',
              hint: '请再次输入新密码',
              errorText: _confirmError,
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 160),
            child: AppPrimaryButton(
              label: '保存新密码',
              isLoading: _loading,
              onPressed: _submit,
            ),
          ),
          if (_status.isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            Text(
              _status,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _status.contains('成功') ? t.success : t.error,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
