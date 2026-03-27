import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/legal_document_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class AboutUpdatePage extends ConsumerStatefulWidget {
  const AboutUpdatePage({super.key});

  @override
  ConsumerState<AboutUpdatePage> createState() => _AboutUpdatePageState();
}

class _AboutUpdatePageState extends ConsumerState<AboutUpdatePage> {
  String _currentVersion = '-';
  String _status = '';
  bool _checking = false;
  String _historyTitle = '更新历史';
  List<String> _historyItems = const ['更新记录加载中...'];
  String _qualificationTitle = '资质';
  List<String> _qualificationItems = const ['资质信息加载中...'];

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadLocalAboutConfig();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _currentVersion = info.version);
  }

  Future<void> _loadLocalAboutConfig() async {
    try {
      final raw = await rootBundle.loadString('assets/config/about_update_0_xx.json');
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return;
      if (!mounted) return;
      setState(() {
        _historyTitle = (json['history_title'] ?? _historyTitle).toString();
        _qualificationTitle = (json['qualification_title'] ?? _qualificationTitle).toString();
        _historyItems = (json['history_items'] is List)
            ? (json['history_items'] as List).map((e) => e.toString()).toList()
            : _historyItems;
        _qualificationItems = (json['qualifications'] is List)
            ? (json['qualifications'] as List).map((e) => e.toString()).toList()
            : _qualificationItems;
      });
    } catch (_) {
      // Keep fallback text when local config is unavailable.
    }
  }

  Future<void> _checkUpdate() async {
    setState(() {
      _checking = true;
      _status = '';
    });
    final api = ref.read(apiClientProvider);
    final result = await api.get('/api/v1/app/version/check', query: {
      'platform': 'android',
      'channel': 'stable',
      'version_name': _currentVersion,
    });
    if (!mounted) return;
    setState(() => _checking = false);

    if (result is NetworkFailure<Map<String, dynamic>>) {
      setState(() => _status = '检查更新失败: ${result.message}');
      return;
    }

    final data = (result as NetworkSuccess<Map<String, dynamic>>).data;
    final latest = (data['latest_version_name'] ?? '').toString();
    final hasUpdate = data['has_update'] == true;
    final forceUpdate = data['force_update'] == true;
    final downloadUrl = (data['download_url'] ?? '').toString();
    setState(() {
      _status = hasUpdate ? '发现新版本: $latest' : '当前已是最新版本（服务端最新: $latest）';
    });

    if (!hasUpdate || downloadUrl.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(forceUpdate ? '发现强制更新' : '发现新版本'),
        content: Text('当前版本 $_currentVersion，最新版本 $latest，是否下载更新？'),
        actions: [
          SizedBox(
            width: 84,
            child: AppSecondaryButton(
              label: '否',
              onPressed: () => Navigator.pop(context, false),
            ),
          ),
          SizedBox(
            width: 84,
            child: AppPrimaryButton(
              label: '是',
              onPressed: () => Navigator.pop(context, true),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await launchUrl(Uri.parse(downloadUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppScaffold(
      appBar: const AppTopBar(title: '关于与更新', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, t.spacing.sm, 0, t.spacing.xl),
        children: [
          SectionReveal(
            child: PageTitleRail(
              title: '当前版本 $_currentVersion',
              subtitle: '资质: 还未申请',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 60),
            child: LegalDocumentCard(
              title: _qualificationTitle,
              lines: _qualificationItems,
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 90),
            child: LegalDocumentCard(
              title: _historyTitle,
              lines: _historyItems,
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 120),
            child: AppPrimaryButton(
              label: '检查更新',
              isLoading: _checking,
              onPressed: _checkUpdate,
            ),
          ),
          if (_status.isNotEmpty) ...[
            SizedBox(height: t.spacing.sm),
            Text(
              _status,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
