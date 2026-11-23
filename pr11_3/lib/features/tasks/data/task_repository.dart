// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';

import '../../../core/storage/cache_service.dart';
import '../../../core/storage/connectivity_service.dart';
import '../domain/task.dart';
import 'task_api.dart';

class TaskRepository {
  TaskRepository({
    required TaskRemoteApi api,
    required TaskCache cache,
    required ConnectivityStatus connectivity,
  }) : _api = api,
       _cache = cache,
       _connectivity = connectivity;

  final TaskRemoteApi _api;
  final TaskCache _cache;
  final ConnectivityStatus _connectivity;
  bool lastLoadUsedCache = false;

  Future<List<Task>> loadTasks(int userId) async {
    final snapshot = await _cache.read(userId) ?? _emptySnapshot();
    lastLoadUsedCache = false;
    if (await _connectivity.isOnline) {
      try {
        final remote = await _api.getTasks(userId);
        final merged = _merge(remote, snapshot);
        await _cache.write(userId, snapshot.copyWith(tasks: merged));
        return merged;
      } on DioException {
        // A failed request falls back to the latest local snapshot.
        lastLoadUsedCache = true;
      }
    } else {
      lastLoadUsedCache = true;
    }
    if (snapshot.tasks.isNotEmpty) return snapshot.tasks;
    final sample = _sampleTasks(userId);
    await _cache.write(userId, snapshot.copyWith(tasks: sample));
    return sample;
  }

  Future<List<Task>> createTask(
    int userId,
    List<Task> currentTasks,
    String title,
  ) async {
    final task = Task(
      id: -DateTime.now().microsecondsSinceEpoch,
      userId: userId,
      title: title,
      completed: false,
    );
    if (await _connectivity.isOnline) {
      try {
        await _api.createTask(task);
      } on DioException {
        // Keep the task in the local cache when the remote service is down.
      }
    }
    final next = [...currentTasks, task];
    await _saveMutation(userId, next, override: task);
    return next;
  }

  Future<List<Task>> updateTask(
    int userId,
    List<Task> currentTasks,
    Task changed,
  ) async {
    if (changed.id > 0 && await _connectivity.isOnline) {
      try {
        await _api.updateTask(changed);
      } on DioException {
        // Local edits remain available even when the fake API is unavailable.
      }
    }
    final next = currentTasks
        .map((task) => task.id == changed.id ? changed : task)
        .toList();
    await _saveMutation(userId, next, override: changed);
    return next;
  }

  Future<List<Task>> deleteTask(
    int userId,
    List<Task> currentTasks,
    int id,
  ) async {
    if (id > 0 && await _connectivity.isOnline) {
      try {
        await _api.deleteTask(id);
      } on DioException {
        // Preserve the deletion locally so it stays hidden after refresh.
      }
    }
    final next = currentTasks.where((task) => task.id != id).toList();
    final old = await _cache.read(userId) ?? _emptySnapshot();
    final overrides = Map<int, Task>.of(old.overrides)..remove(id);
    final deleted = Set<int>.of(old.deletedIds)..add(id);
    await _cache.write(
      userId,
      old.copyWith(tasks: next, overrides: overrides, deletedIds: deleted),
    );
    return next;
  }

  Future<void> _saveMutation(
    int userId,
    List<Task> tasks, {
    required Task override,
  }) async {
    final old = await _cache.read(userId) ?? _emptySnapshot();
    final overrides = Map<int, Task>.of(old.overrides)
      ..[override.id] = override;
    final deleted = Set<int>.of(old.deletedIds)..remove(override.id);
    await _cache.write(
      userId,
      old.copyWith(tasks: tasks, overrides: overrides, deletedIds: deleted),
    );
  }

  List<Task> _merge(List<Task> remote, TaskCacheSnapshot snapshot) {
    // JSONPlaceholder fakes writes, so cached edits and delete markers win.
    final merged = <int, Task>{for (final task in remote) task.id: task};
    for (final task in snapshot.overrides.values) {
      merged[task.id] = task;
    }
    for (final id in snapshot.deletedIds) {
      merged.remove(id);
    }
    return merged.values.toList()..sort((a, b) => a.id.compareTo(b.id));
  }

  TaskCacheSnapshot _emptySnapshot() => TaskCacheSnapshot(
    tasks: const [],
    overrides: const {},
    deletedIds: const {},
  );

  List<Task> _sampleTasks(int userId) => [
    Task(
      id: -1,
      userId: userId,
      title: 'Переглянути список завдань',
      completed: false,
    ),
    Task(
      id: -2,
      userId: userId,
      title: 'Додати перше власне завдання',
      completed: true,
    ),
    Task(
      id: -3,
      userId: userId,
      title: 'Перевірити offline-кеш',
      completed: false,
    ),
  ];
}
