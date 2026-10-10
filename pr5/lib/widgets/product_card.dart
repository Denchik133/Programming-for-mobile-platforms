import 'package:flutter/material.dart';

import '../models/product.dart';
import 'custom_button.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    required this.product,
    this.onAddToCart,
    this.onFavoriteChanged,
    super.key,
  });

  final Product product;
  final ValueChanged<Product>? onAddToCart;
  final ValueChanged<bool>? onFavoriteChanged;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late bool _isFavorite;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isImageZoomed = false;

  @override
  void initState() {
    super.initState();

    _isFavorite = widget.product.isFavorite;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.06,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.product.id != widget.product.id ||
        oldWidget.product.isFavorite != widget.product.isFavorite) {
      _isFavorite = widget.product.isFavorite;
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    widget.onFavoriteChanged?.call(_isFavorite);
  }

  void _animateImage() {
    setState(() {
      _isImageZoomed = !_isImageZoomed;
    });

    if (_isImageZoomed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: _animateImage,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    );
                  },
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: widget.product.imageUrl.isEmpty
                        ? ColoredBox(
                            color: colors.surfaceContainerHighest,
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: colors.primary,
                            ),
                          )
                        : Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return ColoredBox(
                                color: colors.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                  color: colors.onSurfaceVariant,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  tooltip: _isFavorite
                      ? 'Прибрати з обраного'
                      : 'Додати в обране',
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${widget.product.price.toStringAsFixed(2)} ₴',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomButton(
                  label: 'До кошика',
                  icon: Icons.shopping_cart_outlined,
                  expand: true,
                  onPressed: () {
                    widget.onAddToCart?.call(widget.product);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}