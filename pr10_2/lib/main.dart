import 'package:flutter/material.dart';

import 'database/orders_database.dart';
import 'repositories/order_repository.dart';
import 'repositories/product_repository.dart';
import 'screens/analytics_screen.dart';
import 'screens/create_order_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/products_screen.dart';
import 'services/order_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ініціалізація SQLite FFI для настільних платформ (macOS/Windows/Linux)
  OrdersDatabase.initPlatform();

  // Попереднє відкриття бази даних
  await OrdersDatabase.instance.database;

  runApp(const OrderSystemApp());
}

class OrderSystemApp extends StatelessWidget {
  const OrderSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Система замовлень (SQLite)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final ProductRepository _productRepository;
  late final OrderRepository _orderRepository;
  late final OrderService _orderService;

  int _dataVersion = 0;

  @override
  void initState() {
    super.initState();
    _productRepository = ProductRepository();
    _orderRepository = OrderRepository();
    _orderService = OrderService();
  }

  void _onDataChanged() {
    setState(() {
      _dataVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      OrdersScreen(
        key: ValueKey('orders_$_dataVersion'),
        orderRepository: _orderRepository,
        orderService: _orderService,
        onDataChanged: _onDataChanged,
      ),
      CreateOrderScreen(
        key: ValueKey('create_$_dataVersion'),
        orderService: _orderService,
        productRepository: _productRepository,
        onOrderCreated: () {
          _onDataChanged();
          setState(() => _currentIndex = 0); // Перехід до списку замовлень
        },
      ),
      ProductsScreen(
        key: ValueKey('products_$_dataVersion'),
        productRepository: _productRepository,
        onProductUpdated: _onDataChanged,
      ),
      AnalyticsScreen(
        key: ValueKey('analytics_$_dataVersion'),
        orderService: _orderService,
        productRepository: _productRepository,
        onDataChanged: _onDataChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Замовлення',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_shopping_cart_outlined),
            selectedIcon: Icon(Icons.add_shopping_cart),
            label: 'Створити',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Склад',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Аналітика',
          ),
        ],
      ),
    );
  }
}
