import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/supabase_config.dart';

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

/// Fetch all resources from Supabase
Future<List<Resource>> fetchResources() async {
  try {
    final response = await SupabaseConfig.client
        .from('resources')
        .select()
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => Resource.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch resources: $e');
  }
}

/// Fetch single resource by ID
Future<Resource> fetchResourceById(String id) async {
  try {
    final response = await SupabaseConfig.client
        .from('resources')
        .select()
        .eq('id', id)
        .single();

    return Resource.fromJson(response as Map<String, dynamic>);
  } catch (e) {
    throw Exception('Failed to fetch resource: $e');
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
