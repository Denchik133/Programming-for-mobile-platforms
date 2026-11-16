import '../constants/db_constants.dart';

/// Модель позиції замовлення (OrderItem)
class OrderItem {
  final int? id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;

  // Додаткове поле (наприклад, назва товару для зручного відображення при JOIN)
  final String? productName;

  const OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.productName,
  });

  /// Створення об'єкта з Map (SQLite query)
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map[DbConstants.colItemId] as int?,
      orderId: map[DbConstants.colItemOrderId] as int,
      productId: map[DbConstants.colItemProductId] as int,
      quantity: map[DbConstants.colItemQuantity] as int,
      price: (map[DbConstants.colItemPrice] as num).toDouble(),
      productName: map['productName'] as String?,
    );
  }

  /// Перетворення в Map для збереження в SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      DbConstants.colItemOrderId: orderId,
      DbConstants.colItemProductId: productId,
      DbConstants.colItemQuantity: quantity,
      DbConstants.colItemPrice: price,
    };
    if (id != null) {
      map[DbConstants.colItemId] = id;
    }
    return map;
  }

  @override
  String toString() =>
      'OrderItem(id: $id, orderId: $orderId, productId: $productId, quantity: $quantity, price: $price, productName: $productName)';
}
