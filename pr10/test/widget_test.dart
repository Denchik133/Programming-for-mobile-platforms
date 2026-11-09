import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pr10/main.dart';

void main() {
  testWidgets('Notes app displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const NotesApp());

    expect(find.text('Менеджер нотаток'), findsOneWidget);
    expect(find.byTooltip('Створити нотатку'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month), findsOneWidget);
  });
}
