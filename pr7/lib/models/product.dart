
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
  });
}

const List<Product> demoProducts = [
  Product(
    id: 1,
    name: 'Бездротові навушники',
    description: 'Навушники з якісним звуком і зручним дизайном.',
    price: 1499.0,
    category: 'Електроніка',
    imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600',
  ),
  Product(
    id: 2,
    name: 'Смартгодинник',
    description: 'Годинник для відстеження активності та сповіщень.',
    price: 2299.0,
    category: 'Електроніка',
    imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600',
  ),
  Product(
    id: 3,
    name: 'Рюкзак міський',
    description: 'Практичний рюкзак для навчання та щоденних справ.',
    price: 899.0,
    category: 'Аксесуари',
    imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600',
  ),
  Product(
    id: 4,
    name: 'Настільна лампа',
    description: 'Лампа для комфортної роботи та навчання.',
    price: 649.0,
    category: 'Дім',
    imageUrl: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=600',
  ),
  Product(
    id: 5,
    name: 'Портативна колонка',
    description: 'Компактна колонка для прослуховування музики.',
    price: 1199.0,
    category: 'Електроніка',
    imageUrl: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=600',
  ),
  Product(
    id: 6,
    name: 'Пляшка для води',
    description: 'Багаторазова пляшка для води на кожен день.',
    price: 299.0,
    category: 'Аксесуари',
    imageUrl: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=600',
  ),
];
