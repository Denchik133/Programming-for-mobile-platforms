import 'package:flutter/material.dart';

import 'data/contact_repository.dart';
import 'data/sqlite_contact_repository.dart';
import 'ui/contacts_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ContactApp(repositoryFuture: SqliteContactRepository.open()));
}

class ContactApp extends StatelessWidget {
  const ContactApp({super.key, required this.repositoryFuture});

  final Future<ContactRepository> repositoryFuture;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Контакти з перевіркою даних',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B62),
          surface: const Color(0xFFF7F8F5),
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: FutureBuilder<ContactRepository>(
        future: repositoryFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _StartupError(error: snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return ContactsScreen(repository: snapshot.data!);
        },
      ),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storage_rounded, size: 44),
              const SizedBox(height: 12),
              const Text(
                'Не вдалося відкрити базу даних',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
