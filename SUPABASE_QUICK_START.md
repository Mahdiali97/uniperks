# Supabase Quick Start

## Step 1: Get Your Supabase Credentials

1. Go to https://supabase.com/dashboard
2. Create a new project (or use existing)
3. Go to **Settings** → **API**
4. Copy:
   - **Project URL** (looks like `https://xxxxx.supabase.co`)
   - **Public API Key** (looks like `eyJhbG...`)

## Step 2: Configure Your App

Your app is already using Supabase in `lib/main.dart`. The credentials are embedded in the code.

To change credentials:
```dart
// In lib/main.dart
const supabaseUrl = 'YOUR_PROJECT_URL';
const supabaseKey = 'YOUR_PUBLIC_API_KEY';
```

## Step 3: Create Database Tables

In your Supabase project:
1. Go to **SQL Editor**
2. Click **New Query**
3. Paste this entire SQL:

```sql
CREATE TABLE users (
  id bigint primary key generated always as identity,
  username text unique not null,
  email text unique not null,
  password text not null,
  coins integer default 0,
  created_at timestamp default now()
);

CREATE TABLE user_coins (
  id bigint primary key generated always as identity,
  uid text unique not null,
  username text unique not null,
  coins integer default 0,
  last_updated timestamp default now()
);

CREATE TABLE user_carts (
  id bigint primary key generated always as identity,
  uid text unique not null,
  username text unique not null,
  items jsonb default '[]'::jsonb,
  created_at timestamp default now(),
  updated_at timestamp default now()
);

CREATE TABLE daily_quiz_attempts (
  id bigint primary key generated always as identity,
  username text not null,
  module_id text not null,
  attempt_date text not null,
  created_at timestamp default now(),
  unique(username, module_id, attempt_date)
);
```

4. Click **Run**
5. Wait for success message

## Step 4: Run the App

```bash
# Get dependencies
flutter pub get

# Run app
flutter run
```

## Step 5: Test Everything

### Register a User
1. Click "Register" on login page
2. Fill in details:
   - Username: `testuser`
   - Email: `test@example.com`
   - Password: `password123`
3. Click "Register"
4. Check Supabase → **users** table → New row should appear

### Login
1. Go back to login
2. Enter: `testuser` / `password123`
3. Should log in successfully

### Test Cart
1. Go to Shop
2. Add item to cart
3. Check Supabase → **user_carts** table
4. Your cart should be stored there

### Test Coins
1. Go to Quiz
2. Complete a quiz
3. Check Supabase → **user_coins** table
4. Your coins should be updated

## Common Issues & Fixes

### "Connection refused"
- Check internet connection
- Check Supabase credentials in `main.dart`
- Verify project is active in Supabase dashboard

### "Invalid login credentials"
- Make sure user was registered first
- Check username/password spelling
- Try registering a new user

### "Cart not saving"
- Make sure you're logged in
- Check user_carts table in Supabase
- Try refreshing the app

### Tables not created
- Check SQL for errors in Supabase SQL editor
- Make sure you clicked "Run"
- Check table list in Supabase (left sidebar)

## Production Setup

Before deploying to app stores:

1. **Enable Row Level Security (RLS)**
   - In Supabase, go to each table
   - Enable RLS
   - Add policies to restrict user access

2. **Set Environment Variables**
   - Don't hardcode credentials
   - Use Flutter config or environment files

3. **Add Input Validation**
   - Validate email format
   - Check password strength
   - Sanitize user input

4. **Enable HTTPS Only**
   - Always use SSL/TLS
   - Supabase does this by default

5. **Implement Rate Limiting**
   - Prevent spam registrations
   - Limit API calls per user

## File Structure

```
lib/
├── main.dart                  # Supabase init here
├── services/
│   ├── user_service.dart      # Uses Supabase
│   ├── cart_service.dart      # Uses Supabase
│   ├── user_coins_service.dart # Uses Supabase
│   └── daily_quiz_service.dart # Uses Supabase
├── auth/
│   ├── login_page.dart
│   └── register_page.dart
└── pages/
    ├── cart_page.dart
    └── quiz_page.dart
```

## API Examples

### User Registration
```dart
await UserService.registerUser(username, email, password);
```

### User Login
```dart
await UserService.authenticateUser(username, password);
```

### Add Coins
```dart
await UserCoinsService.addCoins(username, 10);
```

### Get Cart
```dart
List<CartItem> cart = await CartService.getCartItems(username);
```

## Database Queries

### View All Users
In Supabase SQL Editor:
```sql
SELECT * FROM users;
```

### View User's Cart
```sql
SELECT * FROM user_carts WHERE username = 'testuser';
```

### View User's Coins
```sql
SELECT * FROM user_coins WHERE username = 'testuser';
```

### View Quiz Attempts
```sql
SELECT * FROM daily_quiz_attempts WHERE username = 'testuser';
```

## Support

- Check `SUPABASE_MIGRATION_COMPLETE.md` for detailed docs
- Check `SUPABASE_MIGRATION.md` for API changes
- Review `lib/main.dart` for initialization code

---

**Status**: Ready to use! 🚀
