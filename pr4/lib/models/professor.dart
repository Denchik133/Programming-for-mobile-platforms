
import 'person.dart';

class Professor extends Person {
  final String department;
  final List<String> taughtCourses;

  Professor({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.birthDate,
    required this.department,
    List<String> taughtCourses = const [],
  }) : taughtCourses = List<String>.from(taughtCourses);

  void assignCourse(String courseName) {
    if (!taughtCourses.contains(courseName)) {
      taughtCourses.add(courseName);
    }
  }

  @override
  String getRole() => 'Викладач';

  @override
  String toString() {
    return '${super.toString()}, кафедра: $department, курси: $taughtCourses';
  }
}
