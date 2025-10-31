import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  static final Map<String, List<CartItem>> _userCarts = {};

  static List<CartItem> getCartItems(String username) {
    return _userCarts[username] ?? [];
  }

  static void addToCart(String username, Product product) {
    _userCarts[username] ??= [];
    
    final existingItemIndex = _userCarts[username]!
        .indexWhere((item) => item.product.id == product.id);
    
    if (existingItemIndex >= 0) {
      _userCarts[username]![existingItemIndex].quantity++;
    } else {
      _userCarts[username]!.add(CartItem(product: product));
    }
  }

  static void removeFromCart(String username, String productId) {
    _userCarts[username]?.removeWhere((item) => item.product.id == productId);
  }

  static void updateQuantity(String username, String productId, int quantity) {
    final items = _userCarts[username];
    if (items != null) {
      final itemIndex = items.indexWhere((item) => item.product.id == productId);
      if (itemIndex >= 0) {
        if (quantity <= 0) {
          items.removeAt(itemIndex);
        } else {
          items[itemIndex].quantity = quantity;
        }
      }
    }
  }

  static double getTotalPrice(String username) {
    final items = getCartItems(username);
    return items.fold(0.0, (total, item) => total + item.totalPrice);
  }

  static int getTotalItems(String username) {
    final items = getCartItems(username);
    return items.fold(0, (total, item) => total + item.quantity);
  }

  static void clearCart(String username) {
    _userCarts[username]?.clear();
  }
}