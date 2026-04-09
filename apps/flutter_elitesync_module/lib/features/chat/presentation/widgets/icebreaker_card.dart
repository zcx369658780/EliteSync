import 'package:flutter/material.dart';

class IcebreakerCard extends StatelessWidget {
  const IcebreakerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          '首聊建议：先聊最近一次让你放松的周末安排，再追问一个开放问题（例如“你当时最开心的瞬间是什么？”）。',
        ),
      ),
    );
  }
}
