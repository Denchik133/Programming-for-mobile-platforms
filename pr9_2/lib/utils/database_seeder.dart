import '../database/database_helper.dart';

import 'package:flutter/foundation.dart';

class DatabaseSeeder {
  static Future<void> seedDatabase() async {
    final db = DatabaseHelper.instance;

    // Перевіряємо, чи вже є семестри.
    final semesters = await db.getSemesters();

    if (semesters.isNotEmpty) {
      debugPrint('Database already contains data.');
      return;
    }

    // ================= SEMESTER =================

    final semesterId = await db.insertSemester({
      'name': 'Fall Semester 2026',
      'start_date': '2026-09-01',
      'end_date': '2027-01-31',
      'is_current': 1,
    });

    // ================= COURSES =================

    final programmingId = await db.insertCourse({
      'semester_id': semesterId,
      'name': 'Mobile Programming',
      'code': 'MP101',
      'credits': 5,
      'instructor': 'John Smith',
      'color': '#2196F3',
      'target_grade': 90.0,
    });

    final databaseId = await db.insertCourse({
      'semester_id': semesterId,
      'name': 'Database Systems',
      'code': 'DB202',
      'credits': 4,
      'instructor': 'Anna Brown',
      'color': '#4CAF50',
      'target_grade': 85.0,
    });

    // ================= ASSIGNMENTS =================

    await db.insertAssignment({
      'course_id': programmingId,
      'name': 'Flutter Basics',
      'type': 'Homework',
      'weight': 20.0,
      'max_score': 100.0,
      'earned_score': 95.0,
      'due_date': '2026-09-15',
    });

    await db.insertAssignment({
      'course_id': programmingId,
      'name': 'SQLite Integration',
      'type': 'Project',
      'weight': 40.0,
      'max_score': 100.0,
      'earned_score': 88.0,
      'due_date': '2026-10-15',
    });

    await db.insertAssignment({
      'course_id': programmingId,
      'name': 'Final Project',
      'type': 'Project',
      'weight': 40.0,
      'max_score': 100.0,
      'earned_score': null,
      'due_date': '2027-01-15',
    });

    await db.insertAssignment({
      'course_id': databaseId,
      'name': 'SQL Queries',
      'type': 'Homework',
      'weight': 30.0,
      'max_score': 100.0,
      'earned_score': 92.0,
      'due_date': '2026-09-20',
    });

    await db.insertAssignment({
      'course_id': databaseId,
      'name': 'Database Design',
      'type': 'Project',
      'weight': 40.0,
      'max_score': 100.0,
      'earned_score': 85.0,
      'due_date': '2026-11-10',
    });

    await db.insertAssignment({
      'course_id': databaseId,
      'name': 'Final Exam',
      'type': 'Exam',
      'weight': 30.0,
      'max_score': 100.0,
      'earned_score': null,
      'due_date': '2027-01-20',
    });

    // ================= ATTENDANCE =================

    await db.insertAttendance({
      'course_id': programmingId,
      'date': '2026-09-05',
      'status': 'present',
    });

    await db.insertAttendance({
      'course_id': programmingId,
      'date': '2026-09-12',
      'status': 'present',
    });

    await db.insertAttendance({
      'course_id': programmingId,
      'date': '2026-09-19',
      'status': 'late',
    });

    await db.insertAttendance({
      'course_id': programmingId,
      'date': '2026-09-26',
      'status': 'absent',
    });

    await db.insertAttendance({
      'course_id': databaseId,
      'date': '2026-09-06',
      'status': 'present',
    });

    await db.insertAttendance({
      'course_id': databaseId,
      'date': '2026-09-13',
      'status': 'present',
    });

    await db.insertAttendance({
      'course_id': databaseId,
      'date': '2026-09-20',
      'status': 'late',
    });

    debugPrint('Demo data inserted successfully.');
  }
}
