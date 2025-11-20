import 'package:flutter/material.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({Key? key}) : super(key: key);

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _urlController = TextEditingController();
  bool _isChecking = false;
  String? _result;

  void _checkUrl() {
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a URL')));
      return;
    }

    setState(() {
      _isChecking = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isChecking = false;
        _result = _urlController.text.contains('phishing')
            ? 'dangerous'
            : 'safe';
      });
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Digital Assistant',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Check if a URL is safe',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24.0),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'Enter URL (e.g., https://example.com)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              prefixIcon: const Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isChecking ? null : _checkUrl,
              child: _isChecking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Check URL'),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24.0),
            Card(
              color: _result == 'safe'
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _result == 'safe' ? Icons.check_circle : Icons.warning,
                      color: _result == 'safe' ? Colors.green : Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      _result == 'safe'
                          ? 'Safe Website'
                          : 'Potentially Dangerous',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _result == 'safe' ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      _result == 'safe'
                          ? 'This URL appears to be safe to visit.'
                          : 'This URL may pose a security risk. Proceed with caution.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
