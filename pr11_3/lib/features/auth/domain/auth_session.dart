class AuthSession {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.accessToken,
  });

  final int userId;
  final String email;
  final String accessToken;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'accessToken': accessToken,
  };

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    userId: json['userId'] as int? ?? 1,
    email: json['email'] as String? ?? 'eve.holt@reqres.in',
    accessToken: json['accessToken'] as String,
  );
}
