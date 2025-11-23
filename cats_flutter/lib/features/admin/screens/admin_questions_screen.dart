import 'dart:convert';
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
  late TextEditingController contentController; // Used for body in phishing, content in others
  late TextEditingController senderNameController;
  late TextEditingController senderEmailController;
  late TextEditingController subjectController;
  late TextEditingController answerController;
  late TextEditingController explanationController;
  late TextEditingController mediaUrlController;
  int difficulty = 1;
  
  bool get isPhishingModule => widget.moduleType == 'phishing';

  @override
  void initState() {
    super.initState();
    
    // Initialize answer, explanation, and mediaUrl controllers (same for all modules)
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
    
    // Handle content field based on module type
    if (isPhishingModule) {
      // For phishing: parse JSON and populate separate fields
      Map<String, dynamic> emailData = {};
      if (widget.question?.content != null && widget.question!.content.isNotEmpty) {
        try {
          emailData = jsonDecode(widget.question!.content) as Map<String, dynamic>;
        } catch (e) {
          // If parsing fails, use empty values
        }
      }
      
      senderNameController = TextEditingController(
        text: emailData['senderName'] ?? '',
      );
      senderEmailController = TextEditingController(
        text: emailData['senderEmail'] ?? '',
      );
      subjectController = TextEditingController(
        text: emailData['subject'] ?? '',
      );
      contentController = TextEditingController(
        text: emailData['body'] ?? '',
      );
    } else {
      // For other modules: use content as plain text
      contentController = TextEditingController(
        text: widget.question?.content ?? '',
      );
      senderNameController = TextEditingController();
      senderEmailController = TextEditingController();
      subjectController = TextEditingController();
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    senderNameController.dispose();
    senderEmailController.dispose();
    subjectController.dispose();
    answerController.dispose();
    explanationController.dispose();
    mediaUrlController.dispose();
    super.dispose();
  }
  
  String _getContentValue() {
    if (isPhishingModule) {
      // Combine phishing fields into JSON
      final emailData = {
        'senderName': senderNameController.text,
        'senderEmail': senderEmailController.text,
        'subject': subjectController.text,
        'body': contentController.text,
      };
      return jsonEncode(emailData);
    } else {
      return contentController.text;
    }
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
            // Conditional fields based on module type
            if (isPhishingModule) ...[
              // Phishing module: 4 separate fields
              TextField(
                controller: senderNameController,
                decoration: const InputDecoration(
                  labelText: 'Sender Name',
                  hintText: 'e.g., IT Support',
                ),
                onChanged: (_) => setState(() {}), // Trigger preview update
              ),
              const SizedBox(height: 16),
              TextField(
                controller: senderEmailController,
                decoration: const InputDecoration(
                  labelText: 'Sender Email',
                  hintText: 'e.g., support@company-security.com',
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}), // Trigger preview update
              ),
              const SizedBox(height: 16),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'e.g., Urgent: Password Expiry',
                ),
                onChanged: (_) => setState(() {}), // Trigger preview update
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Email Body',
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                minLines: 4,
                onChanged: (_) => setState(() {}), // Trigger preview update
              ),
              const SizedBox(height: 16),
              // Preview Card
              _EmailPreviewCard(
                senderName: senderNameController.text,
                senderEmail: senderEmailController.text,
                subject: subjectController.text,
                body: contentController.text,
                mediaUrl: mediaUrlController.text.isNotEmpty 
                    ? mediaUrlController.text 
                    : null,
              ),
            ] else ...[
              // Other modules: single content field
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Question Content'),
                maxLines: 3,
              ),
            ],
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
              onChanged: (_) {
                if (isPhishingModule) setState(() {}); // Trigger preview update
              },
            ),
            const SizedBox(height: 16),
            Slider(
              value: difficulty.toDouble(),
              min: 1,
              max: 3,
              divisions: 2,
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
              final content = _getContentValue();
              
              if (widget.question == null) {
                await ref
                    .read(adminProvider.notifier)
                    .createQuestion(
                      moduleType: widget.moduleType,
                      difficulty: difficulty,
                      content: content,
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
                      content: content,
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
                Navigator.pop(context);
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

/// Preview card widget for phishing email questions
class _EmailPreviewCard extends StatelessWidget {
  final String senderName;
  final String senderEmail;
  final String subject;
  final String body;
  final String? mediaUrl;

  const _EmailPreviewCard({
    required this.senderName,
    required this.senderEmail,
    required this.subject,
    required this.body,
    this.mediaUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            // Email Header
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.shade600,
                  child: Text(
                    senderName.isNotEmpty
                        ? senderName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName.isNotEmpty ? senderName : 'Sender Name',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        senderEmail.isNotEmpty ? senderEmail : 'sender@email.com',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Subject
            if (subject.isNotEmpty)
              Text(
                subject,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            if (subject.isEmpty)
              Text(
                'Subject',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
              ),
            const SizedBox(height: 8),
            // Body
            Text(
              body.isNotEmpty ? body : 'Email body content...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: body.isEmpty ? Colors.grey.shade400 : null,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            // Media preview
            if (mediaUrl != null && mediaUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
