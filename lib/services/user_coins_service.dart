import 'package:supabase_flutter/supabase_flutter.dart';

class UserCoinsService {
  static final _supabase = Supabase.instance.client;
  static const String _tableName = 'user_coins';

  // Get user coins by username
  static Future<int> getCoins(String username) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .maybeSingle();

      if (data != null) {
        return data['coins'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      print('Get Coins Error: $e');
      return 0;
    }
  }

  // Add coins to user (updates existing record, user must exist in users table first)
  static Future<void> addCoins(String username, int coins) async {
    try {
      final currentCoins = await getCoins(username);
      final newCoins = currentCoins + coins;

      // Update the existing record for this username
      await _supabase
          .from(_tableName)
          .update({'coins': newCoins})
          .eq('username', username);

      print('Added $coins coins to user $username');
    } catch (e) {
      print('Add Coins Error: $e');
    }
  }

  // Spend coins (deduct from user)
  static Future<bool> spendCoins(String username, int coins) async {
    try {
      final currentCoins = await getCoins(username);

      if (currentCoins >= coins) {
        final newCoins = currentCoins - coins;
        await _supabase
            .from(_tableName)
            .update({'coins': newCoins})
            .eq('username', username);

        print('Spent $coins coins from user $username');
        return true;
      }

      print('Insufficient coins for user $username');
      return false;
    } catch (e) {
      print('Spend Coins Error: $e');
      return false;
    }
  }

  // Set coins to a specific amount
  static Future<void> setCoins(String username, int coins) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'coins': coins})
          .eq('username', username);

      print('Set coins for user $username to $coins');
    } catch (e) {
      print('Set Coins Error: $e');
    }
  }

  // Initialize coins for new user (only called from UserService during registration)
  static Future<void> initializeCoins(int userId, String username) async {
    try {
      await _supabase.from(_tableName).insert({
        'user_id': userId,
        'username': username,
        'coins': 0,
      });

      print('Initialized coins for user $username');
    } catch (e) {
      print('Initialize Coins Error: $e');
    }
  }
}
