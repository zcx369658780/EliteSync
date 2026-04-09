import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class ConnectionStatusBanner extends StatelessWidget {
  const ConnectionStatusBanner({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == 'connected') return const SizedBox.shrink();
    final t = context.appTokens;
    final isReconnecting = status == 'connecting' || status == 'reconnecting';
    final bg = isReconnecting ? t.warning.withValues(alpha: 0.14) : t.error.withValues(alpha: 0.14);
    final fg = isReconnecting ? t.warning : t.error;
    final text = isReconnecting
        ? '网络波动中，正在尝试恢复连接…恢复后建议下拉刷新会话。'
        : '当前离线，建议稍后重试或下拉刷新会话。';
    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            isReconnecting ? Icons.sync_problem_rounded : Icons.wifi_off_rounded,
            color: fg,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
