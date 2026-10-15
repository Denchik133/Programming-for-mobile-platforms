import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DatePickerScreen extends StatelessWidget {
  const DatePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Дата повернення')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Оберіть дату повернення книги'),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  final today = DateUtils.dateOnly(DateTime.now());

                  final selected = await showDatePicker(
                    context: context,
                    initialDate: today.add(const Duration(days: 14)),
                    firstDate: today.add(const Duration(days: 1)),
                    lastDate: today.add(const Duration(days: 90)),
                  );

                  if (selected != null && context.mounted) {
                    context.pop(selected);
                  }
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text('Вибрати дату'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}