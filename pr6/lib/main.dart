import 'package:flutter/material.dart';

import 'screens/counter_screen.dart';
import 'state/counter_scope.dart';
import 'state/counter_state.dart';

void main() {
  runApp(const CounterHistoryApp());
}

class CounterHistoryApp extends StatefulWidget {
  const CounterHistoryApp({super.key});

  @override
  State<CounterHistoryApp> createState() => _CounterHistoryAppState();
}

class _CounterHistoryAppState extends State<CounterHistoryApp> {
  late final CounterState _counterState;

  @override
  void initState() {
    super.initState();
    _counterState = CounterState();
  }

  @override
  void dispose() {
    _counterState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CounterScope(
      notifier: _counterState,
      child: MaterialApp(
        title: 'Лічильник з історією',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
          ),
          useMaterial3: true,
        ),
        home: const CounterScreen(),
      ),
    );
  }
}
