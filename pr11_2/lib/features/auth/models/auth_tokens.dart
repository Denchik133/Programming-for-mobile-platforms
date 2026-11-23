class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'];
    final refreshToken = json['refreshToken'];
    final expiresAt = json['accessExpiresAt'];
    if (accessToken is! String ||
        refreshToken is! String ||
        expiresAt is! String) {
      throw const FormatException('Некоректні дані токенів.');
    }
    final parsedDate = DateTime.tryParse(expiresAt);
    if (parsedDate == null) {
      throw const FormatException('Некоректний строк дії токена.');
    }
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessExpiresAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'accessExpiresAt': accessExpiresAt.toIso8601String(),
  };
}
