import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';

class HomeSearchHeader extends StatelessWidget {
  const HomeSearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Row(
        children: [
          Icon(Icons.search_rounded),
          SizedBox(width: 8),
          Expanded(child: Text('搜索话题、城市或兴趣')), 
        ],
      ),
    );
  }
}
