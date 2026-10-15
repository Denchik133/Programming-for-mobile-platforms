import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../models/reservation_model.dart';

class ReserveScreen extends StatefulWidget {
  final Book book;

  const ReserveScreen({super.key, required this.book});

  @override
  State<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends State<ReserveScreen> {
  DateTime? _returnDate;

  Future<void> _selectDate() async {
    final result = await context.push<DateTime>('/select-date');

    if (result != null && mounted) {
      setState(() => _returnDate = result);
    }
  }

  void _reserve() {
    if (_returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Спочатку оберіть дату повернення'),
        ),
      );
      return;
    }
    
    final alreadyReserved = reservationModel.reservations.any(
      (reservation) => reservation.book.id == widget.book.id,
    );
    
    if (alreadyReserved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Цю книгу вже заброньовано')),
      );
      return;
    }

    reservationModel.reserve(widget.book, _returnDate!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Книгу «${widget.book.title}» заброньовано')),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final date = _returnDate == null
        ? 'Не вибрано'
        : '${_returnDate!.day.toString().padLeft(2, '0')}.'
            '${_returnDate!.month.toString().padLeft(2, '0')}.'
            '${_returnDate!.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Бронювання книги')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Автор: ${widget.book.author}'),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month),
              title: const Text('Дата повернення'),
              subtitle: Text(date),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectDate,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _reserve,
                child: const Text('Підтвердити бронювання'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}