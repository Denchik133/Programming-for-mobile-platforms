import '../constants/db_constants.dart';

/// Модель замовлення (Order)
class Order {
  final int? id;
  final int userId;
  final double totalAmount;
  final String status; // pending, completed, cancelled
  final DateTime createdAt;

  // Додаткове агреговане поле для UI (наприклад, itemsCount при JOIN)
  final int? itemsCount;

  const Order({
    this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.itemsCount,
  });

  /// Створення об'єкта з Map (SQLite query)
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map[DbConstants.colOrderId] as int?,
      userId: map[DbConstants.colOrderUserId] as int,
      totalAmount: (map[DbConstants.colOrderTotalAmount] as num).toDouble(),
      status: map[DbConstants.colOrderStatus] as String,
      createdAt: DateTime.parse(map[DbConstants.colOrderCreatedAt] as String),
      itemsCount: map['itemsCount'] as int?,
    );
  }

  /// Перетворення в Map для збереження в SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      DbConstants.colOrderUserId: userId,
      DbConstants.colOrderTotalAmount: totalAmount,
      DbConstants.colOrderStatus: status,
      DbConstants.colOrderCreatedAt: createdAt.toIso8601String(),
    };
    if (id != null) {
      map[DbConstants.colOrderId] = id;
    }
    return map;
  }

  Order copyWith({
    int? id,
    int? userId,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
    int? itemsCount,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      itemsCount: itemsCount ?? this.itemsCount,
    );
  }

  @override
  String toString() =>
      'Order(id: $id, userId: $userId, totalAmount: $totalAmount, status: $status, createdAt: $createdAt)';
}
