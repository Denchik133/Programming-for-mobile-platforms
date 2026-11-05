import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // ================= DATABASE INITIALIZATION =================

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'student_grades.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // SEMESTERS
    await db.execute('''
      CREATE TABLE semesters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        is_current INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // COURSES
    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        semester_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        credits INTEGER NOT NULL,
        instructor TEXT NOT NULL,
        color TEXT NOT NULL,
        target_grade REAL NOT NULL,
        FOREIGN KEY (semester_id)
          REFERENCES semesters(id)
          ON DELETE CASCADE
      )
    ''');

    // ASSIGNMENTS
    await db.execute('''
      CREATE TABLE assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        weight REAL NOT NULL,
        max_score REAL NOT NULL,
        earned_score REAL,
        due_date TEXT NOT NULL,
        FOREIGN KEY (course_id)
          REFERENCES courses(id)
          ON DELETE CASCADE
      )
    ''');

    // ATTENDANCE
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (course_id)
          REFERENCES courses(id)
          ON DELETE CASCADE
      )
    ''');

    // INDEXES
    await db.execute(
      'CREATE INDEX idx_courses_semester ON courses(semester_id)',
    );

    await db.execute(
      'CREATE INDEX idx_assignments_course ON assignments(course_id)',
    );

    await db.execute(
      'CREATE INDEX idx_assignments_due_date ON assignments(due_date)',
    );

    await db.execute(
      'CREATE INDEX idx_attendance_course ON attendance(course_id)',
    );

    await db.execute('CREATE INDEX idx_attendance_date ON attendance(date)');
  }

  // ================= SEMESTERS CRUD =================

  Future<int> insertSemester(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('semesters', data);
  }

  Future<List<Map<String, dynamic>>> getSemesters() async {
    final db = await database;

    return await db.query('semesters', orderBy: 'start_date DESC');
  }

  Future<Map<String, dynamic>?> getSemesterById(int id) async {
    final db = await database;

    final result = await db.query(
      'semesters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }

  Future<int> updateSemester(int id, Map<String, dynamic> data) async {
    final db = await database;

    return await db.update('semesters', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSemester(int id) async {
    final db = await database;

    return await db.delete('semesters', where: 'id = ?', whereArgs: [id]);
  }

  // ================= COURSES CRUD =================

  Future<int> insertCourse(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('courses', data);
  }

  Future<List<Map<String, dynamic>>> getCourses(int semesterId) async {
    final db = await database;

    return await db.query(
      'courses',
      where: 'semester_id = ?',
      whereArgs: [semesterId],
      orderBy: 'name ASC',
    );
  }

  Future<Map<String, dynamic>?> getCourseById(int id) async {
    final db = await database;

    final result = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }

  Future<int> updateCourse(int id, Map<String, dynamic> data) async {
    final db = await database;

    return await db.update('courses', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCourse(int id) async {
    final db = await database;

    return await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  // ================= ASSIGNMENTS CRUD =================

  Future<int> insertAssignment(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('assignments', data);
  }

  Future<List<Map<String, dynamic>>> getAssignments(int courseId) async {
    final db = await database;

    return await db.query(
      'assignments',
      where: 'course_id = ?',
      whereArgs: [courseId],
      orderBy: 'due_date ASC',
    );
  }

  Future<Map<String, dynamic>?> getAssignmentById(int id) async {
    final db = await database;

    final result = await db.query(
      'assignments',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }

  Future<List<Map<String, dynamic>>> getAssignmentsBySemester(
    int semesterId,
  ) async {
    final db = await database;

    return await db.rawQuery(
      '''
      SELECT assignments.*, courses.name AS course_name
      FROM assignments
      INNER JOIN courses ON assignments.course_id = courses.id
      WHERE courses.semester_id = ?
      ORDER BY assignments.due_date ASC
      ''',
      [semesterId],
    );
  }

  Future<int> getAssignmentCount(int courseId) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM assignments
      WHERE course_id = ?
      ''',
      [courseId],
    );

    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> getCompletedAssignmentCount(int courseId) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM assignments
      WHERE course_id = ? AND earned_score IS NOT NULL
      ''',
      [courseId],
    );

    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> updateAssignment(int id, Map<String, dynamic> data) async {
    final db = await database;

    return await db.update(
      'assignments',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAssignment(int id) async {
    final db = await database;

    return await db.delete('assignments', where: 'id = ?', whereArgs: [id]);
  }

  // ================= ATTENDANCE CRUD =================

  Future<int> insertAttendance(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('attendance', data);
  }

  Future<List<Map<String, dynamic>>> getAttendance(int courseId) async {
    final db = await database;

    return await db.query(
      'attendance',
      where: 'course_id = ?',
      whereArgs: [courseId],
      orderBy: 'date DESC',
    );
  }

  Future<Map<String, dynamic>?> getAttendanceById(int id) async {
    final db = await database;

    final result = await db.query(
      'attendance',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }

  Future<Map<String, int>> getAttendanceStatistics(int courseId) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS total,
        SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) AS present,
        SUM(CASE WHEN status = 'absent' THEN 1 ELSE 0 END) AS absent,
        SUM(CASE WHEN status = 'late' THEN 1 ELSE 0 END) AS late
      FROM attendance
      WHERE course_id = ?
      ''',
      [courseId],
    );

    final row = result.first;

    return {
      'total': (row['total'] as int?) ?? 0,
      'present': (row['present'] as int?) ?? 0,
      'absent': (row['absent'] as int?) ?? 0,
      'late': (row['late'] as int?) ?? 0,
    };
  }

  Future<int> updateAttendance(int id, Map<String, dynamic> data) async {
    final db = await database;

    return await db.update(
      'attendance',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await database;

    return await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }

  // ================= DATABASE CLOSE =================

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
