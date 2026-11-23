import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isRegistering = false;
  bool _rememberMe = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthController auth) async {
    if (!_formKey.currentState!.validate()) return;
    final succeeded = _isRegistering
        ? await auth.register(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          )
        : await auth.login(
            email: _emailController.text,
            password: _passwordController.text,
            rememberMe: _rememberMe,
          );
    if (succeeded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isRegistering ? 'Обліковий запис створено.' : 'Вхід виконано.',
          ),
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Введіть коректну адресу email.';
    }
    return null;
  }

  String? _validatePassword(String? value) => value == null || value.length < 8
      ? 'Пароль має містити щонайменше 8 символів.'
      : null;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.lock_person_outlined, size: 44),
                        const SizedBox(height: 12),
                        Text(
                          _isRegistering
                              ? 'Створення акаунта'
                              : 'Вхід до акаунта',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Демонстраційна JWT-авторизація',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        if (_isRegistering) ...[
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Ім’я',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Введіть ім’я.'
                                : null,
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: _isRegistering
                              ? TextInputAction.next
                              : TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Пароль',
                            prefixIcon: const Icon(Icons.key_outlined),
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Показати пароль'
                                  : 'Сховати пароль',
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: _validatePassword,
                        ),
                        if (_isRegistering) ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirmController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Підтвердження пароля',
                              prefixIcon: Icon(Icons.verified_user_outlined),
                            ),
                            validator: (value) =>
                                value != _passwordController.text
                                ? 'Паролі не збігаються.'
                                : null,
                          ),
                        ] else ...[
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _rememberMe,
                            onChanged: (value) =>
                                setState(() => _rememberMe = value ?? false),
                            title: const Text('Запам’ятати мене'),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ],
                        if (auth.errorMessage case final message?) ...[
                          const SizedBox(height: 8),
                          Text(
                            message,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: auth.isBusy ? null : () => _submit(auth),
                          icon: auth.isBusy
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  _isRegistering
                                      ? Icons.person_add_alt
                                      : Icons.login,
                                ),
                          label: Text(
                            auth.isBusy
                                ? 'Зачекайте…'
                                : _isRegistering
                                ? 'Зареєструватися'
                                : 'Увійти',
                          ),
                        ),
                        TextButton(
                          onPressed: auth.isBusy
                              ? null
                              : () => setState(() {
                                  _isRegistering = !_isRegistering;
                                  auth.clearError();
                                }),
                          child: Text(
                            _isRegistering
                                ? 'Вже маєте акаунт? Увійти'
                                : 'Немає акаунта? Зареєструватися',
                          ),
                        ),
                        if (!_isRegistering) ...[
                          const Divider(height: 24),
                          const Text(
                            'Демо-доступ: demo@pr11.local · Flutter123',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
