
import 'course.dart';
import 'professor.dart';
import 'student.dart';

class University {
  final String name;
  final List<Student> students = [];
  final List<Professor> professors = [];
  final List<Course> courses = [];

  University({required this.name});

  void addStudent(Student student) {
    if (students.any((item) => item.id == student.id)) {
      throw ArgumentError('Студент з ID ${student.id} вже існує');
    }

    students.add(student);
  }

  void addProfessor(Professor professor) {
    if (professors.any((item) => item.id == professor.id)) {
      throw ArgumentError('Викладач з ID ${professor.id} вже існує');
    }

    professors.add(professor);
  }

  void addCourse(Course course) {
    if (courses.any((item) => item.id == course.id)) {
      throw ArgumentError('Курс з ID ${course.id} вже існує');
    }

    courses.add(course);
  }

  Student? findStudentById(String id) {
    for (final student in students) {
      if (student.id == id) {
        return student;
      }
    }

    return null;
  }

  bool enrollStudent(String studentId, String courseId) {
    final student = findStudentById(studentId);

    if (student == null) {
      return false;
    }

    Course? selectedCourse;

    for (final course in courses) {
      if (course.id == courseId) {
        selectedCourse = course;
        break;
      }
    }

    if (selectedCourse == null ||
        !selectedCourse.canStudentEnroll(student)) {
      return false;
    }

    student.enrollInCourse(selectedCourse.name);
    return true;
  }

  List<Student> getStudentsByCourse(String courseName) {
    return students
        .where((student) => student.enrolledCourses.contains(courseName))
        .toList();
  }

  List<Course> getAvailableCoursesForStudent(String studentId) {
    final student = findStudentById(studentId);

    if (student == null) {
      return [];
    }

    return courses
        .where((course) => course.canStudentEnroll(student))
        .toList();
  }

  Map<String, dynamic> generateStatistics() {
    final averageGpa = students.isEmpty
        ? 0.0
        : students.map((student) => student.gpa).reduce((a, b) => a + b) /
            students.length;

    return {
      'university': name,
      'studentsCount': students.length,
      'professorsCount': professors.length,
      'coursesCount': courses.length,
      'averageGpa': averageGpa,
    };
  }

  @override
  String toString() {
    return 'University($name, students: ${students.length}, '
        'professors: ${professors.length}, courses: ${courses.length})';
  }
}
