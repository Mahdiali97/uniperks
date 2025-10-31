import '../models/product.dart';

class ProductService {
  static final List<Product> _products = [
    Product(
      id: '1',
      name: 'University Hoodie',
      description: 'Comfortable cotton hoodie with university logo',
      price: 45.99,
      imageUrl: 'https://via.placeholder.com/200x200?text=Hoodie',
      category: 'Clothing',
      discount: 20,
    ),
    Product(
      id: '2',
      name: 'Study Planner',
      description: 'Academic year planner for students',
      price: 12.99,
      imageUrl: 'https://via.placeholder.com/200x200?text=Planner',
      category: 'Stationery',
      discount: 15,
    ),
    Product(
      id: '3',
      name: 'Coffee Mug',
      description: 'Insulated coffee mug with university branding',
      price: 18.99,
      imageUrl: 'https://via.placeholder.com/200x200?text=Mug',
      category: 'Accessories',
      discount: 10,
    ),
    Product(
      id: '4',
      name: 'Laptop Bag',
      description: 'Durable laptop bag for students',
      price: 35.99,
      imageUrl: 'https://via.placeholder.com/200x200?text=Bag',
      category: 'Accessories',
      discount: 25,
    ),
    Product(
      id: '5',
      name: 'Textbook Bundle',
      description: 'Essential textbooks for semester',
      price: 120.00,
      imageUrl: 'https://via.placeholder.com/200x200?text=Books',
      category: 'Books',
      discount: 30,
    ),
    Product(
      id: '6',
      name: 'Campus T-Shirt',
      description: 'Official campus t-shirt',
      price: 24.99,
      imageUrl: 'https://via.placeholder.com/200x200?text=TShirt',
      category: 'Clothing',
      discount: 0,
    ),
  ];

  static List<Product> getAllProducts() {
    return _products;
  }

  static List<String> getCategories() {
    return ['All', 'Clothing', 'Accessories', 'Stationery', 'Books'];
  }

  static void addProduct(Product product) {
    _products.add(product);
  }

  static void updateProduct(int index, Product product) {
    if (index >= 0 && index < _products.length) {
      _products[index] = product;
    }
  }

  static void removeProduct(int index) {
    if (index >= 0 && index < _products.length) {
      _products.removeAt(index);
    }
  }

  static Product? getProduct(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}