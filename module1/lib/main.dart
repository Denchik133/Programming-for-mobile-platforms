
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PracticalWorkApp());
}

class PracticalWorkApp extends StatelessWidget {
  const PracticalWorkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Практична робота Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
