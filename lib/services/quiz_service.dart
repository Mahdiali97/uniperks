import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz_question.dart';
import '../models/quiz_module.dart';

class QuizService {
  static final _supabase = Supabase.instance.client;
  static const String _questionsTable = 'quiz_questions';
  static const String _modulesTable = 'quiz_modules';
  static final _random = Random();

  // Get all quiz modules
  static Future<List<QuizModule>> getQuizModules() async {
    try {
      final data = await _supabase
          .from(_modulesTable)
          .select()
          .eq('active', true)
          .order('title');

      return (data as List).map((json) => QuizModule.fromJson(json)).toList();
    } catch (e) {
      print('Get Quiz Modules Error: $e');
      return [];
    }
  }

  // Get all questions for a module
  static Future<List<QuizQuestion>> getQuestionsByModule(
    String moduleId,
  ) async {
    try {
      final data = await _supabase
          .from(_questionsTable)
          .select()
          .eq('module_id', moduleId)
          .order('created_at', ascending: false);

      return (data as List).map((json) => QuizQuestion.fromJson(json)).toList();
    } catch (e) {
      print('Get Questions By Module Error: $e');
      return [];
    }
  }

  // Get random daily questions for a module (5 questions shuffled)
  static Future<List<Map<String, dynamic>>> getDailyQuestions(
    String moduleId, {
    int count = 5,
  }) async {
    try {
      final questions = await getQuestionsByModule(moduleId);

      if (questions.isEmpty) {
        return [];
      }

      // Shuffle all questions
      final shuffled = List<QuizQuestion>.from(questions)..shuffle(_random);

      // Take first 'count' questions
      final selected = shuffled.take(count).toList();

      // Shuffle answers for each question and return as Map with shuffled answers
      return selected.map((q) {
        // Create a shuffled version of answers with their indices
        final answersWithIndices = List.generate(
          q.answers.length,
          (i) => {'answer': q.answers[i], 'originalIndex': i},
        )..shuffle(_random);

        // Find new correct answer index
        final newCorrectIndex = answersWithIndices.indexWhere(
          (item) => item['originalIndex'] == q.correctAnswer,
        );

        return {
          'id': q.id,
          'question': q.question,
          'answers': answersWithIndices.map((item) => item['answer']).toList(),
          'correctAnswer': newCorrectIndex,
          'difficulty': q.difficulty,
          'coins': q.coins,
        };
      }).toList();
    } catch (e) {
      print('Get Daily Questions Error: $e');
      return [];
    }
  }

  // Get question count for module
  static Future<int> getQuestionCount(String moduleId) async {
    try {
      final questions = await getQuestionsByModule(moduleId);
      return questions.length;
    } catch (e) {
      print('Get Question Count Error: $e');
      return 0;
    }
  }

  // Get total coins for module
  static Future<int> getTotalCoins(String moduleId) async {
    try {
      final questions = await getQuestionsByModule(moduleId);
      return questions.fold<int>(0, (sum, q) => sum + q.coins);
    } catch (e) {
      print('Get Total Coins Error: $e');
      return 0;
    }
  }

  // Add new question (Admin only)
  static Future<bool> addQuestion(QuizQuestion question) async {
    try {
      await _supabase.from(_questionsTable).insert(question.toJson());
      return true;
    } catch (e) {
      print('Add Question Error: $e');
      return false;
    }
  }

  // Update question (Admin only)
  static Future<bool> updateQuestion(int id, QuizQuestion question) async {
    try {
      await _supabase
          .from(_questionsTable)
          .update(question.toJson())
          .eq('id', id);
      return true;
    } catch (e) {
      print('Update Question Error: $e');
      return false;
    }
  }

  // Delete question (Admin only)
  static Future<bool> deleteQuestion(int id) async {
    try {
      await _supabase.from(_questionsTable).delete().eq('id', id);
      return true;
    } catch (e) {
      print('Delete Question Error: $e');
      return false;
    }
  }

  // Get all questions (Admin only - for management)
  static Future<List<QuizQuestion>> getAllQuestions() async {
    try {
      final data = await _supabase
          .from(_questionsTable)
          .select()
          .order('module_id')
          .order('created_at', ascending: false);

      return (data as List).map((json) => QuizQuestion.fromJson(json)).toList();
    } catch (e) {
      print('Get All Questions Error: $e');
      return [];
    }
  }

  // Initialize default modules (run once)
  static Future<void> initializeModules() async {
    try {
      final existingModules = await _supabase.from(_modulesTable).select();

      if (existingModules.isEmpty) {
        final modules = [
          QuizModule(
            id: 'upsi_history',
            title: 'UPSI History',
            description:
                'Learn about Sultan Idris Educational University\'s rich history',
            category: 'History',
            icon: '🏛️',
          ),
          QuizModule(
            id: 'general_knowledge',
            title: 'General Knowledge',
            description: 'Test your knowledge on various topics',
            category: 'General',
            icon: '🌍',
          ),
          QuizModule(
            id: 'university_math',
            title: 'University Mathematics',
            description: 'Challenge yourself with math problems',
            category: 'Mathematics',
            icon: '📐',
          ),
          QuizModule(
            id: 'university_english',
            title: 'University English',
            description: 'Improve your English skills',
            category: 'Language',
            icon: '📚',
          ),
        ];

        for (var module in modules) {
          await _supabase.from(_modulesTable).insert(module.toJson());
        }

        print('Initialized default quiz modules');
      }
    } catch (e) {
      print('Initialize Modules Error: $e');
    }
  }
}
