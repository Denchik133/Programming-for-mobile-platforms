import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/db_constants.dart';
import '../models/order_item_request.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../services/order_service.dart';

/// Екран створення нового замовлення з демонстрацією атомарності транзакції
class CreateOrderScreen extends StatefulWidget {
  final OrderService orderService;
  final ProductRepository productRepository;
  final VoidCallback onOrderCreated;

  const CreateOrderScreen({
    super.key,
    required this.orderService,
    required this.productRepository,
    required this.onOrderCreated,
  });

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 2);
  final _userIdController = TextEditingController(text: '1');

  List<Product> _products = [];
  final Map<int, int> _selectedQuantities = {};
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final list = await widget.productRepository.getAllProducts();
      setState(() {
        _products = list;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка завантаження товарів: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  double get _totalPrice {
    double total = 0.0;
    for (final p in _products) {
      final qty = _selectedQuantities[p.id!] ?? 0;
      total += p.price * qty;
    }
    return total;
  }

  int get _totalItemsCount {
    int count = 0;
    for (final qty in _selectedQuantities.values) {
      count += qty;
    }
    return count;
  }

  /// Створення замовлення через транзакцію
  Future<void> _submitOrder({bool forceOverflowTest = false}) async {
    final userId = int.tryParse(_userIdController.text.trim()) ?? 1;

    List<OrderItemRequest> items = [];

    if (forceOverflowTest) {
      // Спеціальний сценарій для демонстрації ROLLBACK:
      // Беремо перший товар і замовляємо більше, ніж є на складі!
      if (_products.isEmpty) return;
      final prod = _products.first;
      items = [
        OrderItemRequest(
          productId: prod.id!,
          quantity: prod.stock + 5, // На 5 більше, ніж доступно!
        ),
      ];
    } else {
      _selectedQuantities.forEach((prodId, qty) {
        if (qty > 0) {
          items.add(OrderItemRequest(productId: prodId, quantity: qty));
        }
      });
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Виберіть хоча б один товар для замовлення!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentTotalPrice = _totalPrice;
    setState(() => _isSubmitting = true);

    try {
      final orderId = await widget.orderService.createOrder(userId, items);
      if (mounted) {
        double finalAmount = currentTotalPrice;
        if (orderId != null) {
          final details = await widget.orderService.getOrderDetails(orderId);
          if (details != null && details['order'] != null) {
            finalAmount = (details['order'][DbConstants.colOrderTotalAmount] as num).toDouble();
          }
        }

        if (!mounted) return;

        setState(() {
          _selectedQuantities.clear();
          _isSubmitting = false;
        });

        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Транзакція успішна!'),
            content: Text(
              'Замовлення #$orderId успішно створено.\n'
              'Сума: ${_currencyFormat.format(finalAmount)}\n\n'
              'Залишки товарів у базі даних SQLite атомарно оновлено.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Чудово'),
              ),
            ],
          ),
        );

        widget.onOrderCreated();
        await _loadProducts();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);

        // Демонстрація Rollback транзакції
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
            title: const Text('Помилка: Транзакція скасована (ROLLBACK)'),
            content: Text(
              'SQLite транзакція автоматично відкотила всі зміни задля підтримки цілісності даних:\n\n'
              '$e\n\n'
              'Жоден товар не було списано, а замовлення не створено.',
            ),
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Зрозуміло'),
              ),
            ],
          ),
        );

        await _loadProducts(); // Оновлюємо склад, щоб користувач бачив, що дані не пошкоджені
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Створення замовлення'),
        actions: [
          IconButton(
            tooltip: 'Оновити склад',
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Панель інформації про користувача та демонстрації
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      const Text('ID Клієнта:'),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _userIdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        icon: const Icon(Icons.flash_on, size: 16),
                        label: const Text('Тест Rollback'),
                        onPressed: _isSubmitting ? null : () => _submitOrder(forceOverflowTest: true),
                      ),
                    ],
                  ),
                ),

                // Список доступних товарів
                Expanded(
                  child: _products.isEmpty
                      ? const Center(child: Text('Товари відсутні на складі'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            final qty = _selectedQuantities[product.id!] ?? 0;
                            final isOutOfStock = product.stock <= 0;

                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                _currencyFormat.format(product.price),
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isOutOfStock
                                                      ? Colors.red.shade100
                                                      : Colors.green.shade100,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'Склад: ${product.stock} шт',
                                                  style: TextStyle(
                                                    color: isOutOfStock
                                                        ? Colors.red.shade900
                                                        : Colors.green.shade900,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Керування кількістю
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline),
                                          onPressed: qty > 0
                                              ? () {
                                                  setState(() {
                                                    _selectedQuantities[product.id!] = qty - 1;
                                                  });
                                                }
                                              : null,
                                        ),
                                        Text(
                                          '$qty',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline),
                                          onPressed: () {
                                            setState(() {
                                              _selectedQuantities[product.id!] = qty + 1;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Нижня панель підсумку та оформлення замовлення
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Товарів: $_totalItemsCount од.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                            Text(
                              _currencyFormat.format(_totalPrice),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: _isSubmitting || _totalItemsCount == 0
                              ? null
                              : () => _submitOrder(),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.shopping_bag_outlined),
                          label: const Text('Оформити (Транзакція)'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
