import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';

class BookScreen extends StatelessWidget {
  final Book book;

  const BookScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Інформація про книгу')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.menu_book, size: 100),
            ),
            const SizedBox(height: 24),
            Text(
              book.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text('Автор: ${book.author}'),
            Text('Жанр: ${book.genre}'),
            Text('Рік видання: ${book.year}'),
            const SizedBox(height: 20),
            Text(book.description),
            const SizedBox(height: 20),
            const Text('Статус: доступна для читання'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    context.push('/catalog/book/${book.id}/reserve'),
                icon: const Icon(Icons.bookmark_add),
                label: const Text('Забронювати книгу'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}