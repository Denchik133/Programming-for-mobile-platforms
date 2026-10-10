import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widgets_project/models/product.dart';
import 'package:flutter_widgets_project/utils/app_state.dart';

void main() {
  const product = Product(
    id: '1',
    name: 'Навушники Pro',
    description: 'Бездротові навушники.',
    price: 2499.99,
    imageUrl: '',
  );

  group('AppState cart', () {
    test('adds product and updates cart count', () {
      final state = AppState();

      state.addToCart(product);

      expect(state.cartCount, 1);
      expect(state.cart, contains(product));
    });

    test('removes product from cart', () {
      final state = AppState();

      state.addToCart(product);
      state.removeFromCart(product);

      expect(state.cartCount, 0);
    });

    test('clears the cart', () {
      final state = AppState();

      state
        ..addToCart(product)
        ..addToCart(product)
        ..clearCart();

      expect(state.cart, isEmpty);
      expect(state.cartCount, 0);
    });
  });

  group('AppState favorites', () {
    test('adds and removes a favorite', () {
      final state = AppState();

      state.toggleFavorite(product);

      expect(state.isFavorite(product.id), isTrue);
      expect(state.favoritesCount, 1);

      state.toggleFavorite(product);

      expect(state.isFavorite(product.id), isFalse);
      expect(state.favoritesCount, 0);
    });

    test('notifies listeners when state changes', () {
      final state = AppState();
      var notifications = 0;

      state.addListener(() {
        notifications++;
      });

      state.addToCart(product);
      state.toggleFavorite(product);

      expect(notifications, 2);
    });
  });
}