import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/screens/login_screen.dart';
import '../auth/screens/register_screen.dart';
import '../features/resources/screens/resources_screen.dart';
import '../features/resources/screens/resource_detail_screen.dart';
import '../features/training/screens/training_hub_screen.dart';
import '../features/assistant/screens/assistant_screen.dart';
import '../features/performance/screens/performance_screen.dart';
import '../features/news/screens/news_screen.dart';
import '../features/news/screens/news_detail_screen.dart';
import '../shared/widgets/app_shell.dart';

/// GoRouter Configuration for CyberGuard
///
/// Phase 2: ShellRoute with 5-tab navigation
class RouterConfig {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // Phase 2: Basic routing - auth will be enhanced with Riverpod
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const RegisterScreen()),
      ),
      // Phase 2: Shell Route with 5 tabs
      ShellRoute(
        pageBuilder: (context, state, child) {
          return MaterialPage(
            key: state.pageKey,
            child: _ShellRouteWidget(child: child),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ResourcesScreen()),
          ),
          GoRoute(
            path: '/training',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TrainingHubScreen()),
          ),
          GoRoute(
            path: '/assistant',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AssistantScreen()),
          ),
          GoRoute(
            path: '/performance',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PerformanceScreen()),
          ),
          GoRoute(
            path: '/news',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: NewsScreen()),
          ),
        ],
      ),
      // Phase 3: Resource detail route (outside shell)
      GoRoute(
        path: '/resource/:id',
        pageBuilder: (context, state) {
          final resourceId = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: ResourceDetailScreen(resourceId: resourceId),
          );
        },
      ),
      // Phase 3: News detail route (outside shell)
      GoRoute(
        path: '/news/:id',
        pageBuilder: (context, state) {
          final newsId = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: NewsDetailScreen(newsId: newsId),
          );
        },
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              const Text('Page not found'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Shell Route Widget that maintains navigation state
class _ShellRouteWidget extends StatefulWidget {
  final Widget child;

  const _ShellRouteWidget({required this.child});

  @override
  State<_ShellRouteWidget> createState() => _ShellRouteWidgetState();
}

class _ShellRouteWidgetState extends State<_ShellRouteWidget> {
  int _currentIndex = 0;

  final List<String> _routes = [
    '/',
    '/training',
    '/assistant',
    '/performance',
    '/news',
  ];

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    context.go(_routes[index]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update current index based on location
    final location = GoRouterState.of(context).uri.path;
    final index = _routes.indexOf(location);
    if (index != -1 && _currentIndex != index) {
      _currentIndex = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentTabIndex: _currentIndex,
      onTabChanged: _onTabChanged,
      child: widget.child,
    );
  }
}
