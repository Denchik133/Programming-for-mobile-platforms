import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/tasks/domain/task.dart';

class TaskCacheSnapshot {
  const TaskCacheSnapshot({
    required this.tasks,
    required this.overrides,
    required this.deletedIds,
  });

  final List<Task> tasks;
  final Map<int, Task> overrides;
  final Set<int> deletedIds;

  TaskCacheSnapshot copyWith({
    List<Task>? tasks,
    Map<int, Task>? overrides,
    Set<int>? deletedIds,
  }) => TaskCacheSnapshot(
    tasks: tasks ?? this.tasks,
    overrides: overrides ?? this.overrides,
    deletedIds: deletedIds ?? this.deletedIds,
  );

  Map<String, dynamic> toJson() => {
    'tasks': tasks.map((task) => task.toJson()).toList(),
    'overrides': {
      for (final entry in overrides.entries)
        entry.key.toString(): entry.value.toJson(),
    },
    'deletedIds': deletedIds.toList(),
  };

  factory TaskCacheSnapshot.fromJson(Map<String, dynamic> json) {
    final rawTasks = json['tasks'] as List<dynamic>? ?? const [];
    final rawOverrides = json['overrides'] as Map<String, dynamic>? ?? const {};
    final rawDeletedIds = json['deletedIds'] as List<dynamic>? ?? const [];
    return TaskCacheSnapshot(
      tasks: rawTasks
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList(),
      overrides: {
        for (final entry in rawOverrides.entries)
          int.parse(entry.key): Task.fromJson(
            entry.value as Map<String, dynamic>,
          ),
      },
      deletedIds: rawDeletedIds.map((item) => (item as num).toInt()).toSet(),
    );
  }
}

abstract interface class TaskCache {
  Future<TaskCacheSnapshot?> read(int userId);
  Future<void> write(int userId, TaskCacheSnapshot snapshot);
}

class CacheService implements TaskCache {
  CacheService(this._preferences);

  final SharedPreferences _preferences;

  String _key(int userId) => 'pr11_3_tasks_user_$userId';

  // Cache snapshot and local edits as JSON so the same data is available offline.
  @override
  Future<TaskCacheSnapshot?> read(int userId) async {
    final raw = _preferences.getString(_key(userId));
    if (raw == null) return null;
    try {
      return TaskCacheSnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      await _preferences.remove(_key(userId));
      return null;
    }
  }

  @override
  Future<void> write(int userId, TaskCacheSnapshot snapshot) async {
    await _preferences.setString(_key(userId), jsonEncode(snapshot.toJson()));
  }
}
