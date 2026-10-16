
import 'package:pr4/models/student.dart';
import 'package:pr4/models/course.dart';
import 'package:pr4/models/person.dart';
import 'package:pr4/models/professor.dart';
import 'package:pr4/models/university.dart';

void main() {
  final student = Student(
    id: 'S001',
    firstName: 'Denys',
    lastName: 'Klymenko',
    birthDate: DateTime(2007, 13, 11),
  );

  student.enrollInCourse('Dart');
  student.enrollInCourse('Flutter');

  student.addGrade('Dart', 90);
  student.addGrade('Dart', 85);
  student.addGrade('Flutter', 95);
  
  final flutterCourse = Course(
    id: 'C002',
    name: 'Advanced Flutter',
    description: 'Поглиблене вивчення Flutter',
    credits: 5,
    prerequisites: ['Dart'],
  );

  print('=== Інформація про студента ===');
  print('ID: ${student.id}');
  print('Ім’я: ${student.fullName}');
  print('Вік: ${student.age}');
  print('Середній бал: ${student.gpa.toStringAsFixed(2)}');
  print('Курси: ${student.enrolledCourses}');
  print('Успішно складені курси: ${student.getPassedCourses()}');

  print('\n=== Серіалізація JSON ===');
  final json = student.toJson();
  print(json);

  final restoredStudent = Student.fromJson(json);
  print('\nВідновлений об’єкт: $restoredStudent');

  print('\n=== Перевірка передумов курсу ===');
  print(flutterCourse);
  print('Передумови виконані: ${flutterCourse.hasPrerequisites(student)}');
  print('Можна записатися: ${flutterCourse.canStudentEnroll(student)}');

    final professor = Professor(
    id: 'P001',
    firstName: 'Oleksandr',
    lastName: 'Klymenko',
    birthDate: DateTime(1998, 3, 15),
    department: 'Інженерія програмного забезпечення',
    taughtCourses: ['Dart'],
  );

  final Person person = professor;

  print('\n=== Наслідування та поліморфізм ===');
  print(person);
  print('Роль: ${person.getRole()}');

  professor.assignCourse('Flutter');
  print('Курси викладача: ${professor.taughtCourses}');

    final university = University(name: 'Фаховий коледж ЗВО "МНТУ" ім. академіка Ю. Бугая');

  university.addStudent(student);
  university.addProfessor(professor);
  university.addCourse(flutterCourse);

  print('\n=== Система управління університетом ===');
  print(university);

  print(
    'Запис на Advanced Flutter: '
    '${university.enrollStudent('S001', 'C002')}',
  );

  print(
    'Студенти курсу Dart: '
    '${university.getStudentsByCourse('Dart').map((s) => s.fullName).toList()}',
  );

  print(
    'Доступні курси: '
    '${university.getAvailableCoursesForStudent('S001').map((c) => c.name).toList()}',
  );

  print('Статистика: ${university.generateStatistics()}');
}
