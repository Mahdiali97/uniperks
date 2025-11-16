import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

/* ===== User Model ===== */
class UserModel {
  final int userId;
  String username;
  String email;
  String? fullName;
  String? phone;
  String? bio;
  String? avatarUrl;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    this.fullName,
    this.phone,
    this.bio,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId: json['id'] as int? ?? 0,
    username: json['username'] as String? ?? '',
    email: json['email'] as String? ?? '',
    fullName: json['full_name'] as String?,
    phone: json['phone'] as String?,
    bio: json['bio'] as String?,
    avatarUrl: json['avatar_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'full_name': fullName,
    'phone': phone,
    'bio': bio,
    'avatar_url': avatarUrl,
  };

  Map<String, dynamic> toUpdatePayload({String? newPassword}) {
    final payload = toJson();
    if (newPassword != null && newPassword.trim().isNotEmpty) {
      payload['password'] = newPassword.trim();
    }
    return payload;
  }
}

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

  // Update user profile (name, email, phone, bio)
  static Future<bool> updateUserProfile({
    required String username,
    String? fullName,
    String? email,
    String? phone,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      if (updateData.isEmpty) return false;

      await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('username', username);

      return true;
    } catch (e) {
      print('Update User Profile Error: $e');
      return false;
    }
  }

  // Upload avatar to Supabase Storage (web-compatible binary upload)
  static Future<String?> uploadAvatar(String username, File avatarFile) async {
    try {
      final fileName =
          '${username}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = await avatarFile.readAsBytes();

      // Validate file size (5 MB max)
      const maxFileSizeBytes = 5 * 1024 * 1024;
      if (bytes.length > maxFileSizeBytes) {
        print('Avatar exceeds 5 MB limit');
        return null;
      }

      final client = _supabase;

      // Upload binary (web-compatible)
      await client.storage
          .from('user_avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl = client.storage
          .from('user_avatars')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Upload Avatar Error: $e');
      return null;
    }
  }

  // Change password
  static Future<bool> changePassword(
    String username,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final user = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .eq('password', oldPassword)
          .maybeSingle();

      if (user == null) {
        print('Incorrect password');
        return false;
      }

      await _supabase
          .from(_tableName)
          .update({'password': newPassword})
          .eq('username', username);

      return true;
    } catch (e) {
      print('Change Password Error: $e');
      return false;
    }
  }

  // Update username
  static Future<bool> updateUsername(
    String oldUsername,
    String newUsername,
  ) async {
    try {
      // Check if new username already exists
      final existing = await _supabase
          .from(_tableName)
          .select()
          .eq('username', newUsername)
          .maybeSingle();

      if (existing != null) {
        print('Username already exists');
        return false;
      }

      // Update username
      await _supabase
          .from(_tableName)
          .update({'username': newUsername})
          .eq('username', oldUsername);

      // Update related tables (user_coins, user_carts, etc.)
      await _supabase
          .from('user_coins')
          .update({'username': newUsername})
          .eq('username', oldUsername);

      await _supabase
          .from('user_carts')
          .update({'username': newUsername})
          .eq('username', oldUsername);

      return true;
    } catch (e) {
      print('Update Username Error: $e');
      return false;
    }
  }

  // Get user profile data
  static Future<Map<String, dynamic>?> getUserProfile(String username) async {
    try {
      final user = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .maybeSingle();

      return user;
    } catch (e) {
      print('Get User Profile Error: $e');
      return null;
    }
  }

  // Delete user account
  static Future<bool> deleteUserAccount(String username) async {
    try {
      // Delete related data first
      await _supabase.from('user_coins').delete().eq('username', username);
      await _supabase.from('user_carts').delete().eq('username', username);

      // Delete user
      await _supabase.from(_tableName).delete().eq('username', username);

      return true;
    } catch (e) {
      print('Delete User Account Error: $e');
      return false;
    }
  }

  // Update user profile with optional password change and avatar
  static Future<({bool ok, String message})> updateProfileSimple(
    String username, {
    String? newEmail,
    String? newFullName,
    String? newPhone,
    String? newBio,
    String? newPassword,
    String? newAvatarUrl,
  }) async {
    try {
      // First, verify the user exists
      print('🔍 Checking if user exists: "$username"');
      final existingUser = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existingUser == null) {
        print('❌ User not found: "$username"');
        return (ok: false, message: 'User not found in database');
      }

      print(
        '✅ User found: ${existingUser['id']} - ${existingUser['username']}',
      );
      print('📋 Current user fields: ${existingUser.keys.toList()}');

      final updateData = <String, dynamic>{};
      if (newEmail != null && newEmail.isNotEmpty) {
        updateData['email'] = newEmail;
      }
      if (newFullName != null && newFullName.isNotEmpty) {
        updateData['full_name'] = newFullName;
      }
      if (newPhone != null && newPhone.isNotEmpty) {
        updateData['phone'] = newPhone;
      }
      if (newBio != null && newBio.isNotEmpty) {
        updateData['bio'] = newBio;
      }
      if (newPassword != null && newPassword.trim().isNotEmpty) {
        updateData['password'] = newPassword.trim();
      }
      if (newAvatarUrl != null && newAvatarUrl.isNotEmpty) {
        updateData['avatar_url'] = newAvatarUrl;
      }

      if (updateData.isEmpty) {
        return (ok: false, message: 'No changes to save');
      }

      print('📝 Updating profile for username: "$username"');
      print('📝 Update data: $updateData');

      // Update WITHOUT .select() to avoid RLS issues
      await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('username', username);

      print('✅ Update completed successfully');

      return (ok: true, message: 'Profile updated successfully');
    } catch (e) {
      print('❌ Update Profile Error: $e');
      return (ok: false, message: 'Failed to update profile: $e');
    }
  }
}
