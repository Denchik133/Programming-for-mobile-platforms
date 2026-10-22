
import 'package:flutter/material.dart';
import '../models/library_item.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late final Library library;
  final TextEditingController yearController =
      TextEditingController(text: '2022');

  int? selectedYear;

  @override
  void initState() {
    super.initState();

    library = Library()
      ..addItem(
        const Book(
          title: 'Dart у дії',
          year: 2022,
          author: 'І. Петренко',
        ),
      )
      ..addItem(
        const Magazine(
          title: 'Mobile Dev',
          year: 2023,
          issueNumber: 5,
        ),
      )
      ..addItem(
        const Book(
          title: 'Основи Flutter',
          year: 2021,
          author: 'О. Коваленко',
        ),
      );

    selectedYear = 2022;
  }

  @override
  void dispose() {
    yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final oldest = library.findOldest();
    final filteredItems = selectedYear == null
        ? library.findByYear(-1)
        : library.findByYear(selectedYear!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Завдання 1: Бібліотека'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Усі видання',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...library.allDescriptions.map(
                (description) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: Text(description),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Пошук за роком видання',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Рік',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => searchByYear(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: searchByYear,
                    child: const Text('Знайти'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (filteredItems.isEmpty)
                const Card(
                  child: ListTile(
                    title: Text('Видань за цей рік не знайдено.'),
                  ),
                )
              else
                ...filteredItems.map(
                  (item) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.search),
                      title: Text(item.describe()),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                'Найстаріше видання',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.history,
                    color: Colors.blue,
                  ),
                  title: Text(
                    oldest?.describe() ?? 'Бібліотека порожня',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void searchByYear() {
    final year = int.tryParse(yearController.text.trim());

    setState(() {
      selectedYear = year;
    });

    if (year == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введи коректний рік, наприклад 2022.'),
        ),
      );
    }
  }
}
