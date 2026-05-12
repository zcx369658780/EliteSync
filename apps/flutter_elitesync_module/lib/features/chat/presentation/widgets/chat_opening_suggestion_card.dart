import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class ChatOpeningSuggestion {
  const ChatOpeningSuggestion({
    required this.title,
    required this.description,
    required this.prompt,
    required this.tag,
    required this.icon,
  });

  final String title;
  final String description;
  final String prompt;
  final String tag;
  final IconData icon;
}

class ChatOpeningSuggestionCard extends StatelessWidget {
  const ChatOpeningSuggestionCard({
    super.key,
    required this.suggestions,
    this.onDraftSelected,
  });

  final List<ChatOpeningSuggestion> suggestions;
  final ValueChanged<String>? onDraftSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppInfoSectionCard(
      title: '低压开场建议',
      subtitle: '把关系提示转成可编辑草稿，由你确认后再发送。',
      leadingIcon: Icons.chat_bubble_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '先从共同点、自然问候或轻追问开始，不急着推进关系，也不替你代聊。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          for (final item in suggestions) ...[
            _OpeningSuggestionRow(
              item: item,
              onTap: onDraftSelected == null
                  ? null
                  : () => onDraftSelected!(item.prompt),
            ),
            SizedBox(height: t.spacing.xs),
          ],
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: const [
              AppChoiceChip(
                label: '可编辑草稿',
                selected: true,
                leading: Icon(Icons.edit_note_rounded),
              ),
              AppChoiceChip(
                label: '冷场恢复',
                selected: true,
                leading: Icon(Icons.volunteer_activism_outlined),
              ),
              AppChoiceChip(
                label: '续话提示',
                selected: true,
                leading: Icon(Icons.auto_awesome_outlined),
              ),
              AppChoiceChip(
                label: '填入后仍需你自己确认发送',
                selected: true,
                leading: Icon(Icons.send_outlined),
              ),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            '以上内容仅为开场参考，不会读取私密聊天，不会写入资料，也不会自动发送消息。草稿只保存在本机输入框 / 草稿缓存中。',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: t.textTertiary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningSuggestionRow extends StatelessWidget {
  const _OpeningSuggestionRow({required this.item, this.onTap});

  final ChatOpeningSuggestion item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return InkWell(
      borderRadius: BorderRadius.circular(t.radius.md),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(t.spacing.sm),
        decoration: BoxDecoration(
          color: t.secondarySurface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(t.radius.md),
          border: Border.all(color: t.overlay.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, size: 18, color: t.brandPrimary),
                SizedBox(width: t.spacing.xs),
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                AppChoiceChip(label: item.tag, selected: true),
              ],
            ),
            SizedBox(height: t.spacing.xxs),
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: t.spacing.xs),
            Text(
              item.prompt,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textPrimary,
                height: 1.38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
