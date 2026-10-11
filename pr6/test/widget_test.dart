import 'package:flutter_test/flutter_test.dart';
import 'package:pr6/main.dart';

void main() {
  testWidgets('Counter history app displays initial state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CounterHistoryApp());

    expect(find.text('Лічильник з історією'), findsOneWidget);
    expect(find.text('Поточне значення'), findsOneWidget);
    expect(find.text('Крок зміни'), findsOneWidget);
    expect(find.text('Записів в історії: 0'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
  });
}
