import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import '../state/counter_scope.dart';
import '../widgets/history_badge.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('build: HistoryScreen');

    final counterState = CounterScope.of(context);
    final history = counterState.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Історія змін'),
        actions: [
          const HistoryBadge(),
        ],
      ),
      body: history.isEmpty
          ? const Center(
              child: Text('Історія поки що порожня'),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final HistoryEntry entry = history[index];

                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.history),
                  ),
                  title: Text(entry.action),
                  subtitle: Text(
                    '${_formatDate(entry.timestamp)}\n'
                    '${entry.valueBefore} → ${entry.valueAfter}',
                  ),
                  isThreeLine: true,
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: OutlinedButton.icon(
          onPressed: history.isEmpty
              ? null
              : counterState.clearHistory,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Очистити історію'),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final date = '${dateTime.day.toString().padLeft(2, '0')}.'
        '${dateTime.month.toString().padLeft(2, '0')}.'
        '${dateTime.year}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';

    return '$date $time';
  }
}
