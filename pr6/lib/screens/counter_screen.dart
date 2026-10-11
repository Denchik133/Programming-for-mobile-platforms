import 'package:flutter/material.dart';

import '../models/counter_data.dart';
import '../screens/history_screen.dart';
import '../widgets/history_badge.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  final CounterData _data = CounterData();
  int _step = 1;

  void _changeCounter(int difference, String action) {
    if (difference < 0 && _data.value + difference < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Значення лічильника не може бути від’ємним'),
        ),
      );
      return;
    }

    setState(() {
      _data.changeValue(
        newValue: _data.value + difference,
        action: action,
      );
    });
  }

  void _resetCounter() {
    if (_data.value == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Лічильник уже дорівнює нулю')),
      );
      return;
    }

    setState(() {
      _data.changeValue(
        newValue: 0,
        action: 'Скидання',
      );
    });
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => HistoryScreen(
          history: List.unmodifiable(_data.history),
          onClearHistory: () {
            setState(_data.clearHistory);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build: CounterScreen');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лічильник з історією'),
        actions: [
          HistoryBadge(count: _data.history.length),
          IconButton(
            tooltip: 'Відкрити історію',
            onPressed: _openHistory,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Поточне значення',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              Text(
                '${_data.value}',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 28),
              const Text('Крок зміни'),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('1')),
                  ButtonSegment(value: 5, label: Text('5')),
                  ButtonSegment(value: 10, label: Text('10')),
                ],
                selected: {_step},
                onSelectionChanged: (selection) {
                  setState(() {
                    _step = selection.first;
                  });
                },
              ),
              const SizedBox(height: 28),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => _changeCounter(_step, 'Збільшення'),
                    icon: const Icon(Icons.add),
                    label: const Text('Збільшити'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _changeCounter(-_step, 'Зменшення'),
                    icon: const Icon(Icons.remove),
                    label: const Text('Зменшити'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _resetCounter,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Скинути'),
              ),
              const SizedBox(height: 24),
              Text('Записів в історії: ${_data.history.length}'),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: _openHistory,
                icon: const Icon(Icons.history),
                label: const Text('Переглянути історію'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
