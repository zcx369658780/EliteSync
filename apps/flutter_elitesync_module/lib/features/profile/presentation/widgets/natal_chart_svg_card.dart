import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NatalChartSvgCard extends StatefulWidget {
  const NatalChartSvgCard({
    super.key,
    required this.svg,
    this.emptyMessage = '暂无星盘 SVG',
  });

  final String svg;
  final String emptyMessage;

  @override
  State<NatalChartSvgCard> createState() => _NatalChartSvgCardState();
}

class _NatalChartSvgCardState extends State<NatalChartSvgCard> {
  final TransformationController _controller = TransformationController();
  double? _lastExtent;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncInitialTransform(double extent) {
    if (_lastExtent != null && (_lastExtent! - extent).abs() < 1) {
      return;
    }
    _lastExtent = extent;
    _controller.value = Matrix4.identity()
      ..translateByDouble(-extent * 0.36, -extent * 0.12, 0, 1.0)
      ..scaleByDouble(1.50, 1.50, 1.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final source = _normalizeSvg(widget.svg);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        _syncInitialTransform(width);

        return SizedBox(
          width: width,
          height: width,
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.black),
            child: ClipRect(
              child: source.isEmpty
                  ? Center(
                      child: Text(
                        widget.emptyMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    )
                  : InteractiveViewer(
                      transformationController: _controller,
                      minScale: 1.0,
                      maxScale: 4.0,
                      constrained: true,
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.string(
                        source,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerLeft,
                        placeholderBuilder: (context) => Center(
                          child: Text(
                            '星盘 SVG 加载中...',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

String _normalizeSvg(String input) {
  final source = input.trim();
  if (source.isEmpty) return source;

  final varDefs = <String, String>{};
  final defRegex = RegExp(r'--([A-Za-z0-9_-]+)\s*:\s*([^;]+);');
  for (final match in defRegex.allMatches(source)) {
    final key = match.group(1)?.trim();
    final value = match.group(2)?.trim();
    if (key != null && key.isNotEmpty && value != null && value.isNotEmpty) {
      varDefs[key] = value;
    }
  }

  var normalized = source.replaceAllMapped(
    RegExp(r'var\(--([A-Za-z0-9_-]+)(?:\s*,\s*([^\)]+))?\)'),
    (match) {
      final key = match.group(1);
      final fallback = match.group(2)?.trim();
      return varDefs[key] ?? fallback ?? 'currentColor';
    },
  );

  normalized = _cropViewBoxToWheel(normalized);
  normalized = _stripAspectTable(normalized);
  return normalized;
}

String _stripAspectTable(String source) {
  final tableRegex = RegExp(
    r'<[^>]*class="[^"]*(?:aspect-table|aspects-table|aspect_table)[^"]*"[^>]*>.*?</[^>]+>',
    dotAll: true,
  );
  return source.replaceAll(tableRegex, '');
}

String _cropViewBoxToWheel(String source) {
  final viewBoxRegex = RegExp(
    "viewBox=['\\\"]\\s*([-\\d\\.]+)\\s+([-\\d\\.]+)\\s+([-\\d\\.]+)\\s+([-\\d\\.]+)\\s*['\\\"]",
  );
  final match = viewBoxRegex.firstMatch(source);
  if (match == null) return source;

  final x = double.tryParse(match.group(1) ?? '');
  final y = double.tryParse(match.group(2) ?? '');
  final width = double.tryParse(match.group(3) ?? '');
  final height = double.tryParse(match.group(4) ?? '');
  if (x == null || y == null || width == null || height == null) return source;
  if (width <= 0 || height <= 0) return source;

  final square = width > height ? height : width;
  final nextViewBox =
      '${_fmtViewBoxValue(x)} ${_fmtViewBoxValue(y)} ${_fmtViewBoxValue(square)} ${_fmtViewBoxValue(square)}';
  return source.replaceFirst(viewBoxRegex, "viewBox='$nextViewBox'");
}

String _fmtViewBoxValue(double value) {
  final rounded = value.roundToDouble();
  if ((value - rounded).abs() < 0.001) {
    return rounded.toInt().toString();
  }
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '');
}
