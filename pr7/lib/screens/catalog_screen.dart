import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import '../models/catalog_model.dart';
import '../models/product.dart';
import 'product_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('build: CatalogScreen');

    final status = context.select<CatalogModel, CatalogStatus>(
      (catalog) => catalog.status,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мій магазин'),
        actions: [
          IconButton(
            tooltip: 'Кошик',
            onPressed: () => Navigator.pushNamed(context, '/cart'),
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
      body: switch (status) {
        CatalogStatus.initial || CatalogStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        CatalogStatus.error => _buildError(context),
        CatalogStatus.success => _buildCatalog(context),
      },
    );
  }

  Widget _buildError(BuildContext context) {
    final message = context.select<CatalogModel, String?>(
      (catalog) => catalog.errorMessage,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56),
            const SizedBox(height: 16),
            Text(message ?? 'Не вдалося завантажити товари'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<CatalogModel>().loadProducts(),
              child: const Text('Повторити'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalog(BuildContext context) {
    final categories = context.select<CatalogModel, List<String>>(
      (catalog) => catalog.categories,
    );

    final selectedCategory = context.select<CatalogModel, String>(
      (catalog) => catalog.selectedCategory,
    );

    final products = context.select<CatalogModel, List<Product>>(
      (catalog) => catalog.filteredProducts,
    );

    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final category in categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: category == selectedCategory,
                    onSelected: (_) {
                      context.read<CatalogModel>().setCategory(category);
                    },
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisExtent: 235,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          ),
        ),
      ],
    );
  }
}


class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    debugPrint('build: ProductCard ${product.id}');

    final isInCart = context.select<CartModel, bool>(
      (cart) => cart.items.any(
        (item) => item.product.id == product.id,
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ProductScreen(
                        product: product,
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported_outlined,
                              size: 56,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.price.toStringAsFixed(0)} грн',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Додати до кошика',
                  onPressed: () {
                    context.read<CartModel>().addProduct(product);
                  },
                  icon: Icon(
                    isInCart
                        ? Icons.add_shopping_cart
                        : Icons.shopping_cart_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}