class Task {
  const Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  final int id;
  final int userId;
  final String title;
  final bool completed;

  Task copyWith({String? title, bool? completed}) => Task(
    id: id,
    userId: userId,
    title: title ?? this.title,
    completed: completed ?? this.completed,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'completed': completed,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: (json['id'] as num).toInt(),
    userId: (json['userId'] as num).toInt(),
    title: json['title'] as String,
    completed: json['completed'] as bool? ?? false,
  );
}
