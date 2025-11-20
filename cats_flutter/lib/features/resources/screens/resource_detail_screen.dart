import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/resources_provider.dart';

class ResourceDetailScreen extends ConsumerWidget {
  final String resourceId;

  const ResourceDetailScreen({Key? key, required this.resourceId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceAsync = ref.watch(resourceProvider(resourceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: resourceAsync.when(
        data: (resource) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resource.mediaUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      resource.mediaUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        );
                      },
                    ),
                  ),
                if (resource.mediaUrl != null) const SizedBox(height: 16.0),
                Text(
                  resource.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8.0),
                Chip(
                  label: Text(resource.category),
                  backgroundColor: Colors.blue.shade100,
                ),
                const SizedBox(height: 16.0),
                Text(
                  resource.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Published: ${resource.createdAt.toString().split('.')[0]}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16.0),
                Text('Error loading resource: $error'),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
