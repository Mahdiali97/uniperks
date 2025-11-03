import 'package:supabase_flutter/supabase_flutter.dart';

class AuthzService {
  static final _supabase = Supabase.instance.client;

  /// Returns true if the currently authenticated Supabase user has role 'admin'
  /// in the public.users table (requires columns: auth_user_id uuid, role text).
  static Future<bool> currentUserIsAdmin() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      final data = await _supabase
          .from('users')
          .select('role')
          .eq('auth_user_id', uid)
          .maybeSingle();
      if (data == null) return false;
      final role = data['role'] as String?;
      return role == 'admin';
    } catch (e) {
      // If policy blocks access or table missing columns, treat as not admin
      return false;
    }
  }
}
