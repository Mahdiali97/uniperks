import 'product.dart';

/// Represents a cart line item with product and quantity.
/// Vouchers are applied at the cart level, not per-item.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  /// Price per unit after product discount only.
  double get unitPrice => product.discountedPrice;

  /// Total price for this item (quantity × unit price).
  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toStorageJson() {
    return {
      'product_id': product.id,
      'product_name': product.name,
      'price': product.price,
      'quantity': quantity,
    };
  }
}
