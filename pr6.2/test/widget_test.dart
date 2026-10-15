
import 'package:flutter_test/flutter_test.dart';
import 'package:pr7/main.dart';
import 'package:pr7/models/cart_model.dart';
import 'package:pr7/models/catalog_model.dart';
import 'package:pr7/models/order_model.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Shop app displays its title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => CatalogModel(),
          ),
          ChangeNotifierProvider(
            create: (_) => CartModel(),
          ),
          ChangeNotifierProvider(
            create: (_) => OrderModel(),
          ),
        ],
        child: const ShopApp(),
      ),
    );

    expect(find.text('Мій магазин'), findsOneWidget);
  });
}
