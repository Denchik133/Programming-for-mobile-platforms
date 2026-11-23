import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = auth.profile;
    return Listener(
      onPointerDown: (_) => auth.recordActivity(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Захищений профіль'),
          actions: [
            IconButton(
              tooltip: 'Вийти',
              onPressed: auth.isBusy ? null : auth.logout,
              icon: const Icon(Icons.logout),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 34,
                            child: Icon(Icons.person, size: 34),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            profile?.name ?? 'Профіль',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(profile?.email ?? ''),
                          const SizedBox(height: 10),
                          Chip(
                            avatar: const Icon(
                              Icons.verified_user_outlined,
                              size: 18,
                            ),
                            label: Text('ID: ${profile?.id ?? '—'}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: profile == null || auth.isBusy
                        ? null
                        : () => _showEditProfile(context, profile),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Редагувати профіль'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    onPressed: auth.isBusy
                        ? null
                        : () => _showChangePassword(context),
                    icon: const Icon(Icons.password_outlined),
                    label: const Text('Змінити пароль'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: auth.isBusy
                        ? null
                        : () => _demonstrateRefresh(context),
                    icon: const Icon(Icons.autorenew),
                    label: const Text('Перевірити оновлення JWT'),
                  ),
                  if (auth.isBusy) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                  if (auth.errorMessage case final message?) ...[
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Демо API: усі Dio-запити обробляє локальний mock-сервер. '
                        'Кнопка оновлення нижче навмисно повертає 401, щоб показати '
                        'автоматичний refresh і повтор захищеного запиту.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _demonstrateRefresh(BuildContext context) async {
    final auth = context.read<AuthController>();
    final succeeded = await auth.demonstrateRefresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          succeeded
              ? 'Отримано 401: токен оновлено, запит повторено.'
              : auth.errorMessage ?? 'Не вдалося оновити токен.',
        ),
      ),
    );
  }

  Future<void> _showEditProfile(
    BuildContext context,
    UserProfile profile,
  ) async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => _EditProfileDialog(profile: profile),
    );
    if (result == null || !context.mounted) return;
    final auth = context.read<AuthController>();
    final succeeded = await auth.updateProfile(
      name: result.$1,
      email: result.$2,
    );
    if (!context.mounted) return;
    _showResult(context, succeeded, 'Профіль оновлено.');
  }

  Future<void> _showChangePassword(BuildContext context) async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
    if (result == null || !context.mounted) return;
    final auth = context.read<AuthController>();
    final succeeded = await auth.changePassword(
      currentPassword: result.$1,
      newPassword: result.$2,
    );
    if (!context.mounted) return;
    _showResult(context, succeeded, 'Пароль змінено.');
  }

  void _showResult(
    BuildContext context,
    bool succeeded,
    String successMessage,
  ) {
    final auth = context.read<AuthController>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          succeeded ? successMessage : auth.errorMessage ?? 'Помилка запиту.',
        ),
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.profile});

  final UserProfile profile;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _email = TextEditingController(text: widget.profile.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Редагувати профіль'),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Ім’я'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Введіть ім’я.' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) =>
                value == null ||
                    !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                        .hasMatch(value.trim())
                ? 'Введіть коректний email.'
                : null,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Скасувати'),
      ),
      FilledButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context, (_name.text.trim(), _email.text.trim()));
          }
        },
        child: const Text('Зберегти'),
      ),
    ],
  );
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Змінити пароль'),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _current,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Поточний пароль'),
            validator: (value) => value == null || value.isEmpty
                ? 'Введіть поточний пароль.'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _next,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Новий пароль'),
            validator: (value) => value == null || value.length < 8
                ? 'Мінімум 8 символів.'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirm,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Підтвердіть пароль'),
            validator: (value) =>
                value != _next.text ? 'Паролі не збігаються.' : null,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Скасувати'),
      ),
      FilledButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context, (_current.text, _next.text));
          }
        },
        child: const Text('Змінити'),
      ),
    ],
  );
}
