import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_shortcut_entity.dart';

class HomeShortcutGrid extends StatelessWidget {
  const HomeShortcutGrid({super.key, required this.shortcuts});

  final List<HomeShortcutEntity> shortcuts;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shortcuts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3,
      ),
      itemBuilder: (context, index) {
        final item = shortcuts[index];
        return AppCard(child: Center(child: Text(item.title)));
      },
    );
  }
}
