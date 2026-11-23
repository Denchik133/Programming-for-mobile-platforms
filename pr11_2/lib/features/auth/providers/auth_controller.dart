import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/storage/token_storage.dart';
import '../data/auth_api.dart';
import '../models/user_profile.dart';

enum AuthStatus { checking, signedOut, signedIn }

class AuthController extends ChangeNotifier {
  AuthController({
    required this._api,
    required this._tokenStorage,
    this.inactivityLimit = const Duration(minutes: 10),
  });

  final AuthApi _api;
  final TokenStorage _tokenStorage;
  final Duration inactivityLimit;

  AuthStatus _status = AuthStatus.checking;
  UserProfile? _profile;
  bool _busy = false;
  String? _errorMessage;
  Timer? _inactivityTimer;

  AuthStatus get status => _status;
  UserProfile? get profile => _profile;
  bool get isBusy => _busy;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    try {
      final tokens = await _tokenStorage.readTokens();
      if (tokens == null) {
        _status = AuthStatus.signedOut;
        return;
      }
      _profile = await _api.getProfile();
      _status = AuthStatus.signedIn;
      _armInactivityTimer();
    } on DioException {
      await _tokenStorage.clear();
      _profile = null;
      _status = AuthStatus.signedOut;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _begin();
    try {
      final session = await _api.login(email.trim(), password);
      await _tokenStorage.save(session.tokens, remember: rememberMe);
      _profile = session.user;
      _status = AuthStatus.signedIn;
      _armInactivityTimer();
      return true;
    } on DioException catch (error) {
      _errorMessage = _message(error);
      return false;
    } finally {
      _end();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _begin();
    try {
      final session = await _api.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );
      await _tokenStorage.save(session.tokens, remember: true);
      _profile = session.user;
      _status = AuthStatus.signedIn;
      _armInactivityTimer();
      return true;
    } on DioException catch (error) {
      _errorMessage = _message(error);
      return false;
    } finally {
      _end();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    _begin();
    try {
      _profile = await _api.updateProfile(
        name: name.trim(),
        email: email.trim(),
      );
      return true;
    } on DioException catch (error) {
      _errorMessage = _message(error);
      return false;
    } finally {
      _end();
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _begin();
    try {
      await _api.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } on DioException catch (error) {
      _errorMessage = _message(error);
      return false;
    } finally {
      _end();
    }
  }

  Future<bool> demonstrateRefresh() async {
    _begin();
    try {
      _profile = await _api.demonstrateRefresh();
      return true;
    } on DioException catch (error) {
      _errorMessage = _message(error);
      return false;
    } finally {
      _end();
    }
  }

  Future<void> logout() async {
    _inactivityTimer?.cancel();
    await _tokenStorage.clear();
    _profile = null;
    _errorMessage = null;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }

  void recordActivity() {
    if (_status == AuthStatus.signedIn) _armInactivityTimer();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _begin() {
    _busy = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _end() {
    _busy = false;
    if (_status == AuthStatus.signedIn) _armInactivityTimer();
    notifyListeners();
  }

  void _armInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(
      inactivityLimit,
      () => unawaited(_expireSession()),
    );
  }

  Future<void> _expireSession() async {
    await _tokenStorage.clear();
    _profile = null;
    _status = AuthStatus.signedOut;
    _errorMessage = 'Сесію завершено через тривалу бездіяльність.';
    notifyListeners();
  }

  String _message(DioException error) =>
      error.message ?? 'Не вдалося виконати запит. Спробуйте ще раз.';

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }
}
