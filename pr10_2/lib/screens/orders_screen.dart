import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/db_constants.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';
import '../services/order_service.dart';
import 'order_details_dialog.dart';

/// Екран зі списком замовлень, фільтрами та пакетними (Batch) операціями
class OrdersScreen extends StatefulWidget {
  final OrderRepository orderRepository;
  final OrderService orderService;
  final VoidCallback onDataChanged;

  const OrdersScreen({
    super.key,
    required this.orderRepository,
    required this.orderService,
    required this.onDataChanged,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 2);
  final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  String _selectedFilter = 'all'; // all, pending, completed, cancelled
  List<Order> _orders = [];
  bool _isLoading = true;

  // Режим пакетного вибору (Batch Selection)
  bool _isSelectionMode = false;
  final Set<int> _selectedOrderIds = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final list = await widget.orderRepository.getAllOrders(
        status: _selectedFilter == 'all' ? null : _selectedFilter,
      );
      setState(() {
        _orders = list;
        _isLoading = false;
        // Очищаємо вибрані, яких більше немає в списку
        _selectedOrderIds.removeWhere((id) => !_orders.any((o) => o.id == id));
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка завантаження замовлень: $e'), backgroundColor: Colors.red),
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

  /// Пакетне оновлення статусу обраних замовлень (Batch update)
  Future<void> _batchUpdateStatus() async {
    if (_selectedOrderIds.isEmpty) return;

    final targetStatus = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Пакетне оновлення (${_selectedOrderIds.length} замовлень)'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, DbConstants.statusCompleted),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 12),
                Text('Змінити статус на "Виконано" (completed)'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, DbConstants.statusCancelled),
            child: const Row(
              children: [
                Icon(Icons.cancel, color: Colors.red),
                SizedBox(width: 12),
                Text('Змінити статус на "Скасовано" (cancelled)'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, DbConstants.statusPending),
            child: const Row(
              children: [
                Icon(Icons.hourglass_empty, color: Colors.orange),
                SizedBox(width: 12),
                Text('Змінити статус на "В обробці" (pending)'),
              ],
            ),
          ),
        ],
      ),
    );

    if (targetStatus == null || !mounted) return;

    try {
      await widget.orderService.updateOrdersStatus(
        _selectedOrderIds.toList(),
        targetStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Пакетне оновлення виконано для ${_selectedOrderIds.length} замовлень!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isSelectionMode = false;
          _selectedOrderIds.clear();
        });
        widget.onDataChanged();
        await _loadOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка пакетного оновлення: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Пакетне видалення старих замовлень (Batch delete)
  Future<void> _showDeleteOldOrdersDialog() async {
    int days = 30;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Видалити старі замовлення (Batch)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ця пакетна операція видаляє старі виконані замовлення з бази даних SQLite. '
                'Завдяки FOREIGN KEY ON DELETE CASCADE всі зв\'язані позиції видаляються автоматично.',
              ),
              const SizedBox(height: 16),
              const Text('Видалити замовлення старші за:'),
              DropdownButton<int>(
                value: days,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Всі старіші за сьогодні')),
                  DropdownMenuItem(value: 7, child: Text('Старші за 7 днів')),
                  DropdownMenuItem(value: 30, child: Text('Старші за 30 днів')),
                  DropdownMenuItem(value: 90, child: Text('Старші за 90 днів')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => days = val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Назад'),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade100),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Видалити', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final count = await widget.orderService.deleteOldOrders(cutoff);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Видалено $count старих замовлень!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onDataChanged();
        await _loadOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка видалення: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showOrderDetails(int orderId) {
    showDialog(
      context: context,
      builder: (_) => OrderDetailsDialog(
        orderId: orderId,
        orderService: widget.orderService,
        onOrderUpdated: () {
          widget.onDataChanged();
          _loadOrders();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('Вибрано: ${_selectedOrderIds.length}')
            : const Text('Список замовлень'),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedOrderIds.clear();
                  });
                },
              )
            : null,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              tooltip: 'Вибрати всі',
              icon: const Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  _selectedOrderIds.addAll(_orders.map((o) => o.id!));
                });
              },
            ),
            IconButton(
              tooltip: 'Пакетне оновлення статусу',
              icon: const Icon(Icons.published_with_changes),
              onPressed: _selectedOrderIds.isEmpty ? null : _batchUpdateStatus,
            ),
          ] else ...[
            IconButton(
              tooltip: 'Режим вибору (Batch)',
              icon: const Icon(Icons.checklist),
              onPressed: () {
                setState(() => _isSelectionMode = true);
              },
            ),
            IconButton(
              tooltip: 'Видалити старі замовлення (Batch)',
              icon: const Icon(Icons.auto_delete_outlined),
              onPressed: _showDeleteOldOrdersDialog,
            ),
            IconButton(
              tooltip: 'Оновити',
              icon: const Icon(Icons.refresh),
              onPressed: _loadOrders,
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Всі', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('В обробці (Pending)', DbConstants.statusPending),
                const SizedBox(width: 8),
                _buildFilterChip('Виконано (Completed)', DbConstants.statusCompleted),
                const SizedBox(width: 8),
                _buildFilterChip('Скасовано (Cancelled)', DbConstants.statusCancelled),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Замовлень за обраним фільтром не знайдено',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final isSelected = _selectedOrderIds.contains(order.id);

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            if (_isSelectionMode) {
                              setState(() {
                                if (isSelected) {
                                  _selectedOrderIds.remove(order.id);
                                } else {
                                  _selectedOrderIds.add(order.id!);
                                }
                              });
                            } else {
                              _showOrderDetails(order.id!);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                if (_isSelectionMode)
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedOrderIds.add(order.id!);
                                        } else {
                                          _selectedOrderIds.remove(order.id);
                                        }
                                      });
                                    },
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Замовлення #${order.id}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(order.status).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: _getStatusColor(order.status)),
                                            ),
                                            child: Text(
                                              _getStatusText(order.status),
                                              style: TextStyle(
                                                color: _getStatusColor(order.status),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                            'Клієнт ID: ${order.userId}',
                                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Позицій: ${order.itemsCount ?? 0}',
                                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _dateFormat.format(order.createdAt),
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                          ),
                                          Text(
                                            _currencyFormat.format(order.totalAmount),
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (!_isSelectionMode)
                                  const Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = value);
          _loadOrders();
        }
      },
    );
  }
}
