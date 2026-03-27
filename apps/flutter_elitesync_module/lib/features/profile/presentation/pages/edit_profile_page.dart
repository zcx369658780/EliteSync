import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nickname = TextEditingController();
  final _birthday = TextEditingController();
  final _city = TextEditingController();
  bool _initialized = false;
  String? _selectedGender;
  String? _selectedTarget;

  static const List<_OptionItem> _genderOptions = [
    _OptionItem(value: 'male', label: '男'),
    _OptionItem(value: 'female', label: '女'),
  ];

  static const List<_OptionItem> _targetOptions = [
    _OptionItem(value: 'marriage', label: '结婚'),
    _OptionItem(value: 'dating', label: '恋爱'),
    _OptionItem(value: 'friendship', label: '交友'),
  ];

  @override
  void dispose() {
    _nickname.dispose();
    _birthday.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(editProfileProvider);
    final detail = async.asData?.value.detail;
    final t = context.appTokens;

    if (detail != null && !_initialized) {
      _initialized = true;
      _nickname.text = detail.nickname;
      _birthday.text = detail.birthday;
      _city.text = detail.city;
      _selectedGender = _normalizeGender(detail.gender);
      _selectedTarget = _normalizeTarget(detail.target);
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
                  _SelectionField(
                    label: '性别',
                    value: _selectedGender,
                    options: _genderOptions,
                    hint: '请选择性别',
                    onChanged: (value) => setState(() => _selectedGender = value),
                  ),
                  SizedBox(height: t.spacing.sm),
                  GestureDetector(
                    onTap: _pickBirthday,
                    child: AbsorbPointer(
                      child: AppTextField(
                        controller: _birthday,
                        label: '生日',
                        hint: '请选择生日',
                        readOnly: true,
                        suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  AppTextField(controller: _city, label: '城市'),
                  SizedBox(height: t.spacing.sm),
                  _SelectionField(
                    label: '婚恋目标',
                    value: _selectedTarget,
                    options: _targetOptions,
                    hint: '请选择婚恋目标',
                    onChanged: (value) => setState(() => _selectedTarget = value),
                  ),
                  SizedBox(height: t.spacing.lg),
                  AppPrimaryButton(
                    label: '保存资料',
                    isLoading: async.asData?.value.saving ?? false,
                    onPressed: () async {
                      final genderValue = _selectedGender ?? '';
                      final targetValue = _selectedTarget ?? '';
                      await ref.read(editProfileProvider.notifier).save(
                            ProfileDetailEntity(
                              nickname: _nickname.text.trim(),
                              gender: genderValue,
                              birthday: _birthday.text.trim(),
                              city: _city.text.trim(),
                              target: targetValue,
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

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    DateTime initial = DateTime(now.year - 24, now.month, now.day);
    if (_birthday.text.isNotEmpty) {
      final parsed = DateTime.tryParse(_birthday.text);
      if (parsed != null) {
        initial = parsed;
      }
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime(now.year - 18, 12, 31),
      helpText: '选择生日',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (picked == null) return;
    setState(() {
      final mm = picked.month.toString().padLeft(2, '0');
      final dd = picked.day.toString().padLeft(2, '0');
      _birthday.text = '${picked.year}-$mm-$dd';
    });
  }

  String? _normalizeGender(String raw) {
    final v = raw.trim().toLowerCase();
    if (v == 'male' || v == '男' || v == 'm') return 'male';
    if (v == 'female' || v == '女' || v == 'f') return 'female';
    return null;
  }

  String? _normalizeTarget(String raw) {
    final v = raw.trim().toLowerCase();
    if (v == 'marriage' || v == '结婚') return 'marriage';
    if (v == 'dating' || v == '恋爱') return 'dating';
    if (v == 'friendship' || v == '交友') return 'friendship';
    return null;
  }
}

class _SelectionField extends StatelessWidget {
  const _SelectionField({
    required this.label,
    required this.value,
    required this.options,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<_OptionItem> options;
  final String hint;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(t.radius.md),
      borderSide: BorderSide(color: t.overlay),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: t.textPrimary, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: t.spacing.xs),
        DropdownButtonFormField<String>(
          key: ValueKey<String>('${label}_${value ?? ''}'),
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: t.surface,
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.textTertiary),
            contentPadding: EdgeInsets.symmetric(horizontal: t.spacing.md, vertical: t.spacing.md),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(borderSide: BorderSide(color: t.brandPrimary)),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: options
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e.value,
                  child: Text(e.label),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
        SizedBox(height: t.spacing.xs),
      ],
    );
  }
}

class _OptionItem {
  const _OptionItem({required this.value, required this.label});

  final String value;
  final String label;
}
