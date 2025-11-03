# ⚡ Quick Setup: Fixed SQL Tables

Just copy-paste this entire block into Supabase SQL Editor:

```sql
-- Delete old tables if you have them
DROP TABLE IF EXISTS quiz_questions CASCADE;
DROP TABLE IF EXISTS quiz_modules CASCADE;
DROP TABLE IF EXISTS redeemed_vouchers CASCADE;
DROP TABLE IF EXISTS vouchers CASCADE;
DROP TABLE IF EXISTS daily_quiz_attempts CASCADE;
DROP TABLE IF EXISTS user_carts CASCADE;
DROP TABLE IF EXISTS user_coins CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create fixed tables with proper foreign keys
CREATE TABLE users (
  id bigint primary key generated always as identity,
  username text unique not null,
  email text unique not null,
  password text not null,
  created_at timestamp default now()
);

CREATE TABLE user_coins (
  id bigint primary key generated always as identity,
  user_id bigint unique not null references users(id) on delete cascade,
  username text not null,
  coins integer default 0,
  last_updated timestamp default now()
);

CREATE TABLE user_carts (
  id bigint primary key generated always as identity,
  user_id bigint unique not null references users(id) on delete cascade,
  username text not null,
  items jsonb default '[]'::jsonb,
  created_at timestamp default now(),
  updated_at timestamp default now()
);

CREATE TABLE daily_quiz_attempts (
  id bigint primary key generated always as identity,
  username text not null references users(username) on delete cascade,
  module_id text not null,
  attempt_date text not null,
  created_at timestamp default now(),
  unique(username, module_id, attempt_date)
);

-- NEW: Vouchers table (admin manages vouchers)
CREATE TABLE vouchers (
  id bigint primary key generated always as identity,
  title text not null,
  description text not null,
  category text not null,
  discount integer not null,
  coins_required integer not null,
  valid_days integer not null,
  active boolean default true,
  created_at timestamp default now()
);

-- NEW: Redeemed vouchers table (tracks user voucher redemptions)
CREATE TABLE redeemed_vouchers (
  id bigint primary key generated always as identity,
  user_id bigint not null references users(id) on delete cascade,
  username text not null,
  voucher_id bigint not null references vouchers(id) on delete cascade,
  voucher_title text not null,
  voucher_category text not null,
  valid_days integer not null,
  redeemed_at timestamp default now(),
  expires_at timestamp not null
);

-- NEW: Quiz modules table (categories like UPSI History, Math, English)
CREATE TABLE quiz_modules (
  id text primary key,
  title text not null,
  description text not null,
  category text not null,
  icon text not null,
  active boolean default true,
  created_at timestamp default now()
);

-- NEW: Quiz questions table (admin adds quiz questions here)
CREATE TABLE quiz_questions (
  id bigint primary key generated always as identity,
  module_id text not null references quiz_modules(id) on delete cascade,
  question text not null,
  answers jsonb not null,
  correct_answer integer not null,
  difficulty integer not null,
  created_at timestamp default now()
);
```

## What This Does

✅ Deletes all old tables  
✅ Creates `users` table (primary)  
✅ Creates `user_coins` with foreign key to `users`  
✅ Creates `user_carts` with foreign key to `users`  
✅ Creates `vouchers` table (admin adds vouchers here)  
✅ Creates `redeemed_vouchers` table (tracks user redemptions)  
✅ Creates `quiz_modules` table (quiz categories like UPSI History, Math, English)  
✅ Creates `quiz_questions` table (admin adds questions with difficulty levels)  
✅ Sets up cascade delete (deleting user deletes their coins/cart/vouchers)  
✅ Makes it impossible to have coins/cart without a user  

## Then Test

1. Open app → Register new user
2. Go to Supabase Dashboard → Tables
3. Check `users` table - new user there ✓
4. Check `user_coins` table - new record with matching `user_id` ✓
5. Check `user_carts` table - new record with matching `user_id` ✓
6. Check `vouchers` table - empty (admin will add) ✓
7. Check `redeemed_vouchers` table - empty (until users redeem) ✓
8. Check `quiz_modules` table - empty (run `QuizService.initializeModules()` or admin adds) ✓
9. Check `quiz_questions` table - empty (admin will add questions) ✓

Done! Your database is now properly structured. 🎉
