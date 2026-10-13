import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import '../models/product.dart';

class ProductScreen extends StatelessWidget {
  final Product product;

  const ProductScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            tooltip: 'Кошик',
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            icon: Selector<CartModel, int>(
              selector: (_, cart) => cart.itemCount,
              builder: (_, count, _) {
                return Badge(
                  label: Text('$count'),
                  isLabelVisible: count > 0,
                  child: const Icon(Icons.shopping_cart_outlined),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 220,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 56,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              product.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(product.description),
            const SizedBox(height: 20),
            Text(
              '${product.price.toStringAsFixed(2)} грн',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  context.read<CartModel>().addProduct(product);
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('До кошика'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
