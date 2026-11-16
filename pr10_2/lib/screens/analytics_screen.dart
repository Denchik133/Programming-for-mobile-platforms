import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/db_constants.dart';
import '../database/orders_database.dart';
import '../models/order_item_request.dart';
import '../repositories/product_repository.dart';
import '../services/order_service.dart';

/// Екран аналітики, звітів продажів та популярних продуктів
class AnalyticsScreen extends StatefulWidget {
  final OrderService orderService;
  final ProductRepository productRepository;
  final VoidCallback onDataChanged;

  const AnalyticsScreen({
    super.key,
    required this.orderService,
    required this.productRepository,
    required this.onDataChanged,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 2);

  bool _isLoading = true;
  double _revenue = 0.0;
  Map<String, int> _orderCounts = {
    'total': 0,
    'pending': 0,
    'completed': 0,
    'cancelled': 0,
  };
  List<Map<String, dynamic>> _topProducts = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final stats = await widget.orderService.getSalesStats();
      final top = await widget.orderService.getTopProducts(10);

      setState(() {
        _revenue = (stats['revenue'] as num?)?.toDouble() ?? 0.0;
        final ordersMap = stats['orders'] as Map<String, dynamic>? ?? {};
        _orderCounts = {
          'total': (ordersMap['total'] as num?)?.toInt() ?? 0,
          'pending': (ordersMap['pending'] as num?)?.toInt() ?? 0,
          'completed': (ordersMap['completed'] as num?)?.toInt() ?? 0,
          'cancelled': (ordersMap['cancelled'] as num?)?.toInt() ?? 0,
        };
        _topProducts = top;
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

  /// Генерація демонстраційного набору даних для викладача/тесту
  Future<void> _seedDemoOrders() async {
    setState(() => _isLoading = true);
    try {
      final products = await widget.productRepository.getAllProducts();
      if (products.length >= 3) {
        // Замовлення 1
        final o1 = await widget.orderService.createOrder(101, [
          OrderItemRequest(productId: products[0].id!, quantity: 2),
          OrderItemRequest(productId: products[1].id!, quantity: 1),
        ]);
        if (o1 != null) {
          await widget.orderService.completeOrder(o1);
        }

        // Замовлення 2
        final o2 = await widget.orderService.createOrder(102, [
          OrderItemRequest(productId: products[1].id!, quantity: 3),
          OrderItemRequest(productId: products[2].id!, quantity: 2),
        ]);
        if (o2 != null) {
          await widget.orderService.completeOrder(o2);
        }

        // Замовлення 3 (Pending)
        await widget.orderService.createOrder(103, [
          OrderItemRequest(productId: products[0].id!, quantity: 1),
        ]);

        // Замовлення 4 (Cancelled)
        final o4 = await widget.orderService.createOrder(104, [
          OrderItemRequest(productId: products[2].id!, quantity: 1),
        ]);
        if (o4 != null) {
          await widget.orderService.cancelOrder(o4);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Демонстраційні замовлення успішно створено!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка генерації демо-даних: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      widget.onDataChanged();
      await _loadAnalytics();
    }
  }

  /// Скидання бази даних до початкового стану
  Future<void> _resetDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Скинути базу даних?'),
        content: const Text('Усі поточні замовлення будуть видалені, а товари повернуться до початкового стану.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Назад')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Скинути'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await OrdersDatabase.instance.resetDatabase();
    widget.onDataChanged();
    await _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналітика та Звіти'),
        actions: [
          IconButton(
            tooltip: 'Згенерувати демо-замовлення',
            icon: const Icon(Icons.playlist_add),
            onPressed: _seedDemoOrders,
          ),
          IconButton(
            tooltip: 'Скинути базу даних',
            icon: const Icon(Icons.restart_alt),
            onPressed: _resetDatabase,
          ),
          IconButton(
            tooltip: 'Оновити',
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Картка загального виторгу
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: const Icon(Icons.monetization_on, color: Colors.white, size: 36),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Загальний виторг (Completed)',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currencyFormat.format(_revenue),
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Статистика замовлень за статусами
                    Text(
                      'Статистика замовлень',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatBox('Всього', '${_orderCounts['total']}', Colors.indigo, Icons.all_inbox),
                        const SizedBox(width: 8),
                        _buildStatBox('Виконано', '${_orderCounts['completed']}', Colors.green, Icons.check_circle),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatBox('В обробці', '${_orderCounts['pending']}', Colors.orange, Icons.hourglass_top),
                        const SizedBox(width: 8),
                        _buildStatBox('Скасовано', '${_orderCounts['cancelled']}', Colors.red, Icons.cancel),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Найпопулярніші продукти (Top sold)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Топ найпопулярніших товарів',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '(За виконаними замовленнями)',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _topProducts.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Немає завершених замовлень для аналізу популярності.\n'
                                'Натисніть кнопку зверху для додавання демо-замовлень.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _topProducts.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = _topProducts[index];
                              final rank = index + 1;
                              final name = item[DbConstants.colProductName] as String;
                              final price = (item[DbConstants.colProductPrice] as num).toDouble();
                              final totalSold = (item['totalSold'] as num).toInt();

                              return Card(
                                elevation: 1,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: rank == 1
                                        ? Colors.amber
                                        : rank == 2
                                            ? Colors.grey.shade400
                                            : rank == 3
                                                ? Colors.brown.shade300
                                                : Colors.blueGrey.shade100,
                                    foregroundColor: rank <= 3 ? Colors.white : Colors.black87,
                                    child: Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Ціна: ${_currencyFormat.format(price)}'),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.green.shade300),
                                    ),
                                    child: Text(
                                      'Продано: $totalSold шт.',
                                      style: TextStyle(
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatBox(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  count,
                  style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
