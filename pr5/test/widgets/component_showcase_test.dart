
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widgets_project/main.dart';
import 'package:flutter_widgets_project/screens/component_showcase_screen.dart';
import 'package:flutter_widgets_project/widgets/animated_counter.dart';
import 'package:flutter_widgets_project/widgets/custom_button.dart';
import 'package:flutter_widgets_project/widgets/profile_widget.dart';

void main() {
  testWidgets('Component Showcase displays custom widgets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WidgetsShowcaseApp());

    await tester.tap(
      find.byTooltip('Демонстрація компонентів'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ComponentShowcaseScreen), findsOneWidget);
    expect(find.text('Демонстрація компонентів'), findsOneWidget);
    expect(find.byType(CustomButton), findsNWidgets(3));
    expect(find.byType(AnimatedCounter), findsOneWidget);
    expect(find.byType(ProfileWidget), findsOneWidget);
  });
}
