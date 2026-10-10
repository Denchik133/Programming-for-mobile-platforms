import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widgets_project/models/user.dart';
import 'package:flutter_widgets_project/widgets/profile_widget.dart';

void main() {
  const testUser = User(
    name: 'Олександр',
    email: 'oleksandr@example.com',
    avatarUrl: '',
  );

  testWidgets('ProfileWidget displays user information', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileWidget(user: testUser),
        ),
      ),
    );

    expect(find.text('Олександр'), findsOneWidget);
    expect(find.text('oleksandr@example.com'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byTooltip('Редагувати профіль'), findsOneWidget);
  });

  testWidgets('ProfileWidget calls edit callback', (
    WidgetTester tester,
  ) async {
    var wasEdited = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileWidget(
            user: testUser,
            onEdit: () {
              wasEdited = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Редагувати профіль'));

    expect(wasEdited, isTrue);
  });
}