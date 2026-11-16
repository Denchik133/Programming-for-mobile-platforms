import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/db_constants.dart';

/// Клас для керування підключенням до бази даних SQLite
class OrdersDatabase {
  static final OrdersDatabase instance = OrdersDatabase._init();
  static Database? _database;

  OrdersDatabase._init();

  /// Конструктор для тестування (дозволяє передавати готову БД, наприклад in-memory)
  OrdersDatabase.withDatabase(Database db) {
    _database = db;
  }

  /// Ініціалізація платформного рушія (потрібно для desktop/тестів на macOS/Linux/Windows)
  static void initPlatform() {
    if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Отримання екземпляра бази даних
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(DbConstants.databaseName);
    return _database!;
  }

  /// Відкриття та налаштування БД
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: DbConstants.databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _createDB,
    );
  }

  /// Конфігурація підключення: вмикання підтримки зовнішніх ключів (Foreign Keys)
  /// За замовчуванням у SQLite foreign keys вимкнені, тому PRAGMA є обов'язковою
  /// для коректної роботи ON DELETE CASCADE
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  /// Створення структури таблиць та індексів
  Future<void> _createDB(Database db, int version) async {
    // 1. Таблиця продуктів
    await db.execute('''
      CREATE TABLE ${DbConstants.tableProducts} (
        ${DbConstants.colProductId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colProductName} TEXT NOT NULL,
        ${DbConstants.colProductPrice} REAL NOT NULL,
        ${DbConstants.colProductStock} INTEGER NOT NULL
      )
    ''');

    // 2. Таблиця замовлень
    await db.execute('''
      CREATE TABLE ${DbConstants.tableOrders} (
        ${DbConstants.colOrderId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colOrderUserId} INTEGER NOT NULL,
        ${DbConstants.colOrderTotalAmount} REAL NOT NULL,
        ${DbConstants.colOrderStatus} TEXT NOT NULL,
        ${DbConstants.colOrderCreatedAt} TEXT NOT NULL
      )
    ''');

    // 3. Таблиця позицій замовлення із Foreign Keys (CASCADE на видалення замовлення)
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

    // 4. Індекси для прискорення вибірок та JOIN операцій
    await db.execute(
      'CREATE INDEX idx_order_user ON ${DbConstants.tableOrders} (${DbConstants.colOrderUserId})',
    );
    await db.execute(
      'CREATE INDEX idx_item_order ON ${DbConstants.tableOrderItems} (${DbConstants.colItemOrderId})',
    );
    await db.execute(
      'CREATE INDEX idx_item_product ON ${DbConstants.tableOrderItems} (${DbConstants.colItemProductId})',
    );

    // 5. Заповнення початковими товарами через Batch операцію
    await _seedInitialProducts(db);
  }

  /// Початкове наповнення товарами для демонстрації роботи
  Future<void> _seedInitialProducts(Database db) async {
    final batch = db.batch();
    final initialProducts = [
      {'name': 'Ноутбук Apple MacBook Air M2', 'price': 42999.0, 'stock': 10},
      {'name': 'Смартфон Google Pixel 8', 'price': 27500.0, 'stock': 15},
      {'name': 'Бездротові навушники Sony WH-1000XM5', 'price': 13999.0, 'stock': 20},
      {'name': 'Механічна клавіатура Keychron K2', 'price': 3800.0, 'stock': 8},
      {'name': 'Миша Logitech MX Master 3S', 'price': 4200.0, 'stock': 12},
      {'name': 'Монітор Dell UltraSharp 27" 4K', 'price': 21499.0, 'stock': 5},
    ];

    for (final p in initialProducts) {
      batch.insert(DbConstants.tableProducts, p);
    }
    await batch.commit(noResult: true);
  }

  /// Закриття з'єднання з базою даних
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Очищення та повторне скидання бази даних (для тестування та демонстрацій)
  Future<void> resetDatabase() async {
    final db = await database;
    await db.execute('DELETE FROM ${DbConstants.tableOrderItems}');
    await db.execute('DELETE FROM ${DbConstants.tableOrders}');
    await db.execute('DELETE FROM ${DbConstants.tableProducts}');
    await _seedInitialProducts(db);
  }
}
