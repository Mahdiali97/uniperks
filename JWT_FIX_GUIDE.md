# JWT 401 Error Fix Guide

## Problem
You're getting: `Failed to create paymentIntent code 401 message invalid jwt`

This means **Supabase Edge Function is rejecting the JWT token** sent from your Flutter app.

## Root Causes & Solutions

### Solution 1: Make the Edge Function Public (RECOMMENDED FOR NOW)
Supabase Edge Functions can be set to require authentication or be public. For payment processing, we can make it public since it validates requests server-side anyway.

**Steps:**
1. Go to Supabase Dashboard → Edge Functions
2. Find `create-payment-intent` function
3. Click on it and look for "Security" or "Authentication" settings
4. Set it to **"Public"** (not authenticated)
5. Save

**Why this works:** The 401 error is Supabase rejecting the request at the edge, not your function code. Making it public lets your function handle the request.

---

### Solution 2: Update Flutter to NOT send Authorization Header

If you want to keep it authenticated, modify the PaymentService to remove the Authorization header (temporarily):

**In `lib/services/payment_service.dart`, change `_createPaymentIntent` to:**

```dart
final response = await http.post(
  url,
  headers: {
    'Content-Type': 'application/json',
    // REMOVE Authorization header temporarily
  },
  body: jsonEncode({
    // ... rest of code
  }),
);
```

---

### Solution 3: Check if User Session is Valid

The token might be expired or malformed. Check the Flutter logs:

**When testing, watch the console output for:**
```
🔐 Session check:
   Current user ID: [some-uuid]
   Session exists: true
   
🔑 Token check:
   Token length: [number]
   Token prefix: eyJhbGci...
   Token has 3 parts (JWT format): true
```

- If `Session exists: false` → **User is NOT logged in**. Log in first.
- If `Token has 3 parts: false` → **Token is malformed**. This is a bug.

---

## Steps to Fix

### Quick Fix (Recommended)
1. **Make Edge Function Public:**
   - Go to Supabase Dashboard
   - Edge Functions → create-payment-intent
   - Set to Public
   - Save & deploy

2. **Test the payment flow again**

### If Step 1 Doesn't Work
1. Check if user is logged in (see logs above)
2. If not logged in → Log in first, then try payment
3. If logged in but still error → Try Solution 2 (remove Authorization header temporarily)

### Proper Fix (Long-term)
Once working, implement proper JWT validation in the Edge Function:
```typescript
// In create-payment-intent/index.ts, add after line 8:
const authHeader = req.headers.get('Authorization');
const token = authHeader?.replace('Bearer ', '');
// Validate token with Supabase admin client
```

---

## Testing Checklist

- [ ] User can log in successfully
- [ ] User is on Payment Page
- [ ] Click "Pay" button
- [ ] Check console for "Session exists: true"
- [ ] If session exists and error still occurs → Make function public
- [ ] Try payment again with public function

---

## Debug Output to Watch For

**Success scenario:**
```
🔐 Session check:
   Current user ID: 12345678-1234-1234-1234-123456789abc
   Session exists: true

🔑 Token check:
   Token length: 456
   Token prefix: eyJhbGciOiJIUzI1NiIs...
   Token has 3 parts: true

📤 Sending request to: https://oaxljityjzjylvvmfrta.supabase.co/functions/v1/create-payment-intent
⚡ Attempting request WITHOUT Authorization header to test...
📨 Response without auth - Status: 200
📨 Response without auth - Body: {"client_secret":"pi_xxx_secret_xxx","id":"pi_xxx"}
✅ Request worked WITHOUT auth header!
```

**Failure scenario (401):**
```
🔐 Session check:
   Current user ID: null
   Session exists: false

❌ No active session! User might not be logged in.
```

---

## Contact / Further Help

If error persists after trying both solutions, collect:
1. The full error response from the console
2. Screenshot of Supabase Edge Functions dashboard (showing function settings)
3. Whether the function is set to Public or Authenticated
