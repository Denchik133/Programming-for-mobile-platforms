import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../../core/storage/secure_key_value_store.dart';
import '../../../features/auth/models/user_profile.dart';

class MockReply {
  const MockReply(this.statusCode, this.data);

  final int statusCode;
  final Object? data;
}

class LocalMockAuthServer {
  LocalMockAuthServer({required this._storage, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const String _accountsKey = 'mock_auth_accounts_v1';
  static const List<int> _signingSecret = [
    112,
    114,
    49,
    49,
    95,
    109,
    111,
    99,
    107,
    95,
    106,
    119,
    116,
    95,
    107,
    101,
    121,
  ];

  final SecureKeyValueStore _storage;
  final DateTime Function() _clock;
  bool _unauthorizedOnNextProfile = false;
  int _tokenSequence = 0;
  int refreshCount = 0;
  int profileRequestCount = 0;

  void rejectNextProfileRequest() => _unauthorizedOnNextProfile = true;

  Future<MockReply> dispatch(RequestOptions request) async {
    final path = request.uri.path;
    final method = request.method.toUpperCase();
    final body = _bodyMap(request.data);

    if (method == 'POST' && path == '/api/auth/register') {
      return _register(body);
    }
    if (method == 'POST' && path == '/api/auth/login') {
      return _login(body);
    }
    if (method == 'POST' && path == '/api/auth/refresh') {
      return _refresh(body);
    }
    if (method == 'GET' && path == '/api/user') {
      profileRequestCount++;
      if (_unauthorizedOnNextProfile) {
        _unauthorizedOnNextProfile = false;
        return _error(401, 'Access-токен застарів.');
      }
      final account = await _accountForAccessToken(request);
      if (account == null) return _error(401, 'Потрібна авторизація.');
      return MockReply(200, {'user': account.profile.toJson()});
    }
    if (method == 'PUT' && path == '/api/user') {
      final account = await _accountForAccessToken(request);
      if (account == null) return _error(401, 'Потрібна авторизація.');
      final name = (body['name'] as String? ?? '').trim();
      final email = (body['email'] as String? ?? '').trim().toLowerCase();
      if (name.isEmpty || !_isEmail(email)) {
        return _error(400, 'Перевірте ім’я та адресу електронної пошти.');
      }
      final accounts = await _readAccounts();
      if (accounts.any(
        (item) => item.id != account.id && item.email == email,
      )) {
        return _error(409, 'Ця електронна адреса вже використовується.');
      }
      final updated = account.copyWith(name: name, email: email);
      await _replaceAccount(updated, accounts);
      return MockReply(200, {'user': updated.profile.toJson()});
    }
    if (method == 'POST' && path == '/api/user/change-password') {
      final account = await _accountForAccessToken(request);
      if (account == null) return _error(401, 'Потрібна авторизація.');
      final currentPassword = body['currentPassword'];
      final newPassword = body['newPassword'];
      if (currentPassword is! String ||
          _passwordHash(currentPassword) != account.passwordHash) {
        return _error(400, 'Поточний пароль не збігається.');
      }
      if (newPassword is! String || newPassword.length < 8) {
        return _error(400, 'Новий пароль має містити щонайменше 8 символів.');
      }
      final accounts = await _readAccounts();
      await _replaceAccount(
        account.copyWith(passwordHash: _passwordHash(newPassword)),
        accounts,
      );
      return const MockReply(200, {'message': 'Пароль змінено.'});
    }
    if (method == 'GET' && path == '/api/debug/not-found') {
      return _error(404, 'Маршрут не знайдено.');
    }
    if (method == 'GET' && path == '/api/debug/server-error') {
      return _error(500, 'Демонстраційна помилка сервера.');
    }
    return _error(404, 'Маршрут не знайдено.');
  }

  Future<MockReply> _register(Map<String, dynamic> body) async {
    final name = (body['name'] as String? ?? '').trim();
    final email = (body['email'] as String? ?? '').trim().toLowerCase();
    final password = body['password'];
    if (name.isEmpty || !_isEmail(email) || password is! String) {
      return _error(400, 'Введіть ім’я, коректний email і пароль.');
    }
    if (password.length < 8) {
      return _error(400, 'Пароль має містити щонайменше 8 символів.');
    }
    final accounts = await _readAccounts();
    if (accounts.any((account) => account.email == email)) {
      return _error(409, 'Користувач із таким email уже існує.');
    }
    final account = _Account(
      id: 'user-${_clock().microsecondsSinceEpoch}',
      name: name,
      email: email,
      passwordHash: _passwordHash(password),
      refreshVersion: 0,
    );
    await _saveAccounts([...accounts, account]);
    return MockReply(201, _sessionJson(account));
  }

  Future<MockReply> _login(Map<String, dynamic> body) async {
    final email = (body['email'] as String? ?? '').trim().toLowerCase();
    final password = body['password'];
    if (password is! String) return _error(400, 'Введіть email і пароль.');
    final accounts = await _readAccounts();
    final account = _findAccount(accounts, (item) => item.email == email);
    if (account == null || account.passwordHash != _passwordHash(password)) {
      return _error(401, 'Неправильний email або пароль.');
    }
    return MockReply(200, _sessionJson(account));
  }

  Future<MockReply> _refresh(Map<String, dynamic> body) async {
    final refreshToken = body['refreshToken'];
    if (refreshToken is! String) {
      return _error(401, 'Не знайдено refresh-токен.');
    }
    final claims = _verifyToken(refreshToken, expectedType: 'refresh');
    if (claims == null) {
      return _error(401, 'Refresh-токен недійсний або застарів.');
    }
    final accounts = await _readAccounts();
    final account = _findAccount(accounts, (item) => item.id == claims['sub']);
    if (account == null || claims['version'] != account.refreshVersion) {
      return _error(401, 'Refresh-токен уже використано. Увійдіть знову.');
    }
    final rotated = account.copyWith(
      refreshVersion: account.refreshVersion + 1,
    );
    await _replaceAccount(rotated, accounts);
    refreshCount++;
    return MockReply(200, _sessionJson(rotated));
  }

  Future<_Account?> _accountForAccessToken(RequestOptions request) async {
    final header = request.headers['Authorization']?.toString() ?? '';
    if (!header.startsWith('Bearer ')) return null;
    final claims = _verifyToken(header.substring(7), expectedType: 'access');
    if (claims == null) return null;
    final accounts = await _readAccounts();
    return _findAccount(accounts, (item) => item.id == claims['sub']);
  }

  Map<String, dynamic> _sessionJson(_Account account) {
    final now = _clock().toUtc();
    final accessExpiry = now.add(const Duration(minutes: 10));
    final refreshExpiry = now.add(const Duration(days: 7));
    final access = _signToken({
      'sub': account.id,
      'type': 'access',
      'jti': ++_tokenSequence,
      'exp': accessExpiry.millisecondsSinceEpoch ~/ 1000,
    });
    final refresh = _signToken({
      'sub': account.id,
      'type': 'refresh',
      'jti': ++_tokenSequence,
      'version': account.refreshVersion,
      'exp': refreshExpiry.millisecondsSinceEpoch ~/ 1000,
    });
    return {
      'tokens': {
        'accessToken': access,
        'refreshToken': refresh,
        'accessExpiresAt': accessExpiry.toIso8601String(),
      },
      'user': account.profile.toJson(),
    };
  }

  String _signToken(Map<String, Object> claims) {
    final header = _encode({'alg': 'HS256', 'typ': 'JWT'});
    final payload = _encode(claims);
    final content = '$header.$payload';
    final signature = Hmac(
      sha256,
      _signingSecret,
    ).convert(utf8.encode(content)).bytes;
    return '$content.${base64Url.encode(signature).replaceAll('=', '')}';
  }

  Map<String, dynamic>? _verifyToken(
    String token, {
    required String expectedType,
  }) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final content = '${parts[0]}.${parts[1]}';
    final signature = Hmac(
      sha256,
      _signingSecret,
    ).convert(utf8.encode(content)).bytes;
    final expected = base64Url.encode(signature).replaceAll('=', '');
    if (expected != parts[2]) return null;
    try {
      final claims = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final expiresAt = claims['exp'];
      if (claims['type'] != expectedType ||
          expiresAt is! int ||
          expiresAt <= _clock().toUtc().millisecondsSinceEpoch ~/ 1000) {
        return null;
      }
      return claims;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  String _encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

  Future<List<_Account>> _readAccounts() async {
    final saved = await _storage.read(_accountsKey);
    if (saved != null) {
      try {
        final rows = jsonDecode(saved) as List<dynamic>;
        return rows
            .map((row) => _Account.fromJson(row as Map<String, dynamic>))
            .toList();
      } on FormatException {
        await _storage.delete(_accountsKey);
      } on TypeError {
        await _storage.delete(_accountsKey);
      }
    }
    final demoAccount = _Account(
      id: 'demo-user',
      name: 'Демо користувач',
      email: 'demo@pr11.local',
      passwordHash: _passwordHash('Flutter123'),
      refreshVersion: 0,
    );
    await _saveAccounts([demoAccount]);
    return [demoAccount];
  }

  Future<void> _saveAccounts(List<_Account> accounts) => _storage.write(
    _accountsKey,
    jsonEncode(accounts.map((account) => account.toJson()).toList()),
  );

  Future<void> _replaceAccount(_Account updated, List<_Account> accounts) =>
      _saveAccounts([
        for (final account in accounts)
          if (account.id == updated.id) updated else account,
      ]);

  String _passwordHash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  bool _isEmail(String value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);

  Map<String, dynamic> _bodyMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      try {
        return Map<String, dynamic>.from(jsonDecode(data) as Map);
      } on FormatException {
        return {};
      } on TypeError {
        return {};
      }
    }
    return {};
  }

  _Account? _findAccount(
    Iterable<_Account> accounts,
    bool Function(_Account) matches,
  ) {
    for (final account in accounts) {
      if (matches(account)) return account;
    }
    return null;
  }

  MockReply _error(int status, String message) =>
      MockReply(status, {'message': message});
}

class _Account {
  const _Account({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.refreshVersion,
  });

  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final int refreshVersion;

  UserProfile get profile => UserProfile(id: id, name: name, email: email);

  _Account copyWith({
    String? name,
    String? email,
    String? passwordHash,
    int? refreshVersion,
  }) => _Account(
    id: id,
    name: name ?? this.name,
    email: email ?? this.email,
    passwordHash: passwordHash ?? this.passwordHash,
    refreshVersion: refreshVersion ?? this.refreshVersion,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'passwordHash': passwordHash,
    'refreshVersion': refreshVersion,
  };

  factory _Account.fromJson(Map<String, dynamic> json) => _Account(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    passwordHash: json['passwordHash'] as String,
    refreshVersion: json['refreshVersion'] as int,
  );
}
