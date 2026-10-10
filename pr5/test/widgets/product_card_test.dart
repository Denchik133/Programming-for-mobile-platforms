import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widgets_project/models/product.dart';
import 'package:flutter_widgets_project/widgets/product_card.dart';

void main() {
  const testProduct = Product(
    id: '1',
    name: 'Навушники Pro',
    description: 'Бездротові навушники з якісним звуком.',
    price: 2499.99,
    imageUrl: '',
  );

  testWidgets('ProductCard displays product information', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductCard(product: testProduct),
          ),
        ),
      ),
    );

    expect(find.text('Навушники Pro'), findsOneWidget);
    expect(
      find.text('Бездротові навушники з якісним звуком.'),
      findsOneWidget,
    );
    expect(find.text('2499.99 ₴'), findsOneWidget);
    expect(find.text('До кошика'), findsOneWidget);
  });

  testWidgets('ProductCard toggles favorite and invokes callback', (
    WidgetTester tester,
  ) async {
    bool? favoriteValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductCard(
              product: testProduct,
              onFavoriteChanged: (value) {
                favoriteValue = value;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Додати в обране'));
    await tester.pump();

    expect(favoriteValue, isTrue);
    expect(find.byTooltip('Прибрати з обраного'), findsOneWidget);
  });

  testWidgets('ProductCard invokes add-to-cart callback', (
    WidgetTester tester,
  ) async {
    Product? addedProduct;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductCard(
              product: testProduct,
              onAddToCart: (product) {
                addedProduct = product;
              },
            ),
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('До кошика'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('До кошика'));
    await tester.pump();

    expect(addedProduct, equals(testProduct));
  });
}