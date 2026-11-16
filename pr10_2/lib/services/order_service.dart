import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/db_constants.dart';
import '../database/orders_database.dart';
import '../models/order_item_request.dart';

/// Сервіс обробки замовлень
/// Реалізує транзакційну логіку, пакетні (batch) операції та формування звітів
class OrderService {
  final OrdersDatabase _db;

  OrderService({OrdersDatabase? db}) : _db = db ?? OrdersDatabase.instance;

  /// Створити замовлення з елементами як єдину АТОМАРНУ транзакцію
  ///
  /// Гарантії транзакції:
  /// 1. Перевірка наявності всіх товарів на складі
  /// 2. Перевірка достатності залишку (stock >= quantity)
  /// 3. Підрахунок актуальної підсумкової суми (totalAmount) на основі цін у БД
  /// 4. Створення запису замовлення в таблиці orders
  /// 5. Створення записів елементів у таблиці order_items
  /// 6. Декремент залишків (stock = stock - quantity) у таблиці products
  ///
  /// Якщо хоча б один товар відсутній або його недостатньо на складі,
  /// викидається виключення, і SQLite АВТОМАТИЧНО виконує ROLLBACK.
  /// База даних залишається в попередньому узгодженому стані.
  Future<int?> createOrder(
    int userId,
    List<OrderItemRequest> items,
  ) async {
    if (items.isEmpty) {
      throw ArgumentError('Замовлення повинно містити хоча б один товар');
    }

    final db = await _db.database;

    try {
      return await db.transaction((txn) async {
        // Кеш цін та залишків для уникнення повторних запитів
        final Map<int, Map<String, dynamic>> productCache = {};

        // 1. Перевірка наявності товарів та залишків на складі
        for (final item in items) {
          final productResult = await txn.query(
            DbConstants.tableProducts,
            where: '${DbConstants.colProductId} = ?',
            whereArgs: [item.productId],
          );

          if (productResult.isEmpty) {
            throw Exception('Товар з ID ${item.productId} не знайдено в базі!');
          }

          final productData = productResult.first;
          final currentStock = productData[DbConstants.colProductStock] as int;
          final productName = productData[DbConstants.colProductName] as String;

          if (currentStock < item.quantity) {
            throw Exception(
              'Недостатньо товару на складі: "$productName" (ID: ${item.productId}). '
              'Запитувано: ${item.quantity}, доступно: $currentStock.',
            );
          }

          productCache[item.productId] = productData;
        }

        // 2. Підрахунок загальної суми замовлення (totalAmount)
        double totalAmount = 0.0;
        for (final item in items) {
          final productData = productCache[item.productId]!;
          final price = (productData[DbConstants.colProductPrice] as num).toDouble();
          totalAmount += price * item.quantity;
        }

        // 3. Створення запису замовлення (status: pending)
        final orderId = await txn.insert(DbConstants.tableOrders, {
          DbConstants.colOrderUserId: userId,
          DbConstants.colOrderTotalAmount: totalAmount,
          DbConstants.colOrderStatus: DbConstants.statusPending,
          DbConstants.colOrderCreatedAt: DateTime.now().toIso8601String(),
        });

        // 4. Додавання позицій замовлення та 5. Оновлення залишків на складі
        for (final item in items) {
          final productData = productCache[item.productId]!;
          final price = (productData[DbConstants.colProductPrice] as num).toDouble();

          // Додаємо позицію замовлення
          await txn.insert(DbConstants.tableOrderItems, {
            DbConstants.colItemOrderId: orderId,
            DbConstants.colItemProductId: item.productId,
            DbConstants.colItemQuantity: item.quantity,
            DbConstants.colItemPrice: price,
          });

          // Атомарно зменшуємо stock товару
          await txn.rawUpdate(
            'UPDATE ${DbConstants.tableProducts} '
            'SET ${DbConstants.colProductStock} = ${DbConstants.colProductStock} - ? '
            'WHERE ${DbConstants.colProductId} = ?',
            [item.quantity, item.productId],
          );
        }

        debugPrint('Order created successfully: $orderId, Total: $totalAmount');
        return orderId;
      });
    } catch (e) {
      debugPrint('Error creating order (Transaction rolled back): $e');
      // Перевикидаємо виключення або повертаємо null для обробки в UI
      rethrow;
    }
  }

  /// Скасувати замовлення з поверненням товарів на склад (ТРАНЗАКЦІЯ)
  ///
  /// 1. Отримуються всі позиції замовлення
  /// 2. Для кожної позиції залишок товару збільшується на придбану кількість
  /// 3. Статус замовлення оновлюється на 'cancelled'
  /// При виникненні будь-якої помилки зміни відкочуються
  Future<bool> cancelOrder(int orderId) async {
    final db = await _db.database;

    try {
      return await db.transaction((txn) async {
        // Перевіряємо поточний статус замовлення
        final orderCheck = await txn.query(
          DbConstants.tableOrders,
          columns: [DbConstants.colOrderStatus],
          where: '${DbConstants.colOrderId} = ?',
          whereArgs: [orderId],
        );

        if (orderCheck.isEmpty) {
          throw Exception('Замовлення #$orderId не знайдено');
        }

        final currentStatus = orderCheck.first[DbConstants.colOrderStatus] as String;
        if (currentStatus == DbConstants.statusCancelled) {
          throw Exception('Замовлення вже скасовано раніше');
        }

        // 1. Отримати позиції замовлення
        final items = await txn.query(
          DbConstants.tableOrderItems,
          where: '${DbConstants.colItemOrderId} = ?',
          whereArgs: [orderId],
        );

        // 2. Повернути товари на склад (інкремент stock)
        for (final item in items) {
          final quantity = item[DbConstants.colItemQuantity] as int;
          final productId = item[DbConstants.colItemProductId] as int;

          await txn.rawUpdate(
            'UPDATE ${DbConstants.tableProducts} '
            'SET ${DbConstants.colProductStock} = ${DbConstants.colProductStock} + ? '
            'WHERE ${DbConstants.colProductId} = ?',
            [quantity, productId],
          );
        }

        // 3. Оновити статус замовлення на 'cancelled'
        await txn.update(
          DbConstants.tableOrders,
          {DbConstants.colOrderStatus: DbConstants.statusCancelled},
          where: '${DbConstants.colOrderId} = ?',
          whereArgs: [orderId],
        );

        debugPrint('Order $orderId cancelled and items returned to stock');
        return true;
      });
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      return false;
    }
  }

  /// Завершити замовлення (перевести в статус 'completed')
  Future<bool> completeOrder(int orderId) async {
    final db = await _db.database;
    try {
      final rows = await db.update(
        DbConstants.tableOrders,
        {DbConstants.colOrderStatus: DbConstants.statusCompleted},
        where: '${DbConstants.colOrderId} = ? AND ${DbConstants.colOrderStatus} = ?',
        whereArgs: [orderId, DbConstants.statusPending],
      );
      return rows > 0;
    } catch (e) {
      debugPrint('Error completing order: $e');
      return false;
    }
  }

  /// Пакетне (Batch) оновлення статусу множини замовлень
  /// Використовує db.batch() для виконання всіх UPDATE в одному мережевому/файловому циклі
  Future<void> updateOrdersStatus(List<int> orderIds, String status) async {
    if (orderIds.isEmpty) return;

    final db = await _db.database;
    final Batch batch = db.batch();

    for (final orderId in orderIds) {
      batch.update(
        DbConstants.tableOrders,
        {DbConstants.colOrderStatus: status},
        where: '${DbConstants.colOrderId} = ?',
        whereArgs: [orderId],
      );
    }

    await batch.commit(noResult: true);
    debugPrint('Batch update completed for ${orderIds.length} orders -> $status');
  }

  /// Пакетне видалення старих виконаних/скасованих замовлень
  /// Завдяки ON DELETE CASCADE зв'язані order_items видаляються автоматично
  Future<int> deleteOldOrders(DateTime before, {String status = DbConstants.statusCompleted}) async {
    final db = await _db.database;
    final count = await db.delete(
      DbConstants.tableOrders,
      where: '${DbConstants.colOrderCreatedAt} < ? AND ${DbConstants.colOrderStatus} = ?',
      whereArgs: [before.toIso8601String(), status],
    );
    debugPrint('Deleted $count old orders before $before with status $status');
    return count;
  }

  /// Звіт: Деталі замовлення із агрегацією кількості позицій та JOIN до товарів
  Future<Map<String, dynamic>?> getOrderDetails(int orderId) async {
    final db = await _db.database;

    final orderData = await db.rawQuery('''
      SELECT o.*, COUNT(oi.${DbConstants.colItemId}) as itemsCount
      FROM ${DbConstants.tableOrders} o
      LEFT JOIN ${DbConstants.tableOrderItems} oi 
        ON o.${DbConstants.colOrderId} = oi.${DbConstants.colItemOrderId}
      WHERE o.${DbConstants.colOrderId} = ?
      GROUP BY o.${DbConstants.colOrderId}
    ''', [orderId]);

    if (orderData.isEmpty) return null;

    final items = await db.rawQuery('''
      SELECT oi.*, p.${DbConstants.colProductName} as productName
      FROM ${DbConstants.tableOrderItems} oi
      INNER JOIN ${DbConstants.tableProducts} p 
        ON oi.${DbConstants.colItemProductId} = p.${DbConstants.colProductId}
      WHERE oi.${DbConstants.colItemOrderId} = ?
    ''', [orderId]);

    return {
      'order': orderData.first,
      'items': items,
    };
  }

  /// Звіт: Найпопулярніші продукти (за кількістю проданих одиниць у завершених замовленнях)
  Future<List<Map<String, dynamic>>> getTopProducts(int limit) async {
    final db = await _db.database;

    return await db.rawQuery('''
      SELECT 
        p.${DbConstants.colProductId},
        p.${DbConstants.colProductName},
        p.${DbConstants.colProductPrice},
        p.${DbConstants.colProductStock},
        SUM(oi.${DbConstants.colItemQuantity}) as totalSold
      FROM ${DbConstants.tableProducts} p
      INNER JOIN ${DbConstants.tableOrderItems} oi 
        ON p.${DbConstants.colProductId} = oi.${DbConstants.colItemProductId}
      INNER JOIN ${DbConstants.tableOrders} o 
        ON oi.${DbConstants.colItemOrderId} = o.${DbConstants.colOrderId}
      WHERE o.${DbConstants.colOrderStatus} = '${DbConstants.statusCompleted}'
      GROUP BY p.${DbConstants.colProductId}
      ORDER BY totalSold DESC
      LIMIT ?
    ''', [limit]);
  }

  /// Звіт: Статистика продажів (загальний виторг та розподіл статусів)
  Future<Map<String, dynamic>> getSalesStats() async {
    final db = await _db.database;

    // 1. Загальний виторг від завершених замовлень
    final totalRevenue = await db.rawQuery('''
      SELECT SUM(${DbConstants.colOrderTotalAmount}) as revenue
      FROM ${DbConstants.tableOrders}
      WHERE ${DbConstants.colOrderStatus} = '${DbConstants.statusCompleted}'
    ''');

    // 2. Розподіл кількості замовлень за статусами
    final ordersCount = await db.rawQuery('''
      SELECT
        COUNT(*) as total,
        SUM(CASE WHEN ${DbConstants.colOrderStatus} = '${DbConstants.statusPending}' THEN 1 ELSE 0 END) as pending,
        SUM(CASE WHEN ${DbConstants.colOrderStatus} = '${DbConstants.statusCompleted}' THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN ${DbConstants.colOrderStatus} = '${DbConstants.statusCancelled}' THEN 1 ELSE 0 END) as cancelled
      FROM ${DbConstants.tableOrders}
    ''');

    final Map<String, dynamic> countData = ordersCount.isNotEmpty ? ordersCount.first : {};

    return {
      'revenue': (totalRevenue.first['revenue'] as num?)?.toDouble() ?? 0.0,
      'orders': {
        'total': (countData['total'] as num?)?.toInt() ?? 0,
        'pending': (countData['pending'] as num?)?.toInt() ?? 0,
        'completed': (countData['completed'] as num?)?.toInt() ?? 0,
        'cancelled': (countData['cancelled'] as num?)?.toInt() ?? 0,
      },
    };
  }
}
