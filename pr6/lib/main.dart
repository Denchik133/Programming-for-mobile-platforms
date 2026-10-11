import 'package:flutter/material.dart';

import 'screens/counter_screen.dart';

void main() {
  runApp(const CounterHistoryApp());
}

class CounterHistoryApp extends StatelessWidget {
  const CounterHistoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Лічильник з історією',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const CounterScreen(),
    );
  }
}
