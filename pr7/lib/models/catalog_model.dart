import 'package:flutter/foundation.dart';

import '../services/fake_api.dart';
import 'product.dart';

enum CatalogStatus { initial, loading, success, error }

class CatalogModel extends ChangeNotifier {
  final FakeApi _api = FakeApi();

  CatalogStatus _status = CatalogStatus.initial;
  List<Product> _products = [];
  String _selectedCategory = 'Усі';
  String? _errorMessage;

  CatalogStatus get status => _status;

  List<Product> get products => List.unmodifiable(_products);

  String get selectedCategory => _selectedCategory;

  String? get errorMessage => _errorMessage;

  List<String> get categories {
    final categories = _products
        .map((product) => product.category)
        .toSet()
        .toList();

    return ['Усі', ...categories];
  }

  List<Product> get filteredProducts {
    if (_selectedCategory == 'Усі') {
      return List.unmodifiable(_products);
    }

    return List.unmodifiable(
      _products.where((product) => product.category == _selectedCategory),
    );
  }

  Future<void> loadProducts() async {
    _status = CatalogStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final products = await _api.fetchProducts();

      _products = products;
      _status = CatalogStatus.success;
    } catch (error) {
      _status = CatalogStatus.error;
      _errorMessage = error.toString();
    }

    notifyListeners();
  }

  void setCategory(String category) {
    if (_selectedCategory == category) {
      return;
    }

    _selectedCategory = category;
    notifyListeners();
  }
}
