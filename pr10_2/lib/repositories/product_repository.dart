import 'package:sqflite/sqflite.dart';

import '../constants/db_constants.dart';
import '../database/orders_database.dart';
import '../models/product.dart';

/// Репозиторій для роботи з таблицею продуктів (products)
class ProductRepository {
  final OrdersDatabase _dbInstance;

  ProductRepository({OrdersDatabase? db})
      : _dbInstance = db ?? OrdersDatabase.instance;

  Future<Database> get _db => _dbInstance.database;

  /// Отримати список усіх товарів
  Future<List<Product>> getAllProducts() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbConstants.tableProducts,
      orderBy: '${DbConstants.colProductName} ASC',
    );
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  /// Отримати товар за ID
  Future<Product?> getProductById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbConstants.tableProducts,
      where: '${DbConstants.colProductId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  /// Створити новий товар
  Future<int> insertProduct(Product product) async {
    final db = await _db;
    return await db.insert(
      DbConstants.tableProducts,
      product.toMap(),
    );
  }

  /// Оновити дані товару
  Future<int> updateProduct(Product product) async {
    final db = await _db;
    return await db.update(
      DbConstants.tableProducts,
      product.toMap(),
      where: '${DbConstants.colProductId} = ?',
      whereArgs: [product.id],
    );
  }

  /// Оновити залишок товару на складі
  Future<int> updateStock(int productId, int newStock) async {
    final db = await _db;
    return await db.update(
      DbConstants.tableProducts,
      {DbConstants.colProductStock: newStock},
      where: '${DbConstants.colProductId} = ?',
      whereArgs: [productId],
    );
  }

  /// Додати множину товарів одночасно через Batch операцію
  Future<void> batchInsertProducts(List<Product> products) async {
    final db = await _db;
    final batch = db.batch();
    for (final product in products) {
      batch.insert(DbConstants.tableProducts, product.toMap());
    }
    await batch.commit(noResult: true);
  }

  /// Видалити товар за ID
  Future<int> deleteProduct(int id) async {
    final db = await _db;
    return await db.delete(
      DbConstants.tableProducts,
      where: '${DbConstants.colProductId} = ?',
      whereArgs: [id],
    );
  }
}
