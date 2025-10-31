class UserCoinsService {
  static final Map<String, int> _userCoins = {};

  static int getCoins(String username) {
    return _userCoins[username] ?? 0;
  }

  static void addCoins(String username, int coins) {
    _userCoins[username] = getCoins(username) + coins;
  }

  static bool spendCoins(String username, int coins) {
    final currentCoins = getCoins(username);
    if (currentCoins >= coins) {
      _userCoins[username] = currentCoins - coins;
      return true;
    }
    return false;
  }
}