sealed class NetworkResult<T> {
  const NetworkResult();

  bool get isSuccess => this is NetworkSuccess<T>;
  bool get isFailure => this is NetworkFailure<T>;
}

class NetworkSuccess<T> extends NetworkResult<T> {
  const NetworkSuccess(this.data, {this.statusCode});

  final T data;
  final int? statusCode;
}

class NetworkFailure<T> extends NetworkResult<T> {
  const NetworkFailure({
    required this.message,
    this.statusCode,
    this.code,
    this.error,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Object? error;
}
