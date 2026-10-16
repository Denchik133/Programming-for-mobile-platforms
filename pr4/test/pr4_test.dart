
import 'package:pr4/pr4.dart';
import 'package:pr4/models/student.dart';
import 'package:pr4/utils/data_processor.dart';
import 'package:test/test.dart';

void main() {
  group('Базовий шаблон', () {
    test('calculate повертає 42', () {
      expect(calculate(), 42);
    });
  });

  group('Student', () {
    test('обчислює середній бал', () {
      final student = Student(
        id: 'S001',
        firstName: 'Denys',
        lastName: 'Klymenko',
        birthDate: DateTime(2008, 5, 10),
      );

      student.addGrade('Dart', 90);
      student.addGrade('Dart', 80);

      expect(student.gpa, 85.0);
      expect(student.fullName, 'Denys Klymenko');
    });

    test('відхиляє оцінку поза діапазоном', () {
      final student = Student(
        id: 'S002',
        firstName: 'Anna',
        lastName: 'Shevchenko',
        birthDate: DateTime(2007, 8, 20),
      );

      expect(
        () => student.addGrade('Dart', 120),
        throwsArgumentError,
      );
    });
  });

  group('DataProcessor', () {
    test('фільтрує парні числа', () {
      expect(
        DataProcessor.filterEvenNumbers([1, 2, 3, 4, 5, 6]),
        [2, 4, 6],
      );
    });

    test('підраховує слова без урахування регістру', () {
      expect(
        DataProcessor.countWords('Dart Flutter Dart'),
        {'dart': 2, 'flutter': 1},
      );
    });

    test('обчислює середнє значення', () {
      expect(calculate(), 42);
    });
  });
}
