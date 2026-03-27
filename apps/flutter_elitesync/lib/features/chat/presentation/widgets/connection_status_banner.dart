import 'package:flutter/material.dart';

class ConnectionStatusBanner extends StatelessWidget {
  const ConnectionStatusBanner({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == 'connected') return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: Colors.amber.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(8),
      child: Text('连接状态: $status'),
    );
  }
}
