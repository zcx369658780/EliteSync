import 'package:dio/dio.dart';
import 'package:flutter_elitesync/core/logging/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({required AppLogger logger}) : _logger = logger;

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug('[REQ] ${options.method} ${options.uri}', tag: 'NETWORK');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.debug(
      '[RES] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
      tag: 'NETWORK',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.warning(
      '[ERR] ${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.uri}',
      tag: 'NETWORK',
      error: err,
      stackTrace: err.stackTrace,
    );
    super.onError(err, handler);
  }
}
