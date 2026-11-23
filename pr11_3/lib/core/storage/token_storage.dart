import 'dart:convert';

import '../../features/auth/domain/auth_session.dart';
import 'secure_store.dart';

class TokenStorage {
  TokenStorage(this._store);

  static const _sessionKey = 'pr11_3_auth_session';
  final SecureStore _store;
  AuthSession? _memorySession;

  Future<AuthSession?> readSession() async {
    if (_memorySession != null) return _memorySession;
    final raw = await _store.read(_sessionKey);
    if (raw == null) return null;
    try {
      _memorySession = AuthSession.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      return _memorySession;
    } on Object {
      await clear();
      return null;
    }
  }

  Future<String?> readAccessToken() async => (await readSession())?.accessToken;

  Future<void> saveSession(
    AuthSession session, {
    required bool remember,
  }) async {
    _memorySession = session;
    if (remember) {
      await _store.write(_sessionKey, jsonEncode(session.toJson()));
    } else {
      await _store.delete(_sessionKey);
    }
  }

  Future<void> clear() async {
    _memorySession = null;
    await _store.delete(_sessionKey);
  }
}
