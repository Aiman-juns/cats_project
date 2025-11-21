import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../config/supabase_config.dart';

/// Resource Model
class Resource {
  final String id;
  final String title;
  final String category;
  final String content;
  final String? mediaUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Resource({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    this.mediaUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      content: json['content'] as String,
      mediaUrl: json['media_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

/// Local hardcoded resources
final _localResources = [
  Resource(
    id: '1',
    title: 'What is Cyber Security?',
    category: 'Phishing',
    content:
        '''In an era where our reliance on technology is higher than ever, Cybersecurity has emerged as a critical practice for protecting our digital way of life. 
    
It is the practice of defending computers, servers, mobile devices, electronic systems, networks, and data from malicious attacks.

What will you learn:
- Concept of Cybersecurity: Understand the core definition of protecting systems.
- The Rise of Cybercrime: How the internet's growth fueled digital threats.
- Core Responsibilities: Developing secure software and analyzing evidence.
- Career Pathways: Roles like Ethical Hackers and Forensic Investigators.''',
    mediaUrl: 'https://www.youtube.com/watch?v=shQEXpUwaIY',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Resource(
    id: '2',
    title: 'Password Best Practices',
    category: 'Authentication',
    content:
        '''Learn how to create and manage strong passwords to protect your accounts.
    
Key points:
- Use at least 12 characters
- Mix uppercase, lowercase, numbers, and symbols
- Avoid personal information
- Use unique passwords for each account
- Consider using a password manager''',
    mediaUrl: null,
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Resource(
    id: '3',
    title: 'Malware Protection',
    category: 'Malware',
    content: '''Understand malware threats and how to protect your systems.
    
Topics covered:
- Types of malware: viruses, trojans, ransomware, spyware
- How malware spreads
- Signs of infection
- Prevention strategies
- Removal and recovery
- Best practices for security''',
    mediaUrl: null,
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

/// Fetch all resources (simulated with local data)
Future<List<Resource>> fetchResources() async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));
  return _localResources;
}

/// Fetch single resource by ID (from local data)
Future<Resource> fetchResourceById(String id) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 300));

  try {
    return _localResources.firstWhere((resource) => resource.id == id);
  } catch (e) {
    throw Exception('Resource with ID $id not found');
  }
}

/// Riverpod provider for resources list
final resourcesProvider = FutureProvider<List<Resource>>((ref) async {
  return fetchResources();
});

/// Riverpod provider for single resource
final resourceProvider = FutureProvider.family<Resource, String>((
  ref,
  id,
) async {
  return fetchResourceById(id);
});
