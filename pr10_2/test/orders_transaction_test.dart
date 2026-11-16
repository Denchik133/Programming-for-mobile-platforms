import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:order_system/constants/db_constants.dart';
import 'package:order_system/database/orders_database.dart';
import 'package:order_system/models/order_item_request.dart';
import 'package:order_system/models/product.dart';
import 'package:order_system/repositories/order_repository.dart';
import 'package:order_system/repositories/product_repository.dart';
import 'package:order_system/services/order_service.dart';

void main() {
  // Ініціалізація FFI для запуску тестів у середовищі Dart/Flutter на Mac/Linux
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late OrdersDatabase ordersDb;
  late ProductRepository productRepo;
  late OrderRepository orderRepo;
  late OrderService orderService;

  setUp(() async {
    // Створюємо повністю ізольовану in-memory базу даних для кожного тесту
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DbConstants.databaseVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON;');
        },
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${DbConstants.tableProducts} (
              ${DbConstants.colProductId} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${DbConstants.colProductName} TEXT NOT NULL,
              ${DbConstants.colProductPrice} REAL NOT NULL,
              ${DbConstants.colProductStock} INTEGER NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE ${DbConstants.tableOrders} (
              ${DbConstants.colOrderId} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${DbConstants.colOrderUserId} INTEGER NOT NULL,
              ${DbConstants.colOrderTotalAmount} REAL NOT NULL,
              ${DbConstants.colOrderStatus} TEXT NOT NULL,
              ${DbConstants.colOrderCreatedAt} TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE ${DbConstants.tableOrderItems} (
              ${DbConstants.colItemId} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${DbConstants.colItemOrderId} INTEGER NOT NULL,
              ${DbConstants.colItemProductId} INTEGER NOT NULL,
              ${DbConstants.colItemQuantity} INTEGER NOT NULL,
              ${DbConstants.colItemPrice} REAL NOT NULL,
              FOREIGN KEY (${DbConstants.colItemOrderId}) 
                REFERENCES ${DbConstants.tableOrders} (${DbConstants.colOrderId}) 
                ON DELETE CASCADE,
              FOREIGN KEY (${DbConstants.colItemProductId}) 
                REFERENCES ${DbConstants.tableProducts} (${DbConstants.colProductId})
            )
          ''');

          await db.execute('CREATE INDEX idx_order_user ON ${DbConstants.tableOrders} (${DbConstants.colOrderUserId})');
          await db.execute('CREATE INDEX idx_item_order ON ${DbConstants.tableOrderItems} (${DbConstants.colItemOrderId})');
          await db.execute('CREATE INDEX idx_item_product ON ${DbConstants.tableOrderItems} (${DbConstants.colItemProductId})');
        },
      ),
    );

    ordersDb = OrdersDatabase.withDatabase(db);
    productRepo = ProductRepository(db: ordersDb);
    orderRepo = OrderRepository(db: ordersDb);
    orderService = OrderService(db: ordersDb);

    // Додаємо тестові товари
    await productRepo.insertProduct(const Product(id: 1, name: 'MacBook Air', price: 40000.0, stock: 5));
    await productRepo.insertProduct(const Product(id: 2, name: 'iPhone 15', price: 30000.0, stock: 10));
    await productRepo.insertProduct(const Product(id: 3, name: 'AirPods Pro', price: 8000.0, stock: 2));
  });

  tearDown(() async {
    await db.close();
  });

  group('Варіант 1: Тестування транзакцій (SQLite Transactions)', () {
    test('Успішне створення замовлення: атомарне списання залишків та створення items', () async {
      final items = [
        OrderItemRequest(productId: 1, quantity: 2), // 2 * 40000 = 80000
        OrderItemRequest(productId: 2, quantity: 3), // 3 * 30000 = 90000
      ];

      final orderId = await orderService.createOrder(101, items);
      expect(orderId, isNotNull);

      // Перевіряємо замовлення
      final order = await orderRepo.getOrderById(orderId!);
      expect(order, isNotNull);
      expect(order!.userId, 101);
      expect(order.totalAmount, 170000.0);
      expect(order.status, DbConstants.statusPending);

      // Перевіряємо order_items
      final orderItems = await orderRepo.getOrderItems(orderId);
      expect(orderItems.length, 2);

      // Перевіряємо оновлений stock
      final product1 = await productRepo.getProductById(1);
      final product2 = await productRepo.getProductById(2);
      expect(product1!.stock, 3); // 5 - 2 = 3
      expect(product2!.stock, 7); // 10 - 3 = 7
    });

    test('Rollback при нестачі товару: stock не списується і замовлення не створюється', () async {
      final items = [
        OrderItemRequest(productId: 1, quantity: 1), // stock 5 (ок)
        OrderItemRequest(productId: 3, quantity: 5), // stock 2 (НЕ вистачає!)
      ];

      expect(
        () async => await orderService.createOrder(101, items),
        throwsA(isA<Exception>()),
      );

      // Перевіряємо, що транзакція повністю відкотилася
      final allOrders = await orderRepo.getAllOrders();
      expect(allOrders, isEmpty);

      final product1 = await productRepo.getProductById(1);
      final product3 = await productRepo.getProductById(3);
      expect(product1!.stock, 5); // Не списано жодної одиниці!
      expect(product3!.stock, 2); // Залишок без змін
    });

    test('Скасування замовлення (cancelOrder): повернення товару на склад та зміна статусу', () async {
      final items = [
        OrderItemRequest(productId: 3, quantity: 2), // 2 * 8000 = 16000
      ];

      final orderId = await orderService.createOrder(101, items);
      expect(orderId, isNotNull);

      // Stock став 0
      var prod3 = await productRepo.getProductById(3);
      expect(prod3!.stock, 0);

      // Скасовуємо замовлення
      final cancelResult = await orderService.cancelOrder(orderId!);
      expect(cancelResult, isTrue);

      // Перевіряємо відновлення товару на складі
      prod3 = await productRepo.getProductById(3);
      expect(prod3!.stock, 2); // Повернуто на склад!

      final updatedOrder = await orderRepo.getOrderById(orderId);
      expect(updatedOrder!.status, DbConstants.statusCancelled);
    });

    test('Foreign key CASCADE: видалення замовлення каскадно видаляє order_items', () async {
      final items = [
        OrderItemRequest(productId: 1, quantity: 1),
      ];
      final orderId = await orderService.createOrder(101, items);
      expect(orderId, isNotNull);

      var orderItems = await orderRepo.getOrderItems(orderId!);
      expect(orderItems.isNotEmpty, isTrue);

      // Видаляємо замовлення
      await orderRepo.deleteOrder(orderId);

      // Перевіряємо, що зв'язані items видалені каскадно
      final itemsInDb = await db.query(
        DbConstants.tableOrderItems,
        where: '${DbConstants.colItemOrderId} = ?',
        whereArgs: [orderId],
      );
      expect(itemsInDb, isEmpty);
    });
  });

  group('Варіант 1: Пакетні (Batch) операції та звіти', () {
    test('Batch оновлення статусів множини замовлень', () async {
      final o1 = await orderService.createOrder(1, [OrderItemRequest(productId: 2, quantity: 1)]);
      final o2 = await orderService.createOrder(2, [OrderItemRequest(productId: 2, quantity: 1)]);

      await orderService.updateOrdersStatus([o1!, o2!], DbConstants.statusCompleted);

      final order1 = await orderRepo.getOrderById(o1);
      final order2 = await orderRepo.getOrderById(o2);
      expect(order1!.status, DbConstants.statusCompleted);
      expect(order2!.status, DbConstants.statusCompleted);
    });

    test('Видалення старих замовлень за датою (deleteOldOrders)', () async {
      final orderId = await orderService.createOrder(1, [OrderItemRequest(productId: 2, quantity: 1)]);
      await orderService.updateOrdersStatus([orderId!], DbConstants.statusCompleted);

      // Оновимо дату замовлення на минулу
      await db.update(
        DbConstants.tableOrders,
        {DbConstants.colOrderCreatedAt: DateTime.now().subtract(const Duration(days: 40)).toIso8601String()},
        where: '${DbConstants.colOrderId} = ?',
        whereArgs: [orderId],
      );

      // Видаляємо замовлення старші 30 днів
      final deletedCount = await orderService.deleteOldOrders(DateTime.now().subtract(const Duration(days: 30)));
      expect(deletedCount, 1);

      final order = await orderRepo.getOrderById(orderId);
      expect(order, isNull);
    });

    test('Звіти: getOrderDetails, getTopProducts, getSalesStats', () async {
      final o1 = await orderService.createOrder(1, [
        OrderItemRequest(productId: 1, quantity: 1), // 40000
        OrderItemRequest(productId: 2, quantity: 2), // 60000
      ]);
      await orderService.updateOrdersStatus([o1!], DbConstants.statusCompleted);

      // Деталі замовлення
      final details = await orderService.getOrderDetails(o1);
      expect(details, isNotNull);
      expect(details!['items'], isNotEmpty);

      // Найпопулярніші продукти
      final top = await orderService.getTopProducts(5);
      expect(top.isNotEmpty, isTrue);
      expect(top.first['id'], 2); // iPhone 15 продано 2 шт

      // Статистика продажів
      final stats = await orderService.getSalesStats();
      expect(stats['revenue'], 100000.0);
      expect(stats['orders']['completed'], 1);
      expect(stats['orders']['total'], 1);
    });
  });
}
