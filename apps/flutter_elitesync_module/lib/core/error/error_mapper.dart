import 'package:flutter_elitesync_module/core/error/app_exception.dart';
import 'package:flutter_elitesync_module/core/error/app_failure.dart';

class ErrorMapper {
  const ErrorMapper();

  AppFailure mapException(Object error) {
    if (error is AppFailure) return error;

    if (error is UnauthorizedException) {
      return UnauthorizedFailure(message: '登录状态已失效，请重新登录。', code: error.code);
    }

    if (error is ValidationException) {
      return ValidationFailure(
        message: error.message.isEmpty ? '提交信息有误，请检查后重试。' : error.message,
        code: error.code,
        fieldErrors: error.fieldErrors,
      );
    }

    if (error is NetworkException) {
      return NetworkFailure(
        message: '网络开小差了，请稍后重试。',
        code: error.code,
        statusCode: error.statusCode,
      );
    }

    if (error is ServerException) {
      return ServerFailure(message: '服务暂时不可用，请稍后再试。', code: error.code);
    }

    if (error is CacheException) {
      return const UnknownFailure(message: '本地缓存读取失败，请重试。');
    }

    if (error is AppException) {
      return UnknownFailure(
        message: error.message.isEmpty ? '发生未知错误，请稍后重试。' : error.message,
        code: error.code,
      );
    }

    return const UnknownFailure(message: '发生未知错误，请稍后重试。');
  }

  String mapToUserMessage(Object error) {
    return mapException(error).message;
  }
}
