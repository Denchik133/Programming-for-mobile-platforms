class Contact {
  const Contact({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;

  Contact withId(int value) => Contact(
    id: value,
    name: name,
    email: email,
    phone: phone,
    createdAt: createdAt,
  );

  Map<String, Object?> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'created_at': createdAt.toIso8601String(),
  };

  factory Contact.fromMap(Map<String, Object?> map) => Contact(
    id: map['id'] as int,
    name: map['name'] as String,
    email: map['email'] as String,
    phone: map['phone'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
