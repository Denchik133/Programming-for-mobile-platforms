// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required this.onUnauthorized,
  }) : _tokenStorage = tokenStorage;

  final TokenStorage _tokenStorage;
  final Future<void> Function() onUnauthorized;

  // Add the stored bearer token to each protected task request.
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // ReqRes has no refresh-token endpoint for this demo; clear invalid sessions.
    if (err.response?.statusCode == 401) {
      await onUnauthorized();
    }
    handler.next(err);
  }
}
