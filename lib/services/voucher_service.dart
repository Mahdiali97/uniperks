import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/voucher.dart';
import '../models/redeemed_voucher.dart';
import 'user_coins_service.dart';

class VoucherService {
  static final _supabase = Supabase.instance.client;
  static const String _vouchersTable = 'vouchers';
  static const String _redeemedTable = 'redeemed_vouchers';

  // Simple in-memory cache for redemption counts
  static final Map<int, _RedemptionCacheEntry> _redemptionCountCache = {};
  static const Duration _cacheTTL = Duration(seconds: 15);

  // Get all vouchers
  static Future<List<Voucher>> getAllVouchers() async {
    try {
      final data = await _supabase
          .from(_vouchersTable)
          .select()
          .order('created_at', ascending: false);

      return (data as List).map((json) => Voucher.fromJson(json)).toList();
    } catch (e) {
      print('Get All Vouchers Error: $e');
      return [];
    }
  }

  // Get active vouchers only
  static Future<List<Voucher>> getActiveVouchers() async {
    try {
      final data = await _supabase
          .from(_vouchersTable)
          .select()
          .eq('active', true)
          .order('created_at', ascending: false);

      return (data as List).map((json) => Voucher.fromJson(json)).toList();
    } catch (e) {
      print('Get Active Vouchers Error: $e');
      return [];
    }
  }

  // Get voucher by ID
  static Future<Voucher?> getVoucher(int id) async {
    try {
      final data = await _supabase
          .from(_vouchersTable)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data != null) {
        return Voucher.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Get Voucher Error: $e');
      return null;
    }
  }

  // Add new voucher (Admin only)
  static Future<bool> addVoucher(Voucher voucher) async {
    try {
      await _supabase.from(_vouchersTable).insert(voucher.toJson());
      return true;
    } catch (e) {
      print('Add Voucher Error: $e');
      return false;
    }
  }

  // Update voucher (Admin only)
  static Future<bool> updateVoucher(int id, Voucher voucher) async {
    try {
      await _supabase
          .from(_vouchersTable)
          .update(voucher.toJson())
          .eq('id', id);
      return true;
    } catch (e) {
      print('Update Voucher Error: $e');
      return false;
    }
  }

  // Delete voucher (Admin only)
  static Future<bool> deleteVoucher(int id) async {
    try {
      await _supabase.from(_vouchersTable).delete().eq('id', id);
      return true;
    } catch (e) {
      print('Delete Voucher Error: $e');
      return false;
    }
  }

  // Toggle voucher active status (Admin only)
  static Future<bool> toggleVoucherActive(int id, bool currentStatus) async {
    try {
      await _supabase
          .from(_vouchersTable)
          .update({'active': !currentStatus})
          .eq('id', id);
      return true;
    } catch (e) {
      print('Toggle Voucher Active Error: $e');
      return false;
    }
  }

  // Redeem voucher (User action)
  static Future<bool> redeemVoucher(String username, Voucher voucher) async {
    try {
      // Enforce max claims limit per user if set
      if (voucher.maxClaims != null) {
        // Check how many times this specific user has claimed this voucher
        final userClaims = await _supabase
            .from(_redeemedTable)
            .select('id')
            .eq('voucher_id', voucher.id)
            .eq('username', username);
        final userClaimCount = (userClaims as List).length;
        if (userClaimCount >= voucher.maxClaims!) {
          print('User has reached max claims limit for this voucher');
          return false;
        }
      }

      // Get user info
      final userData = await _supabase
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      if (userData == null) {
        print('User not found');
        return false;
      }

      final userId = userData['id'] as int;

      // Check if user has enough coins
      final currentCoins = await UserCoinsService.getCoins(username);
      if (currentCoins < voucher.coinsRequired) {
        print('Insufficient coins');
        return false;
      }

      // Calculate expiry date
      final redeemedAt = DateTime.now();
      final expiresAt = redeemedAt.add(Duration(days: voucher.validDays));

      // Insert redeemed voucher
      await _supabase.from(_redeemedTable).insert({
        'user_id': userId,
        'username': username,
        'voucher_id': voucher.id,
        'voucher_title': voucher.title,
        'voucher_category': voucher.category,
        'valid_days': voucher.validDays,
        'redeemed_at': redeemedAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
      });

      // Deduct coins
      await UserCoinsService.spendCoins(username, voucher.coinsRequired);

      // Update cache to reflect new redemption
      final existing = _redemptionCountCache[voucher.id];
      if (existing != null) {
        _redemptionCountCache[voucher.id] = _RedemptionCacheEntry(
          count: existing.count + 1,
          fetchedAt: DateTime.now(),
        );
      }

      print('Voucher redeemed successfully');
      return true;
    } catch (e) {
      print('Redeem Voucher Error: $e');
      return false;
    }
  }

  // Get user's redeemed vouchers
  static Future<List<RedeemedVoucher>> getRedeemedVouchers(
    String username,
  ) async {
    try {
      final data = await _supabase
          .from(_redeemedTable)
          .select()
          .eq('username', username)
          .order('redeemed_at', ascending: false);

      return (data as List)
          .map((json) => RedeemedVoucher.fromJson(json))
          .toList();
    } catch (e) {
      print('Get Redeemed Vouchers Error: $e');
      return [];
    }
  }

  // Get active redeemed vouchers (not expired)
  static Future<List<RedeemedVoucher>> getActiveRedeemedVouchers(
    String username,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      final data = await _supabase
          .from(_redeemedTable)
          .select()
          .eq('username', username)
          .gt('expires_at', now)
          .eq('used', false)
          .order('redeemed_at', ascending: false);

      return (data as List)
          .map((json) => RedeemedVoucher.fromJson(json))
          .toList();
    } catch (e) {
      print('Get Active Redeemed Vouchers Error: $e');
      return [];
    }
  }

  // Statistics for admin
  static Future<int> getTotalVouchers() async {
    try {
      final data = await _supabase.from(_vouchersTable).select();
      return (data as List).length;
    } catch (e) {
      print('Get Total Vouchers Error: $e');
      return 0;
    }
  }

  static Future<int> getActiveVouchersCount() async {
    try {
      final data = await _supabase
          .from(_vouchersTable)
          .select()
          .eq('active', true);
      return (data as List).length;
    } catch (e) {
      print('Get Active Vouchers Count Error: $e');
      return 0;
    }
  }

  static Future<int> getTotalRedemptions() async {
    try {
      final data = await _supabase.from(_redeemedTable).select();
      return (data as List).length;
    } catch (e) {
      print('Get Total Redemptions Error: $e');
      return 0;
    }
  }

  // Mark a redeemed voucher as used (one-time usage enforcement)
  static Future<bool> markRedeemedVoucherUsed(int id) async {
    try {
      await _supabase
          .from(_redeemedTable)
          .update({'used': true, 'used_at': DateTime.now().toIso8601String()})
          .eq('id', id);
      return true;
    } catch (e) {
      print('Mark Redeemed Voucher Used Error: $e');
      return false;
    }
  }

  // Get redemption count for a specific voucher (for maxClaims tracking)
  static Future<int> getRedemptionCount(int voucherId) async {
    try {
      // Serve from cache if fresh
      final cached = _redemptionCountCache[voucherId];
      if (cached != null) {
        final age = DateTime.now().difference(cached.fetchedAt);
        if (age <= _cacheTTL) return cached.count;
      }

      final data = await _supabase
          .from(_redeemedTable)
          .select('id')
          .eq('voucher_id', voucherId);
      final count = (data as List).length;
      _redemptionCountCache[voucherId] = _RedemptionCacheEntry(
        count: count,
        fetchedAt: DateTime.now(),
      );
      return count;
    } catch (e) {
      print('Get Redemption Count Error: $e');
      return 0;
    }
  }

  // Compute discount amount against items that match the voucher's category.
  // Expects each item to include at least: {'category': String, 'line_total': num}
  // Returns the total discount to subtract from order/cart total.
  static double computeCategoryDiscountAmount(
    List<Map<String, dynamic>> items,
    Voucher voucher,
  ) {
    print('=== VOUCHER DISCOUNT CALCULATION ===');
    print('Voucher: ${voucher.title}');
    print('Voucher Category: ${voucher.category}');
    print('Voucher Discount: ${voucher.discount}%');
    print('Voucher Active: ${voucher.active}');

    if (!voucher.active) {
      print('Voucher is NOT active - returning 0');
      return 0.0;
    }
    if (voucher.discount <= 0) {
      print('Voucher discount is <= 0 - returning 0');
      return 0.0;
    }

    double discount = 0.0;
    for (final item in items) {
      final itemCategory = item['category'] as String?;
      final lineTotalNum = item['line_total'];
      if (itemCategory == null || lineTotalNum == null) continue;
      final lineTotal = (lineTotalNum as num).toDouble();

      print(
        'Item Category: "$itemCategory" vs Voucher Category: "${voucher.category}"',
      );
      print('Match: ${itemCategory == voucher.category}');

      if (itemCategory == voucher.category) {
        // Percentage-based discount across matching category items
        final d = (voucher.discount / 100.0) * lineTotal;
        print('  ✓ MATCH! Line Total: RM$lineTotal, Discount: RM$d');
        discount += d;
      } else {
        print('  ✗ No match - skipping');
      }
    }
    print('Total Discount: RM$discount');
    print('====================================');

    // Prevent negative/NaN
    if (discount.isNaN || discount.isInfinite) return 0.0;
    return discount.clamp(0.0, double.maxFinite);
  }

  // Apply discount to items and return adjusted items + discount amount.
  // The returned map contains:
  // - 'items': List<Map> with updated 'line_total'
  // - 'discount_amount': double total discount applied
  static Map<String, dynamic> applyCategoryDiscountToItems(
    List<Map<String, dynamic>> items,
    Voucher voucher,
  ) {
    if (!voucher.active || voucher.discount <= 0) {
      return {'items': items, 'discount_amount': 0.0};
    }

    double totalDiscount = 0.0;
    final adjusted = items.map((item) {
      final itemCategory = item['category'] as String?;
      final lineTotalNum = item['line_total'];
      if (itemCategory == null || lineTotalNum == null) return item;

      final lineTotal = (lineTotalNum as num).toDouble();
      if (itemCategory == voucher.category) {
        final d = (voucher.discount / 100.0) * lineTotal;
        totalDiscount += d;
        final newLineTotal = (lineTotal - d).clamp(0.0, double.maxFinite);
        return {...item, 'line_total': newLineTotal};
      }
      return item;
    }).toList();

    if (totalDiscount.isNaN || totalDiscount.isInfinite) {
      totalDiscount = 0.0;
    }

    return {'items': adjusted, 'discount_amount': totalDiscount};
  }
}

class _RedemptionCacheEntry {
  final int count;
  final DateTime fetchedAt;
  const _RedemptionCacheEntry({required this.count, required this.fetchedAt});
}
