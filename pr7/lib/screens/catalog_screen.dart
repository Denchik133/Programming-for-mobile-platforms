import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';

class CatalogScreen extends StatelessWidget {
  final String? genre;

  const CatalogScreen({super.key, this.genre});

  @override
  Widget build(BuildContext context) {
    final genres = sampleBooks.map((book) => book.genre).toSet().toList();

    final books = genre == null
        ? sampleBooks
        : sampleBooks.where((book) => book.genre == genre).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Каталог бібліотеки')),
      body: Column(
        children: [
          SizedBox(
            height: 58,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Усі'),
                    selected: genre == null,
                    onSelected: (_) => context.go('/catalog'),
                  ),
                ),
                ...genres.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(item),
                      selected: genre == item,
                      onSelected: (_) => context.go(
                        '/catalog?genre=${Uri.encodeQueryComponent(item)}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.menu_book),
                    ),
                    title: Text(book.title),
                    subtitle: Text('${book.author}\n${book.genre}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/catalog/book/${book.id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}