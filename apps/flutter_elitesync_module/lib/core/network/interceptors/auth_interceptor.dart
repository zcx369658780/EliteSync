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
      // Temporary debug aid for emulator-side matching setup.
      // ignore: avoid_print
      print('AUTH_INTERCEPTOR_TOKEN token=$token');
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && _refreshAccessToken != null) {
      final req = err.requestOptions;
      final hasRetried = req.extra['__retried_401__'] == true;
      final currentAuthorization = req.headers['Authorization']?.toString();
      if (!hasRetried) {
        final refreshed = await _refreshAccessToken();
        final nextAuthorization = (refreshed != null && refreshed.isNotEmpty)
            ? 'Bearer $refreshed'
            : null;
        if (nextAuthorization != null &&
            nextAuthorization.isNotEmpty &&
            nextAuthorization != currentAuthorization) {
          req.extra['__retried_401__'] = true;
          req.headers['Authorization'] = nextAuthorization;
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
