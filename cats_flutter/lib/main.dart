import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'config/supabase_config.dart';
import 'config/router_config.dart' as app_router;
import 'shared/theme/app_theme.dart';
import 'auth/providers/auth_provider.dart';
import 'shared/providers/theme_provider.dart';

void main() async {
  // Initialize Supabase before running the app
  await SupabaseConfig.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth provider to listen for user changes
    final authState = ref.watch(authProvider);
    // Watch the theme provider to listen for theme changes
    final isDarkMode = ref.watch(themeProvider);

    // Build a router with admin redirect logic
    final router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        return authState.maybeWhen(
          data: (user) {
            // If user is null (not logged in) - only allow login/register routes
            if (user == null) {
              if (state.uri.path == '/login' || state.uri.path == '/register') {
                return null; // Allow login/register
              }
              return '/login'; // Redirect to login for any other route
            }

            // User is logged in - redirect from login/register based on role
            if (state.uri.path == '/login' || state.uri.path == '/register') {
              // Admin users go to /admin dashboard
              if (user.role == 'admin') {
                return '/admin';
              }
              // Regular users go to home
              return '/';
            }

            return null; // No redirect needed
          },
          loading: () {
            // Loading state - show login for any non-auth pages
            if (state.uri.path != '/login' && state.uri.path != '/register') {
              return '/login';
            }
            return null;
          },
          error: (error, stack) {
            // Error state - go to login
            if (state.uri.path != '/login' && state.uri.path != '/register') {
              return '/login';
            }
            return null;
          },
          orElse: () {
            // Fallback - require login
            if (state.uri.path != '/login' && state.uri.path != '/register') {
              return '/login';
            }
            return null;
          },
        );
      },
      routes: app_router.RouterConfig.routes,
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

    return MaterialApp.router(
      title: 'CyberGuard',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
