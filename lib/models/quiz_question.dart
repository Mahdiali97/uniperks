class QuizQuestion {
  final int id;
  final String moduleId;
  final String question;
  final List<String> answers;
  final int correctAnswer;
  final int difficulty;
  final DateTime? createdAt;

  QuizQuestion({
    required this.id,
    required this.moduleId,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.difficulty,
    this.createdAt,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int,
      moduleId: json['module_id'] as String,
      question: json['question'] as String,
      answers: List<String>.from(json['answers'] as List),
      correctAnswer: json['correct_answer'] as int,
      difficulty: json['difficulty'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module_id': moduleId,
      'question': question,
      'answers': answers,
      'correct_answer': correctAnswer,
      'difficulty': difficulty,
    };
  }

  // Get coins based on difficulty: Easy=1, Medium=1, Hard=2
  int get coins {
    if (difficulty == 3) {
      return 2; // Hard questions give 2 coins
    }
    return 1; // Easy and Medium give 1 coin each
  }

  String get difficultyName {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Unknown';
    }
  }
}
