import 'package:flutter_test/flutter_test.dart';
import 'package:pr11_3/core/storage/cache_service.dart';
import 'package:pr11_3/core/storage/connectivity_service.dart';
import 'package:pr11_3/features/tasks/data/task_api.dart';
import 'package:pr11_3/features/tasks/data/task_repository.dart';
import 'package:pr11_3/features/tasks/domain/task.dart';
import 'package:pr11_3/features/tasks/presentation/task_controller.dart';

void main() {
  group('Task model and manager', () {
    test('parses and serializes JSONPlaceholder task fields', () {
      final task = Task.fromJson({
        'id': 7,
        'userId': 2,
        'title': 'Read the assignment',
        'completed': true,
      });

      expect(task.userId, 2);
      expect(task.completed, isTrue);
      expect(task.toJson()['title'], 'Read the assignment');
    });

    test(
      'loads offline sample, filters, creates, updates and removes tasks',
      () async {
        final remote = _FakeTaskApi();
        final connectivity = _FakeConnectivity(false);
        final cache = _MemoryTaskCache();
        final repository = TaskRepository(
          api: remote,
          cache: cache,
          connectivity: connectivity,
        );
        final controller = TaskController(
          repository: repository,
          connectivity: connectivity,
        );
        addTearDown(controller.dispose);

        await controller.loadForUser(1);
        expect(controller.tasks, hasLength(3));
        expect(controller.isOffline, isTrue);

        controller.setFilter(TaskFilter.active);
        expect(
          controller.visibleTasks.every((task) => !task.completed),
          isTrue,
        );
        controller.setFilter(TaskFilter.all);

        await controller.addTask('Prepare presentation');
        expect(controller.tasks, hasLength(4));
        final added = controller.tasks.last;
        await controller.toggleTask(added);
        expect(controller.tasks.last.completed, isTrue);
        await controller.deleteTask(added.id);
        expect(controller.tasks, hasLength(3));
        expect(remote.getCalls, 0);
      },
    );

    test('merges cached edits and deletions with remote tasks', () async {
      final edited = const Task(
        id: 1,
        userId: 1,
        title: 'Locally edited title',
        completed: true,
      );
      final local = const Task(
        id: -50,
        userId: 1,
        title: 'Created offline',
        completed: false,
      );
      final cache = _MemoryTaskCache(
        initial: TaskCacheSnapshot(
          tasks: [edited, local],
          overrides: {1: edited, -50: local},
          deletedIds: {2},
        ),
      );
      final remote = _FakeTaskApi()
        ..tasks = const [
          Task(id: 1, userId: 1, title: 'Server title', completed: false),
          Task(id: 2, userId: 1, title: 'Deleted locally', completed: false),
          Task(id: 3, userId: 1, title: 'Remote task', completed: false),
        ];
      final repository = TaskRepository(
        api: remote,
        cache: cache,
        connectivity: _FakeConnectivity(true),
      );

      final tasks = await repository.loadTasks(1);

      expect(tasks.map((task) => task.id), [-50, 1, 3]);
      expect(
        tasks.firstWhere((task) => task.id == 1).title,
        'Locally edited title',
      );
      expect(tasks.any((task) => task.id == 2), isFalse);
      expect(repository.lastLoadUsedCache, isFalse);
    });
  });
}

class _FakeConnectivity implements ConnectivityStatus {
  const _FakeConnectivity(this.online);

  final bool online;

  @override
  Future<bool> get isOnline async => online;

  @override
  Stream<bool> get changes => const Stream<bool>.empty();
}

class _MemoryTaskCache implements TaskCache {
  _MemoryTaskCache({TaskCacheSnapshot? initial}) {
    if (initial != null) _snapshots[1] = initial;
  }

  final Map<int, TaskCacheSnapshot> _snapshots = {};

  @override
  Future<TaskCacheSnapshot?> read(int userId) async => _snapshots[userId];

  @override
  Future<void> write(int userId, TaskCacheSnapshot snapshot) async {
    _snapshots[userId] = snapshot;
  }
}

class _FakeTaskApi implements TaskRemoteApi {
  List<Task> tasks = [];
  int getCalls = 0;

  @override
  Future<List<Task>> getTasks(int userId) async {
    getCalls++;
    return tasks;
  }

  @override
  Future<void> createTask(Task task) async {}

  @override
  Future<void> updateTask(Task task) async {}

  @override
  Future<void> deleteTask(int id) async {}
}
