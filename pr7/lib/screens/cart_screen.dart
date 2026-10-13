import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import '../models/order_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('build: CartScreen');

    final items = context.select<CartModel, List<CartItem>>(
      (cart) => cart.items,
    );

    final totalPrice = context.select<CartModel, double>(
      (cart) => cart.totalPrice,
    );

    final itemCount = context.select<CartModel, int>((cart) => cart.itemCount);

    final isLoading = context.select<OrderModel, bool>(
      (order) => order.isLoading,
    );

    final errorMessage = context.select<OrderModel, String?>(
      (order) => order.errorMessage,
    );

    final successMessage = context.select<OrderModel, String?>(
      (order) => order.successMessage,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Кошик'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Badge(
                label: Text('$itemCount'),
                isLabelVisible: itemCount > 0,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Кошик порожній'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return CartItemTile(item: items[index]);
                    },
                  ),
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                errorMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (successMessage != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                successMessage,
                style: const TextStyle(color: Colors.green),
              ),
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Товарів: $itemCount',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Разом: ${totalPrice.toStringAsFixed(2)} грн',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: items.isEmpty || isLoading
                      ? null
                      : () async {
                          await context.read<OrderModel>().placeOrder(
                            context.read<CartModel>(),
                          );
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Оформити замовлення'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    debugPrint('build: CartItemTile ${item.product.id}');

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.shopping_bag_outlined)),
      title: Text(item.product.name),
      subtitle: Text('${item.product.price.toStringAsFixed(2)} грн за одиницю'),
      trailing: SizedBox(
        width: 145,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              tooltip: 'Зменшити кількість',
              onPressed: () {
                context.read<CartModel>().decreaseQuantity(item.product.id);
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('${item.quantity}'),
            IconButton(
              tooltip: 'Збільшити кількість',
              onPressed: () {
                context.read<CartModel>().increaseQuantity(item.product.id);
              },
              icon: const Icon(Icons.add_circle_outline),
            ),
            IconButton(
              tooltip: 'Видалити товар',
              onPressed: () {
                context.read<CartModel>().removeProduct(item.product.id);
              },
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
