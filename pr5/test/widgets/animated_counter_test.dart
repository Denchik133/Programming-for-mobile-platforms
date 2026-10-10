import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widgets_project/widgets/animated_counter.dart';

void main() {
  testWidgets('AnimatedCounter starts with initial value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedCounter(initialValue: 3),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('AnimatedCounter increments and decrements', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedCounter(initialValue: 3),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Збільшити'));
    await tester.pump();

    expect(find.text('4'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip('Зменшити'));
    await tester.pump();

    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('AnimatedCounter respects minimum and maximum values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedCounter(
            initialValue: 0,
            minValue: 0,
            maxValue: 1,
          ),
        ),
      ),
    );

    expect(
      tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip('Зменшити'),
          matching: find.byType(IconButton),
        ),
      ).onPressed,
      isNull,
    );

    await tester.tap(find.byTooltip('Збільшити'));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);

    expect(
      tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip('Збільшити'),
          matching: find.byType(IconButton),
        ),
      ).onPressed,
      isNull,
    );
  });
}