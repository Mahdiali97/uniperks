class QuizModule {
  final String id;
  final String title;
  final String description;
  final String category;
  final int totalQuestions;
  final int coinsReward;
  final String icon;

  QuizModule({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.totalQuestions,
    required this.coinsReward,
    required this.icon,
  });
}

class QuizService {
  static final Map<String, List<Map<String, dynamic>>> _moduleQuestions = {
    'upsi_history': [
      {
        'question': 'In which year was Sultan Idris Educational University (UPSI) established?',
        'answers': ['1922', '1925', '1928', '1930'],
        'correctAnswer': 0,
        'coins': 15,
      },
      {
        'question': 'What was UPSI originally known as before becoming a university?',
        'answers': ['Teacher Training College', 'Sultan Idris Training College', 'Educational Institute', 'Teaching Academy'],
        'correctAnswer': 1,
        'coins': 12,
      },
      {
        'question': 'UPSI is located in which state of Malaysia?',
        'answers': ['Selangor', 'Perak', 'Pahang', 'Negeri Sembilan'],
        'correctAnswer': 1,
        'coins': 10,
      },
      {
        'question': 'What is the main focus of UPSI as an educational institution?',
        'answers': ['Engineering', 'Medicine', 'Teacher Education', 'Business'],
        'correctAnswer': 2,
        'coins': 8,
      },
      {
        'question': 'In which town is UPSI main campus located?',
        'answers': ['Ipoh', 'Tanjung Malim', 'Kuala Lumpur', 'Taiping'],
        'correctAnswer': 1,
        'coins': 10,
      },
      {
        'question': 'What does the acronym UPSI stand for?',
        'answers': ['University Pendidikan Sultan Idris', 'University Pengajaran Sultan Idris', 'University Perak Sultan Idris', 'University Pendidikan Selangor Idris'],
        'correctAnswer': 0,
        'coins': 12,
      },
      {
        'question': 'UPSI became a full university status in which year?',
        'answers': ['1997', '1999', '2000', '2002'],
        'correctAnswer': 1,
        'coins': 15,
      },
    ],
    'general_knowledge': [
      {
        'question': 'What is the capital of Malaysia?',
        'answers': ['Kuala Lumpur', 'Putrajaya', 'Johor Bahru', 'Penang'],
        'correctAnswer': 0,
        'coins': 8,
      },
      {
        'question': 'Which planet is known as the Red Planet?',
        'answers': ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        'correctAnswer': 1,
        'coins': 10,
      },
      {
        'question': 'What is the largest ocean on Earth?',
        'answers': ['Atlantic Ocean', 'Indian Ocean', 'Arctic Ocean', 'Pacific Ocean'],
        'correctAnswer': 3,
        'coins': 8,
      },
      {
        'question': 'Who wrote the novel "To Kill a Mockingbird"?',
        'answers': ['Harper Lee', 'Mark Twain', 'Ernest Hemingway', 'F. Scott Fitzgerald'],
        'correctAnswer': 0,
        'coins': 12,
      },
      {
        'question': 'What is the chemical symbol for gold?',
        'answers': ['Go', 'Gd', 'Au', 'Ag'],
        'correctAnswer': 2,
        'coins': 10,
      },
      {
        'question': 'In which year did World War II end?',
        'answers': ['1944', '1945', '1946', '1947'],
        'correctAnswer': 1,
        'coins': 10,
      },
      {
        'question': 'What is the smallest country in the world?',
        'answers': ['Monaco', 'Liechtenstein', 'Vatican City', 'San Marino'],
        'correctAnswer': 2,
        'coins': 12,
      },
    ],
    'university_math': [
      {
        'question': 'What is the derivative of x²?',
        'answers': ['x', '2x', 'x²', '2x²'],
        'correctAnswer': 1,
        'coins': 15,
      },
      {
        'question': 'What is the integral of 1/x?',
        'answers': ['ln(x)', 'x²/2', '1/x²', 'e^x'],
        'correctAnswer': 0,
        'coins': 18,
      },
      {
        'question': 'What is the value of sin(π/2)?',
        'answers': ['0', '1', '-1', '1/2'],
        'correctAnswer': 1,
        'coins': 12,
      },
      {
        'question': 'What is the limit of (sin x)/x as x approaches 0?',
        'answers': ['0', '1', '∞', 'undefined'],
        'correctAnswer': 1,
        'coins': 20,
      },
      {
        'question': 'What is the determinant of a 2x2 matrix [[a,b],[c,d]]?',
        'answers': ['a+d-b-c', 'ad-bc', 'ac-bd', 'a+b+c+d'],
        'correctAnswer': 1,
        'coins': 15,
      },
      {
        'question': 'What is e^(ln x) equal to?',
        'answers': ['1', 'x', 'e', 'ln x'],
        'correctAnswer': 1,
        'coins': 12,
      },
      {
        'question': 'What is the sum of an infinite geometric series with first term a and ratio r (|r| < 1)?',
        'answers': ['a/(1-r)', 'a(1-r)', 'a+r', 'ar/(1-r)'],
        'correctAnswer': 0,
        'coins': 18,
      },
    ],
    'university_english': [
      {
        'question': 'Which of the following is an example of a metaphor?',
        'answers': ['He runs like the wind', 'Time is money', 'The wind whispered', 'She is as brave as a lion'],
        'correctAnswer': 1,
        'coins': 12,
      },
      {
        'question': 'What is the past participle of "write"?',
        'answers': ['wrote', 'written', 'writing', 'writes'],
        'correctAnswer': 1,
        'coins': 8,
      },
      {
        'question': 'Which sentence uses correct parallel structure?',
        'answers': ['She likes reading, writing, and to paint', 'She likes reading, writing, and painting', 'She likes to read, writing, and painting', 'She likes reading, to write, and painting'],
        'correctAnswer': 1,
        'coins': 15,
      },
      {
        'question': 'What is the meaning of the prefix "anti-"?',
        'answers': ['before', 'against', 'together', 'between'],
        'correctAnswer': 1,
        'coins': 10,
      },
      {
        'question': 'Which of the following is a compound sentence?',
        'answers': ['Although it was raining, we went outside.', 'We went outside because it stopped raining.', 'It was raining, but we went outside anyway.', 'We went outside when the rain stopped.'],
        'correctAnswer': 2,
        'coins': 15,
      },
      {
        'question': 'What type of essay presents arguments for and against a topic?',
        'answers': ['Narrative essay', 'Descriptive essay', 'Argumentative essay', 'Expository essay'],
        'correctAnswer': 2,
        'coins': 12,
      },
      {
        'question': 'Which word is spelled correctly?',
        'answers': ['occurance', 'occurrance', 'occurrence', 'occurence'],
        'correctAnswer': 2,
        'coins': 10,
      },
    ],
  };

  static List<QuizModule> getQuizModules() {
    return [
      QuizModule(
        id: 'upsi_history',
        title: 'UPSI History',
        description: 'Learn about Sultan Idris Educational University\'s rich history and heritage',
        category: 'History',
        totalQuestions: _moduleQuestions['upsi_history']?.length ?? 0,
        coinsReward: _getTotalCoins('upsi_history'),
        icon: '🏛️',
      ),
      QuizModule(
        id: 'general_knowledge',
        title: 'General Knowledge',
        description: 'Test your knowledge on various topics from around the world',
        category: 'General',
        totalQuestions: _moduleQuestions['general_knowledge']?.length ?? 0,
        coinsReward: _getTotalCoins('general_knowledge'),
        icon: '🌍',
      ),
      QuizModule(
        id: 'university_math',
        title: 'University Mathematics',
        description: 'Challenge yourself with university-level math problems',
        category: 'Mathematics',
        totalQuestions: _moduleQuestions['university_math']?.length ?? 0,
        coinsReward: _getTotalCoins('university_math'),
        icon: '📐',
      ),
      QuizModule(
        id: 'university_english',
        title: 'University English',
        description: 'Improve your English language skills and grammar',
        category: 'Language',
        totalQuestions: _moduleQuestions['university_english']?.length ?? 0,
        coinsReward: _getTotalCoins('university_english'),
        icon: '📚',
      ),
    ];
  }

  static int _getTotalCoins(String moduleId) {
    final questions = _moduleQuestions[moduleId] ?? [];
    return questions.fold(0, (sum, question) => sum + (question['coins'] as int));
  }

  static List<Map<String, dynamic>> getQuestionsByModule(String moduleId) {
    return _moduleQuestions[moduleId] ?? [];
  }

  static List<Map<String, dynamic>> getAllQuestions() {
    // This method is kept for backward compatibility
    List<Map<String, dynamic>> allQuestions = [];
    for (var questions in _moduleQuestions.values) {
      allQuestions.addAll(questions);
    }
    return allQuestions;
  }

  static void addQuestion(Map<String, dynamic> question, [String? moduleId]) {
    moduleId ??= 'general_knowledge';
    _moduleQuestions[moduleId] ??= [];
    _moduleQuestions[moduleId]!.add(question);
  }

  static void updateQuestion(String moduleId, int index, Map<String, dynamic> question) {
    if (_moduleQuestions[moduleId] != null && 
        index >= 0 && 
        index < _moduleQuestions[moduleId]!.length) {
      _moduleQuestions[moduleId]![index] = question;
    }
  }

  static void removeQuestion(String moduleId, int index) {
    if (_moduleQuestions[moduleId] != null && 
        index >= 0 && 
        index < _moduleQuestions[moduleId]!.length) {
      _moduleQuestions[moduleId]!.removeAt(index);
    }
  }

  static Map<String, dynamic>? getQuestion(String moduleId, int index) {
    if (_moduleQuestions[moduleId] != null && 
        index >= 0 && 
        index < _moduleQuestions[moduleId]!.length) {
      return _moduleQuestions[moduleId]![index];
    }
    return null;
  }
}