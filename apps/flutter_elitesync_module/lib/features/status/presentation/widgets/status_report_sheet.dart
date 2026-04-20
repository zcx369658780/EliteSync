import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class StatusReportSheet extends StatefulWidget {
  const StatusReportSheet({
    super.key,
    required this.targetName,
    required this.onSubmit,
  });

  final String targetName;
  final Future<void> Function({required String reasonCode, String? detail}) onSubmit;

  static Future<void> show(
    BuildContext context, {
    required String targetName,
    required Future<void> Function({required String reasonCode, String? detail}) onSubmit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => StatusReportSheet(targetName: targetName, onSubmit: onSubmit),
    );
  }

  @override
  State<StatusReportSheet> createState() => _StatusReportSheetState();
}

class _StatusReportSheetState extends State<StatusReportSheet> {
  final _detailController = TextEditingController();
  String _reasonCode = 'harassment';
  bool _busy = false;

  final List<_ReasonOption> _reasons = const [
    _ReasonOption('harassment', '骚扰'),
    _ReasonOption('spam', '广告 / 诱导'),
    _ReasonOption('inappropriate', '不当内容'),
    _ReasonOption('scam', '疑似诈骗'),
    _ReasonOption('other', '其他'),
  ];

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onSubmit(reasonCode: _reasonCode, detail: _detailController.text);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已提交对 ${widget.targetName} 的举报')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('举报失败：$e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: t.spacing.pageHorizontal,
          right: t.spacing.pageHorizontal,
          bottom: MediaQuery.of(context).viewInsets.bottom + t.spacing.lg,
          top: t.spacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '举报动态',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '对象：${widget.targetName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textSecondary,
                  ),
            ),
            SizedBox(height: t.spacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reasons
                  .map(
                    (option) => ChoiceChip(
                      label: Text(option.label),
                      selected: _reasonCode == option.code,
                      onSelected: (_) => setState(() => _reasonCode = option.code),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: t.spacing.md),
            AppCard(
              padding: EdgeInsets.all(t.spacing.cardPadding),
              child: TextField(
                controller: _detailController,
                maxLines: 3,
                minLines: 2,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '补充说明（可选）',
                ),
              ),
            ),
            SizedBox(height: t.spacing.md),
            AppPrimaryButton(
              label: _busy ? '提交中...' : '提交举报',
              fullWidth: true,
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonOption {
  const _ReasonOption(this.code, this.label);

  final String code;
  final String label;
}
