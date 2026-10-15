import 'package:flutter/foundation.dart';

import 'book.dart';

class Reservation {
  final Book book;
  final DateTime returnDate;

  const Reservation({
    required this.book,
    required this.returnDate,
  });
}

class ReservationModel extends ChangeNotifier {
  final List<Reservation> _reservations = [];

  List<Reservation> get reservations =>
      List.unmodifiable(_reservations);

  void reserve(Book book, DateTime returnDate) {
    final alreadyReserved = _reservations.any(
      (reservation) => reservation.book.id == book.id,
    );

    if (alreadyReserved) return;

    _reservations.add(
      Reservation(book: book, returnDate: returnDate),
    );

    notifyListeners();
  }

  void cancel(String bookId) {
    _reservations.removeWhere(
      (reservation) => reservation.book.id == bookId,
    );

    notifyListeners();
  }
}

final ReservationModel reservationModel = ReservationModel();