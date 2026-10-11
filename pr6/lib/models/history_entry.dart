class HistoryEntry {
  final DateTime timestamp;
  final String action;
  final int valueBefore;
  final int valueAfter;

  const HistoryEntry({
    required this.timestamp,
    required this.action,
    required this.valueBefore,
    required this.valueAfter,
  });
}
