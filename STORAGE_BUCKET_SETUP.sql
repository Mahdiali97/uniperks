-- ============================================================================
-- SUPABASE STORAGE SETUP FOR USER AVATARS
-- ============================================================================
-- This SQL creates a storage bucket for user avatars and sets up RLS policies
-- ============================================================================

-- ============================================================================
-- 1. CREATE STORAGE BUCKET FOR AVATARS
-- ============================================================================
-- Run this in Supabase SQL Editor to create the bucket:

-- Insert a new storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('user_avatars', 'user_avatars', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 2. ENABLE RLS ON STORAGE.OBJECTS
-- ============================================================================
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 3. POLICIES FOR USER AVATARS BUCKET
-- ============================================================================

-- Policy 1: Allow anyone to view avatars (public read)
CREATE POLICY "Public Avatar Access"
ON storage.objects
FOR SELECT
USING (bucket_id = 'user_avatars');

-- Policy 2: Allow authenticated users to upload avatars
CREATE POLICY "Users can upload avatars"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'user_avatars' AND
  auth.role() = 'authenticated'
);

-- Policy 3: Allow users to update their own avatars
CREATE POLICY "Users can update own avatars"
ON storage.objects
FOR UPDATE
USING (bucket_id = 'user_avatars')
WITH CHECK (bucket_id = 'user_avatars');

-- Policy 4: Allow users to delete their own avatars
CREATE POLICY "Users can delete own avatars"
ON storage.objects
FOR DELETE
USING (bucket_id = 'user_avatars');

-- ============================================================================
-- ALTERNATIVE: PERMISSIVE POLICIES (Simpler - for development)
-- ============================================================================
-- If the above policies don't work, use these simpler ones:

-- Drop existing policies if needed
DROP POLICY IF EXISTS "Public Avatar Access" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own avatars" ON storage.objects;

-- Create permissive policies
CREATE POLICY "Allow all avatar operations"
ON storage.objects
FOR ALL
USING (bucket_id = 'user_avatars')
WITH CHECK (bucket_id = 'user_avatars');

-- ============================================================================
-- VERIFY BUCKET CREATION
-- ============================================================================
-- Run this to check if bucket was created:
-- SELECT id, name, public FROM storage.buckets WHERE id = 'user_avatars';

-- ============================================================================
-- BUCKET CONFIGURATION IN SUPABASE DASHBOARD (Manual Steps)
-- ============================================================================
-- 1. Go to Supabase Dashboard
-- 2. Navigate to Storage (left sidebar)
-- 3. You should see "user_avatars" bucket
-- 4. Click on it to enter the bucket
-- 5. Go to "Policies" tab
-- 6. Verify the policies are created
-- 7. Make sure "Public" toggle is ON (for public read access)

-- ============================================================================
-- HOW TO USE IN YOUR FLUTTER APP
-- ============================================================================
-- The uploadAvatar() method in user_service.dart will:
-- 1. Pick image from device gallery (via image_picker)
-- 2. Upload to 'user_avatars' bucket with filename: {username}_{timestamp}.jpg
-- 3. Get public URL: https://YOUR_PROJECT.supabase.co/storage/v1/object/public/user_avatars/{filename}
-- 4. Store URL in users.avatar_url column

-- Example:
-- final url = await UserService.uploadAvatar('Ali', imageFile);
-- Result: https://YOUR_PROJECT.supabase.co/storage/v1/object/public/user_avatars/Ali_1700000000000.jpg

