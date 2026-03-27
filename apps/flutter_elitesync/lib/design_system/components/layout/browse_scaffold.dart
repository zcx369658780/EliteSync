import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';

class BrowseScaffold extends StatelessWidget {
  const BrowseScaffold({
    super.key,
    required this.header,
    required this.body,
    this.padding,
  });

  final Widget header;
  final Widget body;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return ColoredBox(
      color: t.browseBackground,
      child: SafeArea(
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(horizontal: t.spacing.pageHorizontal),
          child: Column(
            children: [
              header,
              SizedBox(height: t.spacing.sm),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
