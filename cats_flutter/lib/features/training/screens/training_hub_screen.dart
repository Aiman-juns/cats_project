import 'package:flutter/material.dart';
import 'phishing_screen.dart';
import 'password_dojo_screen.dart';
import 'cyber_attack_screen.dart';

class TrainingHubScreen extends StatelessWidget {
  const TrainingHubScreen({Key? key}) : super(key: key);

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
          const SizedBox(height: 16.0),
          _ModuleCard(
            title: 'Phishing Detection',
            description: 'Learn to identify phishing emails and websites',
            icon: Icons.mail_outline,
            color: Colors.blue,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PhishingScreen()),
              );
            },
          ),
          const SizedBox(height: 12.0),
          _ModuleCard(
            title: 'Password Dojo',
            description: 'Create and test strong passwords',
            icon: Icons.lock,
            color: Colors.green,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PasswordDojoScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12.0),
          _ModuleCard(
            title: 'Cyber Attack Analyst',
            description: 'Analyze and identify cyber attack scenarios',
            icon: Icons.shield,
            color: Colors.orange,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CyberAttackScreen(),
                ),
              );
            },
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
