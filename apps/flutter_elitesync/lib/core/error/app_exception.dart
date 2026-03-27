sealed class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, this.statusCode});

  final int? statusCode;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.code});
}

class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.code,
    this.fieldErrors = const {},
  });

  final Map<String, String> fieldErrors;
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

class UnknownException extends AppException {
  const UnknownException(super.message, {super.code});
}
