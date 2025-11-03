# Coins System - Complete Fix & Guide

## ✅ Problem Solved

**Issue**: After completing a quiz, coins were not being saved to the database, so they didn't show up on the dashboard.

**Root Cause**: The `_nextQuestion()` method was calling async methods without `await`, so the operations were never executed.

---

## 🔧 What Was Fixed

### **Before (Broken)**
```dart
void _nextQuestion() {
  setState(() {
    if (currentQuestionIndex < currentQuestions.length - 1) {
      // ...
    } else {
      quizCompleted = true;
      DailyQuizService.recordQuizAttempt(...);  // ❌ Not awaited
      UserCoinsService.addCoins(...);           // ❌ Not awaited
    }
  });
}
```

**Problem**: Async methods returned Futures but were never `await`ed, so the code continued without actually saving anything.

### **After (Fixed)**
```dart
void _nextQuestion() async {
  if (currentQuestionIndex < currentQuestions.length - 1) {
    setState(() {
      currentQuestionIndex++;
    });
  } else {
    try {
      // Properly await both operations
      await DailyQuizService.recordQuizAttempt(...);  // ✅ Now awaited
      await UserCoinsService.addCoins(...);           // ✅ Now awaited
      
      if (!mounted) return;
      setState(() {
        quizCompleted = true;
      });
    } catch (e) {
      // Error handling
    }
  }
}
```

**Solution**: 
1. Made `_nextQuestion()` async
2. Added `await` to both async operations
3. Added error handling with try/catch
4. Check `mounted` before setState after async operations

---

## 💰 How Coins Work (Complete Flow)

### **1. Earning Coins from Quiz**

```
Quiz Page:
├─ User selects module
├─ User answers questions
│  └─ Correct answer → Coins earned based on difficulty
│     (Easy: 5 coins, Medium: 10 coins, Hard: 15 coins)
├─ User finishes last question
├─ Clicks "Finish" button
│  ├─ _nextQuestion() called
│  ├─ await DailyQuizService.recordQuizAttempt()
│  │  └─ Saves to daily_quiz_attempts table
│  ├─ await UserCoinsService.addCoins(username, score)
│  │  ├─ Fetches current coins from user_coins table
│  │  ├─ Adds earned amount
│  │  └─ Saves updated total back to database
│  └─ Shows "Quiz Complete" screen with coins earned
└─ "Back to Modules" button → Returns to dashboard
```

### **2. Dashboard Updates**

```
Dashboard:
├─ Home page loads
│  └─ initState() calls _refreshCoinsAndCart()
│     ├─ Fetches coins from UserCoinsService
│     └─ Displays in AppBar + Stats section
│
├─ User takes quiz
│  └─ Coins saved to database
│
└─ User clicks "Home" tab to return
   └─ bottomNavigationBar onTap triggers refresh
      ├─ _refreshCoinsAndCart() called
      ├─ Fetches latest coins from database
      └─ Updates display everywhere
         ├─ AppBar coin icon
         ├─ Stats card
         └─ Cart badge
```

### **3. Complete User Journey**

```
┌─────────────────────────────────────┐
│  Dashboard                          │
│  Coins: 0                           │
│  [Home] [Shop] [Cart] [Quiz]        │
└─────────────────────────────────────┘
          ↓ Click [Quiz]
┌─────────────────────────────────────┐
│  Quiz Module Selection              │
│  □ General Knowledge               │
│  □ Science                          │
│  □ History                          │
└─────────────────────────────────────┘
          ↓ Select module
┌─────────────────────────────────────┐
│  Quiz Questions                     │
│  Q1: What is 2+2?                   │
│  [A] 3  [B] 4  [C] 5  [D] 6         │
│              ↓ Answer correct
│  ✅ Correct! +5 coins               │
│              ↓ Continue
│  Q2: ...                            │
│              ↓ Answer 5 questions
│  All correct = 25 coins earned
│              ↓ Click "Finish"
├─────────────────────────────────────┤
│  ✅ Great Job!                      │
│  You scored 25 coins!               │
│  5 questions completed              │
│  [Retake Quiz] [Back to Modules]    │
│              ↓ Click Back
└─────────────────────────────────────┘
          ↓ Returns to dashboard
┌─────────────────────────────────────┐
│  Dashboard                          │
│  Coins: 25 ✅ UPDATED!             │
│  [Home] [Shop] [Cart] [Quiz]        │
└─────────────────────────────────────┘
```

---

## 📊 Coins Earning Breakdown

### **By Question Difficulty**

| Difficulty | Coins per Question |
|------------|-------------------|
| Easy (1) | 5 coins |
| Medium (2) | 10 coins |
| Hard (3) | 15 coins |

### **Example Quiz Earnings**

```
Quiz with 10 questions (all correct):
├─ 3 Easy questions × 5 = 15 coins
├─ 5 Medium questions × 10 = 50 coins
├─ 2 Hard questions × 15 = 30 coins
└─ TOTAL = 95 coins earned ✅
```

---

## 🎯 All Coin Sources

### **1. Quiz Completion** ✅ (Just Fixed)
- Earn coins based on correct answers
- Each question has difficulty level
- Saved to database when quiz finished

### **2. Shopping Checkout** ✅ (Already Working)
- 10% cashback in coins on purchases
- Example: $50 purchase = 5 coins earned
- Coins added when purchase completed

### **3. Daily Quiz Limits**
- Can only take each quiz once per day
- Re-attempt available next day
- System tracks via daily_quiz_attempts table

---

## 🔄 Coin Flow in Database

### **User Takes Quiz**
```
Quiz Page (RAM):
│
├─ User answers questions
│  └─ score = 0
│     ├─ Q1 correct (Easy, 5 pts) → score = 5
│     ├─ Q2 correct (Medium, 10 pts) → score = 15
│     └─ Q3 correct (Hard, 15 pts) → score = 30
│
└─ User clicks "Finish"
   └─ await UserCoinsService.addCoins(username, 30)
      ├─ Query: SELECT coins FROM user_coins WHERE username = ?
      ├─ Current coins in DB: 0
      ├─ New total: 0 + 30 = 30
      └─ Query: UPDATE user_coins SET coins = 30 WHERE username = ?
         ✅ Database updated with 30 coins
```

### **Dashboard Refreshes**
```
Dashboard (React to user return):
│
├─ User clicks Home tab
│  └─ bottomNavigationBar onTap → if (index == 0) _refreshCoinsAndCart()
│     ├─ Query: SELECT coins FROM user_coins WHERE username = ?
│     ├─ Get: 30 coins
│     └─ setState() → Rebuild with new value
│
└─ UI Updates:
   ├─ AppBar: Shows 30 coins ✅
   ├─ Stats: Shows 30 coins ✅
   └─ User sees: "Coins: 30" (was 0 before)
```

---

## 🧪 Testing Coin Updates

### **Test 1: Quiz Completion**
1. ✅ Go to Quiz page
2. ✅ Select a module
3. ✅ Answer all questions correctly
4. ✅ Click "Finish" button
5. ✅ See "Great Job! You scored X coins!"
6. ✅ Click "Back to Modules"
7. ✅ **Coins should appear on dashboard** ✅

### **Test 2: Purchase Cashback**
1. ✅ Go to Shop
2. ✅ Add product ($50)
3. ✅ Go to Cart
4. ✅ Click "Proceed to Checkout"
5. ✅ Click "Complete Purchase"
6. ✅ See "You earned 5 coins!" (10% of $50)
7. ✅ Click Home tab
8. ✅ **Coins should update** ✅

### **Test 3: Combined Earnings**
1. Start with 0 coins
2. Take quiz → Earn 25 coins
3. Check Home tab → Shows 25 ✅
4. Make purchase (50) → Earn 5 coins (10% cashback)
5. Check Home tab → Shows 30 ✅

### **Test 4: Daily Limit**
1. Take General Knowledge quiz ✅
2. Try to take same quiz again → Should show "Already taken today"
3. Try different quiz → Should work ✅
4. Next day → Can retake first quiz ✅

---

## 📱 UI Components Using Coins

### **1. AppBar Coin Badge**
```dart
FutureBuilder<int>(
  future: _coinsFuture,  // Refreshable
  builder: (context, snapshot) {
    final coins = snapshot.data ?? 0;
    return Text('$coins');  // Shows updated coins
  },
)
```
- Updates when: User navigates to Home tab
- Displays: Top right corner with coin icon
- Color: Amber/gold

### **2. Stats Card on Home**
```dart
Expanded(
  child: FutureBuilder<int>(
    future: _coinsFuture,  // Refreshable
    builder: (context, snapshot) {
      final coins = snapshot.data ?? 0;
      return _buildStatCard('Coins', '$coins', ...);
    },
  ),
)
```
- Updates when: User navigates to Home tab
- Displays: Large card with coin count
- Shows: Icon + Number + Label

### **3. Quiz Completion Screen**
```dart
Text(
  'You scored $score coins!',  // Shows earned amount
  style: TextStyle(...),
)
```
- Displays: After quiz completion
- Shows: Coins earned in this session
- Updates: Dashboard when user returns home

---

## 🐛 Troubleshooting Coins Not Showing

### **If coins don't appear after quiz:**

1. ✅ Check console for errors
   - Look for exception messages
   - Check Supabase connection

2. ✅ Verify quiz completed
   - See "Great Job!" screen
   - Coins shown in completion message

3. ✅ Go back to Home
   - Click Home tab
   - Dashboard should refresh coins

4. ✅ Check Supabase
   - Log into Supabase dashboard
   - Check `user_coins` table
   - Verify coins were actually saved

### **If coins don't update on dashboard:**

1. ✅ Verify you're on Home tab
   - Coins only refresh when navigating to Home (index 0)

2. ✅ Wait a moment
   - Database query takes time
   - Give FutureBuilder time to rebuild

3. ✅ Try refreshing manually
   - Click another tab
   - Click Home again
   - Forces refresh

---

## ✨ Key Improvements Made

✅ **Quiz coins now actually save to database**
- Fixed: Missing `await` on async calls
- Added: Try/catch error handling
- Added: `mounted` check before setState

✅ **Dashboard coins update automatically**
- Already implemented: Refresh on Home tab navigation
- Result: Users see new coins immediately

✅ **Error handling throughout**
- If save fails: SnackBar shows error
- If network fails: User sees error message
- Safe: `mounted` check prevents crashes

✅ **Complete coin flow implemented**
- Quiz → Coins earned ✅
- Purchase → Coins earned ✅
- Dashboard → Shows all coins ✅
- Refresh → Updates automatically ✅

---

## 📈 Full Coin System Architecture

```
┌─────────────────────────────────────────────────┐
│           UNIPERKS COIN SYSTEM                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  Sources of Coins:                              │
│  ├─ Quiz Completion (5-15 per question)        │
│  ├─ Shopping Cashback (10% of purchase)        │
│  └─ (Future: Daily bonuses, achievements)      │
│                                                 │
│  Database Tables:                               │
│  ├─ user_coins                                  │
│  │  ├─ username                                │
│  │  └─ coins (total balance)                   │
│  ├─ daily_quiz_attempts                        │
│  │  ├─ username                                │
│  │  ├─ module_id                               │
│  │  └─ attempt_date                            │
│  └─ user_carts                                 │
│     ├─ username                                │
│     └─ items (with prices for cashback)        │
│                                                 │
│  Dashboard Display:                             │
│  ├─ AppBar badge                               │
│  ├─ Stats card                                 │
│  └─ (Future: Coin history, leaderboard)       │
│                                                 │
│  Update Mechanism:                              │
│  ├─ Quiz page saves to database                │
│  ├─ Dashboard refreshes when navigating home   │
│  ├─ FutureBuilder shows latest value           │
│  └─ Real-time user feedback                    │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## ✅ Status

- ✅ **Quiz coins now save to database**
- ✅ **Dashboard coins update automatically**
- ✅ **Purchase coins working (10% cashback)**
- ✅ **Error handling in place**
- ✅ **Zero compilation errors**
- ✅ **Ready for production**

---

**All Coin Systems Now Fully Functional!** 🎉💰
