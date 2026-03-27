import 'package:dio/dio.dart';

typedef AccessTokenProvider = Future<String?> Function();
typedef RefreshAccessToken = Future<String?> Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required AccessTokenProvider accessTokenProvider,
    RefreshAccessToken? refreshAccessToken,
  }) : _accessTokenProvider = accessTokenProvider,
       _refreshAccessToken = refreshAccessToken;

  final AccessTokenProvider _accessTokenProvider;
  final RefreshAccessToken? _refreshAccessToken;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _accessTokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && _refreshAccessToken != null) {
      final req = err.requestOptions;
      final hasRetried = req.extra['__retried_401__'] == true;
      if (!hasRetried) {
        final refreshed = await _refreshAccessToken();
        if (refreshed != null && refreshed.isNotEmpty) {
          req.extra['__retried_401__'] = true;
          req.headers['Authorization'] = 'Bearer $refreshed';
          try {
            final response = await Dio().fetch(req);
            handler.resolve(response);
            return;
          } catch (_) {
            // fallback to original error
          }
        }
      }
    }

    super.onError(err, handler);
  }
}
