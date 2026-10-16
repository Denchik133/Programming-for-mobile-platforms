
import '../models/student.dart';

class DataProcessor {
  static List<int> filterEvenNumbers(List<int> numbers) {
    return numbers.where((number) => number.isEven).toList();
  }

  static Map<String, int> countWords(String text) {
    final words = text
        .toLowerCase()
        .split(RegExp(r'[\s.,!?;:]+'))
        .where((word) => word.isNotEmpty);

    final result = <String, int>{};

    for (final word in words) {
      result[word] = (result[word] ?? 0) + 1;
    }

    return result;
  }

  static List<Student> sortStudentsByGPA(List<Student> students) {
    final result = List<Student>.from(students);
    result.sort((a, b) => b.gpa.compareTo(a.gpa));
    return result;
  }

  static Set<String> getUniqueSkills(List<List<String>> skills) {
    return skills.expand((items) => items).toSet();
  }

  static Set<String> findCommonCourses(
    Student firstStudent,
    Student secondStudent,
  ) {
    return firstStudent.enrolledCourses
        .toSet()
        .intersection(secondStudent.enrolledCourses.toSet());
  }

  static Map<int, List<Student>> groupStudentsByYear(
    List<Student> students,
  ) {
    final groups = <int, List<Student>>{};

    for (final student in students) {
      final year = student.birthDate.year;
      groups.putIfAbsent(year, () => []).add(student);
    }

    return groups;
  }

  static Map<String, double> calculateAverageGradesByCourse(
    List<Student> students,
  ) {
    final gradeGroups = <String, List<int>>{};

    for (final student in students) {
      for (final entry in student.grades.entries) {
        gradeGroups.putIfAbsent(entry.key, () => []).addAll(entry.value);
      }
    }

    return gradeGroups.map((course, grades) {
      final average = grades.reduce((a, b) => a + b) / grades.length;
      return MapEntry(course, average);
    });
  }
}
