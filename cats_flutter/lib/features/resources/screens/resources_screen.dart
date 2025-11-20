import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/resources_provider.dart';

class ResourcesScreen extends ConsumerWidget {
  const ResourcesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(resourcesProvider);

    return resourcesAsync.when(
      data: (resources) {
        if (resources.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.library_books,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'No resources available',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learning Resources',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              ...resources.map((resource) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.article),
                      title: Text(resource.title),
                      subtitle: Text(resource.category),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        context.push('/resource/${resource.id}');
                      },
                    ),
                  ),
                );
              }).toList(),
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
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16.0),
              Text(
                'Error loading resources: $error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(resourcesProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }
}
