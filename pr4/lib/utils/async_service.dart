
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/student.dart';

class AsyncService {
  Future<Map<String, dynamic>> fetchStudentData(String id) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    return {
      'id': id,
      'firstName': 'Denys',
      'lastName': 'Klymenko',
      'birthDate': '2008-05-10T00:00:00.000',
    };
  }

  Future<void> saveStudentsToFile(
    List<Student> students,
    String path,
  ) async {
    final file = File(path);
    final data = students.map((student) => student.toJson()).toList();

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
  }

  Future<List<Student>> loadStudentsFromFile(String path) async {
    final file = File(path);

    if (!await file.exists()) {
      return [];
    }

    final contents = await file.readAsString();
    final decoded = jsonDecode(contents) as List<dynamic>;

    return decoded
        .map(
          (item) => Student.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Stream<Student> studentStream(List<Student> students) async* {
    for (final student in students) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      yield student;
    }
  }

  Future<List<Student>> loadWithTimeout(
    String path, {
    Duration timeout = const Duration(seconds: 3),
  }) {
    return loadStudentsFromFile(path).timeout(timeout);
  }
}
