
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Застосунок чату підтримки запускається', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('Чат підтримки')),
          body: Center(child: Text('Застосунок запущено')),
        ),
      ),
    );

    expect(find.text('Чат підтримки'), findsOneWidget);
    expect(find.text('Застосунок запущено'), findsOneWidget);
  });
}
