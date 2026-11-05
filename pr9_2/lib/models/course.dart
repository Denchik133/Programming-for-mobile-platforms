class Course {
  final int? id;
  final int semesterId;
  final String name;
  final String code;
  final int credits;
  final String instructor;
  final String color;
  final double targetGrade;

  const Course({
    this.id,
    required this.semesterId,
    required this.name,
    required this.code,
    required this.credits,
    required this.instructor,
    required this.color,
    required this.targetGrade,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'semester_id': semesterId,
      'name': name,
      'code': code,
      'credits': credits,
      'instructor': instructor,
      'color': color,
      'target_grade': targetGrade,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as int?,
      semesterId: map['semester_id'] as int,
      name: map['name'] as String,
      code: map['code'] as String,
      credits: map['credits'] as int,
      instructor: map['instructor'] as String,
      color: map['color'] as String,
      targetGrade: (map['target_grade'] as num).toDouble(),
    );
  }
}
