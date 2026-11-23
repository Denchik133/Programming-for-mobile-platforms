// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/storage/connectivity_service.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';

enum TaskFilter { all, active, completed }

class TaskController extends ChangeNotifier {
  TaskController({
    required TaskRepository repository,
    required ConnectivityStatus connectivity,
  }) : _repository = repository,
       _connectivity = connectivity {
    _networkSubscription = _connectivity.changes.listen((online) {
      isOffline = !online;
      notifyListeners();
      if (online && _userId != null) unawaited(refresh());
    });
  }

  final TaskRepository _repository;
  final ConnectivityStatus _connectivity;
  late final StreamSubscription<bool> _networkSubscription;

  List<Task> tasks = [];
  int? _userId;
  bool isLoading = false;
  bool isOffline = false;
  TaskFilter filter = TaskFilter.all;
  String query = '';
  String? errorMessage;

  List<Task> get visibleTasks {
    final normalizedQuery = query.trim().toLowerCase();
    return tasks.where((task) {
      final matchesFilter = switch (filter) {
        TaskFilter.all => true,
        TaskFilter.active => !task.completed,
        TaskFilter.completed => task.completed,
      };
      return matchesFilter &&
          task.title.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  int get completedCount => tasks.where((task) => task.completed).length;
  int get activeCount => tasks.length - completedCount;

  Future<void> loadForUser(int userId) async {
    if (_userId == userId && tasks.isNotEmpty) return;
    _userId = userId;
    await refresh();
  }

  Future<void> refresh() async {
    final userId = _userId;
    if (userId == null) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      tasks = await _repository.loadTasks(userId);
      isOffline = _repository.lastLoadUsedCache;
    } on Object catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(TaskFilter value) {
    filter = value;
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    final userId = _userId;
    if (userId == null) return;
    tasks = await _repository.createTask(userId, tasks, title.trim());
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final userId = _userId;
    if (userId == null) return;
    tasks = await _repository.updateTask(userId, tasks, task);
    notifyListeners();
  }

  Future<void> toggleTask(Task task) =>
      updateTask(task.copyWith(completed: !task.completed));

  Future<void> deleteTask(int id) async {
    final userId = _userId;
    if (userId == null) return;
    tasks = await _repository.deleteTask(userId, tasks, id);
    notifyListeners();
  }

  void clearCurrentUser() {
    _userId = null;
    tasks = [];
    query = '';
    filter = TaskFilter.all;
    notifyListeners();
  }

  @override
  void dispose() {
    _networkSubscription.cancel();
    super.dispose();
  }
}
