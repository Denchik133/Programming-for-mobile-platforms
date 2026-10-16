
class Student {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;

  final List<String> enrolledCourses = [];
  final Map<String, List<int>> grades = {};

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
  });

  String get fullName => '$firstName $lastName';

  int get age {
    final today = DateTime.now();
    var result = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      result--;
    }

    return result;
  }

  double get gpa {
    final allGrades = grades.values.expand((items) => items).toList();

    if (allGrades.isEmpty) {
      return 0.0;
    }

    return allGrades.reduce((a, b) => a + b) / allGrades.length;
  }

  void enrollInCourse(String courseName) {
    if (!enrolledCourses.contains(courseName)) {
      enrolledCourses.add(courseName);
    }
  }

  void addGrade(String courseName, int grade) {
    if (grade < 0 || grade > 100) {
      throw ArgumentError('Оцінка повинна бути від 0 до 100');
    }

    grades.putIfAbsent(courseName, () => []);
    grades[courseName]!.add(grade);
  }

  List<String> getPassedCourses() {
    return grades.entries
        .where(
          (entry) =>
              entry.value.isNotEmpty &&
              entry.value.reduce((a, b) => a + b) / entry.value.length >= 60,
        )
        .map((entry) => entry.key)
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String(),
      'enrolledCourses': enrolledCourses,
      'grades': grades,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    final student = Student(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
    );

    student.enrolledCourses.addAll(
      (json['enrolledCourses'] as List<dynamic>? ?? []).cast<String>(),
    );

    final rawGrades = json['grades'] as Map<String, dynamic>? ?? {};

    for (final entry in rawGrades.entries) {
      student.grades[entry.key] = (entry.value as List<dynamic>)
          .map((grade) => grade as int)
          .toList();
    }

    return student;
  }

  @override
  String toString() {
    return 'Student(id: $id, name: $fullName, age: $age, GPA: ${gpa.toStringAsFixed(2)})';
  }
}
