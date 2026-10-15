import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _cardController = TextEditingController();

  String _savedName = '';
  String _savedCard = '';
  bool _hasSavedProfile = false;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_checkChanges);
    _cardController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final changed = _nameController.text != _savedName ||
        _cardController.text != _savedCard;

    if (changed != _isDirty) {
      setState(() => _isDirty = changed);
    }
  }

  Future<bool> _confirmExit() async {
    if (!_isDirty) return true;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Незбережені зміни'),
        content: const Text(
          'Ви справді хочете вийти без збереження змін?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Залишитися'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Вийти'),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  Future<void> _leaveForm() async {
    if (_isDirty) {
      final confirmed = await _confirmExit();

      if (!confirmed || !mounted) return;
    }

    if (!mounted) return;

    setState(() {
      _nameController.text = _savedName;
      _cardController.text = _savedCard;
      _isDirty = false;
    });

    context.go('/catalog');
  }

  void _saveProfile() {
    setState(() {
      _savedName = _nameController.text.trim();
      _savedCard = _cardController.text.trim();
      _nameController.text = _savedName;
      _cardController.text = _savedCard;
      _hasSavedProfile = true;
      _isDirty = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Профіль збережено')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !mounted) return;

        final confirmed = await _confirmExit();

        if (confirmed && mounted) {
          setState(() {
            _nameController.text = _savedName;
            _cardController.text = _savedCard;
            _isDirty = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Профіль читача'),
          actions: [
            IconButton(
              tooltip: 'Вийти з форми',
              onPressed: _leaveForm,
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CircleAvatar(
                radius: 42,
                child: Icon(Icons.person, size: 48),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ім’я читача',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cardController,
                decoration: const InputDecoration(
                  labelText: 'Номер читацького квитка',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Зберегти профіль'),
              ),
              if (_hasSavedProfile) ...[
                const SizedBox(height: 24),
                const Text(
                  'Збережені дані',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Ім’я: $_savedName'),
                Text('Читацький квиток: $_savedCard'),
              ],
              const SizedBox(height: 24),
              if (authModel.isLoggedIn)
                OutlinedButton(
                  onPressed: () {
                    authModel.logout();
                    context.go('/profile');
                  },
                  child: const Text('Вийти з акаунта'),
                )
              else
                OutlinedButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Увійти до бібліотеки'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}