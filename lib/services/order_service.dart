import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/voucher.dart';
import 'voucher_service.dart';

class OrderService {
  static final _supabase = Supabase.instance.client;
  static const _ordersTable = 'orders';
  static const _itemsTable = 'order_items';

  /// Create an order with its items atomically (best-effort: inserts order then items)
  /// Returns created Order or null on failure.
  static Future<Order?> createOrder({
    required String username,
    required List<CartItem> cartItems,
    required double subtotal,
    required double discountAmount,
    required double totalAmount,
    required int itemCount,
    Map<String, dynamic>? voucher,
    String? deliveryMethod, // 'self_pickup' or 'delivery'
    Voucher?
    voucherObject, // Optional strongly-typed voucher for category discount
  }) async {
    try {
      // If a voucher object provided and discountAmount not precomputed, derive category discount
      if (voucherObject != null && discountAmount == 0) {
        // Build simple item maps for discount computation
        final itemMaps = cartItems
            .map(
              (c) => {
                'category': c.product.category,
                'line_total': c.totalPrice,
              },
            )
            .toList();
        final computedDiscount = VoucherService.computeCategoryDiscountAmount(
          itemMaps,
          voucherObject,
        );
        discountAmount = computedDiscount;
        totalAmount = (subtotal - discountAmount).clamp(0.0, double.maxFinite);
        // If voucher map not passed, create it for persistence
        voucher ??= {
          'voucher_id': voucherObject.id,
          'voucher_title': voucherObject.title,
          'voucher_discount': voucherObject.discount,
        };
      }

      final orderInsert = await _supabase
          .from(_ordersTable)
          .insert({
            'username': username,
            'subtotal': subtotal,
            'discount_amount': discountAmount,
            'total_amount': totalAmount,
            'item_count': itemCount,
            'voucher_id': voucher?['voucher_id'],
            'voucher_title': voucher?['voucher_title'],
            'voucher_discount': voucher?['voucher_discount'],
            'delivery_method': deliveryMethod,
            'status': 'paid',
          })
          .select()
          .maybeSingle();

      if (orderInsert == null) return null;
      final orderId = orderInsert['id'] as int;

      // Prepare order_items rows
      final itemsPayload = cartItems.map((c) {
        return {
          'order_id': orderId,
          'product_id': c.product.id,
          'product_name': c.product.name,
          'image_url': c.product.imageUrl,
          'unit_price': c.unitPrice,
          'quantity': c.quantity,
          'line_total': c.totalPrice,
        };
      }).toList();

      if (itemsPayload.isNotEmpty) {
        await _supabase.from(_itemsTable).insert(itemsPayload);
      }

      return Order.fromJson(orderInsert);
    } catch (e) {
      print('Create Order Error: $e');
      return null;
    }
  }

  static Future<List<Order>> getOrdersForUser(String username) async {
    try {
      final data = await _supabase
          .from(_ordersTable)
          .select()
          .eq('username', username)
          .order('created_at', ascending: false);
      return (data as List).map((j) => Order.fromJson(j)).toList();
    } catch (e) {
      print('Get Orders For User Error: $e');
      return [];
    }
  }

  static Future<List<OrderItem>> getOrderItems(int orderId) async {
    try {
      final data = await _supabase
          .from(_itemsTable)
          .select()
          .eq('order_id', orderId)
          .order('created_at', ascending: true);
      return (data as List).map((j) => OrderItem.fromJson(j)).toList();
    } catch (e) {
      print('Get Order Items Error: $e');
      return [];
    }
  }

  /// Convenience: calculate pricing (subtotal, discount, total) given cart items and optional voucher.
  /// Does not persist anything; useful for UI preview before calling createOrder.
  static Map<String, double> calculateTotals({
    required List<CartItem> cartItems,
    Voucher? voucherObject,
  }) {
    final subtotal = cartItems.fold<double>(0, (sum, c) => sum + c.totalPrice);
    final itemCount = cartItems.fold<int>(0, (sum, c) => sum + c.quantity);
    double discount = 0.0;
    if (voucherObject != null) {
      final itemMaps = cartItems
          .map(
            (c) => {'category': c.product.category, 'line_total': c.totalPrice},
          )
          .toList();
      discount = VoucherService.computeCategoryDiscountAmount(
        itemMaps,
        voucherObject,
      );
    }
    final total = (subtotal - discount).clamp(0.0, double.maxFinite);
    return {
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'itemCount': itemCount.toDouble(),
    };
  }
}
