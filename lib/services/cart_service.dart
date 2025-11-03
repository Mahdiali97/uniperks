import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'product_service.dart';

class CartService {
  static final _supabase = Supabase.instance.client;
  static const String _tableName = 'user_carts';

  // Get cart items for user
  static Future<List<CartItem>> getCartItems(String username) async {
    try {
      final cartData = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .maybeSingle();

      if (cartData != null) {
        final items = cartData['items'] as List<dynamic>? ?? [];
        List<CartItem> cartItems = [];

        for (var item in items) {
          final itemMap = item as Map<String, dynamic>;
          final productId = itemMap['product_id'] as String;
          final quantity = itemMap['quantity'] as int? ?? 1;

          final product = ProductService.getProduct(productId);
          if (product != null) {
            cartItems.add(CartItem(product: product, quantity: quantity));
          }
        }

        return cartItems;
      }

      return [];
    } catch (e) {
      print('Get Cart Items Error: $e');
      return [];
    }
  }

  // Add product to cart
  static Future<void> addToCart(
    String username,
    Product product, {
    int quantity = 1,
  }) async {
    try {
      final cartData = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .maybeSingle();

      List<Map<String, dynamic>> items = [];

      if (cartData != null) {
        items = List<Map<String, dynamic>>.from(
          cartData['items'] as List? ?? [],
        );

        // Check if product already in cart
        bool found = false;
        for (int i = 0; i < items.length; i++) {
          if (items[i]['product_id'] == product.id) {
            items[i]['quantity'] =
                (items[i]['quantity'] as int? ?? 1) + quantity;
            found = true;
            break;
          }
        }

        // Add new item if not found
        if (!found) {
          items.add({
            'product_id': product.id,
            'product_name': product.name,
            'price': product.price,
            'quantity': quantity,
          });
        }

        await _supabase
            .from(_tableName)
            .update({'items': items})
            .eq('username', username);
      } else {
        // Create new cart
        items = [
          {
            'product_id': product.id,
            'product_name': product.name,
            'price': product.price,
            'quantity': quantity,
          },
        ];

        await _supabase.from(_tableName).insert({
          'username': username,
          'items': items,
        });
      }

      print('Added ${product.name} to cart for user $username');
    } catch (e) {
      print('Add To Cart Error: $e');
    }
  }

  // Remove product from cart
  static Future<void> removeFromCart(String username, String productId) async {
    try {
      final cartData = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .maybeSingle();

      if (cartData != null) {
        var items = List<Map<String, dynamic>>.from(
          cartData['items'] as List? ?? [],
        );
        items.removeWhere((item) => item['product_id'] == productId);

        await _supabase
            .from(_tableName)
            .update({'items': items})
            .eq('username', username);

        print('Removed product $productId from cart for user $username');
      }
    } catch (e) {
      print('Remove From Cart Error: $e');
    }
  }

  // Update product quantity in cart
  static Future<void> updateQuantity(
    String username,
    String productId,
    int quantity,
  ) async {
    try {
      final cartData = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .maybeSingle();

      if (cartData != null) {
        var items = List<Map<String, dynamic>>.from(
          cartData['items'] as List? ?? [],
        );

        for (int i = 0; i < items.length; i++) {
          if (items[i]['product_id'] == productId) {
            if (quantity <= 0) {
              items.removeAt(i);
            } else {
              items[i]['quantity'] = quantity;
            }
            break;
          }
        }

        await _supabase
            .from(_tableName)
            .update({'items': items})
            .eq('username', username);

        print('Updated quantity for product $productId to $quantity');
      }
    } catch (e) {
      print('Update Quantity Error: $e');
    }
  }

  // Get total price of cart
  static Future<double> getTotalPrice(String username) async {
    try {
      final items = await getCartItems(username);
      double total = 0.0;
      for (var item in items) {
        total += item.totalPrice;
      }
      return total;
    } catch (e) {
      print('Get Total Price Error: $e');
      return 0.0;
    }
  }

  // Get total items count in cart
  static Future<int> getTotalItems(String username) async {
    try {
      final items = await getCartItems(username);
      int total = 0;
      for (var item in items) {
        total += item.quantity;
      }
      return total;
    } catch (e) {
      print('Get Total Items Error: $e');
      return 0;
    }
  }

  // Clear entire cart
  static Future<void> clearCart(String username) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'items': []})
          .eq('username', username);

      print('Cleared cart for user $username');
    } catch (e) {
      print('Clear Cart Error: $e');
    }
  }

  // Initialize cart for new user
  static Future<void> initializeCart(String username) async {
    try {
      await _supabase.from(_tableName).insert({
        'username': username,
        'items': [],
      });

      print('Initialized cart for user $username');
    } catch (e) {
      print('Initialize Cart Error: $e');
    }
  }
}
