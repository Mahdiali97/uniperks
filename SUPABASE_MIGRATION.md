# Supabase Migration - API Changes

## Summary

Your services have been migrated from GetStorage to Supabase. All methods are now **async** and return `Future<T>`.

##  Critical Changes for UI

### Old (Sync) Code:
```dart
UserService.registerUser(username, email, password);  // Returns bool
```

### New (Async) Code:
```dart
await UserService.registerUser(username, email, password);  // Returns Future<bool>
```

## Updated Service APIs

### UserService

| Method | Old | New |
|--------|-----|-----|
| `registerUser()` | `bool` | `Future<bool>` |
| `authenticateUser()` | `bool` | `Future<bool>` |
| `userExists()` | `bool` | `Future<bool>` |
| `emailExists()` | `bool` | `Future<bool>` |
| `getAllUsers()` | `List<...>` | `Future<List<...>>` |
| `getUser()` | `Map?` | `Future<Map?>` |
| `removeUser(index: int)` | `void` | `removeUser(username: String)` → `Future<void>` |

### UserCoinsService

| Method | Old | New |
|--------|-----|-----|
| `getCoins()` | `int` | `Future<int>` |
| `addCoins()` | `void` | `Future<void>` |
| `spendCoins()` | `bool` | `Future<bool>` |
| `setCoins()` | `void` (new) | `Future<void>` |
| `initializeCoins()` | (new) | `Future<void>` |

### CartService

| Method | Old | New |
|--------|-----|-----|
| `getCartItems()` | `List<CartItem>` | `Future<List<CartItem>>` |
| `addToCart()` | `void` | `Future<void>` |
| `removeFromCart()` | `void` | `Future<void>` |
| `updateQuantity()` | `void` | `Future<void>` |
| `getTotalPrice()` | `double` | `Future<double>` |
| `getTotalItems()` | `int` | `Future<int>` |
| `clearCart()` | `void` | `Future<void>` |
| `initializeCart()` | (new) | `Future<void>` |

### DailyQuizService

| Method | Old | New |
|--------|-----|-----|
| `canTakeQuizToday()` | `bool` | `Future<bool>` |
| `recordQuizAttempt()` | `void` | `Future<void>` |
| `getTimeUntilReset()` | `String` | `Future<String>` |
| `hasTakenAnyQuizToday()` | `bool` | `Future<bool>` |
| `getTodayCompletedQuizzesCount()` | `int` | `Future<int>` |
| `getUserQuizAttempts()` | `Map<...>` | `Future<List<Map<...>>>` |

## Pages That Need Updates

### ✅ Already Updated:
- `lib/auth/login_page.dart` - Updated await calls
- `lib/auth/register_page.dart` - Updated await calls
- `lib/pages/cart_page.dart` - Converted to FutureBuilder
- `lib/user_dashboard.dart` - Fixed cart badge

### ⏳ Still Needs Updates:
- `lib/admin_dashboard.dart` - Complex, multiple async calls
- `lib/pages/quiz_page.dart` - Module selection requires async
- Other pages that call UserService/CartService

## How to Fix Remaining Pages

### Pattern 1: Simple Async Check (Login/Register)
```dart
// OLD
if (UserService.userExists(username)) { ... }

// NEW
if (await UserService.userExists(username)) { ... }
```

### Pattern 2: Using FutureBuilder (UI Display)
```dart
// OLD
final users = UserService.getAllUsers();
ListView.builder(
  itemCount: users.length,
  itemBuilder: (ctx, idx) => Text(users[idx]['username']),
)

// NEW
FutureBuilder<List<Map<String, dynamic>>>(
  future: UserService.getAllUsers(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    final users = snapshot.data ?? [];
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (ctx, idx) => Text(users[idx]['username']),
    );
  },
)
```

### Pattern 3: Async Callback (Buttons/Actions)
```dart
// OLD
onPressed: () {
  UserService.removeUser(index);
  setState(() {});
}

// NEW
onPressed: () async {
  final username = users[index]['username'];
  await UserService.removeUser(username);
  setState(() {});
}
```

## Supabase Database Tables Required

Create these tables in your Supabase project:

### users
```sql
CREATE TABLE users (
  id bigint primary key generated always as identity,
  username text unique not null,
  email text unique not null,
  password text not null,
  coins integer default 0,
  created_at timestamp default now()
);
```

### user_coins
```sql
CREATE TABLE user_coins (
  id bigint primary key generated always as identity,
  uid text unique not null,
  username text unique not null,
  coins integer default 0,
  last_updated timestamp default now()
);
```

### user_carts
```sql
CREATE TABLE user_carts (
  id bigint primary key generated always as identity,
  uid text unique not null,
  username text unique not null,
  items jsonb default '[]'::jsonb,
  created_at timestamp default now(),
  updated_at timestamp default now()
);
```

### daily_quiz_attempts
```sql
CREATE TABLE daily_quiz_attempts (
  id bigint primary key generated always as identity,
  username text not null,
  module_id text not null,
  attempt_date text not null,
  created_at timestamp default now(),
  unique(username, module_id, attempt_date)
);
```

## Quick Fix Checklist

- [ ] Update `admin_dashboard.dart` to use FutureBuilder or move data fetching to initState
- [ ] Update `quiz_page.dart` to handle async calls in module selection
- [ ] Fix any remaining pages calling sync service methods
- [ ] Test user registration flow
- [ ] Test cart operations
- [ ] Test admin panel

## Notes

- All Supabase calls require internet connection
- Get storage is removed as a dependency from pubspec.yaml
- For offline support, implement local caching manually if needed
- Error handling is crucial - wrap async calls in try/catch
