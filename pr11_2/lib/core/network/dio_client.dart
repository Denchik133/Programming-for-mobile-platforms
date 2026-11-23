import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../core/storage/token_storage.dart';
import '../../features/auth/data/local_mock_auth_server.dart';
import 'dio_error_interceptor.dart';
import 'jwt_auth_interceptor.dart';
import 'mock_auth_server_interceptor.dart';

Dio createAuthDio({
  required TokenStorage tokenStorage,
  required LocalMockAuthServer mockServer,
  bool enableLogging = kDebugMode,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://mock-auth.local/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      validateStatus: (status) => status != null && status < 500,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ),
  );
  dio.interceptors.addAll([
    JwtAuthInterceptor(dio: dio, tokenStorage: tokenStorage),
    DioErrorInterceptor(),
    PrettyDioLogger(
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: false,
      error: true,
      compact: true,
      enabled: enableLogging,
    ),
    MockAuthServerInterceptor(mockServer),
  ]);
  return dio;
}
