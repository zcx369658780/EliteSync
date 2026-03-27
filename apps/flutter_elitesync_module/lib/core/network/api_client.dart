import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';

class ApiClient {
  ApiClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
        options: options,
      );
      return NetworkSuccess(
        response.data ?? <String, dynamic>{},
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _mapDioError(e);
    } catch (e) {
      return NetworkFailure(message: 'Unknown request error', error: e);
    }
  }

  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
        queryParameters: query,
        options: options,
      );
      return NetworkSuccess(
        response.data ?? <String, dynamic>{},
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _mapDioError(e);
    } catch (e) {
      return NetworkFailure(message: 'Unknown request error', error: e);
    }
  }

  Future<NetworkResult<Map<String, dynamic>>> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: body,
        queryParameters: query,
        options: options,
      );
      return NetworkSuccess(
        response.data ?? <String, dynamic>{},
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _mapDioError(e);
    } catch (e) {
      return NetworkFailure(message: 'Unknown request error', error: e);
    }
  }

  Future<NetworkResult<Map<String, dynamic>>> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: body,
        queryParameters: query,
        options: options,
      );
      return NetworkSuccess(
        response.data ?? <String, dynamic>{},
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _mapDioError(e);
    } catch (e) {
      return NetworkFailure(message: 'Unknown request error', error: e);
    }
  }

  NetworkFailure<Map<String, dynamic>> _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final response = e.response?.data;

    String? code;
    String message = 'Request failed';

    if (response is Map<String, dynamic>) {
      final msg = response['message'];
      final c = response['code'];
      if (msg is String && msg.trim().isNotEmpty) {
        message = msg;
      }
      if (c is String && c.trim().isNotEmpty) {
        code = c;
      }
    } else {
      message = switch (e.type) {
        DioExceptionType.connectionTimeout => 'Connection timeout',
        DioExceptionType.sendTimeout => 'Send timeout',
        DioExceptionType.receiveTimeout => 'Receive timeout',
        DioExceptionType.connectionError => 'Connection error',
        DioExceptionType.badCertificate => 'Bad certificate',
        DioExceptionType.cancel => 'Request cancelled',
        DioExceptionType.badResponse => 'Bad response',
        DioExceptionType.unknown => 'Unknown network error',
      };
    }

    return NetworkFailure(
      message: message,
      statusCode: statusCode,
      code: code,
      error: e,
    );
  }
}
