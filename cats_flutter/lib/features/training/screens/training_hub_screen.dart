import 'package:flutter/material.dart';
import 'phishing_screen.dart';
import 'password_dojo_screen.dart';
import 'cyber_attack_screen.dart';

class TrainingHubScreen extends StatelessWidget {
  const TrainingHubScreen({Key? key}) : super(key: key);

  void _showLevelSelectionDialog(
    BuildContext context,
    String moduleName,
    Widget Function(int difficulty) screenBuilder,
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
  Widget build(BuildContext context) {
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
class LevelSelectionDialog extends StatelessWidget {
  final String moduleName;
  final Function(int difficulty) onLevelSelected;

  const LevelSelectionDialog({
    Key? key,
    required this.moduleName,
    required this.onLevelSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            ...List.generate(3, (index) {
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
