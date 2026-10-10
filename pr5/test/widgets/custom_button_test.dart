import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widgets_project/widgets/custom_button.dart';

void main() {
  testWidgets('CustomButton displays label and handles tap', (
    WidgetTester tester,
  ) async {
    var wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            label: 'Додати товар',
            icon: Icons.add,
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Додати товар'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.text('Додати товар'));
    expect(wasPressed, isTrue);
  });

  testWidgets('CustomButton shows loading indicator and disables tap', (
    WidgetTester tester,
  ) async {
    var wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            label: 'Завантаження',
            isLoading: true,
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    expect(wasPressed, isFalse);
  });

  testWidgets('CustomButton supports outlined variant', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomButton(
            label: 'Скасувати',
            variant: CustomButtonVariant.outlined,
            onPressed: null,
          ),
        ),
      ),
    );

    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.text('Скасувати'), findsOneWidget);
  });
}