import 'dart:async';

import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'todo_form_screen.dart';

enum TodoFilter { all, completed, pending }

class _InitialData {
  const _InitialData({required this.todos, required this.users});

  final List<Todo> todos;
  final List<User> users;
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key, required this.api});

  final ApiService api;

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<_InitialData> _initialFuture;
  List<Todo>? _todos;
  String _search = '';
  int? _selectedUserId;
  TodoFilter _filter = TodoFilter.all;
  int _nextLocalId = 100000;
  bool _loadingUserTasks = false;

  @override
  void initState() {
    super.initState();
    _initialFuture = _loadInitialData();
  }

  Future<_InitialData> _loadInitialData() async {
    final results = await Future.wait([
      widget.api.getTodos(),
      widget.api.getUsers(),
    ]);
    return _InitialData(
      todos: results[0] as List<Todo>,
      users: results[1] as List<User>,
    );
  }

  void _retry() {
    setState(() {
      _todos = null;
      _selectedUserId = null;
      _initialFuture = _loadInitialData();
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _todos = null;
      _initialFuture = _loadInitialData();
    });
    try {
      await _initialFuture;
    } on ApiException {
      // FutureBuilder renders the error state with a retry button.
    }
  }

  Future<void> _selectUser(int? userId) async {
    final previousUserId = _selectedUserId;
    setState(() {
      _selectedUserId = userId;
      _loadingUserTasks = true;
    });
    try {
      final todos = await widget.api.getTodos(userId: userId);
      if (!mounted) return;
      setState(() => _todos = todos);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _selectedUserId = previousUserId);
      _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _loadingUserTasks = false);
    }
  }

  List<Todo> _currentTodos(_InitialData data) =>
      List<Todo>.of(_todos ?? data.todos);

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createTodo(_InitialData data) async {
    final result = await Navigator.of(context).push<TodoFormResult>(
      MaterialPageRoute(builder: (_) => TodoFormScreen(users: data.users)),
    );
    if (result == null) return;

    final draft = Todo(
      id: 0,
      userId: result.userId,
      title: result.title,
      completed: result.completed,
    );
    try {
      await widget.api.createTodo(draft);
      if (!mounted) return;
      final created = draft.copyWith(id: _nextLocalId++, locallyCreated: true);
      setState(() => _todos = [created, ..._currentTodos(data)]);
      _showMessage('Завдання додано до списку.');
    } on ApiException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _editTodo(Todo todo, _InitialData data) async {
    final result = await Navigator.of(context).push<TodoFormResult>(
      MaterialPageRoute(
        builder: (_) => TodoFormScreen(users: data.users, todo: todo),
      ),
    );
    if (result == null) return;

    final draft = todo.copyWith(title: result.title, userId: result.userId);
    try {
      final updated = todo.locallyCreated
          ? draft
          : await widget.api.updateTodo(draft);
      if (!mounted) return;
      setState(() {
        _todos = _currentTodos(data)
            .map(
              (item) =>
                  item.id == todo.id ? updated.copyWith(id: todo.id) : item,
            )
            .toList(growable: false);
      });
      _showMessage('Завдання оновлено.');
    } on ApiException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _setCompleted(
    Todo todo,
    bool completed,
    _InitialData data,
  ) async {
    try {
      final updated = todo.locallyCreated
          ? todo.copyWith(completed: completed)
          : await widget.api.updateCompleted(todo.id, completed);
      if (!mounted) return;
      setState(() {
        _todos = _currentTodos(data)
            .map(
              (item) =>
                  item.id == todo.id ? updated.copyWith(id: todo.id) : item,
            )
            .toList(growable: false);
      });
    } on ApiException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<bool> _confirmDelete(Todo todo) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Видалити завдання?'),
          content: Text('«${todo.title}» буде прибрано зі списку.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Скасувати'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Видалити'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _deleteTodo(Todo todo, _InitialData data) async {
    final beforeDelete = _currentTodos(data);
    final index = beforeDelete.indexWhere((item) => item.id == todo.id);
    setState(() {
      _todos = beforeDelete.where((item) => item.id != todo.id).toList();
    });

    try {
      if (!todo.locallyCreated) await widget.api.deleteTodo(todo.id);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          final restored = _currentTodos(data);
          restored.insert(index.clamp(0, restored.length), todo);
          _todos = restored;
        });
        _showMessage(error.message);
      }
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Завдання видалено.'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Скасувати',
            onPressed: () {
              setState(() {
                final restored = _currentTodos(data);
                restored.insert(index.clamp(0, restored.length), todo);
                _todos = restored;
              });
            },
          ),
        ),
      );
  }

  List<Todo> _filterTodos(List<Todo> todos) {
    return todos
        .where((todo) {
          final matchesFilter = switch (_filter) {
            TodoFilter.all => true,
            TodoFilter.completed => todo.completed,
            TodoFilter.pending => !todo.completed,
          };
          final matchesUser =
              _selectedUserId == null || todo.userId == _selectedUserId;
          final matchesSearch = todo.title.toLowerCase().contains(
            _search.toLowerCase(),
          );
          return matchesFilter && matchesUser && matchesSearch;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мій список завдань'),
        actions: [
          IconButton(
            tooltip: 'Оновити список',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FutureBuilder<_InitialData>(
        future: _initialFuture,
        builder: (context, snapshot) => snapshot.hasData
            ? FloatingActionButton.extended(
                onPressed: () => _createTodo(snapshot.data!),
                icon: const Icon(Icons.add),
                label: const Text('Нове завдання'),
              )
            : const SizedBox.shrink(),
      ),
      body: FutureBuilder<_InitialData>(
        future: _initialFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            return _ErrorState(
              message: error is ApiException
                  ? error.message
                  : 'Не вдалося завантажити дані. Спробуйте ще раз.',
              onRetry: _retry,
            );
          }
          final data = snapshot.data!;
          final allTodos = _todos ?? data.todos;
          final summaryTodos = _selectedUserId == null
              ? allTodos
              : allTodos
                    .where((todo) => todo.userId == _selectedUserId)
                    .toList();
          final visibleTodos = _filterTodos(allTodos);
          final usersById = {for (final user in data.users) user.id: user};
          final groups = <int, List<Todo>>{};
          for (final todo in visibleTodos) {
            groups.putIfAbsent(todo.userId, () => []).add(todo);
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _ProgressCard(todos: summaryTodos),
                if (_loadingUserTasks) const LinearProgressIndicator(),
                const SizedBox(height: 14),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Пошук за назвою',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Очистити пошук',
                            onPressed: () => setState(() => _search = ''),
                            icon: const Icon(Icons.close),
                          ),
                    filled: true,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _search = value.trim()),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _filterChip(TodoFilter.all, 'Усі'),
                    _filterChip(TodoFilter.completed, 'Виконані'),
                    _filterChip(TodoFilter.pending, 'Очікують'),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int?>(
                  initialValue: _selectedUserId,
                  decoration: const InputDecoration(
                    labelText: 'Фільтр за користувачем',
                    prefixIcon: Icon(Icons.person_search_outlined),
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Усі користувачі'),
                    ),
                    ...data.users.map(
                      (user) => DropdownMenuItem<int?>(
                        value: user.id,
                        child: Text(user.name),
                      ),
                    ),
                  ],
                  onChanged: _selectUser,
                ),
                const SizedBox(height: 18),
                Text(
                  'Завдання за користувачами',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (visibleTodos.isEmpty)
                  const _EmptyState()
                else
                  for (final entry in groups.entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                      child: Text(
                        usersById[entry.key]?.name ?? 'Користувач ${entry.key}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    for (final todo in entry.value)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Dismissible(
                          key: ValueKey('todo-${todo.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .errorContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete_outline),
                          ),
                          confirmDismiss: (_) => _confirmDelete(todo),
                          onDismissed: (_) =>
                              unawaited(_deleteTodo(todo, data)),
                          child: _TodoCard(
                            todo: todo,
                            onToggle: (value) =>
                                _setCompleted(todo, value, data),
                            onEdit: () => _editTodo(todo, data),
                          ),
                        ),
                      ),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterChip(TodoFilter filter, String label) => ChoiceChip(
    label: Text(label),
    selected: _filter == filter,
    onSelected: (_) => setState(() => _filter = filter),
  );
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.todos});

  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    final completed = todos.where((todo) => todo.completed).length;
    final fraction = todos.isEmpty ? 0.0 : completed / todos.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist_rounded),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Прогрес виконання',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text('$completed / ${todos.length}'),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: fraction, minHeight: 8),
            const SizedBox(height: 8),
            Text(
              '${(fraction * 100).round()}% виконано · ${todos.length - completed} очікують',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  const _TodoCard({
    required this.todo,
    required this.onToggle,
    required this.onEdit,
  });

  final Todo todo;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: (value) => onToggle(value ?? false),
        ),
        title: Text(
          todo.title,
          style: todo.completed
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Text('ID користувача: ${todo.userId}'),
        trailing: IconButton(
          tooltip: 'Редагувати завдання',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 36),
          SizedBox(height: 8),
          Text('За вибраними умовами завдань не знайдено.'),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Спробувати ще раз'),
          ),
        ],
      ),
    ),
  );
}
