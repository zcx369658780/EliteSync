import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({this.maxRetries = 2});

  final int maxRetries;

  static const _retryableMethods = {'GET', 'HEAD', 'OPTIONS'};

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    final isRetryableMethod = _retryableMethods.contains(
      requestOptions.method.toUpperCase(),
    );
    final hasResponse = err.response != null;
    final isConnectionError =
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    final retries = (requestOptions.extra['__retry_count__'] as int?) ?? 0;

    if (isRetryableMethod &&
        !hasResponse &&
        isConnectionError &&
        retries < maxRetries) {
      requestOptions.extra['__retry_count__'] = retries + 1;

      final delayMs = 250 * (retries + 1);
      await Future<void>.delayed(Duration(milliseconds: delayMs));

      try {
        final response = await Dio().fetch(requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {
        // fallthrough
      }
    }

    super.onError(err, handler);
  }
}
