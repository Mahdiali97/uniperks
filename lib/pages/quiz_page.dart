import 'package:flutter/material.dart';
import '../services/user_coins_service.dart';
import '../services/quiz_service.dart';
import '../services/daily_quiz_service.dart';

class QuizPage extends StatefulWidget {
  final String username;

  const QuizPage({super.key, required this.username});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
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
    final modules = QuizService.getQuizModules();
    final todayCompletedCount = DailyQuizService.getTodayCompletedQuizzesCount(widget.username);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quiz Challenge'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Progress Card
            Card(
              elevation: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Quiz Progress',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Completed today: $todayCompletedCount/${modules.length}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '🏆',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a quiz topic (Once per day per topic)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.9, // Slightly taller for status info
                ),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  final canTake = DailyQuizService.canTakeQuizToday(widget.username, module.id);
                  return _buildModuleCard(module, canTake);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(QuizModule module, bool canTake) {
    final timeUntilReset = DailyQuizService.getTimeUntilReset(widget.username, module.id);

    return Card(
      elevation: canTake ? 3 : 1,
      child: InkWell(
        onTap: canTake ? () => _selectModule(module) : () => _showDailyLimitDialog(module, timeUntilReset),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: canTake ? [
                Colors.deepPurple.withOpacity(0.05),
                Colors.deepPurple.withOpacity(0.02),
              ] : [
                Colors.grey.withOpacity(0.05),
                Colors.grey.withOpacity(0.02),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon, category, and status
              Row(
                children: [
                  Text(
                    module.icon,
                    style: TextStyle(
                      fontSize: 24,
                      color: canTake ? null : Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: canTake 
                          ? Colors.deepPurple.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      module.category,
                      style: TextStyle(
                        fontSize: 9,
                        color: canTake ? Colors.deepPurple : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Title
              Text(
                module.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: canTake ? null : Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              
              // Description
              Text(
                module.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: canTake ? Colors.grey[600] : Colors.grey[400],
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              
              // Status and Stats
              if (!canTake) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '✓ Completed Today',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeUntilReset,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                // Stats for available quizzes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.quiz, size: 12, color: Colors.blue),
                        const SizedBox(width: 3),
                        Text(
                          '${module.totalQuestions} questions',
                          style: const TextStyle(fontSize: 10, color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.monetization_on, size: 12, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          'Up to ${module.coinsReward} coins',
                          style: const TextStyle(fontSize: 10, color: Colors.amber),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
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
          title: Row(
            children: [
              Text(module.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Quiz Completed',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have already completed "${module.title}" today!',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Quiz Limit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            'Each quiz can only be taken once per day',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '⏰ $timeUntilReset',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Suggest other available quizzes
                _showAvailableQuizzes();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Other Quizzes'),
            ),
          ],
        );
      },
    );
  }

  void _showAvailableQuizzes() {
    final modules = QuizService.getQuizModules();
    final availableModules = modules.where((module) => 
        DailyQuizService.canTakeQuizToday(widget.username, module.id)).toList();

    if (availableModules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 You\'ve completed all quizzes today! Come back tomorrow for more.'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Available Quizzes'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: availableModules.map((module) => 
                ListTile(
                  leading: Text(module.icon, style: const TextStyle(fontSize: 20)),
                  title: Text(module.title, style: const TextStyle(fontSize: 14)),
                  subtitle: Text('${module.coinsReward} coins', style: const TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(context);
                    _selectModule(module);
                  },
                ),
              ).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuizCompletedScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Complete'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selectedModule!.icon,
                style: const TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 16),
              Text(
                'Daily Quiz Completed! 🎉',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                selectedModule!.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You earned',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '$score coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Come back tomorrow for more quizzes!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goBackToModules,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Back to Quizzes'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Check if there are more available quizzes
                        _showAvailableQuizzes();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Try Other Quizzes'),
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

  Widget _buildQuizScreen() {
    final currentQuestion = currentQuestions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedModule!.title,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Question ${currentQuestionIndex + 1} of ${currentQuestions.length}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => _goBackToModules(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 14),
                const SizedBox(width: 2),
                Text(
                  '${currentQuestion['coins']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / currentQuestions.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              minHeight: 6,
            ),
            const SizedBox(height: 20),

            // Question Card - Made smaller
            Card(
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.withOpacity(0.05),
                      Colors.deepPurple.withOpacity(0.02),
                    ],
                  ),
                ),
                child: Text(
                  currentQuestion['question'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Answer Options - Made more compact
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion['answers'].length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildAnswerOption(
                      currentQuestion['answers'][index],
                      index,
                      currentQuestion['correctAnswer'],
                    ),
                  );
                },
              ),
            ),

            // Next Button - Made smaller
            if (answerSelected)
              SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    currentQuestionIndex == currentQuestions.length - 1 ? 'Finish Quiz' : 'Next Question',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoQuestionsScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Not Available'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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
              Icon(Icons.quiz, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No questions available',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              const Text('This quiz module is being prepared'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _goBackToModules,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Choose Another Topic'),
              ),
            ],
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
      color: cardColor,
      elevation: selectedAnswerIndex == index ? 4 : 2,
      child: InkWell(
        onTap: answerSelected ? null : () => _selectAnswer(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: textColor ?? Colors.grey,
                    width: 2,
                  ),
                  color: selectedAnswerIndex == index && !answerSelected
                      ? Colors.deepPurple
                      : Colors.transparent,
                ),
                child: icon != null
                    ? Icon(icon, color: Colors.white, size: 12)
                    : selectedAnswerIndex == index && !answerSelected
                        ? const Icon(Icons.circle, color: Colors.white, size: 8)
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  answer,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor ?? Colors.black87,
                    fontWeight: selectedAnswerIndex == index ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectModule(QuizModule module) {
    setState(() {
      selectedModule = module;
      currentQuestions = QuizService.getQuestionsByModule(module.id);
      currentQuestionIndex = 0;
      score = 0;
      quizCompleted = false;
      answerSelected = false;
      selectedAnswerIndex = null;
    });
  }

  void _selectAnswer(int index) {
    setState(() {
      selectedAnswerIndex = index;
      answerSelected = true;
    });

    if (index == currentQuestions[currentQuestionIndex]['correctAnswer']) {
      score += currentQuestions[currentQuestionIndex]['coins'] as int;
    }
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < currentQuestions.length - 1) {
        currentQuestionIndex++;
        answerSelected = false;
        selectedAnswerIndex = null;
      } else {
        quizCompleted = true;
        // Record that user completed this quiz today
        DailyQuizService.recordQuizAttempt(widget.username, selectedModule!.id);
        // Add earned coins to user's account
        UserCoinsService.addCoins(widget.username, score);
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      quizCompleted = false;
      answerSelected = false;
      selectedAnswerIndex = null;
    });
  }

  void _goBackToModules() {
    setState(() {
      selectedModule = null;
      currentQuestions = [];
      currentQuestionIndex = 0;
      score = 0;
      quizCompleted = false;
      answerSelected = false;
      selectedAnswerIndex = null;
    });
  }
}