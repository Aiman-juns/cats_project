import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/training_provider.dart';

class PhishingScreen extends ConsumerStatefulWidget {
  const PhishingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PhishingScreen> createState() => _PhishingScreenState();
}

class _PhishingScreenState extends ConsumerState<PhishingScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  bool _isCorrect = false;
  String _feedbackMessage = '';

  void _handleSwipe({required bool isPhishing}) {
    if (_isAnswered) return;

    final questions = ref.read(phishingQuestionsProvider).value ?? [];
    if (questions.isEmpty) return;

    final question = questions[_currentIndex];
    final correct =
        question.correctAnswer.toLowerCase() ==
        (isPhishing ? 'phishing' : 'safe');

    setState(() {
      _isAnswered = true;
      _isCorrect = correct;
      _feedbackMessage = correct
          ? '✓ Correct! That is ${isPhishing ? 'PHISHING' : 'SAFE'}.'
          : '✗ Incorrect! It is actually ${question.correctAnswer}.';

      if (correct) {
        _score +=
            (6 - question.difficulty) * 10; // More points for harder difficulty
      }
    });

    // Move to next question after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAnswered = false;
          _currentIndex++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(phishingQuestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phishing Detection'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Score: $_score',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading questions: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(phishingQuestionsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(
              child: Text('No phishing questions available yet'),
            );
          }

          if (_currentIndex >= questions.length) {
            return _buildCompletionScreen(questions.length, context);
          }

          final question = questions[_currentIndex];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Text(
                    'Question ${_currentIndex + 1}/${questions.length}',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  // Difficulty indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < question.difficulty
                                ? Colors.orange
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Question card
                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        // Swiped right - mark as phishing
                        _handleSwipe(isPhishing: true);
                      } else if (details.primaryVelocity! < 0) {
                        // Swiped left - mark as safe
                        _handleSwipe(isPhishing: false);
                      }
                    },
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            if (question.mediaUrl != null)
                              Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      question.mediaUrl!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              height: 200,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            Text(
                              question.content,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Feedback
                  if (_isAnswered)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isCorrect
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        border: Border.all(
                          color: _isCorrect ? Colors.green : Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _feedbackMessage,
                            style: TextStyle(
                              color: _isCorrect ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.explanation,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        Text(
                          'Swipe to answer:',
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  const SizedBox(height: 16),
                  // Answer buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isAnswered
                            ? null
                            : () => _handleSwipe(isPhishing: true),
                        icon: const Icon(Icons.warning),
                        label: const Text('Phishing'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          disabledBackgroundColor: Colors.red.shade200,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isAnswered
                            ? null
                            : () => _handleSwipe(isPhishing: false),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Safe'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          disabledBackgroundColor: Colors.green.shade200,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompletionScreen(int totalQuestions, BuildContext context) {
    final maxScore = totalQuestions * 50; // Max 50 points per question

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          Text(
            'Training Complete!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Text(
                  'Your Score',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_score / $maxScore',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${((_score / maxScore) * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _score = 0;
                _isAnswered = false;
              });
            },
            icon: const Icon(Icons.restart_alt),
            label: const Text('Try Again'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to Training Hub'),
          ),
        ],
      ),
    );
  }
}
