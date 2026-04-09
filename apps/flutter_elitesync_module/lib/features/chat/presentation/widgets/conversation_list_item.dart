import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/highlight_text.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';

class ConversationListItem extends StatelessWidget {
  const ConversationListItem({
    super.key,
    required this.item,
    required this.onTap,
    this.highlightQuery = '',
  });
  final ConversationEntity item;
  final VoidCallback onTap;
  final String highlightQuery;

  String _conversationStatus() {
    if (item.unread > 0) {
      return '待回复';
    }
    if (item.lastMessage.contains('你好') ||
        item.lastMessage.contains('嗨') ||
        item.lastMessage.contains('破冰')) {
      return '破冰中';
    }
    if (item.lastMessage.contains('匹配') || item.lastMessage.contains('系统')) {
      return '新匹配';
    }
    return '已开启聊天';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(t.radius.lg),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: t.spacing.sm,
            vertical: t.spacing.xs,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      t.brandPrimary.withValues(alpha: 0.9),
                      t.brandSecondary.withValues(alpha: 0.78),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.name.isEmpty ? '?' : item.name.substring(0, 1),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: t.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightText(
                      text: item.name,
                      query: highlightQuery,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      highlightStyle: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(
                            color: t.brandPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    SizedBox(height: t.spacing.xxs),
                    Text(
                      item.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                    ),
                    SizedBox(height: t.spacing.xxs),
                    Text(
                      _conversationStatus(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: item.unread > 0
                            ? t.brandPrimary
                            : t.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: t.spacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.lastTime,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: t.textTertiary),
                  ),
                  SizedBox(height: t.spacing.xxs),
                  if (item.unread > 0)
                    Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: t.brandPrimary,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${item.unread}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
