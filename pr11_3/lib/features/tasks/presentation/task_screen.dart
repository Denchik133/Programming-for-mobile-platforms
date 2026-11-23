import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../domain/task.dart';
import 'task_controller.dart';
import 'task_form_dialog.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({required this.userId, required this.email, super.key});

  final int userId;
  final String email;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TaskController>().loadForUser(widget.userId);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Мої завдання'),
      actions: [
        IconButton(
          tooltip: 'Оновити список',
          onPressed: () => context.read<TaskController>().refresh(),
          icon: const Icon(Icons.refresh),
        ),
        PopupMenuButton<String>(
          tooltip: widget.email,
          onSelected: (value) async {
            if (value == 'logout') {
              context.read<TaskController>().clearCurrentUser();
              await context.read<AuthController>().logout();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'account',
              enabled: false,
              child: Text(widget.email),
            ),
            const PopupMenuItem(value: 'logout', child: Text('Вийти')),
          ],
        ),
      ],
    ),
    body: Consumer<TaskController>(
      builder: (context, controller, _) {
        return Column(
          children: [
            if (controller.isOffline)
              OfflineBanner(onRetry: controller.refresh),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Активні',
                          value: controller.activeCount,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'Виконані',
                          value: controller.completedCount,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'Усього',
                          value: controller.tasks.length,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _search,
                    onChanged: controller.setQuery,
                    decoration: InputDecoration(
                      hintText: 'Пошук за назвою',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Очистити пошук',
                              onPressed: () {
                                _search.clear();
                                controller.setQuery('');
                              },
                              icon: const Icon(Icons.clear),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<TaskFilter>(
                    segments: const [
                      ButtonSegment(value: TaskFilter.all, label: Text('Усі')),
                      ButtonSegment(
                        value: TaskFilter.active,
                        label: Text('Активні'),
                      ),
                      ButtonSegment(
                        value: TaskFilter.completed,
                        label: Text('Виконані'),
                      ),
                    ],
                    selected: {controller.filter},
                    onSelectionChanged: (selection) =>
                        controller.setFilter(selection.first),
                  ),
                ],
              ),
            ),
            if (controller.isLoading) const LinearProgressIndicator(),
            if (controller.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(controller.errorMessage!),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                child: controller.visibleTasks.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 80),
                          Icon(Icons.inbox_outlined, size: 48),
                          SizedBox(height: 12),
                          Center(child: Text('Завдань не знайдено')),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                        itemCount: controller.visibleTasks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (context, index) => _TaskTile(
                          task: controller.visibleTasks[index],
                          onToggle: controller.toggleTask,
                          onEdit: _editTask,
                          onDelete: controller.deleteTask,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addTask,
      icon: const Icon(Icons.add),
      label: const Text('Нове завдання'),
    ),
  );

  Future<void> _addTask() async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => const TaskFormDialog(),
    );
    if (title != null && mounted) {
      await context.read<TaskController>().addTask(title);
    }
  }

  Future<void> _editTask(Task task) async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => TaskFormDialog(task: task),
    );
    if (title != null && mounted) {
      await context.read<TaskController>().updateTask(
        task.copyWith(title: title),
      );
    }
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final ValueChanged<Task> onToggle;
  final ValueChanged<Task> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Checkbox(
        value: task.completed,
        onChanged: (_) => onToggle(task),
      ),
      title: Text(
        task.title,
        style: task.completed
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text('ID користувача: ${task.userId}'),
      onTap: () => onEdit(task),
      trailing: IconButton(
        tooltip: 'Видалити завдання',
        onPressed: () => onDelete(task.id),
        icon: const Icon(Icons.delete_outline),
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        children: [
          Text('$value', style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    ),
  );
}
