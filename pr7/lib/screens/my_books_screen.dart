import 'package:flutter/material.dart';

import '../models/reservation_model.dart';

class MyBooksScreen extends StatelessWidget {
  const MyBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: reservationModel,
      builder: (context, _) {
        final reservations = reservationModel.reservations;

        return Scaffold(
          appBar: AppBar(title: const Text('Мої книги')),
          body: reservations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_border, size: 72),
                      SizedBox(height: 16),
                      Text('У вас поки немає заброньованих книг'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    final book = reservation.book;
                    final date = reservation.returnDate;

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.menu_book),
                        title: Text(book.title),
                        subtitle: Text(
                          '${book.author}\nДата повернення: '
                          '${date.day.toString().padLeft(2, '0')}.'
                          '${date.month.toString().padLeft(2, '0')}.'
                          '${date.year}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          tooltip: 'Скасувати бронювання',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            reservationModel.cancel(book.id);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Бронювання скасовано'),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}