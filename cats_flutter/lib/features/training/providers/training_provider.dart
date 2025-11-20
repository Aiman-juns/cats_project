import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/supabase_config.dart';

/// Question Models
class Question {
  final String id;
  final String moduleType; // 'phishing', 'password', 'attack'
  final int difficulty; // 1-5
  final String content;
  final String correctAnswer;
  final String explanation;
  final String? mediaUrl;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.moduleType,
    required this.difficulty,
    required this.content,
    required this.correctAnswer,
    required this.explanation,
    this.mediaUrl,
    required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      moduleType: json['module_type'] as String,
      difficulty: json['difficulty'] as int,
      content: json['content'] as String,
      correctAnswer: json['correct_answer'] as String,
      explanation: json['explanation'] as String,
      mediaUrl: json['media_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// User Progress Model
class UserProgress {
  final String id;
  final String userId;
  final String questionId;
  final bool isCorrect;
  final int scoreAwarded;
  final DateTime attemptDate;

  UserProgress({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.isCorrect,
    required this.scoreAwarded,
    required this.attemptDate,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      questionId: json['question_id'] as String,
      isCorrect: json['is_correct'] as bool,
      scoreAwarded: json['score_awarded'] as int,
      attemptDate: DateTime.parse(json['attempt_date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'question_id': questionId,
    'is_correct': isCorrect,
    'score_awarded': scoreAwarded,
    'attempt_date': attemptDate.toIso8601String(),
  };
}

/// Fetch questions by module type
Future<List<Question>> fetchQuestionsByModule(String moduleType) async {
  try {
    final response = await SupabaseConfig.client
        .from('questions')
        .select()
        .eq('module_type', moduleType)
        .order('difficulty', ascending: true);

    return (response as List<dynamic>)
        .map((json) => Question.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch questions: $e');
  }
}

/// Record user progress
Future<void> recordProgress(UserProgress progress) async {
  try {
    await SupabaseConfig.client.from('user_progress').insert(progress.toJson());
  } catch (e) {
    throw Exception('Failed to record progress: $e');
  }
}

/// Fetch user progress for a module
Future<List<UserProgress>> fetchUserProgressByModule(
  String userId,
  String moduleType,
) async {
  try {
    final questions = await fetchQuestionsByModule(moduleType);
    final questionIds = questions.map((q) => q.id).toList();

    if (questionIds.isEmpty) return [];

    final response = await SupabaseConfig.client
        .from('user_progress')
        .select()
        .eq('user_id', userId)
        .inFilter('question_id', questionIds);

    return (response as List<dynamic>)
        .map((json) => UserProgress.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch user progress: $e');
  }
}

/// Riverpod Providers

/// Phishing module questions
final phishingQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  return fetchQuestionsByModule('phishing');
});

/// Password module questions
final passwordQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  return fetchQuestionsByModule('password');
});

/// Attack module questions
final attackQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  return fetchQuestionsByModule('attack');
});

/// User progress for phishing module
final phishingProgressProvider =
    FutureProvider.family<List<UserProgress>, String>((ref, userId) async {
      return fetchUserProgressByModule(userId, 'phishing');
    });

/// User progress for password module
final passwordProgressProvider =
    FutureProvider.family<List<UserProgress>, String>((ref, userId) async {
      return fetchUserProgressByModule(userId, 'password');
    });

/// User progress for attack module
final attackProgressProvider =
    FutureProvider.family<List<UserProgress>, String>((ref, userId) async {
      return fetchUserProgressByModule(userId, 'attack');
    });
