/// Запит на додавання товару до замовлення
class OrderItemRequest {
  final int productId;
  final int quantity;

  OrderItemRequest({
    required this.productId,
    required this.quantity,
  });

  @override
  String toString() =>
      'OrderItemRequest(productId: $productId, quantity: $quantity)';
}
