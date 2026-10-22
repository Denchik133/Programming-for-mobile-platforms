
import 'package:flutter/material.dart';
import '../widgets/rating_badge.dart';

class RatingDemoScreen extends StatelessWidget {
  const RatingDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Завдання 2: RatingBadge'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Приклади рейтингів',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                RatingBadge(
                  rating: 4.8,
                  label: 'Відмінно',
                ),
                SizedBox(height: 16),
                RatingBadge(
                  rating: 3.5,
                  label: 'Добре',
                ),
                SizedBox(height: 16),
                RatingBadge(
                  rating: 1.7,
                  label: 'Низький рейтинг',
                ),
                SizedBox(height: 16),
                RatingBadge(rating: 4.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
