import 'dart:math';

import 'package:flutter/foundation.dart';

import 'cart_model.dart';

class OrderModel extends ChangeNotifier {
  final Random _random = Random();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> placeOrder(CartModel cart) async {
    if (cart.isEmpty || _isLoading) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(seconds: 2));

      if (_random.nextInt(4) == 0) {
        throw Exception('Не вдалося оформити замовлення');
      }

      cart.clear();
      _successMessage = 'Замовлення успішно оформлено!';
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
