import 'package:flutter/material.dart';

class HistoryBadge extends StatelessWidget {
  final int count;

  const HistoryBadge({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('build: HistoryBadge');

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Center(
        child: Badge(
          label: Text('$count'),
          child: const Icon(Icons.history),
        ),
      ),
    );
  }
}
