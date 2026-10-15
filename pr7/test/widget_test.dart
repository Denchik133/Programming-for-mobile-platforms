import 'package:flutter_test/flutter_test.dart';
import 'package:pr7/main.dart';

void main() {
  testWidgets('Бібліотека відкриває каталог', (tester) async {
    await tester.pumpWidget(const LibraryApp());
    await tester.pumpAndSettle();

    expect(find.text('Каталог бібліотеки'), findsOneWidget);
    expect(find.text('Мої книги'), findsOneWidget);
    expect(find.text('Профіль'), findsOneWidget);
  });
}