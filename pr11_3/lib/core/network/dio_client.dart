import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../storage/token_storage.dart';
import 'api_endpoints.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

Dio createReqResDio({bool enableLogging = kDebugMode}) =>
    _createDio(ApiEndpoints.reqResBaseUrl, enableLogging: enableLogging);

Dio createTasksDio({
  required TokenStorage tokenStorage,
  required Future<void> Function() onUnauthorized,
  bool enableLogging = kDebugMode,
}) {
  final dio = _baseDio(ApiEndpoints.jsonPlaceholderBaseUrl);
  dio.interceptors.addAll([
    AuthInterceptor(tokenStorage: tokenStorage, onUnauthorized: onUnauthorized),
    ErrorInterceptor(),
    RetryInterceptor(dio, maxRetries: 1),
    _logger(enableLogging),
  ]);
  return dio;
}

Dio _createDio(String baseUrl, {required bool enableLogging}) {
  final dio = _baseDio(baseUrl);
  dio.interceptors.addAll([
    ErrorInterceptor(),
    RetryInterceptor(dio, maxRetries: 1),
    _logger(enableLogging),
  ]);
  return dio;
}

Dio _baseDio(String baseUrl) => Dio(
  BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    sendTimeout: const Duration(seconds: 5),
    headers: const {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
    },
  ),
);

PrettyDioLogger _logger(bool enabled) => PrettyDioLogger(
  requestHeader: false,
  requestBody: false,
  responseHeader: false,
  responseBody: false,
  error: true,
  compact: true,
  enabled: enabled,
);
