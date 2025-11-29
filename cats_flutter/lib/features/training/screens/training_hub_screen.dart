import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/supabase_config.dart';
import '../providers/training_provider.dart';
import 'phishing_screen.dart';
import 'password_dojo_screen.dart';
import 'cyber_attack_screen.dart';

class TrainingHubScreen extends ConsumerWidget {
  const TrainingHubScreen({Key? key}) : super(key: key);

  void _showLevelSelectionDialog(
    BuildContext context,
    String moduleName,
    Widget Function(int difficulty) screenBuilder,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => LevelSelectionDialog(
        moduleName: moduleName,
        onLevelSelected: (difficulty) {
          Navigator.pop(context); // Close dialog
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => screenBuilder(difficulty)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = SupabaseConfig.client.auth.currentUser?.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Training Modules',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Choose a difficulty level before starting each module',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16.0),
          _ModuleCard(
            title: 'Phishing Detection',
            description: 'Learn to identify phishing emails and websites',
            icon: Icons.mail_outline,
            color: Colors.blue,
            onTap: () => _showLevelSelectionDialog(
              context,
              'Phishing Detection',
              (difficulty) => PhishingScreen(difficulty: difficulty),
              ref,
            ),
          ),
          const SizedBox(height: 12.0),
          _ModuleCard(
            title: 'Password Dojo',
            description: 'Create and test strong passwords',
            icon: Icons.lock,
            color: Colors.green,
            onTap: () => _showLevelSelectionDialog(
              context,
              'Password Dojo',
              (difficulty) => PasswordDojoLoaderScreen(difficulty: difficulty),
              ref,
            ),
          ),
          const SizedBox(height: 12.0),
          _ModuleCard(
            title: 'Cyber Attack Analyst',
            description: 'Analyze and identify cyber attack scenarios',
            icon: Icons.shield,
            color: Colors.orange,
            onTap: () => _showLevelSelectionDialog(
              context,
              'Cyber Attack Analyst',
              (difficulty) => CyberAttackScreen(difficulty: difficulty),
              ref,
            ),
          ),
          const SizedBox(height: 32.0),
          // Recent Activity Section
          Text(
            'Recent Activity',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12.0),
          if (userId != null)
            _RecentActivityWidget(userId: userId)
          else
            Center(
              child: Text(
                'Please log in to see your activity',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}

/// Dialog for selecting difficulty level before starting a training module
class LevelSelectionDialog extends ConsumerWidget {
  final String moduleName;
  final Function(int difficulty) onLevelSelected;

  const LevelSelectionDialog({
    Key? key,
    required this.moduleName,
    required this.onLevelSelected,
  }) : super(key: key);

  String _getModuleType(String moduleName) {
    if (moduleName.contains('Phishing')) return 'phishing';
    if (moduleName.contains('Password')) return 'password';
    if (moduleName.contains('Attack')) return 'attack';
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    final moduleType = _getModuleType(moduleName);

    return AlertDialog(
      title: const Text('Select Difficulty Level'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose the difficulty level for $moduleName',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (userId != null && moduleType.isNotEmpty)
              _LevelListWithProgress(
                userId: userId,
                moduleType: moduleType,
                onLevelSelected: onLevelSelected,
              )
            else
              _DefaultLevelList(onLevelSelected: onLevelSelected),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Default level list without progress tracking
class _DefaultLevelList extends StatelessWidget {
  final Function(int) onLevelSelected;

  const _DefaultLevelList({required this.onLevelSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final level = index + 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getLevelColor(level),
              child: Text(
                '$level',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text('Level $level'),
            subtitle: Text(_getLevelDescription(level)),
            trailing: const Icon(Icons.arrow_forward),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            onTap: () => onLevelSelected(level),
          ),
        );
      }),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'Beginner - Easy questions';
      case 2:
        return 'Intermediate - Moderate difficulty';
      case 3:
        return 'Advanced - Challenging scenarios';
      default:
        return '';
    }
  }
}

/// Widget to display level list with progress
class _LevelListWithProgress extends ConsumerWidget {
  final String userId;
  final String moduleType;
  final Function(int) onLevelSelected;

  const _LevelListWithProgress({
    required this.userId,
    required this.moduleType,
    required this.onLevelSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(
      moduleProgressProvider((userId: userId, moduleType: moduleType)),
    );

    return progressAsync.when(
      loading: () => Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getLevelColor(index + 1),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text('Level ${index + 1}'),
              trailing: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }),
      ),
      error: (error, stack) => Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final level = index + 1;
          return _buildLevelTile(context, level, null, onLevelSelected);
        }),
      ),
      data: (progressMap) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final level = index + 1;
            final progress = progressMap[level] ?? 0.0;
            return _buildLevelTile(context, level, progress, onLevelSelected);
          }),
        );
      },
    );
  }

  Widget _buildLevelTile(
    BuildContext context,
    int level,
    double? progress,
    Function(int) onTap,
  ) {
    final isComplete = progress == 1.0;
    final hasProgress = progress != null && progress > 0 && progress < 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getLevelColor(level),
          child: Text(
            '$level',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text('Level $level'),
        subtitle: Text(_getLevelDescription(level)),
        trailing: isComplete
            ? const Icon(Icons.check_circle, color: Colors.green)
            : hasProgress
            ? Text(
                '${(progress * 100).toStringAsFixed(0)}% Done',
                style: Theme.of(context).textTheme.labelSmall,
              )
            : const Icon(Icons.arrow_forward),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        onTap: () => onTap(level),
      ),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'Beginner - Easy questions';
      case 2:
        return 'Intermediate - Moderate difficulty';
      case 3:
        return 'Advanced - Challenging scenarios';
      default:
        return '';
    }
  }
}

/// Widget to display recent activity feed
class _RecentActivityWidget extends ConsumerWidget {
  final String userId;

  const _RecentActivityWidget({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider(userId));

    return activityAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Failed to load activity: $error',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.red),
          ),
        ),
      ),
      data: (activities) {
        if (activities.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No activity yet.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            final question = activity.question;
            final questionContent = question?.content ?? 'Unknown question';
            final truncatedContent = questionContent.length > 60
                ? '${questionContent.substring(0, 60)}...'
                : questionContent;
            final formattedDate = _formatDate(activity.attemptDate);

            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(
                  activity.isCorrect ? Icons.check_circle : Icons.cancel,
                  color: activity.isCorrect ? Colors.green : Colors.red,
                ),
                title: Text(
                  truncatedContent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Difficulty ${question?.difficulty ?? '?'} • $formattedDate',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                trailing: Icon(
                  activity.isCorrect ? Icons.check : Icons.close,
                  color: activity.isCorrect ? Colors.green : Colors.red,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
