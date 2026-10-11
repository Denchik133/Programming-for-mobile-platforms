import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import '../widgets/history_badge.dart';

class HistoryScreen extends StatelessWidget {
  final List<HistoryEntry> history;
  final VoidCallback onClearHistory;

  const HistoryScreen({
    super.key,
    required this.history,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Історія змін'),
        actions: [
          HistoryBadge(count: history.length),
        ],
      ),
      body: history.isEmpty
          ? const Center(
              child: Text('Історія поки що порожня'),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];

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
              : () {
                  onClearHistory();
                },
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
