import 'package:flutter/material.dart';

import '../state/counter_scope.dart';

class HistoryBadge extends StatelessWidget {
  const HistoryBadge({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('build: HistoryBadge');

    final count = CounterScope.of(context).historyCount;

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
