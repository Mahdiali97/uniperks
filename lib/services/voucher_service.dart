import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/voucher.dart';
import '../models/redeemed_voucher.dart';
import 'user_coins_service.dart';

class VoucherService {
  static final _supabase = Supabase.instance.client;
  static const String _vouchersTable = 'vouchers';
  static const String _redeemedTable = 'redeemed_vouchers';

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
}
