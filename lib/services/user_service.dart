import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final _supabase = Supabase.instance.client;
  static const String _tableName = 'users';

  // Register user
  static Future<bool> registerUser(
    String username,
    String email,
    String password,
  ) async {
    try {
      // Check if username or email already exists
      final existingUser = await _supabase
          .from(_tableName)
          .select()
          .or('username.eq.$username,email.eq.$email')
          .maybeSingle();

      if (existingUser != null) {
        return false;
      }

      // Determine role: 'admin' if username is 'admin', otherwise 'user'
      final role = username.toLowerCase() == 'admin' ? 'admin' : 'user';

      // Insert user into database
      final response = await _supabase.from(_tableName).insert({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      }).select();

      if (response.isNotEmpty) {
        final userId = response[0]['id'] as int;

        // Initialize user coins and cart with the new user's ID
        await _initializeUserCoins(userId, username);
        await _initializeUserCart(userId, username);

        return true;
      }

      return false;
    } catch (e) {
      print('Register User Error: $e');
      return false;
    }
  }

  // Initialize coins for new user (internal helper)
  static Future<void> _initializeUserCoins(int userId, String username) async {
    try {
      await _supabase.from('user_coins').insert({
        'user_id': userId,
        'username': username,
        'coins': 0,
      });
    } catch (e) {
      print('Initialize User Coins Error: $e');
    }
  }

  // Initialize cart for new user (internal helper)
  static Future<void> _initializeUserCart(int userId, String username) async {
    try {
      await _supabase.from('user_carts').insert({
        'user_id': userId,
        'username': username,
        'items': [],
      });
    } catch (e) {
      print('Initialize User Cart Error: $e');
    }
  }

  // Authenticate user
  static Future<bool> authenticateUser(String username, String password) async {
    try {
      final user = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      return user != null;
    } catch (e) {
      print('Authenticate User Error: $e');
      return false;
    }
  }

  // Check if user is admin by username
  static bool isAdminUser(String username) {
    return username.toLowerCase() == 'admin';
  }

  // Get user role from database
  static Future<String?> getUserRole(String username) async {
    try {
      final user = await _supabase
          .from(_tableName)
          .select('role')
          .eq('username', username)
          .maybeSingle();

      return user != null ? user['role'] as String? : null;
    } catch (e) {
      print('Get User Role Error: $e');
      return null;
    }
  }

  // Check if username exists
  static Future<bool> userExists(String username) async {
    try {
      final user = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .maybeSingle();

      return user != null;
    } catch (e) {
      print('User Exists Error: $e');
      return false;
    }
  }

  // Check if email exists
  static Future<bool> emailExists(String email) async {
    try {
      final user = await _supabase
          .from(_tableName)
          .select()
          .eq('email', email)
          .maybeSingle();

      return user != null;
    } catch (e) {
      print('Email Exists Error: $e');
      return false;
    }
  }

  // Get all users
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final users = await _supabase.from(_tableName).select();
      return List<Map<String, dynamic>>.from(users);
    } catch (e) {
      print('Get All Users Error: $e');
      return [];
    }
  }

  // Get user by username
  static Future<Map<String, dynamic>?> getUser(String username) async {
    try {
      final user = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .maybeSingle();

      return user;
    } catch (e) {
      print('Get User Error: $e');
      return null;
    }
  }

  // Remove user
  static Future<void> removeUser(String username) async {
    try {
      await _supabase.from(_tableName).delete().eq('username', username);
    } catch (e) {
      print('Remove User Error: $e');
    }
  }

  // Initialize default users (for testing)
  static Future<void> initializeDefaultUsers() async {
    try {
      final existingUsers = await getAllUsers();
      if (existingUsers.isEmpty) {
        await registerUser('admin', 'admin@uniperks.com', 'admin123');
        await registerUser('testuser', 'test@example.com', 'test123');
      }
    } catch (e) {
      print('Initialize Default Users Error: $e');
    }
  }
}
