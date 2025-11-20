import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

class AdminStatsScreen extends ConsumerWidget {
  const AdminStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(allUsersProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (users) {
        // Calculate overall stats
        final totalUsers = users.length;
        final totalScore = users.fold<int>(
          0,
          (sum, user) => sum + (user['total_score'] as int? ?? 0),
        );
        final avgScore = totalUsers > 0
            ? (totalScore / totalUsers).toStringAsFixed(2)
            : '0';
        final adminCount = users.where((u) => u['role'] == 'admin').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall statistics
              Text(
                'Overall Statistics',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StatCard(
                    title: 'Total Users',
                    value: totalUsers.toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    title: 'Total Score',
                    value: totalScore.toString(),
                    icon: Icons.star,
                    color: Colors.yellow.shade700,
                  ),
                  _StatCard(
                    title: 'Average Score',
                    value: avgScore,
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                  _StatCard(
                    title: 'Admins',
                    value: adminCount.toString(),
                    icon: Icons.admin_panel_settings,
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Top users
              Text(
                'Top 5 Users',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._getTopUsers(users, 5).asMap().entries.map((entry) {
                final index = entry.key;
                final user = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(user['full_name'] ?? 'Unknown'),
                    subtitle: Text(user['email'] ?? 'No email'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${user['total_score'] ?? 0} pts',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),
              // Most active users
              Text(
                'Most Active Users (By Level)',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._getHighestLevelUsers(users, 5).asMap().entries.map((entry) {
                final index = entry.key;
                final user = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade100,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(user['full_name'] ?? 'Unknown'),
                    subtitle: Text('Level ${user['level'] ?? 1}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Lvl ${user['level'] ?? 1}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getTopUsers(
    List<Map<String, dynamic>> users,
    int count,
  ) {
    final sorted = List<Map<String, dynamic>>.from(users);
    sorted.sort((a, b) {
      final scoreA = a['total_score'] as int? ?? 0;
      final scoreB = b['total_score'] as int? ?? 0;
      return scoreB.compareTo(scoreA);
    });
    return sorted.take(count).toList();
  }

  List<Map<String, dynamic>> _getHighestLevelUsers(
    List<Map<String, dynamic>> users,
    int count,
  ) {
    final sorted = List<Map<String, dynamic>>.from(users);
    sorted.sort((a, b) {
      final levelA = a['level'] as int? ?? 1;
      final levelB = b['level'] as int? ?? 1;
      return levelB.compareTo(levelA);
    });
    return sorted.take(count).toList();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
