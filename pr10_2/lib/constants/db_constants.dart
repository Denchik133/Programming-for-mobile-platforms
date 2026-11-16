/// Константи бази даних SQLite для системи замовлень
class DbConstants {
  DbConstants._();

  static const String databaseName = 'orders_system.db';
  static const int databaseVersion = 1;

  // Таблиця продуктів
  static const String tableProducts = 'products';
  static const String colProductId = 'id';
  static const String colProductName = 'name';
  static const String colProductPrice = 'price';
  static const String colProductStock = 'stock';

  // Таблиця замовлень
  static const String tableOrders = 'orders';
  static const String colOrderId = 'id';
  static const String colOrderUserId = 'userId';
  static const String colOrderTotalAmount = 'totalAmount';
  static const String colOrderStatus = 'status';
  static const String colOrderCreatedAt = 'createdAt';

  // Таблиця елементів замовлення
  static const String tableOrderItems = 'order_items';
  static const String colItemId = 'id';
  static const String colItemOrderId = 'orderId';
  static const String colItemProductId = 'productId';
  static const String colItemQuantity = 'quantity';
  static const String colItemPrice = 'price';

  // Статуси замовлення
  static const String statusPending = 'pending';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Список доступних статусів
  static const List<String> allStatuses = [
    statusPending,
    statusCompleted,
    statusCancelled,
  ];
}
