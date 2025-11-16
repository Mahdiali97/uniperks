import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  static final _supabase = Supabase.instance.client;
  static const String _tableName = 'products';

  // Cache storage with timestamps
  static List<Product>? _productsCache;
  static DateTime? _productsCacheTime;
  static final Map<String, List<Product>> _categoryCache = {};
  static final Map<String, DateTime> _categoryCacheTime = {};

  // Cache validity duration (5 minutes)
  static const Duration _cacheDuration = Duration(minutes: 5);

  static bool _isCacheValid(DateTime? cacheTime) {
    if (cacheTime == null) return false;
    return DateTime.now().difference(cacheTime) < _cacheDuration;
  }

  static void clearCache() {
    _productsCache = null;
    _productsCacheTime = null;
    _categoryCache.clear();
    _categoryCacheTime.clear();
  }

  // Get all products from database with caching
  static Future<List<Product>> getAllProducts() async {
    try {
      // Return cached products if still valid
      if (_isCacheValid(_productsCacheTime) && _productsCache != null) {
        return _productsCache!;
      }

      final data = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      final products = (data as List)
          .map((json) => Product.fromJson(json))
          .toList();

      // Update cache
      _productsCache = products;
      _productsCacheTime = DateTime.now();

      return products;
    } catch (e) {
      print('Get All Products Error: $e');
      // Return cached products even if expired to handle offline scenarios
      return _productsCache ?? [];
    }
  }

  // Get product by ID
  static Future<Product?> getProduct(int id) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return Product.fromJson(data);
    } catch (e) {
      print('Get Product Error: $e');
      return null;
    }
  }

  // Get products by category with caching
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      if (category == 'All') {
        return getAllProducts();
      }

      // Return cached category products if still valid
      if (_isCacheValid(_categoryCacheTime[category]) &&
          _categoryCache[category] != null) {
        return _categoryCache[category]!;
      }

      final data = await _supabase
          .from(_tableName)
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      final products = (data as List)
          .map((json) => Product.fromJson(json))
          .toList();

      // Update cache for this category
      _categoryCache[category] = products;
      _categoryCacheTime[category] = DateTime.now();

      return products;
    } catch (e) {
      print('Get Products By Category Error: $e');
      // Return cached products even if expired
      return _categoryCache[category] ?? [];
    }
  }

  // Get available categories
  static Future<List<String>> getCategories() async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select('category')
          .order('category');

      final categories = (data as List)
          .map((item) => item['category'] as String)
          .toSet()
          .toList();

      return ['All', ...categories];
    } catch (e) {
      print('Get Categories Error: $e');
      return ['All', 'Clothing', 'Accessories', 'Stationery', 'Books'];
    }
  }

  // Add new product (Admin only)
  static Future<bool> addProduct(Product product) async {
    try {
      await _supabase.from(_tableName).insert(product.toJson());
      clearCache(); // Clear cache so new product appears immediately
      return true;
    } catch (e) {
      print('Add Product Error: $e');
      return false;
    }
  }

  // Update product (Admin only)
  static Future<bool> updateProduct(int id, Product product) async {
    try {
      await _supabase
          .from(_tableName)
          .update(product.toJsonForUpdate())
          .eq('id', id);
      clearCache(); // Clear cache so changes appear immediately
      return true;
    } catch (e) {
      print('Update Product Error: $e');
      return false;
    }
  }

  // Delete product (Admin only)
  static Future<bool> deleteProduct(int id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
      clearCache(); // Clear cache so deletion appears immediately
      return true;
    } catch (e) {
      print('Delete Product Error: $e');
      return false;
    }
  }

  // Search products
  static Future<List<Product>> searchProducts(String query) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select()
          .ilike('name', '%$query%')
          .order('created_at', ascending: false);

      return (data as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Search Products Error: $e');
      return [];
    }
  }
}
