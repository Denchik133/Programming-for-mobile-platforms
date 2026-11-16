import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

/// Екран керування каталогом товарів та залишками на складі
class ProductsScreen extends StatefulWidget {
  final ProductRepository productRepository;
  final VoidCallback onProductUpdated;

  const ProductsScreen({
    super.key,
    required this.productRepository,
    required this.onProductUpdated,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 2);
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
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
          SnackBar(content: Text('Помилка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Діалог додавання нового товару
  Future<void> _showAddProductDialog() async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '10');

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новий товар'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Назва товару', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Ціна (грн)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Початковий залишок (шт)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Скасувати')),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final price = double.tryParse(priceCtrl.text.trim());
              final stock = int.tryParse(stockCtrl.text.trim());

              if (name.isEmpty || price == null || stock == null) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Заповніть усі поля коректно')),
                );
                return;
              }

              await widget.productRepository.insertProduct(
                Product(name: name, price: price, stock: stock),
              );
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Додати'),
          ),
        ],
      ),
    );

    nameCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();

    if (created == true) {
      widget.onProductUpdated();
      await _loadProducts();
    }
  }

  /// Діалог поповнення складу
  Future<void> _showRestockDialog(Product product) async {
    final addCtrl = TextEditingController(text: '10');

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Поповнити "${product.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Поточний залишок: ${product.stock} шт.'),
            const SizedBox(height: 12),
            TextField(
              controller: addCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Кількість для додавання',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Назад')),
          FilledButton(
            onPressed: () async {
              final count = int.tryParse(addCtrl.text.trim()) ?? 0;
              if (count <= 0) return;

              await widget.productRepository.updateStock(
                product.id!,
                product.stock + count,
              );
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Поповнити'),
          ),
        ],
      ),
    );

    addCtrl.dispose();

    if (updated == true) {
      widget.onProductUpdated();
      await _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Склад та товари'),
        actions: [
          IconButton(
            tooltip: 'Оновити',
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        icon: const Icon(Icons.add),
        label: const Text('Додати товар'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('Товарів немає'))
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 80),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final isLowStock = product.stock <= 3;
                    final isOutOfStock = product.stock == 0;

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isOutOfStock
                              ? Colors.red.shade100
                              : isLowStock
                                  ? Colors.orange.shade100
                                  : Colors.blue.shade100,
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: isOutOfStock
                                ? Colors.red
                                : isLowStock
                                    ? Colors.orange
                                    : Colors.blue,
                          ),
                        ),
                        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Ціна: ${_currencyFormat.format(product.price)} | Залишок: ${product.stock} шт.',
                          style: TextStyle(
                            color: isOutOfStock
                                ? Colors.red
                                : isLowStock
                                    ? Colors.orange.shade800
                                    : null,
                            fontWeight: isLowStock ? FontWeight.w600 : null,
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Поповнити залишок',
                          icon: const Icon(Icons.add_shopping_cart, color: Colors.teal),
                          onPressed: () => _showRestockDialog(product),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
