
import 'student.dart';

class Course {
  final String id;
  final String name;
  final String description;
  final int credits;
  final List<String> prerequisites;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.credits,
    this.prerequisites = const [],
  }) {
    if (credits <= 0) {
      throw ArgumentError('Кількість кредитів повинна бути більшою за 0');
    }
  }

  bool hasPrerequisites(Student student) {
    return prerequisites.every(
      (course) => student.getPassedCourses().contains(course),
    );
  }

  bool canStudentEnroll(Student student) {
    return !student.enrolledCourses.contains(name) &&
        hasPrerequisites(student);
  }

  @override
  String toString() {
    return 'Course(id: $id, name: $name, credits: $credits, prerequisites: $prerequisites)';
  }
}
