class Semester {
  final int? id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;

  const Semester({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isCurrent = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_current': isCurrent ? 1 : 0,
    };
  }

  factory Semester.fromMap(Map<String, dynamic> map) {
    return Semester(
      id: map['id'] as int?,
      name: map['name'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      isCurrent: (map['is_current'] as int) == 1,
    );
  }
}
