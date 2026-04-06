import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/logging/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({required AppLogger logger}) : _logger = logger;

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('[REQ] ${options.method} ${options.uri}');
    _logger.debug('[REQ] ${options.method} ${options.uri}', tag: 'NETWORK');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      '[RES] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
    );
    _logger.debug(
      '[RES] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
      tag: 'NETWORK',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      '[ERR] ${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.uri}',
    );
    _logger.warning(
      '[ERR] ${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.uri}',
      tag: 'NETWORK',
      error: err,
      stackTrace: err.stackTrace,
    );
    super.onError(err, handler);
  }
}
