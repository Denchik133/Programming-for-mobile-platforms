class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final email = json['email'];
    if (id is! String || name is! String || email is! String) {
      throw const FormatException('Сервер повернув некоректний профіль.');
    }
    return UserProfile(id: id, name: name, email: email);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}
