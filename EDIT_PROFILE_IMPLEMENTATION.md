# Edit Profile Implementation - UniPerks

## What Was Implemented

I've integrated a clean, minimal edit profile feature into your UniPerks app using your existing Supabase backend and UserService.

## Files Modified/Created

### 1. **lib/services/user_service.dart** (MODIFIED)
- **Added `UserModel` class**: Lightweight model for user data
  - Fields: `userId`, `username`, `email`, `fullName`, `phone`, `bio`, `avatarUrl`
  - Includes `.fromJson()` and `.toJson()` factories for Supabase conversion
  - `.toUpdatePayload()` handles optional password inclusion

- **Added `updateProfileSimple()` method**: 
  - Updates profile fields (email, full_name, phone, bio)
  - Optional password update (only if provided)
  - Returns `(ok: bool, message: String)` tuple
  - Works directly with existing Supabase users table

### 2. **lib/pages/edit_profile_simple.dart** (NEW)
- Simplified edit profile page using the UserModel
- Features:
  - Loads current user data into forms
  - Avatar upload with camera picker
  - Email (required), full name, phone, bio fields
  - Optional password change field
  - Save/Cancel buttons with loading states
  - Success/error snackbars

### 3. **lib/pages/profile_page.dart** (MODIFIED)
- Updated "Edit Profile" button to navigate to `EditProfileSimplePage`
- Auto-refreshes profile data after successful edit
- Maintains existing functionality

---

## How It Works

### Data Flow:
1. User taps "Edit Profile" in profile page
2. `EditProfileSimplePage` loads user data via `UserService.getUserProfile()`
3. User edits fields and optionally changes password
4. On save, calls `UserService.updateProfileSimple()` with updated values
5. Password only included in update if user entered a new one
6. Supabase updates the `users` table row
7. Success/error snackbar shown, page pops back to profile

### Update Behavior:
```dart
// Only password if provided:
UPDATE users SET 
  email = ?, 
  full_name = ?, 
  phone = ?, 
  bio = ?,
  password = ? (only if newPassword is not null/empty)
WHERE username = ?
```

---

## Usage

Navigate to the feature:
```dart
// From any page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => EditProfileSimplePage(
      username: currentUsername, // e.g., 'testuser'
    ),
  ),
);
```

Or tap "Edit Profile" in the Profile page (already wired).

---

## Testing Checklist

- [ ] Run app: `flutter run`
- [ ] Navigate to Profile tab
- [ ] Tap "Edit Profile"
- [ ] Edit email, full name, phone, bio
- [ ] Leave password blank → should not update password
- [ ] Try entering password → password should update
- [ ] Upload avatar → should show preview
- [ ] Tap "Save Changes" → should see success message
- [ ] Go back to profile → verify changes persist
- [ ] Restart app → confirm data persisted to Supabase

---

## Notes

- **Database Columns**: Ensure these columns exist in `users` table in Supabase:
  - `full_name` (text, nullable)
  - `phone` (text, nullable)
  - `bio` (text, nullable)
  - `avatar_url` (text, nullable)

- **Password Logic**: Password only updated if user enters value; existing methods `changePassword()`, `updateUsername()` still work independently

- **Avatar Upload**: Uses existing `UserService.uploadAvatar()` method; requires `user_avatars` bucket in Supabase Storage

- **Clean Code**: Follows your app's patterns (StatefulWidget, Supabase, UserService static methods, snackbars)

---

## Key Differences from Complex Version

| Feature | Old (edit_profile_page.dart) | New (edit_profile_simple.dart) |
|---------|-----|-----|
| Avatar Upload | Full upload | Supported |
| Form Fields | 4 (full_name, email, phone, bio) | 5 (+ password) |
| Password Change | Separate method | Integrated optional field |
| API Integration | Supabase Storage + complex methods | Simple updateProfileSimple() |
| UI | Feature-rich | Clean & minimal |
| Maintenance | Multiple methods to keep in sync | Single updateProfileSimple() |

---

## Ready to Use

✅ All files created and integrated  
✅ No compilation errors  
✅ Uses existing Supabase backend  
✅ Follows your app's code patterns  
✅ Ready to test in your running app
