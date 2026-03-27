import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/features/verification/presentation/providers/verification_provider.dart';

class VerificationSubmitPage extends ConsumerStatefulWidget {
  const VerificationSubmitPage({super.key});

  @override
  ConsumerState<VerificationSubmitPage> createState() => _VerificationSubmitPageState();
}

class _VerificationSubmitPageState extends ConsumerState<VerificationSubmitPage> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(verificationProvider);
    final state = async.asData?.value;
    final t = context.appTokens;

    return AppScaffold(
      appBar: const AppTopBar(title: '提交认证', mode: AppTopBarMode.backTitle),
      body: ListView(
        children: [
          SizedBox(height: t.spacing.md),
          const SectionReveal(
            child: PageTitleRail(
              title: '提交认证信息',
              subtitle: '仅用于实名认证，不会公开展示',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 60),
            child: AppTextField(controller: _nameController, label: '真实姓名', hint: '请输入真实姓名'),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 110),
            child: AppTextField(controller: _idController, label: '身份证号', hint: '请输入身份证号'),
          ),
          SizedBox(height: t.spacing.lg),
          SectionReveal(
            delay: const Duration(milliseconds: 160),
            child: AppPrimaryButton(
              label: '提交审核',
              isLoading: state?.isSubmitting ?? false,
              onPressed: () async {
                final router = GoRouter.of(context);
                await ref.read(verificationProvider.notifier).submit(
                      realName: _nameController.text.trim(),
                      idNumber: _idController.text.trim(),
                    );
                if (!mounted) return;
                router.pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
