
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widgets_project/main.dart';

void main() {
  testWidgets('Widget Store displays the welcome screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WidgetsShowcaseApp());

    expect(find.text('Widget Store'), findsOneWidget);
    expect(find.text('Вітаємо у Widget Store!'), findsOneWidget);
  });
}
