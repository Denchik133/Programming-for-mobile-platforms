// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../../core/storage/token_storage.dart';
import '../data/auth_api.dart';
import '../domain/auth_session.dart';

class AuthController extends ChangeNotifier {
  AuthController({required AuthApi api, required TokenStorage tokenStorage})
    : _api = api,
      _tokenStorage = tokenStorage;

  final AuthApi _api;
  final TokenStorage _tokenStorage;

  AuthSession? session;
  bool isLoading = true;
  String? errorMessage;

  Future<void> initialize() async {
    session = await _tokenStorage.readSession();
    isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password, {required bool remember}) =>
      _signIn(() => _api.login(email.trim(), password), remember: remember);

  Future<bool> register(
    String email,
    String password, {
    required bool remember,
  }) =>
      _signIn(() => _api.register(email.trim(), password), remember: remember);

  Future<bool> _signIn(
    Future<AuthSession> Function() authenticate, {
    required bool remember,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      session = await authenticate();
      await _tokenStorage.saveSession(session!, remember: remember);
      return true;
    } on Object catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    session = null;
    errorMessage = null;
    await _tokenStorage.clear();
    notifyListeners();
  }

  Future<void> expireSession() => logout();
}
