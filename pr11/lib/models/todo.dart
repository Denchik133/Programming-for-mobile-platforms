class Todo {
  const Todo({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
    this.locallyCreated = false,
  });

  final int id;
  final int userId;
  final String title;
  final bool completed;

  /// JSONPlaceholder simulates writes without persisting them. New items are
  /// kept in the client for the current session and do not have a server ID.
  final bool locallyCreated;

  factory Todo.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final userId = json['userId'];
    final title = json['title'];
    final completed = json['completed'];
    if (id is! int ||
        userId is! int ||
        title is! String ||
        completed is! bool) {
      throw const FormatException('Некоректна структура завдання у JSON.');
    }
    return Todo(id: id, userId: userId, title: title, completed: completed);
  }

  Map<String, dynamic> toJson({bool includeId = true}) => {
    if (includeId) 'id': id,
    'userId': userId,
    'title': title,
    'completed': completed,
  };

  Todo copyWith({
    int? id,
    int? userId,
    String? title,
    bool? completed,
    bool? locallyCreated,
  }) => Todo(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    completed: completed ?? this.completed,
    locallyCreated: locallyCreated ?? this.locallyCreated,
  );
}
