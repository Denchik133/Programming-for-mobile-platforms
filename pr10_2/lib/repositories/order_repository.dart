import 'package:sqflite/sqflite.dart';

import '../constants/db_constants.dart';
import '../database/orders_database.dart';
import '../models/order.dart';
import '../models/order_item.dart';

/// Репозиторій для роботи з таблицями замовлень (orders) та позицій (order_items)
class OrderRepository {
  final OrdersDatabase _dbInstance;

  OrderRepository({OrdersDatabase? db})
      : _dbInstance = db ?? OrdersDatabase.instance;

  Future<Database> get _db => _dbInstance.database;

  /// Отримати список замовлень з можливістю фільтрації за статусом
  /// Використовує LEFT JOIN для підрахунку кількості товарів у кожному замовленні
  Future<List<Order>> getAllOrders({String? status}) async {
    final db = await _db;

    String query = '''
      SELECT o.*, COUNT(oi.${DbConstants.colItemId}) as itemsCount
      FROM ${DbConstants.tableOrders} o
      LEFT JOIN ${DbConstants.tableOrderItems} oi ON o.${DbConstants.colOrderId} = oi.${DbConstants.colItemOrderId}
    ''';

    List<dynamic> args = [];
    if (status != null && status.isNotEmpty && status != 'all') {
      query += ' WHERE o.${DbConstants.colOrderStatus} = ?';
      args.add(status);
    }

    query += '''
      GROUP BY o.${DbConstants.colOrderId}
      ORDER BY o.${DbConstants.colOrderCreatedAt} DESC
    ''';

    final List<Map<String, dynamic>> results = await db.rawQuery(query, args);
    return results.map((m) => Order.fromMap(m)).toList();
  }

  /// Отримати замовлення за ID
  Future<Order?> getOrderById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> results = await db.query(
      DbConstants.tableOrders,
      where: '${DbConstants.colOrderId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Order.fromMap(results.first);
  }

  /// Отримати список позицій конкретного замовлення з назвами товарів (INNER JOIN)
  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final db = await _db;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT oi.*, p.${DbConstants.colProductName} as productName
      FROM ${DbConstants.tableOrderItems} oi
      INNER JOIN ${DbConstants.tableProducts} p 
        ON oi.${DbConstants.colItemProductId} = p.${DbConstants.colProductId}
      WHERE oi.${DbConstants.colItemOrderId} = ?
      ORDER BY oi.${DbConstants.colItemId} ASC
    ''', [orderId]);

    return results.map((m) => OrderItem.fromMap(m)).toList();
  }

  /// Видалити замовлення за ID
  /// Завдяки FOREIGN KEY ON DELETE CASCADE зв'язані order_items видаляються автоматично!
  Future<int> deleteOrder(int orderId) async {
    final db = await _db;
    return await db.delete(
      DbConstants.tableOrders,
      where: '${DbConstants.colOrderId} = ?',
      whereArgs: [orderId],
    );
  }
}
