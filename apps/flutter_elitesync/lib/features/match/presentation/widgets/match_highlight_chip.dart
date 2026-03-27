import 'package:flutter/material.dart';

class MatchHighlightChip extends StatelessWidget {
  const MatchHighlightChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}
