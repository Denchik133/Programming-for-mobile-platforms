
import 'package:flutter_test/flutter_test.dart';
import 'package:module1/models/library_item.dart';

void main() {
  test('Бібліотека додає та знаходить елементи', () {
    final library = Library();

    library.addItem(
      const Book(
        title: 'Dart у дії',
        year: 2022,
        author: 'І. Петренко',
      ),
    );

    library.addItem(
      const Magazine(
        title: 'Mobile Dev',
        year: 2023,
        issueNumber: 5,
      ),
    );

    expect(library.findByYear(2022), hasLength(1));
    expect(
      library.allDescriptions,
      contains('Dart у дії (2022) — І. Петренко'),
    );
    expect(library.findOldest()?.title, 'Dart у дії');
  });

  test('Порожня бібліотека повертає null', () {
    final library = Library();

    expect(library.findOldest(), isNull);
    expect(library.findByYear(2022), isEmpty);
    expect(library.allDescriptions, isEmpty);
  });
}
