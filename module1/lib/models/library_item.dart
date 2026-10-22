
/// Абстрактний базовий клас для елементів бібліотеки.
abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({
    required this.title,
    required this.year,
  });

  /// Повертає текстовий опис елемента.
  String describe();
}

/// Книга з автором.
class Book extends LibraryItem {
  final String author;

  const Book({
    required super.title,
    required super.year,
    required this.author,
  });

  @override
  String describe() => '$title ($year) — $author';
}

/// Журнал із номером випуску.
class Magazine extends LibraryItem {
  final int issueNumber;

  const Magazine({
    required super.title,
    required super.year,
    required this.issueNumber,
  });

  @override
  String describe() => '$title ($year), випуск $issueNumber';
}

/// Бібліотека, яка зберігає книги та журнали.
class Library {
  final List<LibraryItem> _items = [];

  /// Додає елемент до бібліотеки.
  void addItem(LibraryItem item) {
    _items.add(item);
  }

  /// Знаходить усі елементи, видані у вказаному році.
  List<LibraryItem> findByYear(int year) {
    return _items.where((item) => item.year == year).toList();
  }

  /// Повертає описи всіх елементів бібліотеки.
  List<String> get allDescriptions {
    return _items.map((item) => item.describe()).toList();
  }

  /// Знаходить найстаріший елемент або null, якщо бібліотека порожня.
  LibraryItem? findOldest() {
    if (_items.isEmpty) {
      return null;
    }

    LibraryItem oldest = _items.first;

    for (final item in _items.skip(1)) {
      if (item.year < oldest.year) {
        oldest = item;
      }
    }

    return oldest;
  }
}
