
abstract class Person {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;

  Person({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
  });

  String get fullName => '$firstName $lastName';

  int get age {
    final today = DateTime.now();
    var result = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      result--;
    }

    return result;
  }

  String getRole();

  @override
  String toString() => '$fullName, вік: $age, роль: ${getRole()}';
}
