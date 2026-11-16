import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/db_constants.dart';
import '../services/order_service.dart';

/// Діалог перегляду деталей замовлення
class OrderDetailsDialog extends StatefulWidget {
  final int orderId;
  final OrderService orderService;
  final VoidCallback onOrderUpdated;

  const OrderDetailsDialog({
    super.key,
    required this.orderId,
    required this.orderService,
    required this.onOrderUpdated,
  });

  @override
  State<OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<OrderDetailsDialog> {
  final _currencyFormat = NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 2);
  final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _orderData;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details = await widget.orderService.getOrderDetails(widget.orderId);
      if (details == null) {
        setState(() {
          _errorMessage = 'Замовлення не знайдено';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _orderData = details['order'] as Map<String, dynamic>?;
        _items = (details['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Помилка завантаження: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Скасувати замовлення?'),
        content: const Text(
          'Транзакція скасування поверне всі замовлені товари назад на склад та змінить статус на "cancelled".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Назад'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade100),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Скасувати замовлення', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final success = await widget.orderService.cancelOrder(widget.orderId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Замовлення скасовано, товари успішно повернено на склад!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onOrderUpdated();
          await _loadOrderDetails();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не вдалося скасувати замовлення.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _completeOrder() async {
    try {
      final success = await widget.orderService.completeOrder(widget.orderId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Замовлення успішно переведено в статус "completed"!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onOrderUpdated();
          await _loadOrderDetails();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case DbConstants.statusCompleted:
        return Colors.green;
      case DbConstants.statusPending:
        return Colors.orange;
      case DbConstants.statusCancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case DbConstants.statusCompleted:
        return 'Виконано';
      case DbConstants.statusPending:
        return 'В обробці';
      case DbConstants.statusCancelled:
        return 'Скасовано';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final order = _orderData!;
    final status = order[DbConstants.colOrderStatus] as String;
    final totalAmount = (order[DbConstants.colOrderTotalAmount] as num).toDouble();
    final createdAt = DateTime.parse(order[DbConstants.colOrderCreatedAt] as String);
    final userId = order[DbConstants.colOrderUserId];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Замовлення #${widget.orderId}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(status)),
              ),
              child: Text(
                _getStatusText(status),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Користувач ID: $userId',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const Spacer(),
            Text(
              _dateFormat.format(createdAt),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        const Divider(height: 24),
        Text(
          'Товари в замовленні (${_items.length}):',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _items.isEmpty
              ? const Center(child: Text('Товари відсутні'))
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final name = item['productName'] ?? 'Товар #${item[DbConstants.colItemProductId]}';
                    final quantity = item[DbConstants.colItemQuantity] as int;
                    final price = (item[DbConstants.colItemPrice] as num).toDouble();
                    final subtotal = price * quantity;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('$quantity шт. × ${_currencyFormat.format(price)}'),
                      trailing: Text(
                        _currencyFormat.format(subtotal),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    );
                  },
                ),
        ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Разом до сплати:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text(
              _currencyFormat.format(totalAmount),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (status == DbConstants.statusPending) ...[
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: const Text('Скасувати', style: TextStyle(color: Colors.red)),
                  onPressed: _cancelOrder,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Завершити'),
                  onPressed: _completeOrder,
                ),
              ),
            ] else ...[
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрити'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
