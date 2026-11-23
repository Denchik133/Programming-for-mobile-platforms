import 'package:flutter/material.dart';

import '../domain/task.dart';

class TaskFormDialog extends StatefulWidget {
  const TaskFormDialog({this.task, super.key});

  final Task? task;

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  late final TextEditingController _title = TextEditingController(
    text: widget.task?.title ?? '',
  );

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.task == null ? 'Нове завдання' : 'Редагування завдання'),
    content: TextField(
      controller: _title,
      autofocus: true,
      maxLength: 120,
      decoration: const InputDecoration(
        labelText: 'Назва',
        hintText: 'Наприклад, підготувати звіт',
      ),
      onSubmitted: (_) => _save(context),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Скасувати'),
      ),
      FilledButton(
        onPressed: () => _save(context),
        child: const Text('Зберегти'),
      ),
    ],
  );

  void _save(BuildContext context) {
    final value = _title.text.trim();
    if (value.isEmpty) return;
    Navigator.pop(context, value);
  }
}
