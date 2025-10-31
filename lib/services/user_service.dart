class UserService {
  static List<Map<String, String>> registeredUsers = [];

  static bool registerUser(String username, String email, String password) {
    // Check if username or email already exists
    bool userExists = registeredUsers.any((user) => 
        user['username'] == username || user['email'] == email);
    
    if (!userExists) {
      registeredUsers.add({
        'username': username,
        'email': email,
        'password': password,
      });
      return true;
    }
    return false;
  }

  static bool authenticateUser(String username, String password) {
    return registeredUsers.any((user) => 
        user['username'] == username && user['password'] == password);
  }

  static bool userExists(String username) {
    return registeredUsers.any((user) => user['username'] == username);
  }

  static bool emailExists(String email) {
    return registeredUsers.any((user) => user['email'] == email);
  }

  static List<Map<String, String>> getAllUsers() {
    return registeredUsers;
  }

  static void removeUser(int index) {
    if (index >= 0 && index < registeredUsers.length) {
      registeredUsers.removeAt(index);
    }
  }

  static Map<String, String>? getUser(String username) {
    try {
      return registeredUsers.firstWhere((user) => user['username'] == username);
    } catch (e) {
      return null;
    }
  }

  // For testing purposes, add some default users
  static void initializeDefaultUsers() {
    if (registeredUsers.isEmpty) {
      registerUser('admin', 'admin@uniperks.com', 'admin123');
      registerUser('student1', 'student1@university.edu', 'password123');
      registerUser('testuser', 'test@example.com', 'test123');
    }
  }
}