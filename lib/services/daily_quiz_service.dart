class DailyQuizService {
  // Store quiz attempts with date tracking
  // Format: {username: {quizModuleId: 'YYYY-MM-DD'}}
  static final Map<String, Map<String, String>> _dailyQuizAttempts = {};

  // Check if user can take a specific quiz today
  static bool canTakeQuizToday(String username, String moduleId) {
    final today = DateTime.now();
    final todayString = _formatDate(today);
    
    if (!_dailyQuizAttempts.containsKey(username)) {
      return true;
    }
    
    final userAttempts = _dailyQuizAttempts[username]!;
    if (!userAttempts.containsKey(moduleId)) {
      return true;
    }
    
    final lastAttemptDate = userAttempts[moduleId]!;
    return lastAttemptDate != todayString;
  }

  // Record that user has taken a quiz today
  static void recordQuizAttempt(String username, String moduleId) {
    final today = DateTime.now();
    final todayString = _formatDate(today);
    
    if (!_dailyQuizAttempts.containsKey(username)) {
      _dailyQuizAttempts[username] = {};
    }
    
    _dailyQuizAttempts[username]![moduleId] = todayString;
  }

  // Get time until user can take quiz again
  static String getTimeUntilReset(String username, String moduleId) {
    if (canTakeQuizToday(username, moduleId)) {
      return 'Available now';
    }
    
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final difference = tomorrow.difference(now);
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    
    return 'Available in ${hours}h ${minutes}m';
  }

  // Check if user has taken any quiz today
  static bool hasTakenAnyQuizToday(String username) {
    if (!_dailyQuizAttempts.containsKey(username)) {
      return false;
    }
    
    final today = _formatDate(DateTime.now());
    final userAttempts = _dailyQuizAttempts[username]!;
    
    return userAttempts.values.any((date) => date == today);
  }

  // Get all quiz attempts for a user
  static Map<String, String> getUserQuizAttempts(String username) {
    return _dailyQuizAttempts[username] ?? {};
  }

  // Reset all attempts (for testing purposes)
  static void resetAllAttempts() {
    _dailyQuizAttempts.clear();
  }

  // Get completed quizzes today count
  static int getTodayCompletedQuizzesCount(String username) {
    if (!_dailyQuizAttempts.containsKey(username)) {
      return 0;
    }
    
    final today = _formatDate(DateTime.now());
    final userAttempts = _dailyQuizAttempts[username]!;
    
    return userAttempts.values.where((date) => date == today).length;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}