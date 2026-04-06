class AstroProfileApiException implements Exception {
  const AstroProfileApiException({
    required this.message,
    this.statusCode,
    this.code,
  });

  final String message;
  final int? statusCode;
  final String? code;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isRateLimited => statusCode == 429;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() {
    return 'AstroProfileApiException(statusCode: $statusCode, code: $code, message: $message)';
  }
}