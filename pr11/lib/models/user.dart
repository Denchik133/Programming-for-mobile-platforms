class User {
  const User({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final email = json['email'];
    if (id is! int || name is! String || email is! String) {
      throw const FormatException('Некоректна структура користувача у JSON.');
    }
    return User(id: id, name: name, email: email);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}
