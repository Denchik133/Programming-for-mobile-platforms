import 'package:flutter/material.dart';

import '../data/contact_repository.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key, required this.repository});

  final ContactRepository repository;

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late final ContactService _service;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  List<Contact> _contacts = const [];
  Map<String, String> _fieldErrors = const {};
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _service = ContactService(widget.repository);
    _loadContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final contacts = await _service.getContacts();
      if (!mounted) return;
      setState(() => _contacts = contacts);
    } on ContactStorageException catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveContact() async {
    setState(() {
      _saving = true;
      _fieldErrors = const {};
    });

    try {
      await _service.createContact(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );
      if (!mounted) return;
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      await _loadContacts();
      if (mounted) _showMessage('Контакт перевірено та збережено.');
    } on ContactValidationException catch (error) {
      if (mounted) setState(() => _fieldErrors = error.errors);
    } on ContactStorageException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteContact(Contact contact) async {
    final id = contact.id;
    if (id == null) return;
    try {
      await _service.deleteContact(id);
      await _loadContacts();
      if (mounted) _showMessage('Контакт видалено.');
    } on ContactStorageException catch (error) {
      if (mounted) _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Перевірка даних'),
        actions: [
          IconButton(
            tooltip: 'Оновити список',
            onPressed: _loading ? null : _loadContacts,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              const _IntroCard(),
              const SizedBox(height: 18),
              _buildFormCard(context),
              const SizedBox(height: 18),
              _buildContactsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Новий контакт',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Поля очищуються та перевіряються перед записом у SQLite.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Ім’я',
                hintText: 'Наприклад, Олена Коваль',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                errorText: _fieldErrors['name'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Електронна пошта',
                hintText: 'olena@example.com',
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                errorText: _fieldErrors['email'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Телефон',
                hintText: '+380 67 123 45 67',
                prefixIcon: const Icon(Icons.phone_outlined),
                errorText: _fieldErrors['phone'],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _saveContact,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.verified_outlined),
                label: Text(_saving ? 'Перевірка…' : 'Перевірити й зберегти'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Збережені контакти',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (!_loading && _loadError == null)
                  Chip(label: Text('${_contacts.length}')),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_loadError != null)
              _InlineMessage(
                icon: Icons.error_outline_rounded,
                message: _loadError!,
                action: TextButton(
                  onPressed: _loadContacts,
                  child: const Text('Спробувати ще раз'),
                ),
              )
            else if (_contacts.isEmpty)
              const _InlineMessage(
                icon: Icons.inbox_outlined,
                message: 'Тут з’являться контакти після успішної перевірки.',
              )
            else
              ..._contacts.map(_contactTile),
          ],
        ),
      ),
    );
  }

  Widget _contactTile(Contact contact) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Text(contact.name.substring(0, 1))),
      title: Text(contact.name),
      subtitle: Text('${contact.email}\n${contact.phone}'),
      isThreeLine: true,
      trailing: IconButton(
        tooltip: 'Видалити контакт',
        onPressed: () => _deleteContact(contact),
        icon: const Icon(Icons.delete_outline_rounded),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: colors.onPrimaryContainer,
            size: 30,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Валідація перед збереженням',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Очищення вводу → перевірка полів → SQLite. Некоректні дані не потрапляють до бази.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: colors.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          ?action,
        ],
      ),
    );
  }
}
