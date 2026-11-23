import 'dart:convert';

import '../../features/auth/models/auth_tokens.dart';
import 'secure_key_value_store.dart';

class TokenStorage {
  TokenStorage(this._storage);

  static const _sessionKey = 'auth_session_v1';

  final SecureKeyValueStore _storage;
  AuthTokens? _memoryTokens;
  bool _rememberSession = false;

  bool get remembersSession => _rememberSession;

  Future<AuthTokens?> readTokens() async {
    if (_memoryTokens != null) return _memoryTokens;
    final stored = await _storage.read(_sessionKey);
    if (stored == null) return null;
    try {
      _memoryTokens = AuthTokens.fromJson(
        jsonDecode(stored) as Map<String, dynamic>,
      );
      _rememberSession = true;
      return _memoryTokens;
    } on FormatException {
      await clear();
      return null;
    } on TypeError {
      await clear();
      return null;
    }
  }

  Future<void> save(AuthTokens tokens, {required bool remember}) async {
    _memoryTokens = tokens;
    _rememberSession = remember;
    if (remember) {
      await _storage.write(_sessionKey, jsonEncode(tokens.toJson()));
    } else {
      await _storage.delete(_sessionKey);
    }
  }

  Future<void> update(AuthTokens tokens) =>
      save(tokens, remember: _rememberSession);

  Future<void> clear() async {
    _memoryTokens = null;
    _rememberSession = false;
    await _storage.delete(_sessionKey);
  }
}
