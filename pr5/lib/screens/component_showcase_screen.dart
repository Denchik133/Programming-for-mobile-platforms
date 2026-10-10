
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../widgets/animated_counter.dart';
import '../widgets/custom_button.dart';
import '../widgets/product_card.dart';
import '../widgets/profile_widget.dart';

class ComponentShowcaseScreen extends StatelessWidget {
  const ComponentShowcaseScreen({super.key});

  static const User _user = User(
    name: 'Олександр',
    email: 'oleksandr@example.com',
    avatarUrl: '',
  );

  static const Product _product = Product(
    id: 'showcase-1',
    name: 'Навушники Pro',
    description: 'Бездротові навушники з якісним звуком.',
    price: 2499.99,
    imageUrl: '',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Showcase'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Демонстрація компонентів',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Приклади власних віджетів, їхніх станів '
                'та інтерактивності.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              Text('1. CustomButton',
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  CustomButton(
                    label: 'Основна кнопка',
                    onPressed: () => _showMessage(
                      context,
                      'Натиснуто основну кнопку',
                    ),
                  ),
                  CustomButton(
                    label: 'Другорядна',
                    variant: CustomButtonVariant.secondary,
                    onPressed: () => _showMessage(
                      context,
                      'Натиснуто другорядну кнопку',
                    ),
                  ),
                  CustomButton(
                    label: 'Контурна',
                    variant: CustomButtonVariant.outlined,
                    onPressed: () => _showMessage(
                      context,
                      'Натиснуто контурну кнопку',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text('2. AnimatedCounter',
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              const AnimatedCounter(
                initialValue: 3,
                minValue: 0,
                maxValue: 10,
              ),
              const SizedBox(height: 24),

              Text('3. ProfileWidget',
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              ProfileWidget(
                user: _user,
                onEdit: () => _showMessage(
                  context,
                  'Натиснуто редагування профілю',
                ),
              ),
              const SizedBox(height: 24),

              Text('4. ProductCard',
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: ProductCard(
                  product: _product,
                  onAddToCart: (product) => _showMessage(
                    context,
                    '${product.name} додано до демонстраційного кошика',
                  ),
                  onFavoriteChanged: (isFavorite) =>
                      _showMessage(
                    context,
                    isFavorite
                        ? 'Товар додано в обране'
                        : 'Товар видалено з обраного',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}