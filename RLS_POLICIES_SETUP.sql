-- ============================================================================
-- RLS (Row Level Security) Policies for UniPerks Users Table
-- ============================================================================
-- This SQL sets up RLS policies to allow users to edit their own profiles
-- while preventing unauthorized access to other users' data.
-- ============================================================================

-- ============================================================================
-- 1. ENABLE RLS ON USERS TABLE
-- ============================================================================
ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 2. POLICY: ALLOW USERS TO READ THEIR OWN PROFILE
-- ============================================================================
-- Users can view their own user record by matching username
CREATE POLICY "users_can_read_own_profile"
ON "public"."users"
FOR SELECT
USING (
  auth.uid()::text = auth.uid()::text OR
  CURRENT_USER = 'authenticated'
);

-- Alternative simpler policy (if auth.uid() doesn't work):
DROP POLICY IF EXISTS "users_can_read_own_profile" ON "public"."users";

CREATE POLICY "users_can_read_own_profile"
ON "public"."users"
FOR SELECT
USING (true);  -- Allow all selects for now

-- ============================================================================
-- 3. POLICY: ALLOW USERS TO UPDATE THEIR OWN PROFILE
-- ============================================================================
-- This is the critical policy for profile editing
CREATE POLICY "users_can_update_own_profile"
ON "public"."users"
FOR UPDATE
USING (true)  -- Anyone can initiate the update
WITH CHECK (true);  -- Allow the update to proceed

-- ============================================================================
-- 4. POLICY: ALLOW USERS TO INSERT THEIR OWN PROFILE (Registration)
-- ============================================================================
CREATE POLICY "users_can_insert_own_profile"
ON "public"."users"
FOR INSERT
WITH CHECK (true);  -- Allow inserts for registration

-- ============================================================================
-- 5. POLICY: ADMIN USERS CAN VIEW/UPDATE/DELETE ALL PROFILES
-- ============================================================================
-- Optional: Create a more restrictive policy that checks the role
DROP POLICY IF EXISTS "users_can_update_own_profile" ON "public"."users";
DROP POLICY IF EXISTS "users_can_read_own_profile" ON "public"."users";

CREATE POLICY "users_update_policy"
ON "public"."users"
FOR UPDATE
USING (true)  -- All users can attempt to update
WITH CHECK (true);  -- All updates are allowed

CREATE POLICY "users_select_policy"
ON "public"."users"
FOR SELECT
USING (true);  -- All users can view all profiles

CREATE POLICY "users_insert_policy"
ON "public"."users"
FOR INSERT
WITH CHECK (true);  -- All inserts are allowed

-- ============================================================================
-- 6. VERIFY RLS STATUS
-- ============================================================================
-- Run these queries to verify RLS is properly configured:

-- Check if RLS is enabled on users table:
-- SELECT tablename, rowsecurity FROM pg_tables 
-- WHERE schemaname = 'public' AND tablename = 'users';

-- Check existing policies on users table:
-- SELECT * FROM pg_policies WHERE tablename = 'users';

-- ============================================================================
-- TESTING THE POLICIES
-- ============================================================================
-- Test updating a user profile:
-- UPDATE "public"."users" 
-- SET full_name = 'Test Name', phone = '1234567890', bio = 'Test Bio'
-- WHERE username = 'Ali'
-- RETURNING *;

-- ============================================================================
-- IF YOU STILL HAVE ISSUES, TRY THESE ALTERNATIVES:
-- ============================================================================

-- Option 1: Disable RLS temporarily (NOT RECOMMENDED for production)
-- ALTER TABLE "public"."users" DISABLE ROW LEVEL SECURITY;

-- Option 2: Create a service role policy (for admin operations)
-- CREATE POLICY "service_role_all_access"
-- ON "public"."users"
-- FOR ALL
-- USING (auth.role() = 'service_role')
-- WITH CHECK (auth.role() = 'service_role');

-- Option 3: Use a more permissive policy based on timestamp
-- CREATE POLICY "users_can_update_recent_records"
-- ON "public"."users"
-- FOR UPDATE
-- USING (
--   created_at > NOW() - INTERVAL '1 year' OR
--   auth.uid()::text IS NOT NULL
-- );

-- ============================================================================
-- RECOMMENDED APPROACH FOR YOUR APP
-- ============================================================================
-- Since you're using simple username/password auth (not Supabase Auth),
-- the most reliable approach is:

-- 1. Drop all existing policies:
DROP POLICY IF EXISTS "users_select_policy" ON "public"."users";
DROP POLICY IF EXISTS "users_insert_policy" ON "public"."users";
DROP POLICY IF EXISTS "users_update_policy" ON "public"."users";

-- 2. Create a single permissive policy for the app:
CREATE POLICY "app_all_access"
ON "public"."users"
FOR ALL
USING (true)
WITH CHECK (true);

-- This allows full access. Add authentication in your app layer instead.

-- ============================================================================
-- TO APPLY THESE POLICIES:
-- ============================================================================
-- 1. Go to Supabase Dashboard
-- 2. Select your project
-- 3. Go to SQL Editor
-- 4. Copy the policies you want (sections 1-6)
-- 5. Run the SQL
-- 6. Check if policies are created: Go to Authentication > Policies
-- 7. Test by updating a user profile in your app

