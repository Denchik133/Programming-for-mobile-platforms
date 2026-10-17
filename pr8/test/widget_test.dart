
import 'package:flutter_test/flutter_test.dart';
import 'package:pr8/main.dart';

void main() {
  testWidgets('Застосунок чату підтримки запускається', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SupportChatApp());

    expect(find.text('Чат підтримки'), findsOneWidget);
  });
}
