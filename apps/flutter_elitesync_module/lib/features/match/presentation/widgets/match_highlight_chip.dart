import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_tag.dart';

class MatchHighlightChip extends StatelessWidget {
  const MatchHighlightChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppTag(label: label, variant: AppTagVariant.brand);
  }
}
