# SQL Table Structure Fixes ✅

## Problem Solved

The original table structure had independent `user_coins` and `user_carts` tables that didn't properly reference the `users` table. This caused:

1. **No data integrity** - Coins and cart records could exist without corresponding users
2. **No cascading deletes** - Deleting a user didn't remove their coins or cart
3. **Orphaned data** - Old user records would leave behind coins and cart data
4. **Initialization issues** - Coins and carts weren't automatically created during registration

## Fixed Table Structure

### 1. Users Table (Primary)
```sql
CREATE TABLE users (
  id bigint primary key generated always as identity,
  username text unique not null,
  email text unique not null,
  password text not null,
  created_at timestamp default now()
);
```

**Key Changes:**
- ✅ Removed `coins` column (now in separate table)
- ✅ Keeps `id` as primary key for foreign key references
- ✅ `username` and `email` are unique constraints

### 2. User Coins Table (With Foreign Key)
```sql
CREATE TABLE user_coins (
  id bigint primary key generated always as identity,
  user_id bigint unique not null references users(id) on delete cascade,
  username text not null,
  coins integer default 0,
  last_updated timestamp default now()
);
```

**Key Changes:**
- ✅ **Added `user_id`** - Foreign key reference to `users(id)`
- ✅ **UNIQUE constraint on `user_id`** - One coins record per user
- ✅ **ON DELETE CASCADE** - Coins deleted when user deleted
- ✅ **Kept `username`** - For easier queries by username
- ✅ **Removed `uid` column** - Replaced with proper `user_id`

### 3. User Carts Table (With Foreign Key)
```sql
CREATE TABLE user_carts (
  id bigint primary key generated always as identity,
  user_id bigint unique not null references users(id) on delete cascade,
  username text not null,
  items jsonb default '[]'::jsonb,
  created_at timestamp default now(),
  updated_at timestamp default now()
);
```

**Key Changes:**
- ✅ **Added `user_id`** - Foreign key reference to `users(id)`
- ✅ **UNIQUE constraint on `user_id`** - One cart per user
- ✅ **ON DELETE CASCADE** - Cart deleted when user deleted
- ✅ **Kept `username`** - For easier queries by username
- ✅ **Removed `uid` column** - Replaced with proper `user_id`

### 4. Daily Quiz Attempts Table (Maintains Existing Foreign Key)
```sql
CREATE TABLE daily_quiz_attempts (
  id bigint primary key generated always as identity,
  username text not null references users(username) on delete cascade,
  module_id text not null,
  attempt_date text not null,
  created_at timestamp default now(),
  unique(username, module_id, attempt_date)
);
```

**Key Changes:**
- ✅ **Foreign key on `username`** - References `users(username)` with cascade delete
- ✅ **ON DELETE CASCADE** - Attempts deleted when user deleted
- ✅ **Unique constraint** - Prevents duplicate attempts on same date/module

## Service Code Changes

### UserService - Registration Now Initializes Related Data

```dart
// Register user
static Future<bool> registerUser(
  String username,
  String email,
  String password,
) async {
  try {
    // Check if user exists
    final existingUser = await _supabase
        .from(_tableName)
        .select()
        .or('username.eq.$username,email.eq.$email')
        .maybeSingle();

    if (existingUser != null) {
      return false;
    }

    // Insert user and GET the generated ID
    final response = await _supabase.from(_tableName).insert({
      'username': username,
      'email': email,
      'password': password,
    }).select();

    if (response.isNotEmpty) {
      final userId = response[0]['id'] as int;
      
      // ✅ NEW: Automatically initialize coins and cart
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
```

**Benefits:**
- ✅ When user registers, coins record is **automatically created** with `user_id`
- ✅ When user registers, cart record is **automatically created** with `user_id`
- ✅ No need to manually call initialization methods
- ✅ Prevents orphaned data

### UserCoinsService - Works With Initialized Records

```dart
// Add coins to user (updates existing record)
static Future<void> addCoins(String username, int coins) async {
  try {
    final currentCoins = await getCoins(username);
    final newCoins = currentCoins + coins;

    // ✅ UPDATE only (not UPSERT) - record already exists
    await _supabase
        .from(_tableName)
        .update({'coins': newCoins})
        .eq('username', username);

    print('Added $coins coins to user $username');
  } catch (e) {
    print('Add Coins Error: $e');
  }
}
```

**Benefits:**
- ✅ Simpler code - no need for UPSERT
- ✅ Faster queries - UPDATE is simpler than UPSERT
- ✅ Data integrity - record guaranteed to exist

## Migration Path (If You Have Existing Data)

If you already have users, coins, and carts in old tables, run this SQL:

```sql
-- Drop old constraints
ALTER TABLE user_coins DROP CONSTRAINT IF EXISTS user_coins_uid_key;
ALTER TABLE user_carts DROP CONSTRAINT IF EXISTS user_carts_uid_key;

-- Add user_id column if not exists
ALTER TABLE user_coins ADD COLUMN user_id bigint;
ALTER TABLE user_carts ADD COLUMN user_id bigint;

-- Populate user_id from users table
UPDATE user_coins uc
SET user_id = u.id
FROM users u
WHERE uc.username = u.username;

UPDATE user_carts uc
SET user_id = u.id
FROM users u
WHERE uc.username = u.username;

-- Make user_id NOT NULL and add foreign key
ALTER TABLE user_coins ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE user_carts ALTER COLUMN user_id SET NOT NULL;

ALTER TABLE user_coins ADD CONSTRAINT user_coins_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE user_carts ADD CONSTRAINT user_carts_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Add unique constraint on user_id
ALTER TABLE user_coins ADD CONSTRAINT user_coins_user_id_key UNIQUE (user_id);
ALTER TABLE user_carts ADD CONSTRAINT user_carts_user_id_key UNIQUE (user_id);

-- Drop old uid columns if they exist
ALTER TABLE user_coins DROP COLUMN IF EXISTS uid;
ALTER TABLE user_carts DROP COLUMN IF EXISTS uid;
```

## Setup Instructions

### For Fresh Start (No Existing Data)

1. **Delete all existing tables** in Supabase SQL editor:
   ```sql
   DROP TABLE IF EXISTS daily_quiz_attempts;
   DROP TABLE IF EXISTS user_carts;
   DROP TABLE IF EXISTS user_coins;
   DROP TABLE IF EXISTS users;
   ```

2. **Create new tables** (see `SUPABASE_MIGRATION_COMPLETE.md` Step 3)

3. **Test registration:**
   - Open app and register new user
   - Check Supabase dashboard
   - Should see:
     - New row in `users` table
     - New row in `user_coins` table with `user_id` and `username`
     - New row in `user_carts` table with `user_id` and `username`

### For Existing Data

1. Run the migration SQL above
2. Verify all `user_coins` records have `user_id` populated
3. Verify all `user_carts` records have `user_id` populated
4. Test the app

## Testing the Fix

### Test 1: Register New User
```
1. Open app
2. Click Register
3. Enter: username="john", email="john@test.com", password="pass123"
4. Click Register
5. Go to Supabase Dashboard

Expected Results:
✅ users table has new row: {id: 1, username: "john", email: "john@test.com", ...}
✅ user_coins table has new row: {id: 1, user_id: 1, username: "john", coins: 0}
✅ user_carts table has new row: {id: 1, user_id: 1, username: "john", items: []}
```

### Test 2: Earn Coins
```
1. Login as john
2. Complete a quiz
3. Check coins increased

Expected Results:
✅ Dashboard shows increased coins
✅ user_coins table shows updated coins value
✅ Coins persisted in database (refresh app - coins still there)
```

### Test 3: Add to Cart
```
1. Login as john
2. Add products to cart
3. Check Supabase

Expected Results:
✅ user_carts table shows items array with products
✅ Items persist after app restart
```

### Test 4: Delete User (Cascade Test)
```
1. In Supabase SQL editor, run:
   DELETE FROM users WHERE username = 'john';

Expected Results:
✅ User deleted from users table
✅ Automatically deleted from user_coins table (cascade)
✅ Automatically deleted from user_carts table (cascade)
✅ No orphaned data left behind
```

## Benefits of This Structure

| Benefit | Old Structure | New Structure |
|---------|--------------|---------------|
| **Data Integrity** | ❌ Orphaned records possible | ✅ Foreign keys ensure valid data |
| **Cascade Deletes** | ❌ Manual cleanup required | ✅ Automatic cleanup on delete |
| **Unique Coins/Cart** | ❌ Multiple coins records per user | ✅ One coins record per user (unique user_id) |
| **Foreign Key** | ❌ Separate uid columns | ✅ Proper references to users table |
| **Query Speed** | ⚠️ Works but less optimized | ✅ Better indexing with user_id |
| **Data Initialization** | ❌ Manual initialization needed | ✅ Automatic during registration |

## Summary

✅ **User Coins** - Now properly linked to users table with `user_id` foreign key  
✅ **User Carts** - Now properly linked to users table with `user_id` foreign key  
✅ **Data Integrity** - Cascade deletes prevent orphaned data  
✅ **Auto Initialization** - Coins and carts auto-created during registration  
✅ **No More UPSERT** - Simple UPDATE queries work because records always exist  

Your database is now properly structured with complete referential integrity!
