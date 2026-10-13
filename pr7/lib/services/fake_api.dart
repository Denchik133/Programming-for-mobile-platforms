import 'dart:math';

import '../models/product.dart';

class FakeApi {
  final Random _random = Random();

  Future<List<Product>> fetchProducts() async {
    await Future<void>.delayed(const Duration(seconds: 1));

    if (_random.nextInt(5) == 0) {
      throw Exception('Сервер недоступний');
    }

    return demoProducts;
  }
}
