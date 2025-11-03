import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  static final _supabase = Supabase.instance.client;
  static const String _tableName = 'products';

  // Get all products from database
  static Future<List<Product>> getAllProducts() async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return (data as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Get All Products Error: $e');
      return [];
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

  // Get products by category
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      if (category == 'All') {
        return getAllProducts();
      }

      final data = await _supabase
          .from(_tableName)
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return (data as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Get Products By Category Error: $e');
      return [];
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
