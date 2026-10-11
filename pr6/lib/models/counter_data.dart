import 'history_entry.dart';

class CounterData {
  int value;
  final List<HistoryEntry> history;

  CounterData({
    this.value = 0,
    List<HistoryEntry>? history,
  }) : history = history ?? [];

  void changeValue({
    required int newValue,
    required String action,
  }) {
    history.insert(
      0,
      HistoryEntry(
        timestamp: DateTime.now(),
        action: action,
        valueBefore: value,
        valueAfter: newValue,
      ),
    );

    value = newValue;
  }

  void clearHistory() {
    history.clear();
  }
}
