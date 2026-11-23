import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MaterialBanner(
    content: const Text(
      'Немає мережі: показано кешовані або локальні завдання.',
    ),
    leading: const Icon(Icons.cloud_off_outlined),
    actions: [TextButton(onPressed: onRetry, child: const Text('Оновити'))],
  );
}
