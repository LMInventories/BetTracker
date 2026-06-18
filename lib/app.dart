import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shared/theme.dart';
import 'features/fixtures/fixtures_screen.dart';
import 'features/match_detail/match_detail_screen.dart';
import 'features/alerts/alerts_screen.dart';
import 'features/settings/settings_screen.dart';

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => _Shell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const FixturesScreen()),
        GoRoute(path: '/alerts', builder: (_, __) => const AlertsScreen()),
        GoRoute(
            path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
    GoRoute(
      path: '/match/:id',
      builder: (context, state) => MatchDetailScreen(
        fixtureId: int.parse(state.pathParameters['id']!),
      ),
    ),
  ],
);

class BetTrackerApp extends StatelessWidget {
  const BetTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BetTracker',
      theme: AppTheme.dark(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int selectedIndex = 0;
    if (location == '/alerts') selectedIndex = 1;
    if (location == '/settings') selectedIndex = 2;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/');
          if (i == 1) context.go('/alerts');
          if (i == 2) context.go('/settings');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sports_soccer), label: 'Matches'),
          NavigationDestination(icon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
