-- Admin RLS setup for UniPerks
-- This script enables RLS on products and creates secure policies for
-- public reads and admin-only writes using Supabase Auth.

-- 1) Ensure RLS is enabled
alter table public.products enable row level security;

-- 2) Public read policy (optional; keep if you want anyone to see products)
drop policy if exists "Public can read products" on public.products;
create policy "Public can read products"
  on public.products
  for select
  using (true);

-- 3) Use application users table to manage roles
-- We assume an existing public.users table used by the app.
-- Add columns to link to Supabase Auth and to store role.
alter table if exists public.users
  add column if not exists auth_user_id uuid unique,
  add column if not exists role text check (role in ('admin','user')) default 'user';

create index if not exists users_auth_user_id_idx on public.users(auth_user_id);

comment on column public.users.auth_user_id is 'FK to auth.users.id for this application user';
comment on column public.users.role is 'Role of the user in the app: admin or user';

-- 4) Admin-only write policies using public.users (role = admin)
drop policy if exists "Admins (users table) can insert products" on public.products;
create policy "Admins (users table) can insert products"
  on public.products
  for insert
  to authenticated
  with check (exists (
    select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'
  ));

drop policy if exists "Admins (users table) can update products" on public.products;
create policy "Admins (users table) can update products"
  on public.products
  for update
  to authenticated
  using (exists (
    select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'
  ))
  with check (exists (
    select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'
  ));

drop policy if exists "Admins (users table) can delete products" on public.products;
create policy "Admins (users table) can delete products"
  on public.products
  for delete
  to authenticated
  using (exists (
    select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'
  ));

-- 5) Extend RLS to other tables (vouchers, quiz)
alter table if exists public.vouchers enable row level security;
alter table if exists public.quiz_questions enable row level security;
alter table if exists public.quiz_modules enable row level security;
alter table if exists public.users enable row level security;

-- Public can read these tables (optional depending on app needs)
drop policy if exists "Public can read vouchers" on public.vouchers;
create policy "Public can read vouchers"
  on public.vouchers for select using (true);

drop policy if exists "Public can read quiz_questions" on public.quiz_questions;
create policy "Public can read quiz_questions"
  on public.quiz_questions for select using (true);

drop policy if exists "Public can read quiz_modules" on public.quiz_modules;
create policy "Public can read quiz_modules"
  on public.quiz_modules for select using (true);

-- Admin-only writes for vouchers
drop policy if exists "Admins can insert vouchers" on public.vouchers;
create policy "Admins can insert vouchers"
  on public.vouchers for insert to authenticated
  with check (exists (select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'));

drop policy if exists "Admins can update vouchers" on public.vouchers;
create policy "Admins can update vouchers"
  on public.vouchers for update to authenticated
  using (exists (select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'))
  with check (exists (select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'));

drop policy if exists "Admins can delete vouchers" on public.vouchers;
create policy "Admins can delete vouchers"
  on public.vouchers for delete to authenticated
  using (exists (select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'));

-- Admin-only writes for quiz tables
drop policy if exists "Admins can insert quiz_questions" on public.quiz_questions;
create policy "Admins can insert quiz_questions"
  on public.quiz_questions for insert to authenticated
  with check (exists (select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'));

drop policy if exists "Admins can update quiz_questions" on public.quiz_questions;
create policy "Admins can update quiz_questions"
  on public.quiz_questions for update to authenticated
  using (exists (select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'))
  with check (exists (select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'));

drop policy if exists "Admins can delete quiz_questions" on public.quiz_questions;
create policy "Admins can delete quiz_questions"
  on public.quiz_questions for delete to authenticated
  using (exists (select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'));

-- Module management (if managed via UI)
drop policy if exists "Admins can manage quiz_modules" on public.quiz_modules;
create policy "Admins can manage quiz_modules"
  on public.quiz_modules for all to authenticated
  using (exists (select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'))
  with check (exists (select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'));

-- Users table policies:
drop policy if exists "Public can read app users" on public.users;
create policy "Public can read app users"
  on public.users for select using (true);

drop policy if exists "Admins can write app users" on public.users;
create policy "Admins can write app users"
  on public.users for all to authenticated
  using (true)
  with check (exists (select 1 from public.users u where u.auth_user_id = auth.uid() and u.role = 'admin'));

-- 6) Map your admin account
-- After creating your admin account via Supabase Auth, run:
-- update public.users set auth_user_id = '<auth.users.id>', role = 'admin' where username = '<your-existing-admin-username>';
-- Or insert a new app user row with role = 'admin' if it doesn't exist.
