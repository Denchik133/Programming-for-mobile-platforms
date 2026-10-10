import 'package:flutter/material.dart';

import 'models/product.dart';
import 'models/user.dart';
import 'utils/app_state.dart';
import 'utils/app_theme.dart';
import 'widgets/animated_counter.dart';
import 'widgets/product_card.dart';
import 'widgets/profile_widget.dart';
import 'screens/component_showcase_screen.dart';

void main() {
  runApp(const WidgetsShowcaseApp());
}

class WidgetsShowcaseApp extends StatelessWidget {
  const WidgetsShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Widgets Showcase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppState _appState = AppState();

  static const User _currentUser = User(
    name: 'Олександр',
    email: 'oleksandr@example.com',
    avatarUrl: '',
  );

  static const List<Product> _products = [
    Product(
      id: '1',
      name: 'Навушники Pro',
      description: 'Бездротові навушники з якісним звуком.',
      price: 2499.99,
      imageUrl: '',
    ),
    Product(
      id: '2',
      name: 'Смартгодинник',
      description: 'Зручний помічник для щоденних справ.',
      price: 3299.00,
      imageUrl: '',
    ),
    Product(
      id: '3',
      name: 'Портативна колонка',
      description: 'Компактна колонка для музики будь-де.',
      price: 1799.50,
      imageUrl: '',
    ),
  ];

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Widget Store',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          AnimatedBuilder(
            animation: _appState,
            builder: (context, child) {
              return IconButton(
                tooltip: 'Кошик: ${_appState.cartCount}',
                onPressed: () {
                  _showMessage(
                    'Товарів у кошику: ${_appState.cartCount}',
                  );
                },
                icon: Badge(
                  label: Text('${_appState.cartCount}'),
                  isLabelVisible: _appState.cartCount > 0,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _appState,
            builder: (context, child) {
              return IconButton(
                tooltip: 'Обране: ${_appState.favoritesCount}',
                onPressed: () {
                  _showMessage(
                    'Обраних товарів: ${_appState.favoritesCount}',
                  );
                },
                icon: Badge(
                  label: Text('${_appState.favoritesCount}'),
                  isLabelVisible: _appState.favoritesCount > 0,
                  child: const Icon(Icons.favorite_border),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Демонстрація компонентів',
            icon: const Icon(Icons.widgets_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const ComponentShowcaseScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Профіль',
            onPressed: () {
              _showMessage('Ви переглядаєте профіль користувача');
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Вітаємо у Widget Store!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Демонстрація власних Flutter-віджетів та анімацій.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                const _WelcomeCard(),
                const SizedBox(height: 24),

                Text(
                  'Профіль користувача',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ProfileWidget(
                  user: _currentUser,
                  onEdit: () {
                    _showMessage(
                      'Редагування профілю буде додано пізніше',
                    );
                  },
                ),
                const SizedBox(height: 24),

                Text(
                  'Демонстрація анімацій',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const AnimatedCounter(
                  initialValue: 3,
                  minValue: 0,
                  maxValue: 10,
                ),
                const SizedBox(height: 24),

                Text(
                  'Каталог товарів',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 800
                        ? 3
                        : constraints.maxWidth >= 520
                            ? 2
                            : 1;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _products.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: columns == 1 ? 1.15 : 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final product = _products[index];

                        return ProductCard(
                          product: product.copyWith(
                            isFavorite: _appState.isFavorite(product.id),
                          ),
                          onAddToCart: (selectedProduct) {
                            _appState.addToCart(selectedProduct);
                            _showMessage(
                              '${selectedProduct.name} додано до кошика',
                            );
                          },
                          onFavoriteChanged: (isFavorite) {
                            _appState.toggleFavorite(product);
                            _showMessage(
                              isFavorite
                                  ? '${product.name} додано в обране'
                                  : '${product.name} видалено з обраного',
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                Text(
                  'Компоненти проєкту',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FeatureChip(
                      icon: Icons.person_outline,
                      label: 'Профіль користувача',
                    ),
                    _FeatureChip(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Картки товарів',
                    ),
                    _FeatureChip(
                      icon: Icons.animation,
                      label: 'Анімації',
                    ),
                    _FeatureChip(
                      icon: Icons.touch_app_outlined,
                      label: 'Інтерактивність',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.tertiary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.widgets_outlined,
            color: colors.onPrimary,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'Власні віджети. Єдиний дизайн.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Навчальний проєкт із повторно використовуваними '
            'компонентами, керуванням станом і плавними анімаціями.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.onPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text(label),
      padding: const EdgeInsets.all(8),
    );
  }
}