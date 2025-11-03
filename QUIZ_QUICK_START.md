# 🎯 Quick Start - Quiz System Setup

## Step 1: Run SQL Setup (Supabase)
Copy from `SQL_QUICK_SETUP.md` and run in Supabase SQL Editor

```sql
-- Tables created:
-- quiz_modules (categories)
-- quiz_questions (questions with difficulty, answers)
```

## Step 2: Initialize Default Modules
Call once in your app (main.dart or admin dashboard):

```dart
await QuizService.initializeModules();
```

This creates:
- ✅ UPSI History
- ✅ General Knowledge  
- ✅ University Mathematics
- ✅ University English

## Step 3: Add Quiz Questions
Go to **Admin Dashboard** → **Quiz Management**:
1. Select a module (e.g., "UPSI History")
2. Click "Add Question"
3. Fill in:
   - **Question**: The quiz question
   - **Difficulty**: Easy (1 coin), Medium (1 coin), or Hard (2 coins)
   - **Options**: 4 answer choices
   - **Correct Answer**: Select via radio button
4. Click "Add"

Repeat to add 5-10 questions per module for best experience.

## Step 4: Test Quiz
1. Login as regular user
2. Go to **Quiz** page
3. Select a module
4. Take quiz (5 random questions)
5. Verify:
   - Questions are different each attempt
   - Answer order changes each attempt
   - Coins awarded after completing

## That's It! 🎉

---

## 🔍 Key Features You'll See

| Feature | What Happens |
|---------|-------------|
| **Random Questions** | Each quiz loads 5 different questions randomly |
| **Shuffled Answers** | Answer positions change each time you play |
| **Easy Questions** | Worth 1 coin each |
| **Medium Questions** | Worth 1 coin each |
| **Hard Questions** | Worth 2 coins each |
| **Daily Limit** | Can only take each quiz once per day |
| **Progress Tracking** | See how many quizzes completed today |

---

## 📞 Troubleshooting

**Q: Quiz page shows "No Questions Available"**  
A: Make sure you added questions in Admin Dashboard

**Q: Answers always in same order**  
A: Answers are shuffled - take quiz again, they'll be different

**Q: Not getting coins**  
A: Make sure you select correct answer before proceeding

---

**Questions?** Check `QUIZ_SYSTEM_FINAL_STATUS.md` for full documentation.
