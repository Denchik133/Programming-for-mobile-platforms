import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/preferences_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
  });

  final ValueChanged<String> onThemeChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late PreferencesManager _manager;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();

  String _theme = 'system';
  String _language = 'Українська';
  double _fontSize = 16;
  bool _compactMode = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _sounds = true;
  int _reminderFrequency = 1;

  List<String> _categories = ['Навчання', 'Робота'];
  bool _loading = true;

  final List<String> _availableCategories = [
    'Навчання',
    'Робота',
    'Спорт',
    'Музика',
    'Подорожі',
    'Технології',
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _manager = await PreferencesManager.getInstance();
      final data = _manager.getAll();

      _nameController.text = data['name'] as String;
      _emailController.text = data['email'] as String;
      _ageController.text = (data['age'] as int).toString();

      setState(() {
        _theme = data['theme'] as String;
        _fontSize = (data['fontSize'] as num).toDouble();
        _language = data['language'] as String;
        _compactMode = data['compactMode'] as bool;
        _pushNotifications = data['pushNotifications'] as bool;
        _emailNotifications = data['emailNotifications'] as bool;
        _sounds = data['sounds'] as bool;
        _reminderFrequency = data['reminderFrequency'] as int;
        _categories =
            List<String>.from(data['favoriteCategories'] as List);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);
      _showMessage('Помилка завантаження: $e');
    }
  }
  
  Future<void> _save(String key, dynamic value) async {
    if (_loading) return;
    
    try {
      await _manager.saveValue(key, value);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Помилка збереження: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _reset() async {
    try {
      await _manager.resetToDefaults();

      if (!mounted) return;

      _nameController.text = '';
      _emailController.text = '';
      _ageController.text = '18';

      setState(() {
        _theme = 'system';
        _fontSize = 16;
        _language = 'Українська';
        _compactMode = false;
        _pushNotifications = true;
        _emailNotifications = true;
        _sounds = true;
        _reminderFrequency = 1;
        _categories = [];
      });

      _showMessage('Налаштування скинуто');
    } catch (e) {
      _showMessage('Помилка скидання: $e');
    }
  }

  void _export() {
    try {
      final json = _manager.exportToJson();

      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Експорт налаштувань'),
          content: SingleChildScrollView(
            child: SelectableText(
              const JsonEncoder.withIndent('  ')
                  .convert(jsonDecode(json)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрити'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showMessage('Помилка експорту: $e');
    }
  }

  Future<void> _editCategories() async {
    final selected = Set<String>.from(_categories);

    final result = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Улюблені категорії'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              children: _availableCategories.map((category) {
                return FilterChip(
                  label: Text(category),
                  selected: selected.contains(category),
                  onSelected: (value) {
                    setDialogState(() {
                      if (value) {
                        selected.add(category);
                      } else {
                        selected.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Скасувати'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, selected.toList()),
              child: const Text('Зберегти'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() => _categories = result);
      await _save('favoriteCategories', _categories);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: _fontSize / 16,
            ),
        visualDensity: _compactMode
            ? VisualDensity.compact
            : VisualDensity.standard,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Мої налаштування'),
          actions: [
            IconButton(
              tooltip: 'Експортувати JSON',
              onPressed: _export,
              icon: const Icon(Icons.code),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Профіль', Icons.person),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Ім'я",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _save('name', value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _save('email', value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Вік',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final age = int.tryParse(value);
                if (age != null && age >= 1 && age <= 120) {
                  _save('age', age);
                }
              },
            ),
            const SizedBox(height: 24),
            _sectionTitle('Вигляд', Icons.palette),
            const Text('Тема'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'light',
                  label: Text('Світла'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: 'dark',
                  label: Text('Темна'),
                  icon: Icon(Icons.dark_mode),
                ),
                ButtonSegment(
                  value: 'system',
                  label: Text('Системна'),
                  icon: Icon(Icons.settings_brightness),
                ),
              ],
              selected: {_theme},
              onSelectionChanged: (values) async {
                final theme = values.first;
                setState(() => _theme = theme);
                widget.onThemeChanged(theme);
                await _save('theme', theme);
              },
            ),
            const SizedBox(height: 16),
            Text('Розмір шрифту: ${_fontSize.round()}'),
            Slider(
              min: 12,
              max: 24,
              divisions: 12,
              value: _fontSize,
              label: _fontSize.round().toString(),
              onChanged: (value) {
                setState(() => _fontSize = value);
                _save('fontSize', value);
              },
            ),
            DropdownButtonFormField<String>(
              initialValue: _language,
              decoration: const InputDecoration(
                labelText: 'Мова',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Українська',
                  child: Text('Українська'),
                ),
                DropdownMenuItem(
                  value: 'English',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'Polski',
                  child: Text('Polski'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _language = value);
                _save('language', value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Компактний режим'),
              value: _compactMode,
              onChanged: (value) {
                setState(() => _compactMode = value);
                _save('compactMode', value);
              },
            ),
            const SizedBox(height: 24),
            _sectionTitle('Сповіщення', Icons.notifications),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Push-сповіщення'),
              value: _pushNotifications,
              onChanged: (value) {
                setState(() => _pushNotifications = value);
                _save('pushNotifications', value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Email-сповіщення'),
              value: _emailNotifications,
              onChanged: (value) {
                setState(() => _emailNotifications = value);
                _save('emailNotifications', value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Звуки'),
              value: _sounds,
              onChanged: (value) {
                setState(() => _sounds = value);
                _save('sounds', value);
              },
            ),
            DropdownButtonFormField<int>(
              initialValue: _reminderFrequency,
              decoration: const InputDecoration(
                labelText: 'Частота нагадувань',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Щодня')),
                DropdownMenuItem(value: 2, child: Text('Щотижня')),
                DropdownMenuItem(value: 3, child: Text('Щомісяця')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _reminderFrequency = value);
                _save('reminderFrequency', value);
              },
            ),
            const SizedBox(height: 24),
            _sectionTitle('Улюблені категорії', Icons.category),
            Wrap(
              spacing: 8,
              children: _categories
                  .map((category) => Chip(label: Text(category)))
                  .toList(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _editCategories,
                icon: const Icon(Icons.edit),
                label: const Text('Змінити категорії'),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.restore),
              label: const Text('Скинути до типових'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _export,
              icon: const Icon(Icons.data_object),
              label: const Text('Експортувати налаштування'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}