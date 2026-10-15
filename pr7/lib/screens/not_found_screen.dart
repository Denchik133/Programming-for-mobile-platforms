import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сторінку не знайдено')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 72),
            const SizedBox(height: 16),
            const Text('Такої сторінки не існує'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/catalog'),
              child: const Text('До каталогу'),
            ),
          ],
        ),
      ),
    );
  }
}