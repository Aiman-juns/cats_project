import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/performance_provider.dart';

class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceAsyncValue = ref.watch(performanceProvider);

    return performanceAsyncValue.when(
      data: (stats) => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Performance',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16.0),
            // Current Level and Total Score
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Level',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Level ${stats.level}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: Colors.blue),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Score',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          '${stats.totalScore} pts',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Accuracy and Attempts
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(
                            'Accuracy',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '${stats.accuracyPercentage.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(
                            'Attempts',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '${stats.totalAttempts}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.purple),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Text(
              'Module Progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            // Module Progress Cards
            _ModuleProgressCard(
              title: 'Phishing Detection',
              stats: stats.moduleStats['phishing'],
              color: Colors.blue,
            ),
            const SizedBox(height: 12.0),
            _ModuleProgressCard(
              title: 'Password Dojo',
              stats: stats.moduleStats['password'],
              color: Colors.green,
            ),
            const SizedBox(height: 12.0),
            _ModuleProgressCard(
              title: 'Cyber Attack Analyst',
              stats: stats.moduleStats['attack'],
              color: Colors.orange,
            ),
            const SizedBox(height: 24.0),
            Text(
              'Medals & Achievements',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            _AchievementsView(stats: stats),
          ],
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading performance: $error'),
          ],
        ),
      ),
    );
  }
}

class _ModuleProgressCard extends StatelessWidget {
  final String title;
  final ModuleStats? stats;
  final Color color;

  const _ModuleProgressCard({
    required this.title,
    required this.stats,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final stats = this.stats;
    if (stats == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12.0),
              Text(
                'No attempts yet',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  '${stats.correct}/${stats.attempts}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: LinearProgressIndicator(
                value: stats.completionPercentage / 100,
                minHeight: 8.0,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 12.0),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completion',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      '${stats.completionPercentage.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accuracy',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      '${stats.accuracy.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      '${stats.totalScore}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsView extends ConsumerWidget {
  final PerformanceStats stats;

  const _AchievementsView({
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...stats.achievements.map((achievement) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: _AchievementCard(achievement: achievement),
            );
          }),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({
    required this.achievement,
  });

  IconData _getIconData(IconType type) {
    return switch (type) {
      IconType.trophy => Icons.emoji_events,
      IconType.flash => Icons.flash_on,
      IconType.verified => Icons.verified,
      IconType.star => Icons.star,
      IconType.shield => Icons.shield,
      IconType.rocket => Icons.rocket_launch,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: achievement.isUnlocked
                  ? Colors.amber
                  : Colors.grey.shade300,
              child: Icon(
                _getIconData(achievement.iconType),
                color: achievement.isUnlocked ? Colors.white : Colors.grey,
                size: 32,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              achievement.title,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4.0),
            SizedBox(
              width: 80,
              child: Text(
                achievement.description,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (achievement.isUnlocked) ...[
              const SizedBox(height: 8.0),
              Text(
                'Unlocked',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.amber,
                  fontSize: 9,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Models are imported from performance_provider.dart at the top
