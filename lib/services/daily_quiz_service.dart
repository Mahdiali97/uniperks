import 'package:supabase_flutter/supabase_flutter.dart';

class DailyQuizService {
  static final _supabase = Supabase.instance.client;
  static const String _tableName = 'daily_quiz_attempts';

  // Check if user can take a specific quiz today
  static Future<bool> canTakeQuizToday(String username, String moduleId) async {
    try {
      final today = DateTime.now();
      final todayString = _formatDate(today);

      final data = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .eq('module_id', moduleId)
          .eq('attempt_date', todayString)
          .maybeSingle();

      return data == null;
    } catch (e) {
      print('Can Take Quiz Today Error: $e');
      return true;
    }
  }

  // Record that user has taken a quiz today
  static Future<void> recordQuizAttempt(
    String username,
    String moduleId,
  ) async {
    try {
      final today = DateTime.now();
      final todayString = _formatDate(today);

      await _supabase.from(_tableName).insert({
        'username': username,
        'module_id': moduleId,
        'attempt_date': todayString,
      });

      print('Recorded quiz attempt for user $username on module $moduleId');
    } catch (e) {
      print('Record Quiz Attempt Error: $e');
    }
  }

  // Get time until user can take quiz again
  static Future<String> getTimeUntilReset(
    String username,
    String moduleId,
  ) async {
    try {
      final canTake = await canTakeQuizToday(username, moduleId);
      if (canTake) {
        return 'Available now';
      }

      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final difference = tomorrow.difference(now);
      
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);

      return 'Available in ${hours}h ${minutes}m';
    } catch (e) {
      print('Get Time Until Reset Error: $e');
      return 'Error';
    }
  }

  // Check if user has taken any quiz today
  static Future<bool> hasTakenAnyQuizToday(String username) async {
    try {
      final today = DateTime.now();
      final todayString = _formatDate(today);

      final attempts = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .eq('attempt_date', todayString);

      return attempts.isNotEmpty;
    } catch (e) {
      print('Has Taken Any Quiz Today Error: $e');
      return false;
    }
  }

  // Get all quiz attempts for a user
  static Future<List<Map<String, dynamic>>> getUserQuizAttempts(
    String username,
  ) async {
    try {
      final attempts = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username);

      return List<Map<String, dynamic>>.from(attempts);
    } catch (e) {
      print('Get User Quiz Attempts Error: $e');
      return [];
    }
  }

  // Get completed quizzes today count
  static Future<int> getTodayCompletedQuizzesCount(String username) async {
    try {
      final today = DateTime.now();
      final todayString = _formatDate(today);

      final attempts = await _supabase
          .from(_tableName)
          .select()
          .eq('username', username)
          .eq('attempt_date', todayString);

      return attempts.length;
    } catch (e) {
      print('Get Today Completed Quizzes Count Error: $e');
      return 0;
    }
  }

  // Initialize attempts for new user (optional)
  static Future<void> initializeAttempts(String username) async {
    try {
      // Just add first record if needed
      print('Initialized quiz attempts for user $username');
    } catch (e) {
      print('Initialize Attempts Error: $e');
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
