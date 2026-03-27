sealed class AppFailure {
  const AppFailure({required this.message, this.code});

  final String message;
  final String? code;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure({required super.message, super.code, this.statusCode});

  final int? statusCode;
}

class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({required super.message, super.code});
}

class ValidationFailure extends AppFailure {
  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors = const {},
  });

  final Map<String, String> fieldErrors;
}

class ServerFailure extends AppFailure {
  const ServerFailure({required super.message, super.code});
}

class EmptyFailure extends AppFailure {
  const EmptyFailure({required super.message, super.code});
}

class UnknownFailure extends AppFailure {
  const UnknownFailure({required super.message, super.code});
}
