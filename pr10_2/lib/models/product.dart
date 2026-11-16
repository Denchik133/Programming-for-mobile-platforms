import '../constants/db_constants.dart';

/// Модель товару (Product)
class Product {
  final int? id;
  final String name;
  final double price;
  final int stock;

  const Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  /// Створення об'єкта з Map (SQLite query)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map[DbConstants.colProductId] as int?,
      name: map[DbConstants.colProductName] as String,
      price: (map[DbConstants.colProductPrice] as num).toDouble(),
      stock: map[DbConstants.colProductStock] as int,
    );
  }

  /// Перетворення в Map для збереження в SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      DbConstants.colProductName: name,
      DbConstants.colProductPrice: price,
      DbConstants.colProductStock: stock,
    };
    if (id != null) {
      map[DbConstants.colProductId] = id;
    }
    return map;
  }

  Product copyWith({
    int? id,
    String? name,
    double? price,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }

  @override
  String toString() =>
      'Product(id: $id, name: $name, price: $price, stock: $stock)';
}
