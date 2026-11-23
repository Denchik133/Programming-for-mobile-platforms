import 'package:dio/dio.dart';

import '../../core/storage/token_storage.dart';
import '../../features/auth/models/auth_tokens.dart';

class JwtAuthInterceptor extends Interceptor {
  JwtAuthInterceptor({required this._dio, required this._tokenStorage});

  final Dio _dio;
  final TokenStorage _tokenStorage;
  Future<AuthTokens>? _refreshInProgress;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isProtected(options)) {
      final tokens = await _tokenStorage.readTokens();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    if (!_shouldRefresh(response.requestOptions, response.statusCode)) {
      handler.next(response);
      return;
    }
    try {
      final tokens = await _tokenStorage.readTokens();
      if (tokens == null) {
        handler.next(response);
        return;
      }
      final renewed = await _refresh(tokens.refreshToken);
      await _tokenStorage.update(renewed);
      final request = response.requestOptions
        ..extra['authRetried'] = true
        ..headers['Authorization'] = 'Bearer ${renewed.accessToken}';
      handler.resolve(await _dio.fetch<dynamic>(request));
    } on DioException catch (error) {
      await _tokenStorage.clear();
      handler.reject(error);
    } on Object catch (error) {
      await _tokenStorage.clear();
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          error: error,
          type: DioExceptionType.unknown,
          message: 'Не вдалося оновити сесію. Увійдіть знову.',
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldRefresh(err.requestOptions, err.response?.statusCode)) {
      handler.next(err);
      return;
    }
    try {
      final tokens = await _tokenStorage.readTokens();
      if (tokens == null) {
        handler.next(err);
        return;
      }
      final renewed = await _refresh(tokens.refreshToken);
      await _tokenStorage.update(renewed);
      final request = err.requestOptions
        ..extra['authRetried'] = true
        ..headers['Authorization'] = 'Bearer ${renewed.accessToken}';
      handler.resolve(await _dio.fetch<dynamic>(request));
    } on DioException catch (refreshError) {
      await _tokenStorage.clear();
      handler.next(refreshError);
    } on Object catch (refreshError) {
      await _tokenStorage.clear();
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: refreshError,
          type: DioExceptionType.unknown,
          message: 'Не вдалося оновити сесію. Увійдіть знову.',
        ),
      );
    }
  }

  bool _shouldRefresh(RequestOptions request, int? statusCode) =>
      statusCode == 401 &&
      _isProtected(request) &&
      request.extra['authRetried'] != true;

  bool _isProtected(RequestOptions options) {
    final path = options.uri.path;
    return path == '/api/user' || path.startsWith('/api/user/');
  }

  Future<AuthTokens> _refresh(String refreshToken) async {
    final current = _refreshInProgress;
    if (current != null) return current;
    final request = _requestRefresh(refreshToken);
    _refreshInProgress = request;
    try {
      return await request;
    } finally {
      if (identical(_refreshInProgress, request)) _refreshInProgress = null;
    }
  }

  Future<AuthTokens> _requestRefresh(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final data = response.data;
    if (data == null || data['tokens'] is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Сервер повернув некоректні токени.',
      );
    }
    return AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>);
  }
}
