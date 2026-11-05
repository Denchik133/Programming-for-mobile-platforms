class Assignment {
  final int? id;
  final int courseId;
  final String name;
  final String type;
  final double weight;
  final double maxScore;
  final double? earnedScore;
  final DateTime dueDate;

  const Assignment({
    this.id,
    required this.courseId,
    required this.name,
    required this.type,
    required this.weight,
    required this.maxScore,
    this.earnedScore,
    required this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'name': name,
      'type': type,
      'weight': weight,
      'max_score': maxScore,
      'earned_score': earnedScore,
      'due_date': dueDate.toIso8601String(),
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'] as int?,
      courseId: map['course_id'] as int,
      name: map['name'] as String,
      type: map['type'] as String,
      weight: (map['weight'] as num).toDouble(),
      maxScore: (map['max_score'] as num).toDouble(),
      earnedScore: (map['earned_score'] as num?)?.toDouble(),
      dueDate: DateTime.parse(map['due_date'] as String),
    );
  }
}
