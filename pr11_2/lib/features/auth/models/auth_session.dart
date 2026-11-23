import 'auth_tokens.dart';
import 'user_profile.dart';

class AuthSession {
  const AuthSession({required this.tokens, required this.user});

  final AuthTokens tokens;
  final UserProfile user;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
    user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
  );
}
