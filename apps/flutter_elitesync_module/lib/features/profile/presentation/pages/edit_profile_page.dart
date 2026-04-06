import 'dart:async';

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
import 'package:flutter_elitesync_module/app/router/app_route_observer.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> with RouteAware {
  final _pageScrollController = ScrollController();
  final _nickname = TextEditingController();
  final _birthday = TextEditingController();
  final _birthTime = TextEditingController();
  final _city = TextEditingController();
  final _birthPlace = TextEditingController();
  final _birthPlaceQuery = TextEditingController();
  final _birthPlacePanelKey = GlobalKey();
  bool _initialized = false;
  String _lastSyncedSignature = '';
  String? _selectedGender;
  String? _selectedTarget;
  bool _birthPlacePanelVisible = false;
  bool _birthPlacePanelAnimatingOut = false;
  bool _birthPlaceSearching = false;
  String? _birthPlaceSearchError;
  Timer? _birthPlaceSearchDebounce;
  int _birthPlaceSearchTicket = 0;
  String? _selectedBirthPlace;
  double? _selectedBirthLat;
  double? _selectedBirthLng;
  List<_BirthPlaceItem> _birthPlaceCandidatesView = const [];
  RouteObserver<PageRoute<dynamic>>? _routeObserver;

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
    if (_routeObserver != null) {
      _routeObserver!.unsubscribe(this);
    }
    _birthPlaceSearchDebounce?.cancel();
    _pageScrollController.dispose();
    _nickname.dispose();
    _birthday.dispose();
    _birthTime.dispose();
    _city.dispose();
    _birthPlace.dispose();
    _birthPlaceQuery.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final observer = ref.read(appRouteObserverProvider);
    if (_routeObserver != observer) {
      _routeObserver?.unsubscribe(this);
      _routeObserver = observer;
      _routeObserver?.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
    }
  }

  @override
  void didPopNext() {
    ref.invalidate(editProfileProvider);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(editProfileProvider);
    final detail = async.asData?.value.detail;
    final t = context.appTokens;

    if (detail != null) {
      final signature = [
        detail.nickname,
        detail.gender,
        detail.birthday,
        detail.birthTime,
        detail.city,
        detail.target,
        detail.birthPlace ?? '',
        detail.birthLat?.toStringAsFixed(6) ?? '',
        detail.birthLng?.toStringAsFixed(6) ?? '',
      ].join('|');
      final shouldSync = !_initialized || _lastSyncedSignature != signature;
      if (shouldSync) {
        _initialized = true;
        _lastSyncedSignature = signature;
        _nickname.text = detail.nickname;
        _birthday.text = detail.birthday;
        _birthTime.text = detail.birthTime;
        _city.text = detail.city;
        _birthPlace.text = detail.birthPlace ?? '';
        _birthPlaceQuery.text = detail.birthPlace ?? '';
        _selectedGender = _normalizeGender(detail.gender);
        _selectedTarget = _normalizeTarget(detail.target);
        _selectedBirthPlace = detail.birthPlace;
        _selectedBirthLat = detail.birthLat;
        _selectedBirthLng = detail.birthLng;
      }
    }

    return AppScaffold(
      appBar: const AppTopBar(title: '编辑资料', mode: AppTopBarMode.backTitle),
      body: ListView(
        controller: _pageScrollController,
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
                  GestureDetector(
                    onTap: _pickBirthTime,
                    child: AbsorbPointer(
                      child: AppTextField(
                        controller: _birthTime,
                        label: '出生时间',
                        hint: '请选择出生时间',
                        readOnly: true,
                        suffixIcon: const Icon(Icons.schedule_rounded, size: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: t.spacing.xxs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '出生时间会影响八字 / 紫微 / 星盘计算，建议填写精确时间',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: t.textSecondary,
                            height: 1.35,
                          ),
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  _BirthPlaceSearchField(
                    searchController: _birthPlaceQuery,
                    valueController: _birthPlace,
                    visible: _birthPlacePanelVisible,
                    animatingOut: _birthPlacePanelAnimatingOut,
                    searching: _birthPlaceSearching,
                    errorText: _birthPlaceSearchError,
                    candidates: _birthPlaceCandidatesView.take(10).toList(),
                    selectedLabel: _selectedBirthPlace,
                    onFocusTap: () {
                      setState(() => _birthPlacePanelVisible = true);
                      _ensureBirthPlacePanelVisible();
                    },
                    onQueryChanged: _onBirthPlaceQueryChanged,
                    onSelect: (item) async {
                      setState(() {
                        _selectedBirthPlace = item.label;
                        _selectedBirthLat = item.lat;
                        _selectedBirthLng = item.lng;
                        _birthPlace.text = item.label;
                        _birthPlaceQuery.text = item.label;
                        _birthPlacePanelAnimatingOut = true;
                      });
                      await Future<void>.delayed(const Duration(milliseconds: 500));
                      if (!mounted) return;
                      setState(() {
                        _birthPlacePanelAnimatingOut = false;
                        _birthPlacePanelVisible = false;
                      });
                    },
                    panelKey: _birthPlacePanelKey,
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
                      final birthTimeValue = _birthTime.text.trim();
                      if (birthTimeValue.isEmpty) {
                        final shouldContinue = await _confirmSaveWithoutBirthTime(context);
                        if (!shouldContinue || !context.mounted) return;
                      }
                      try {
                        await ref.read(editProfileProvider.notifier).save(
                              ProfileDetailEntity(
                                nickname: _nickname.text.trim(),
                                gender: genderValue,
                                birthday: _birthday.text.trim(),
                                birthTime: birthTimeValue,
                                city: _city.text.trim(),
                                target: targetValue,
                                birthPlace: _birthPlace.text.trim(),
                                birthLat: _selectedBirthLat,
                                birthLng: _selectedBirthLng,
                              ),
                            );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('资料已保存')));
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('保存失败：$e')),
                        );
                      }
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

  Future<void> _onBirthPlaceQueryChanged(String query) async {
    setState(() {
      _birthPlacePanelVisible = true;
      _birthPlacePanelAnimatingOut = false;
      _birthPlaceSearching = query.trim().isNotEmpty;
      _birthPlaceSearchError = null;
      if (query.trim().isEmpty) {
        _birthPlaceCandidatesView = const [];
      }
    });

    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _ensureBirthPlacePanelVisible();

    final ticket = ++_birthPlaceSearchTicket;
    _birthPlaceSearchDebounce?.cancel();
    _birthPlaceSearchDebounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final suggestions = await ref.read(profileRepositoryProvider).searchBirthPlaces(
              query: trimmed,
            );
        if (!mounted || ticket != _birthPlaceSearchTicket) return;
        setState(() {
          _birthPlaceCandidatesView = suggestions
              .map(
                (item) => _BirthPlaceItem(
                  label: item.label,
                  address: item.address,
                  city: item.city,
                  district: item.district,
                  lat: item.lat,
                  lng: item.lng,
                ),
              )
              .toList();
          _birthPlaceSearchError = null;
        });
        if (suggestions.isNotEmpty) {
          _ensureBirthPlacePanelVisible();
        }
      } catch (_) {
        if (!mounted || ticket != _birthPlaceSearchTicket) return;
        setState(() {
          _birthPlaceCandidatesView = const [];
          _birthPlaceSearchError = '百度地点服务当前不可用，请稍后重试';
        });
      } finally {
        if (mounted && ticket == _birthPlaceSearchTicket) {
          setState(() {
            _birthPlaceSearching = false;
          });
        }
      }
    });
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

  Future<void> _pickBirthTime() async {
    final initial = _parseBirthTime(_birthTime.text) ?? const TimeOfDay(hour: 12, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: '选择出生时间',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (picked == null) return;
    setState(() {
      _birthTime.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  TimeOfDay? _parseBirthTime(String raw) {
    final trimmed = raw.trim();
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(trimmed)) {
      return null;
    }
    final parts = trimmed.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
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

  void _ensureBirthPlacePanelVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _birthPlacePanelKey.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: 0.12,
      );
    });
  }
}

Future<bool> _confirmSaveWithoutBirthTime(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('未填写出生时间'),
      content: const Text(
        '出生时间会影响八字、紫微和星盘的计算精度。当前保存后，系统可能会使用历史值或默认值进行计算。是否继续保存？',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('继续保存'),
        ),
      ],
    ),
  );
  return result ?? false;
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

class _BirthPlaceItem {
  const _BirthPlaceItem({
    required this.label,
    required this.address,
    required this.city,
    required this.district,
    required this.lat,
    required this.lng,
  });

  final String label;
  final String address;
  final String city;
  final String district;
  final double lat;
  final double lng;
}

class _BirthPlaceSearchField extends StatelessWidget {
  const _BirthPlaceSearchField({
    required this.searchController,
    required this.valueController,
    required this.visible,
    required this.animatingOut,
    required this.searching,
    required this.errorText,
    required this.candidates,
    required this.selectedLabel,
    required this.onFocusTap,
    required this.onQueryChanged,
    required this.onSelect,
    this.panelKey,
  });

  final TextEditingController searchController;
  final TextEditingController valueController;
  final bool visible;
  final bool animatingOut;
  final bool searching;
  final String? errorText;
  final List<_BirthPlaceItem> candidates;
  final String? selectedLabel;
  final VoidCallback onFocusTap;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<_BirthPlaceItem> onSelect;
  final Key? panelKey;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '出生地点',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: t.spacing.xs),
        GestureDetector(
          onTap: onFocusTap,
          child: AppTextField(
            controller: searchController,
            label: '搜索出生地',
            hint: '输入城市名搜索出生地',
            suffixIcon: const Icon(Icons.search_rounded, size: 18),
            onChanged: onQueryChanged,
          ),
        ),
        AnimatedSize(
          key: panelKey,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: visible && !animatingOut ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: visible
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: t.spacing.xs),
                      if (searching) ...[
                        Text(
                          '正在搜索百度地点...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textTertiary),
                        ),
                        SizedBox(height: t.spacing.xs),
                      ] else if (candidates.isEmpty && (searchController.text.trim().isNotEmpty)) ...[
                        Text(
                          '未找到匹配地点，请继续输入更完整的地点名称',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textTertiary),
                        ),
                        SizedBox(height: t.spacing.xs),
                      ],
                      Wrap(
                        spacing: t.spacing.xs,
                        runSpacing: t.spacing.xs,
                        children: candidates.take(10).map((item) {
                          final selected = item.label == selectedLabel;
                          final latLng = '${item.lat.toStringAsFixed(6)}, ${item.lng.toStringAsFixed(6)}';
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            child: FilterChip(
                              label: SizedBox(
                                width: 240,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (item.address.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.address,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: t.textTertiary,
                                            ),
                                      ),
                                    ],
                                    const SizedBox(height: 2),
                                    Text(
                                      latLng,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: t.textTertiary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              selected: selected,
                              onSelected: (_) => onSelect(item),
                            ),
                          );
                        }).toList(),
                      ),
                      if ((errorText ?? '').isNotEmpty) ...[
                        SizedBox(height: t.spacing.xs),
                        Text(
                          errorText!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.error),
                        ),
                      ],
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        if ((valueController.text).isNotEmpty) ...[
          SizedBox(height: t.spacing.xs),
          Text(
            '已选出生地：${valueController.text}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
          ),
        ],
      ],
    );
  }
}
