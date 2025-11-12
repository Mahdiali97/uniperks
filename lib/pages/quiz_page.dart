import 'package:flutter/material.dart';
import '../services/user_coins_service.dart';
import '../services/quiz_service.dart';
import '../services/daily_quiz_service.dart';
import '../models/quiz_module.dart';
import '../widgets/floating_reward_badge.dart';

class QuizPage extends StatefulWidget {
  final String username;

  const QuizPage({super.key, required this.username});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final GlobalKey<FloatingRewardBadgeOverlayState> _overlayKey = GlobalKey();
  QuizModule? selectedModule;
  int currentQuestionIndex = 0;
  int score = 0;
  bool quizCompleted = false;
  bool answerSelected = false;
  int? selectedAnswerIndex;
  List<Map<String, dynamic>> currentQuestions = [];

  @override
  Widget build(BuildContext context) {
    if (selectedModule == null) {
      return _buildModuleSelection();
    }

    if (quizCompleted) {
      return _buildQuizCompletedScreen();
    }

    if (currentQuestions.isEmpty) {
      return _buildNoQuestionsScreen();
    }

    return _buildQuizScreen();
  }

  Widget _buildModuleSelection() {
    return FloatingRewardBadgeOverlay(
      key: _overlayKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Daily Quiz Challenge',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          automaticallyImplyLeading: false,
        ),
        body: FutureBuilder<int>(
          future: DailyQuizService.getTodayCompletedQuizzesCount(
            widget.username,
          ),
          builder: (context, completedSnapshot) {
            if (completedSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final todayCompletedCount = completedSnapshot.data ?? 0;

            return FutureBuilder<List<QuizModule>>(
              future: QuizService.getQuizModules(),
              builder: (context, modulesSnapshot) {
                if (modulesSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (modulesSnapshot.hasError) {
                  return Center(child: Text('Error: ${modulesSnapshot.error}'));
                }

                final modules = modulesSnapshot.data ?? [];

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Today\'s Progress',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),

                        // Daily Progress Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A90E2), Color(0xFF0066CC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Today\'s Progress',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: modules.isNotEmpty
                                      ? todayCompletedCount / modules.length
                                      : 0,
                                  minHeight: 8,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.3,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$todayCompletedCount of ${modules.length} completed',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Available Modules
                        Text(
                          'Available Modules',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // Modules List
                        ...modules.map((module) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: FutureBuilder<bool>(
                              future: DailyQuizService.canTakeQuizToday(
                                widget.username,
                                module.id,
                              ),
                              builder: (context, canTakeSnapshot) {
                                final canTake = canTakeSnapshot.data ?? false;
                                return FutureBuilder<String>(
                                  future: DailyQuizService.getTimeUntilReset(
                                    widget.username,
                                    module.id,
                                  ),
                                  builder: (context, timeSnapshot) {
                                    final timeUntilReset =
                                        timeSnapshot.data ?? '';
                                    return _buildModuleCard(
                                      module,
                                      canTake,
                                      timeUntilReset,
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    QuizModule module,
    bool canTake,
    String timeUntilReset,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: canTake
            ? () => _selectModule(module)
            : () => _showDailyLimitDialog(module, timeUntilReset),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: canTake
                      ? Color(0xFF0066CC).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.quiz,
                  color: canTake ? Color(0xFF0066CC) : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<int>(
                      future: QuizService.getQuestionCount(module.id),
                      builder: (context, countSnapshot) {
                        final count = countSnapshot.data ?? 0;
                        return FutureBuilder<int>(
                          future: QuizService.getTotalCoins(module.id),
                          builder: (context, coinsSnapshot) {
                            final totalCoins = coinsSnapshot.data ?? 0;
                            return Text(
                              '$count questions • Earn up to $totalCoins coins',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: canTake
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      canTake ? 'Available' : 'Locked',
                      style: TextStyle(
                        color: canTake ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDailyLimitDialog(QuizModule module, String timeUntilReset) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Already Completed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have already completed the ${module.title} quiz today.',
              ),
              const SizedBox(height: 12),
              Text('Time until reset: $timeUntilReset'),
              const SizedBox(height: 12),
              const Text('Come back later to take the quiz again!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuizCompletedScreen() {
    return FloatingRewardBadgeOverlay(
      key: _overlayKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Quiz Complete',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Great Job!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You scored $score coins!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Color(0xFF0066CC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${currentQuestions.length} questions completed',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),
                // Retake disabled: Users cannot retake the quiz on the same day.
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _goBackToModules,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0066CC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Modules',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0066CC),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    final currentQuestion = currentQuestions[currentQuestionIndex];

    return FloatingRewardBadgeOverlay(
      key: _overlayKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedModule!.title,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                'Question ${currentQuestionIndex + 1}/${currentQuestions.length}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black87,
          leading: IconButton(
            onPressed: _goBackToModules,
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$score',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / currentQuestions.length,
                  minHeight: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF0066CC),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Question
              Text(
                currentQuestion['question'],
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Answers
              Expanded(
                child: ListView.builder(
                  itemCount: (currentQuestion['answers'] as List).length,
                  itemBuilder: (context, index) {
                    return _buildAnswerOption(
                      currentQuestion['answers'][index],
                      index,
                      currentQuestion['correctAnswer'],
                    );
                  },
                ),
              ),

              // Next Button
              if (answerSelected)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0066CC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      currentQuestionIndex == currentQuestions.length - 1
                          ? 'Finish'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoQuestionsScreen() {
    return FloatingRewardBadgeOverlay(
      key: _overlayKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Quiz Not Available',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black87,
          leading: IconButton(
            onPressed: _goBackToModules,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No Questions Found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This quiz module does not have any questions yet.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _goBackToModules,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0066CC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Modules',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(String answer, int index, int correctAnswer) {
    Color? cardColor;
    Color? textColor;
    IconData? icon;

    if (answerSelected) {
      if (index == correctAnswer) {
        cardColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check;
      } else if (index == selectedAnswerIndex) {
        cardColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.close;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: cardColor == null
            ? BorderSide(color: Colors.grey[200]!)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: answerSelected
            ? null
            : () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm your answer'),
                    content: Text('Submit this answer?\n\n"$answer"'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066CC),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  _finalizeAnswer(index, correctAnswer);
                }
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  answer,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: textColor ?? Colors.black87,
                    fontWeight: selectedAnswerIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, color: textColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _selectModule(QuizModule module) async {
    setState(() {
      selectedModule = module;
      currentQuestionIndex = 0;
      score = 0;
      quizCompleted = false;
      answerSelected = false;
      selectedAnswerIndex = null;
    });

    // Show loading while fetching questions
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    // Load today's randomized questions
    final questions = await QuizService.getDailyQuestions(module.id, count: 5);

    if (mounted) {
      Navigator.of(context).pop();
      setState(() {
        currentQuestions = questions;
      });
      // Show a beautiful 3..2..1 countdown before starting
      await _showCountdownOverlay();
    }
  }

  void _finalizeAnswer(int index, int correctAnswer) {
    setState(() {
      selectedAnswerIndex = index;
      answerSelected = true;
    });

    if (index == correctAnswer) {
      // Get coins from question (already calculated based on difficulty)
      int coinsEarned =
          currentQuestions[currentQuestionIndex]['coins'] as int? ?? 1;
      score += coinsEarned;

      // Show floating reward badge for correct answer
      _overlayKey.currentState?.showRewardBadge(
        RewardBadgeConfig(
          icon: Icons.star,
          label: '+$coinsEarned',
          mainColor: Colors.amber,
          accentColor: Colors.orange,
          size: RewardBadgeSize.medium,
          sparkleCount: 10,
        ),
      );
    }
  }

  void _nextQuestion() async {
    if (currentQuestionIndex < currentQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        answerSelected = false;
        selectedAnswerIndex = null;
      });
    } else {
      // Quiz completed - save coins and record attempt
      try {
        // Record that user completed this quiz today
        await DailyQuizService.recordQuizAttempt(
          widget.username,
          selectedModule!.id,
        );
        // Add earned coins to user's account
        await UserCoinsService.addCoins(widget.username, score);

        if (!mounted) return;
        setState(() {
          quizCompleted = true;
        });

        // Show completion reward badge
        _overlayKey.currentState?.showRewardBadge(
          RewardBadgeConfig(
            icon: Icons.emoji_events,
            label: 'Quiz Complete!\n+$score coins',
            mainColor: Colors.green,
            accentColor: Colors.lightGreen,
            size: RewardBadgeSize.large,
            sparkleCount: 15,
            displayDuration: const Duration(milliseconds: 2500),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving quiz: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Retake disabled intentionally – users cannot retake on the same day.

  Future<void> _showCountdownOverlay() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'countdown',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return const _CountdownOverlay();
      },
    );
  }

  void _goBackToModules() {
    setState(() {
      selectedModule = null;
      currentQuestions = [];
      currentQuestionIndex = 0;
      quizCompleted = false;
      answerSelected = false;
      selectedAnswerIndex = null;
    });
  }
}

// Full-screen animated countdown 3 → 1
class _CountdownOverlay extends StatefulWidget {
  const _CountdownOverlay();

  @override
  State<_CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<_CountdownOverlay> {
  int _number = 3;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    for (int i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _number = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft glowing backdrop circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0066CC).withOpacity(0.35),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
            // Countdown number with pretty scale + fade
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                );
                return FadeTransition(
                  opacity: curved,
                  child: ScaleTransition(scale: curved, child: child),
                );
              },
              child: Text(
                '$_number',
                key: ValueKey(_number),
                style: const TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
