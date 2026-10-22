
import 'package:flutter/material.dart';
import 'rating_demo_screen.dart';
import 'library_screen.dart';
import 'counter_screen.dart';
import 'weather_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Практична робота з Flutter'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.school,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Практична робота',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dart та Flutter: чотири завдання',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                _buildTaskButton(
                  context,
                  title: 'Завдання 1. Класи та колекції',
                  icon: Icons.library_books,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const LibraryScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildTaskButton(
                  context,
                  title: 'Завдання 2. RatingBadge',
                  icon: Icons.star,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            const RatingDemoScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildTaskButton(
                  context,
                  title: 'Завдання 3. Лічильник і навігація',
                  icon: Icons.touch_app,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const CounterScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildTaskButton(
                  context,
                  title: 'Завдання 4. Асинхронна погода',
                  icon: Icons.cloud,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const WeatherScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(title),
      ),
    );
  }
}
