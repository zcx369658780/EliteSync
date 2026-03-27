import 'package:flutter/material.dart';

class ProfileResultTagList extends StatelessWidget {
  const ProfileResultTagList({super.key, required this.tags});
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: tags.map((e) => Chip(label: Text(e))).toList());
  }
}
