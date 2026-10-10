import 'package:flutter/foundation.dart';

import '../models/product.dart';

class AppState extends ChangeNotifier {
  final List<Product> _cart = [];
  final Set<String> _favoriteIds = {};

  List<Product> get cart => List.unmodifiable(_cart);

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  int get cartCount => _cart.length;

  int get favoritesCount => _favoriteIds.length;

  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  void addToCart(Product product) {
    _cart.add(product);
    notifyListeners();
  }

  void toggleFavorite(Product product) {
    if (!_favoriteIds.add(product.id)) {
      _favoriteIds.remove(product.id);
    }

    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cart.remove(product);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}