import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync/features/profile/presentation/providers/profile_providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nickname = TextEditingController();
  final _gender = TextEditingController();
  final _birthday = TextEditingController();
  final _city = TextEditingController();
  final _target = TextEditingController();

  @override
  void dispose() {
    _nickname.dispose();
    _gender.dispose();
    _birthday.dispose();
    _city.dispose();
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(editProfileProvider);
    final detail = async.asData?.value.detail;
    final t = context.appTokens;

    if (detail != null && _nickname.text.isEmpty) {
      _nickname.text = detail.nickname;
      _gender.text = detail.gender;
      _birthday.text = detail.birthday;
      _city.text = detail.city;
      _target.text = detail.target;
    }

    return AppScaffold(
      appBar: const AppTopBar(title: '编辑资料', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, t.spacing.sm, 0, t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(
              title: '完善基础资料',
              subtitle: '资料越完整，匹配解释越准确',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 70),
            child: AppCard(
              child: Column(
                children: [
                  AppTextField(controller: _nickname, label: '昵称'),
                  SizedBox(height: t.spacing.sm),
                  AppTextField(controller: _gender, label: '性别'),
                  SizedBox(height: t.spacing.sm),
                  AppTextField(controller: _birthday, label: '生日'),
                  SizedBox(height: t.spacing.sm),
                  AppTextField(controller: _city, label: '城市'),
                  SizedBox(height: t.spacing.sm),
                  AppTextField(controller: _target, label: '婚恋目标'),
                  SizedBox(height: t.spacing.lg),
                  AppPrimaryButton(
                    label: '保存资料',
                    isLoading: async.asData?.value.saving ?? false,
                    onPressed: () async {
                      await ref.read(editProfileProvider.notifier).save(
                            ProfileDetailEntity(
                              nickname: _nickname.text.trim(),
                              gender: _gender.text.trim(),
                              birthday: _birthday.text.trim(),
                              city: _city.text.trim(),
                              target: _target.text.trim(),
                            ),
                          );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('资料已保存')));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
