import 'package:flutter/foundation.dart';

import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }

  double get totalPrice => product.price * quantity;
}

class CartModel extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => List.unmodifiable(_items.values);

  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => _items.isEmpty;

  void addProduct(Product product) {
    final existingItem = _items[product.id];

    if (existingItem == null) {
      _items[product.id] = CartItem(product: product, quantity: 1);
    } else {
      _items[product.id] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
    }

    notifyListeners();
  }

  void increaseQuantity(int productId) {
    final item = _items[productId];
    if (item == null) return;

    _items[productId] = item.copyWith(quantity: item.quantity + 1);

    notifyListeners();
  }

  void decreaseQuantity(int productId) {
    final item = _items[productId];
    if (item == null) return;

    if (item.quantity <= 1) {
      removeProduct(productId);
      return;
    }

    _items[productId] = item.copyWith(quantity: item.quantity - 1);

    notifyListeners();
  }

  void removeProduct(int productId) {
    if (_items.remove(productId) != null) {
      notifyListeners();
    }
  }

  void clear() {
    if (_items.isEmpty) return;

    _items.clear();
    notifyListeners();
  }
}
