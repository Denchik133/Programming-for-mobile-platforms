
import 'dart:async';
import 'dart:io';

import 'package:pr4/models/student.dart';
import 'package:pr4/utils/async_service.dart';

Future<void> main() async {
  final service = AsyncService();

  final student = Student(
    id: 'S001',
    firstName: 'Denys',
    lastName: 'Klymenko',
    birthDate: DateTime(2007, 13, 11),
  );

  student.enrollInCourse('Dart');
  student.addGrade('Dart', 90);
  student.addGrade('Dart', 85);

  print('=== Future: отримання даних ===');
  final data = await service.fetchStudentData('S001');
  print(data);

  print('\n=== Запис JSON ===');
  const path = 'data/students.json';
  await Directory('data').create(recursive: true);
  await service.saveStudentsToFile([student], path);
  print('Дані збережено у $path');

  print('\n=== Завантаження JSON ===');
  final loadedStudents = await service.loadStudentsFromFile(path);

  for (final item in loadedStudents) {
    print(item);
  }

  print('\n=== Future.wait ===');
  final results = await Future.wait([
    service.fetchStudentData('S001'),
    service.fetchStudentData('S002'),
  ]);
  print('Отримано записів: ${results.length}');

  print('\n=== Stream ===');
  await for (final item in service.studentStream(loadedStudents)) {
    print('Отримано зі Stream: ${item.fullName}');
  }

  print('\n=== Обробка помилок і тайм-ауту ===');
  try {
    final timedOutStudents = await service.loadWithTimeout(
      path,
      timeout: const Duration(seconds: 3),
    );
    print('Завантажено студентів: ${timedOutStudents.length}');
  } on TimeoutException {
    print('Перевищено час очікування');
  } on FileSystemException catch (error) {
    print('Помилка роботи з файлом: ${error.message}');
  } catch (error) {
    print('Інша помилка: $error');
  }
}
