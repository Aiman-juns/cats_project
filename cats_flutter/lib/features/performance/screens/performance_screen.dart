import 'package:flutter/material.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                        'Level 1',
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
                        '0 pts',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          Text(
            'Module Progress',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16.0),
          // Module Progress Cards
          _ProgressCard(
            title: 'Phishing Detection',
            progress: 0.0,
            color: Colors.blue,
            score: '0/100',
          ),
          const SizedBox(height: 12.0),
          _ProgressCard(
            title: 'Password Dojo',
            progress: 0.0,
            color: Colors.green,
            score: '0/100',
          ),
          const SizedBox(height: 12.0),
          _ProgressCard(
            title: 'Cyber Attack Analyst',
            progress: 0.0,
            color: Colors.orange,
            score: '0/100',
          ),
          const SizedBox(height: 24.0),
          Text(
            'Medals & Achievements',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _MedalCard(
                  icon: Icons.emoji_events,
                  title: 'First Steps',
                  description: 'Complete first module',
                  isUnlocked: false,
                ),
                const SizedBox(width: 12.0),
                _MedalCard(
                  icon: Icons.flash_on,
                  title: 'Quick Learner',
                  description: '10 correct answers',
                  isUnlocked: false,
                ),
                const SizedBox(width: 12.0),
                _MedalCard(
                  icon: Icons.verified,
                  title: 'Security Expert',
                  description: 'Complete all modules',
                  isUnlocked: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;
  final String score;

  const _ProgressCard({
    required this.title,
    required this.progress,
    required this.color,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
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
                  score,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8.0,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isUnlocked;

  const _MedalCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: isUnlocked ? Colors.amber : Colors.grey.shade300,
              child: Icon(
                icon,
                color: isUnlocked ? Colors.white : Colors.grey,
                size: 32,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4.0),
            SizedBox(
              width: 80,
              child: Text(
                description,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
