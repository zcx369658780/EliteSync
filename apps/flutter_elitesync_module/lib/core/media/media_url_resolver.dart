import 'dart:io';

String resolveMediaUrl(String rawUrl, {required String apiBaseUrl}) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) return '';

  if (trimmed.startsWith('file://')) {
    return trimmed;
  }

  if (trimmed.startsWith('/') && File(trimmed).existsSync()) {
    return trimmed;
  }

  final apiOrigin = Uri.tryParse(apiBaseUrl.trim());
  if (apiOrigin == null || apiOrigin.host.isEmpty) {
    return trimmed;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null) {
    return trimmed;
  }

  if (!uri.hasScheme) {
    return apiOrigin.resolveUri(uri).toString();
  }

  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return trimmed;
  }

  if (!_isLocalHost(uri.host)) {
    return trimmed;
  }

  return Uri(
    scheme: apiOrigin.scheme.isNotEmpty ? apiOrigin.scheme : uri.scheme,
    host: apiOrigin.host,
    port: apiOrigin.hasPort ? apiOrigin.port : null,
    path: uri.path,
    query: uri.hasQuery ? uri.query : null,
    fragment: uri.fragment.isNotEmpty ? uri.fragment : null,
  ).toString();
}

bool _isLocalHost(String host) {
  final normalized = host.trim().toLowerCase();
  return normalized == 'localhost' ||
      normalized == '127.0.0.1' ||
      normalized == '::1' ||
      normalized == '10.0.2.2';
}
