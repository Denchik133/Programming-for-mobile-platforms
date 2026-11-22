import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../models/user.dart';

class TodoFormResult {
  const TodoFormResult({
    required this.title,
    required this.userId,
    required this.completed,
  });

  final String title;
  final int userId;
  final bool completed;
}

class TodoFormScreen extends StatefulWidget {
  const TodoFormScreen({super.key, required this.users, this.todo});

  final List<User> users;
  final Todo? todo;

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  int? _userId;
  bool _completed = false;

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _userId =
        widget.todo?.userId ??
        (widget.users.isEmpty ? null : widget.users.first.id);
    _completed = widget.todo?.completed ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _userId == null) return;
    Navigator.of(context).pop(
      TodoFormResult(
        title: _titleController.text.trim(),
        userId: _userId!,
        completed: _completed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редагувати завдання' : 'Нове завдання'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextFormField(
                    controller: _titleController,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Назва завдання',
                      hintText: 'Наприклад, підготувати звіт',
                      prefixIcon: Icon(Icons.edit_note_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Введіть назву завдання.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  if (!_isEditing) ...[
                    DropdownButtonFormField<int>(
                      initialValue: _userId,
                      decoration: const InputDecoration(
                        labelText: 'Користувач',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                      items: widget.users
                          .map(
                            (user) => DropdownMenuItem<int>(
                              value: user.id,
                              child: Text(user.name),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) => setState(() => _userId = value),
                      validator: (value) =>
                          value == null ? 'Оберіть користувача.' : null,
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _completed,
                      onChanged: (value) =>
                          setState(() => _completed = value ?? false),
                      title: const Text('Завдання вже виконано'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ] else
                    const Text(
                      'Статус завдання можна змінити перемикачем у списку.',
                    ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_isEditing ? 'Зберегти зміни' : 'Створити'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
