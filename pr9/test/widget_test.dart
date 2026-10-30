import 'package:flutter_test/flutter_test.dart';
import 'package:pr9/main.dart';
import 'package:pr9/services/preferences_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Settings app displays the main screen', (tester) async {
    final preferences = await PreferencesManager.getInstance();

    await tester.pumpWidget(
      SettingsApp(preferences: preferences),
    );

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Мої налаштування'), findsOneWidget);
  });
}