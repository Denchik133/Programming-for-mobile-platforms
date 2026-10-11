import 'package:flutter/foundation.dart';

import '../models/history_entry.dart';

class CounterState extends ChangeNotifier {
  int _value = 0;
  final List<HistoryEntry> _history = [];

  int get value => _value;

  List<HistoryEntry> get history => List.unmodifiable(_history);

  int get historyCount => _history.length;

  void changeValue({
    required int newValue,
    required String action,
  }) {
    if (newValue < 0) {
      return;
    }

    _history.insert(
      0,
      HistoryEntry(
        timestamp: DateTime.now(),
        action: action,
        valueBefore: _value,
        valueAfter: newValue,
      ),
    );

    _value = newValue;
    notifyListeners();
  }

  void clearHistory() {
    if (_history.isEmpty) {
      return;
    }

    _history.clear();
    notifyListeners();
  }
}
