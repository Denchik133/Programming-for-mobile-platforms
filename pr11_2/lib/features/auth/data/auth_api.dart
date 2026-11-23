import 'package:dio/dio.dart';

import '../models/auth_session.dart';
import '../models/user_profile.dart';
import 'local_mock_auth_server.dart';

class AuthApi {
  AuthApi(this._dio, this._mockServer);

  final Dio _dio;
  final LocalMockAuthServer _mockServer;

  Future<AuthSession> login(String email, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthSession.fromJson(response.data!);
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );
    return AuthSession.fromJson(response.data!);
  }

  Future<UserProfile> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('user');
    return UserProfile.fromJson(response.data!['user'] as Map<String, dynamic>);
  }

  Future<UserProfile> updateProfile({
    required String name,
    required String email,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      'user',
      data: {'name': name, 'email': email},
    );
    return UserProfile.fromJson(response.data!['user'] as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post<void>(
      'user/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  Future<UserProfile> demonstrateRefresh() async {
    _mockServer.rejectNextProfileRequest();
    return getProfile();
  }

  Dio get dioForDiagnostics => _dio;
}
