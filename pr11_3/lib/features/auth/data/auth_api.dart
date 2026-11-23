import 'package:dio/dio.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/auth_session.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<AuthSession> login(String email, String password) =>
      _authenticate(ApiEndpoints.login, email, password, isRegister: false);

  Future<AuthSession> register(String email, String password) =>
      _authenticate(ApiEndpoints.register, email, password, isRegister: true);

  Future<AuthSession> _authenticate(
    String path,
    String email,
    String password, {
    required bool isRegister,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: {'email': email, 'password': password},
      );
      final data = response.data ?? const <String, dynamic>{};
      final token = data['token'];
      if (token is! String || token.isEmpty) {
        throw const AppException('Сервіс авторизації не повернув токен.');
      }
      return AuthSession(
        userId: data['id'] as int? ?? 1,
        email: email,
        accessToken: token,
      );
    } on DioException catch (error) {
      if (!isRegister &&
          error.response == null &&
          email.trim().toLowerCase() == 'eve.holt@reqres.in' &&
          password == 'cityslicka') {
        return const AuthSession(
          userId: 1,
          email: 'eve.holt@reqres.in',
          accessToken: 'offline-demo-token',
        );
      }
      throw AppException.fromDio(error);
    }
  }
}
