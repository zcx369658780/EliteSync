import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_tag.dart';

class ProfileResultTagList extends StatelessWidget {
  const ProfileResultTagList({super.key, required this.tags});
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((e) => AppTag(label: e)).toList(),
    );
  }
}
