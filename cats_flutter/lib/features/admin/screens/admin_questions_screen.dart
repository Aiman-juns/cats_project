import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../../training/providers/training_provider.dart';

class AdminQuestionsScreen extends ConsumerStatefulWidget {
  const AdminQuestionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminQuestionsScreen> createState() =>
      _AdminQuestionsScreenState();
}

class _AdminQuestionsScreenState extends ConsumerState<AdminQuestionsScreen> {
  String _selectedModule = 'phishing';

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(adminQuestionsProvider(_selectedModule));

    return questionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.refresh(adminQuestionsProvider(_selectedModule)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (questions) {
        return Column(
          children: [
            // Module selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Module', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'phishing', label: Text('Phishing')),
                      ButtonSegment(value: 'password', label: Text('Password')),
                      ButtonSegment(value: 'attack', label: Text('Attack')),
                    ],
                    selected: {_selectedModule},
                    onSelectionChanged: (newSelection) {
                      setState(() => _selectedModule = newSelection.first);
                    },
                  ),
                ],
              ),
            ),
            // Questions list
            Expanded(
              child: questions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No questions yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showCreateQuestionDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Create First Question'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        return _QuestionCard(
                          question: question,
                          onEdit: () =>
                              _showEditQuestionDialog(context, question),
                          onDelete: () =>
                              _showDeleteConfirmDialog(context, question.id),
                        );
                      },
                    ),
            ),
            // Add button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateQuestionDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Question'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateQuestionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _QuestionDialogContent(
        moduleType: _selectedModule,
        onSave: (question) {
          ref.invalidate(adminQuestionsProvider(_selectedModule));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditQuestionDialog(BuildContext context, Question question) {
    showDialog(
      context: context,
      builder: (context) => _QuestionDialogContent(
        moduleType: question.moduleType,
        question: question,
        onSave: (updated) {
          ref.invalidate(adminQuestionsProvider(_selectedModule));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String questionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(adminProvider.notifier)
                    .deleteQuestion(questionId);
                ref.invalidate(adminQuestionsProvider(_selectedModule));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Question deleted')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.question,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        label: Text('Difficulty: ${question.difficulty}'),
                        backgroundColor: Colors.blue.shade100,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(onTap: onEdit, child: const Text('Edit')),
                    PopupMenuItem(onTap: onDelete, child: const Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Answer: ${question.correctAnswer}',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionDialogContent extends ConsumerStatefulWidget {
  final String moduleType;
  final Question? question;
  final Function(Question) onSave;

  const _QuestionDialogContent({
    required this.moduleType,
    this.question,
    required this.onSave,
  });

  @override
  ConsumerState<_QuestionDialogContent> createState() =>
      _QuestionDialogContentState();
}

class _QuestionDialogContentState
    extends ConsumerState<_QuestionDialogContent> {
  late TextEditingController contentController;
  late TextEditingController answerController;
  late TextEditingController explanationController;
  late TextEditingController mediaUrlController;
  int difficulty = 1;

  @override
  void initState() {
    super.initState();
    contentController = TextEditingController(
      text: widget.question?.content ?? '',
    );
    answerController = TextEditingController(
      text: widget.question?.correctAnswer ?? '',
    );
    explanationController = TextEditingController(
      text: widget.question?.explanation ?? '',
    );
    mediaUrlController = TextEditingController(
      text: widget.question?.mediaUrl ?? '',
    );
    difficulty = widget.question?.difficulty ?? 1;
  }

  @override
  void dispose() {
    contentController.dispose();
    answerController.dispose();
    explanationController.dispose();
    mediaUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.question == null ? 'Create Question' : 'Edit Question',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Question Content'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Correct Answer'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: explanationController,
              decoration: const InputDecoration(labelText: 'Explanation'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: mediaUrlController,
              decoration: const InputDecoration(
                labelText: 'Media URL (optional)',
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: difficulty.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: 'Difficulty: $difficulty',
              onChanged: (value) => setState(() => difficulty = value.toInt()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              if (widget.question == null) {
                await ref
                    .read(adminProvider.notifier)
                    .createQuestion(
                      moduleType: widget.moduleType,
                      difficulty: difficulty,
                      content: contentController.text,
                      correctAnswer: answerController.text,
                      explanation: explanationController.text,
                      mediaUrl: mediaUrlController.text.isEmpty
                          ? null
                          : mediaUrlController.text,
                    );
              } else {
                await ref
                    .read(adminProvider.notifier)
                    .updateQuestion(
                      questionId: widget.question!.id,
                      difficulty: difficulty,
                      content: contentController.text,
                      correctAnswer: answerController.text,
                      explanation: explanationController.text,
                      mediaUrl: mediaUrlController.text.isEmpty
                          ? null
                          : mediaUrlController.text,
                    );
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.question == null
                          ? 'Question created'
                          : 'Question updated',
                    ),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
