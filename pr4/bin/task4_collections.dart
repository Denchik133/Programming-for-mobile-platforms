
import 'package:pr4/models/student.dart';
import 'package:pr4/utils/data_processor.dart';

void main() {
  final numbers = [12, 7, 4, 19, 22, 8, 5];

  final student1 = Student(
    id: 'S001',
    firstName: 'Denys',
    lastName: 'Klymenko',
    birthDate: DateTime(2007, 13, 11),
  );

  student1.enrollInCourse('Dart');
  student1.enrollInCourse('Flutter');
  student1.addGrade('Dart', 90);
  student1.addGrade('Dart', 85);
  student1.addGrade('Flutter', 95);

  final student2 = Student(
    id: 'S002',
    firstName: 'Vlad',
    lastName: 'Krysenko',
    birthDate: DateTime(2008, 8, 20),
  );

  student2.enrollInCourse('Dart');
  student2.enrollInCourse('Java');
  student2.addGrade('Dart', 75);
  student2.addGrade('Java', 88);

  final students = [student1, student2];

  print('=== Фільтрація чисел ===');
  print('Парні числа: ${DataProcessor.filterEvenNumbers(numbers)}');

  print('\n=== Підрахунок слів ===');
  print(
    DataProcessor.countWords(
      'Dart Flutter Dart programming Flutter Dart',
    ),
  );

  print('\n=== Сортування студентів за GPA ===');
  for (final student in DataProcessor.sortStudentsByGPA(students)) {
    print('${student.fullName}: ${student.gpa.toStringAsFixed(2)}');
  }

  print('\n=== Унікальні навички ===');
  final skills = DataProcessor.getUniqueSkills([
    ['Dart', 'Flutter', 'Git'],
    ['Python', 'Git', 'SQL'],
  ]);
  print(skills);

  print('\n=== Спільні курси ===');
  print(DataProcessor.findCommonCourses(student1, student2));

  print('\n=== Групування студентів за роком народження ===');
  final groups = DataProcessor.groupStudentsByYear(students);
  for (final entry in groups.entries) {
    print('${entry.key}: ${entry.value.map((s) => s.fullName).toList()}');
  }

  print('\n=== Середні оцінки за курсами ===');
  print(DataProcessor.calculateAverageGradesByCourse(students));
}
