class Attendance {
  final int? id;
  final int courseId;
  final DateTime date;
  final String status;

  const Attendance({
    this.id,
    required this.courseId,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as int?,
      courseId: map['course_id'] as int,
      date: DateTime.parse(map['date'] as String),
      status: map['status'] as String,
    );
  }
}
