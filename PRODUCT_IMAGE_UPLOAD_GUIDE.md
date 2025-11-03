# Product Image Upload - Complete Setup Guide

## ✅ What's Been Implemented

The admin product add/edit dialog now supports **TWO ways** to add product images:

### Option 1: Image URL (existing)
- Paste any external image URL (Unsplash, etc.)
- Works immediately, no upload needed

### Option 2: Gallery Upload (NEW ✨)
- Pick an image from device gallery
- **Automatically uploads to Supabase Storage**
- Returns a public URL stored in the database

---

## 🗄️ Database Setup

### The `products` table already has the `image_url` column:

```sql
CREATE TABLE products (
  id bigint primary key generated always as identity,
  name text not null,
  description text not null,
  price numeric(10,2) not null,
  image_url text,  -- ✅ Already exists!
  category text not null,
  discount integer default 0,
  rating numeric(2,1) default 0,
  reviews jsonb default '[]'::jsonb,
  created_at timestamp default now()
);
```

✅ **No changes needed** - the column is already there!

---

## 🪣 Supabase Storage Setup (REQUIRED)

You need to create a storage bucket in Supabase for product images.

### Step 1: Run SQL in Supabase

1. Go to **Supabase Dashboard** → Your Project
2. Click **SQL Editor** in sidebar
3. Copy and paste the entire `STORAGE_SETUP.sql` file
4. Click **Run**

This creates:
- ✅ `product-images` bucket (public, 5MB limit)
- ✅ Policies for upload/view/delete

### Step 2: Verify Bucket Created

1. Go to **Storage** in Supabase sidebar
2. You should see `product-images` bucket
3. Public access: ✅ Enabled

---

## 📱 How It Works

### Admin Add Product Flow:

1. **Admin opens Add Product dialog**
2. **Fills in product details** (name, price, etc.)
3. **Image options**:
   - **Option A**: Paste image URL in "Image URL" field
   - **Option B**: Click "Pick from Gallery" button
     - Gallery picker opens
     - Admin selects image
     - Shows "Selected: filename.jpg"
4. **Admin clicks Add/Update**
   - If gallery image selected:
     - Shows loading spinner
     - Uploads image to Supabase Storage (`product-images` bucket)
     - Gets public URL from Supabase
     - Saves URL to database
   - If URL provided:
     - Directly saves URL to database
5. **Product saved with image!**

### Validation:
- ⚠️ At least ONE must be filled (URL or gallery image)
- ⚠️ If both empty → button disabled + warning shown
- ✅ Can use both (gallery overrides URL)

---

## 🔧 Technical Implementation

### Files Changed:

**`lib/admin_dashboard.dart`:**
```dart
// Added imports
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

// New upload method
Future<String?> _uploadImageToSupabase(String filePath) async {
  final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final bytes = await File(filePath).readAsBytes();
  
  // Upload to Supabase Storage
  await Supabase.instance.client.storage
      .from('product-images')
      .uploadBinary(fileName, bytes, ...);
  
  // Return public URL
  return Supabase.instance.client.storage
      .from('product-images')
      .getPublicUrl(fileName);
}

// Dialog updated to:
// 1. Show gallery picker button
// 2. Upload image when gallery selected
// 3. Show loading during upload
// 4. Handle errors gracefully
```

**`pubspec.yaml`:**
```yaml
dependencies:
  image_picker: ^1.0.7  # Added for gallery support
```

---

## 🚀 Testing Steps

### 1. Setup Storage (one-time):
```sql
-- Run STORAGE_SETUP.sql in Supabase SQL Editor
```

### 2. Test Image URL (existing feature):
1. Admin → Products tab → Add Product
2. Fill form
3. Paste image URL: `https://images.unsplash.com/photo-xyz?w=400`
4. Click Add
5. ✅ Product appears with image

### 3. Test Gallery Upload (new feature):
1. Admin → Products tab → Add Product
2. Fill form
3. Click "Pick from Gallery"
4. Select an image from device
5. See "Selected: image.jpg"
6. Click Add
7. ⏳ Loading spinner shows
8. ✅ Product appears with uploaded image

### 4. Test Validation:
1. Admin → Add Product
2. Fill form but leave both image fields empty
3. See red warning: "Please provide either an image URL or pick a photo from gallery."
4. Add button is **disabled** (grey)
5. ✅ Cannot submit without image

---

## 🎯 User Experience

### Before (URL only):
```
Admin must:
1. Find image online
2. Copy URL
3. Paste in form
```

### After (URL + Gallery):
```
Admin can:
1. Use existing URLs (fast)
   OR
2. Pick from device gallery (convenient)
   - Upload happens automatically
   - No manual URL needed
```

---

## 📊 Storage Details

### Bucket Configuration:
- **Name**: `product-images`
- **Access**: Public (anyone can view)
- **File limit**: 5MB per image
- **Allowed types**: JPEG, JPG, PNG, WebP
- **Naming**: `product_{timestamp}.jpg`

### Security:
- ✅ Public can **view** images
- ✅ Authenticated users can **upload**
- ✅ Authenticated users can **update/delete**
- ❌ Anonymous users **cannot upload**

### Example URLs:
```
https://{project}.supabase.co/storage/v1/object/public/product-images/product_1698765432000.jpg
```

---

## ⚠️ Important Notes

1. **Storage bucket MUST be created** before using gallery upload
   - Run `STORAGE_SETUP.sql` once
   - Verify in Supabase Dashboard → Storage

2. **Image size limit**: 5MB
   - Larger images will fail to upload
   - User sees error message

3. **Internet required**: Upload only works with network
   - Offline = upload fails
   - Error shown to admin

4. **File format**: Currently uploads as JPEG
   - PNG/WebP also supported by bucket
   - Can adjust in code if needed

---

## 🐛 Troubleshooting

### Error: "Failed to upload image"
**Cause**: Storage bucket not created  
**Fix**: Run `STORAGE_SETUP.sql` in Supabase

### Error: "Bucket 'product-images' not found"
**Cause**: Bucket name mismatch  
**Fix**: Check bucket exists in Storage tab

### Image doesn't appear after upload
**Cause**: Public access not enabled  
**Fix**: Re-run storage policies in SQL

### Gallery picker doesn't open
**Cause**: Permission denied  
**Fix**: Grant storage permission in device settings

---

## ✅ Checklist

Before using gallery upload:
- [ ] Run `STORAGE_SETUP.sql` in Supabase
- [ ] Verify `product-images` bucket exists
- [ ] Test image URL (existing feature)
- [ ] Test gallery upload (new feature)
- [ ] Verify images display in product catalog

---

## 🎉 Summary

**Database**: ✅ `image_url` column already exists (no changes needed)  
**Storage**: ⚠️ Run `STORAGE_SETUP.sql` to create bucket (one-time setup)  
**Code**: ✅ Already updated with upload logic  
**Dependencies**: ✅ `image_picker` added to pubspec.yaml  

**Admin can now**:
- ✅ Add products with image URLs (fast, existing)
- ✅ Add products with gallery images (convenient, NEW)
- ✅ See clear validation errors
- ✅ Get automatic upload to cloud storage

Done! 🚀
