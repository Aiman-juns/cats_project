import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

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
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user['avatar_url'] ?? ''),
                  onBackgroundImageError: (_, __) {},
                  child: user['avatar_url'] == null
                      ? Text(user['full_name']?[0]?.toUpperCase() ?? 'U')
                      : null,
                ),
                title: Text(user['full_name'] ?? 'Unknown'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['email'] ?? 'No email'),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text('Level ${user['level'] ?? 1}'),
                          backgroundColor: Colors.blue.shade100,
                          labelPadding: EdgeInsets.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Chip(
                          label: Text('Score: ${user['total_score'] ?? 0}'),
                          backgroundColor: Colors.green.shade100,
                          labelPadding: EdgeInsets.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        if (user['role'] == 'admin') ...[
                          Chip(
                            label: const Text('Admin'),
                            backgroundColor: Colors.orange.shade100,
                            labelPadding: EdgeInsets.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => _showUserDetailsDialog(context, user, ref),
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUserDetailsDialog(
    BuildContext context,
    Map<String, dynamic> user,
    WidgetRef ref,
  ) {
    final userId = user['id'] as String;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'User Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _UserStatsContent(userId: userId),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserStatsContent extends ConsumerWidget {
  final String userId;

  const _UserStatsContent({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider(userId));

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (stats) {
        final user = stats['user'] as Map<String, dynamic>;
        final totalAttempts = stats['totalAttempts'] as int;
        final correctAnswers = stats['correctAnswers'] as int;
        final accuracy = stats['accuracy'] as String;
        final totalScore = stats['totalScore'] as int;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user['full_name'] ?? 'Unknown User',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user['email'] ?? 'No email',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatRow('Total Score', totalScore.toString(), Colors.blue),
                  const SizedBox(height: 8),
                  _StatRow(
                    'Total Attempts',
                    totalAttempts.toString(),
                    Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _StatRow(
                    'Correct Answers',
                    correctAnswers.toString(),
                    Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _StatRow('Accuracy', '$accuracy%', Colors.purple),
                  const SizedBox(height: 8),
                  _StatRow('Level', '${user['level'] ?? 1}', Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Last 10 attempts shown below',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            ...(stats['progress'] as List<Map<String, dynamic>>)
                .take(10)
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          p['is_correct'] == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: p['is_correct'] == true
                              ? Colors.green
                              : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${p['is_correct'] == true ? 'Correct' : 'Incorrect'} - Score: ${p['score_awarded']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
