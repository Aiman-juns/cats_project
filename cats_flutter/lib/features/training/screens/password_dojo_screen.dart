import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordDojoScreen extends ConsumerStatefulWidget {
  final int difficulty;

  const PasswordDojoScreen({
    Key? key,
    required this.difficulty,
  }) : super(key: key);

  @override
  ConsumerState<PasswordDojoScreen> createState() => _PasswordDojoScreenState();
}

class _PasswordDojoScreenState extends ConsumerState<PasswordDojoScreen> {
  late TextEditingController _passwordController;
  int _currentLevel = 1;
  int _totalScore = 0;
  bool _passwordAccepted = false;
  List<bool> _validationChecks = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;

    final checks = [
      password.length >= 8, // Length check
      password.contains(RegExp(r'[A-Z]')), // Uppercase
      password.contains(RegExp(r'[0-9]')), // Numbers
      password.contains(
        RegExp(r'[!@#\$%^&*()_+\-=\[\]{};:`<>?/\\|~.]'),
      ), // Special chars
    ];

    setState(() {
      _validationChecks = checks;
      _passwordAccepted = checks.every((c) => c);
    });
  }

  void _submitPassword() {
    if (!_passwordAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must meet all requirements')),
      );
      return;
    }

    // Calculate score based on difficulty and password length
    int score = 50; // Base score
    score += (widget.difficulty * 20); // Bonus based on selected difficulty
    score += (_currentLevel * 20); // Bonus per level
    if (_passwordController.text.length > 12) score += 20; // Extra length bonus
    if (_validationChecks.every((c) => c)) score += 30; // Perfection bonus

    setState(() {
      _totalScore += score;
      _currentLevel++;
      _passwordController.clear();
    });

    if (_currentLevel > 3) {
      _showCompletionDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Great! You earned $score points')),
      );
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Level Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Total Score: $_totalScore',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            const Text('You have completed all Password Dojo levels!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Training Hub'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentLevel = 1;
                _totalScore = 0;
                _passwordController.clear();
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  String _getLevelDescription() {
    switch (_currentLevel) {
      case 1:
        return 'Create a basic secure password (Level 1)';
      case 2:
        return 'Create a strong password with mixed complexity (Level 2)';
      case 3:
        return 'Create an advanced password (Level 3)';
      default:
        return 'Password Dojo Complete!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Dojo - Difficulty ${widget.difficulty}'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Score: $_totalScore',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Level indicator
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
                    Text(
                      'Level $_currentLevel/3',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getLevelDescription(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _currentLevel / 3,
                        minHeight: 6,
                        backgroundColor: Colors.blue.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Password input
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Enter Password',
                  hintText: 'Type a secure password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 32),
              // Validation checks
              Text(
                'Password Requirements:',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildChecklistItem(
                'At least 8 characters',
                _validationChecks[0],
                context,
              ),
              const SizedBox(height: 12),
              _buildChecklistItem(
                'At least 1 uppercase letter',
                _validationChecks[1],
                context,
              ),
              const SizedBox(height: 12),
              _buildChecklistItem(
                'At least 1 number',
                _validationChecks[2],
                context,
              ),
              const SizedBox(height: 12),
              _buildChecklistItem(
                'At least 1 special character (!@#\$%^&*)',
                _validationChecks[3],
                context,
              ),
              const SizedBox(height: 32),
              // Password strength indicator
              _buildStrengthIndicator(context),
              const SizedBox(height: 32),
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _passwordAccepted ? _submitPassword : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Submit Password'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _passwordAccepted
                        ? Colors.green
                        : Colors.grey,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Training Hub'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String text, bool isValid, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.shade50 : Colors.grey.shade50,
        border: Border.all(
          color: isValid ? Colors.green : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            color: isValid ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isValid ? Colors.green : Colors.grey.shade700,
                fontWeight: isValid ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthIndicator(BuildContext context) {
    int passCount = _validationChecks.where((c) => c).length;
    String strength = '';
    Color color = Colors.red;

    if (passCount == 0) {
      strength = 'No Requirements Met';
      color = Colors.red;
    } else if (passCount < 2) {
      strength = 'Weak';
      color = Colors.orange;
    } else if (passCount < 4) {
      strength = 'Good';
      color = Colors.yellow.shade700;
    } else {
      strength = 'Strong';
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.electric_bolt, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password Strength',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                strength,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$passCount/4',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
