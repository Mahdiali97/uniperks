# Profile Management Feature Guide

## Overview
Added comprehensive profile management and privacy/security features to UniPerks. Users can now edit their profiles, manage security settings, and control privacy preferences.

## New Features

### 1. **Edit Profile Page** (`lib/pages/edit_profile_page.dart`)

#### Features:
- **Avatar Upload**: Click the camera icon on avatar to select and upload a profile picture from gallery
- **Full Name**: Update display name
- **Email Address**: Update email contact
- **Phone Number**: Update phone contact  
- **Bio**: Add personal bio/description
- **Image Optimization**: Images automatically optimized (512x512px max, 85% quality)

#### How to Use:
1. Navigate to Profile → Edit Profile
2. Click camera icon to change avatar
3. Fill in profile fields
4. Click "Save Changes"
5. Changes persist to Supabase

#### Technical Details:
- Avatar stored in Supabase Storage (`user_avatars` bucket)
- Images uploaded with timestamp-based filenames to avoid conflicts
- Public URL generated for avatar display
- Profile data stored in `users` table

---

### 2. **Privacy & Security Page** (`lib/pages/privacy_security_page.dart`)

#### Account Security Section:

**Change Password**
- Dialog shows 3 password fields (current, new, confirm)
- Validates current password against database
- Enforces 6+ character minimum for new password
- Confirms passwords match before submission
- Successful change requires re-authentication on next login

**Change Username**
- Update account username
- Validates new username is unique
- Updates related tables: `user_coins`, `user_carts`
- After change, user redirected to login page to re-authenticate

**Two-Factor Authentication** (Coming Soon)
- Toggle switch to prepare for 2FA implementation
- Will add SMS/email verification on login

#### Privacy Preferences Section:

**Email Notifications**
- Toggle to opt-in/out of order and promotional emails
- Default: ON

**Push Notifications**
- Toggle for mobile push notifications
- Default: OFF

#### Danger Zone:

**Delete Account**
- Confirmation dialog requires typing exact username
- Shows what data will be deleted:
  - Personal data
  - Purchase history  
  - Vouchers and coins
- Permanently deletes account and related records
- User redirected to login after deletion

---

## Updated Services

### `lib/services/user_service.dart`

#### New Methods:

**`updateUserProfile()`**
```dart
static Future<bool> updateUserProfile({
  required String username,
  String? fullName,
  String? email,
  String? phone,
  String? bio,
  String? avatarUrl,
})
```
- Updates user profile fields
- Returns true on success

**`uploadAvatar()`**
```dart
static Future<String?> uploadAvatar(
  String username,
  File avatarFile,
)
```
- Uploads image to Supabase Storage
- Returns public URL or null on failure

**`changePassword()`**
```dart
static Future<bool> changePassword(
  String username,
  String oldPassword,
  String newPassword,
)
```
- Validates current password
- Updates to new password
- Returns true on success

**`updateUsername()`**
```dart
static Future<bool> updateUsername(
  String oldUsername,
  String newUsername,
)
```
- Checks if new username is unique
- Updates username in all tables
- Returns false if username exists

**`getUserProfile()`**
```dart
static Future<Map<String, dynamic>?> getUserProfile(String username)
```
- Retrieves complete user profile data

**`deleteUserAccount()`**
```dart
static Future<bool> deleteUserAccount(String username)
```
- Deletes all user-related data
- Removes from related tables first

---

## Updated Pages

### `lib/pages/profile_page.dart`

#### Changes:
- "Edit Profile" button now navigates to `EditProfilePage`
- Refreshes profile data after successful edits
- "Privacy & Security" button now navigates to `PrivacySecurityPage`

---

## Database Schema Requirements

### New Column (Optional but Recommended):
```sql
ALTER TABLE users ADD COLUMN avatar_url TEXT;
ALTER TABLE users ADD COLUMN full_name TEXT;
ALTER TABLE users ADD COLUMN phone TEXT;
ALTER TABLE users ADD COLUMN bio TEXT;
```

### Storage Bucket:
```
Create bucket: user_avatars
Policy: Public read access
```

---

## File Structure

```
lib/
├── pages/
│   ├── edit_profile_page.dart (NEW)
│   ├── privacy_security_page.dart (NEW)
│   └── profile_page.dart (UPDATED)
├── services/
│   └── user_service.dart (UPDATED)
└── [other files...]
```

---

## UI/UX Highlights

### Design System:
- **Primary Color**: `Color(0xFF0066CC)` (Blue)
- **Success Color**: `Colors.green`
- **Danger Color**: `Colors.red`
- **Border Radius**: 12dp standard
- **Shadow**: Subtle (0.05 opacity)

### Navigation:
- Smooth page transitions with material route
- Back button support on all new pages
- Proper scaffold structure with AppBar

### Dialogs:
- Confirmation dialogs for sensitive actions (password, username, delete)
- Loading indicators during async operations
- Success/error snackbars

---

## Testing Checklist

- [ ] Edit profile with new full name
- [ ] Upload profile avatar from gallery
- [ ] Edit email and phone
- [ ] Change password successfully
- [ ] Try incorrect password (should fail)
- [ ] Change username uniquely
- [ ] Toggle notification preferences
- [ ] Delete account (confirm and cancel flows)
- [ ] Verify avatar displays on profile
- [ ] Verify changes persist after app restart

---

## Future Enhancements

1. **Two-Factor Authentication**
   - SMS verification on login
   - Email verification option
   
2. **Profile Visibility**
   - Public profile option
   - Profile sharing
   
3. **Notifications**
   - Actual email sending via backend
   - Push notification service
   
4. **Advanced Security**
   - Device management
   - Login history
   - Suspicious activity alerts

5. **Avatar Options**
   - Default avatar styles
   - Avatar cropping UI
   - Avatar gallery preview

---

## Error Handling

All pages include comprehensive error handling:
- Network failures show snackbars
- Validation errors display inline
- Async operations include loading states
- Failed operations don't silently fail

---

## Notes for Developers

1. **Imports**: Make sure to import the new pages where navigating to them
2. **Supabase Storage**: Ensure `user_avatars` bucket exists in Supabase dashboard
3. **File Picker**: Uses `image_picker` package (already in pubspec.yaml)
4. **State Management**: Pages use StatefulWidget + setState (fits project pattern)
5. **Async Patterns**: Uses Future/async-await with proper mounted checks

---

## Support

For questions or issues:
1. Check error messages in snackbars
2. Review console for print() debug statements
3. Verify Supabase table and storage configuration
4. Test with proper network connectivity
