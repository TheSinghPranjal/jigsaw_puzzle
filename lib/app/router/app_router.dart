import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/game_repository.dart';
import '../../features/collections/presentation/collection_screens.dart';
import '../../features/daily_puzzle/presentation/daily_screen.dart';
import '../../features/favorites/presentation/favorites_screens.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/onboarding_screens.dart';
import '../../features/levels/presentation/level_screens.dart';
import '../../features/profile/presentation/profile_screens.dart';
import '../../features/puzzle/screens/completion_screen.dart';
import '../../features/puzzle/screens/game_screen.dart';
import '../../features/rewards/presentation/reward_screens.dart';
import '../../features/settings/presentation/settings_screens.dart';
import '../theme/app_theme.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) => GoRouter(
      navigatorKey: _rootKey,
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => _Shell(shell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/explore', builder: (_, _) => const ExploreScreen(), routes: [
                GoRoute(path: 'collection/:id', builder: (_, s) => CollectionScreen(id: s.pathParameters['id']!)),
                GoRoute(path: 'map', builder: (_, _) => const ChapterMapScreen()),
              ]),
            ]),
            StatefulShellBranch(routes: [GoRoute(path: '/daily', builder: (_, _) => const DailyScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/favorites', builder: (_, _) => const FavoritesScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen())]),
          ],
        ),
        GoRoute(parentNavigatorKey: _rootKey, path: '/level/:id', builder: (_, s) => LevelPreviewScreen(id: int.parse(s.pathParameters['id']!))),
        GoRoute(parentNavigatorKey: _rootKey, path: '/play', builder: (_, s) {
          final a = s.extra! as PlayArgs;
          return GameScreen(key: ValueKey('${a.setup.key}-${a.restart}-${s.pageKey.value}'), setup: a.setup, restart: a.restart);
        }),
        GoRoute(parentNavigatorKey: _rootKey, path: '/complete', builder: (_, s) => CompletionScreen(result: s.extra! as CompletionResult)),
        GoRoute(parentNavigatorKey: _rootKey, path: '/history', builder: (_, _) => const HistoryScreen()),
        GoRoute(parentNavigatorKey: _rootKey, path: '/rewards', builder: (_, _) => const RewardsScreen()),
        GoRoute(parentNavigatorKey: _rootKey, path: '/achievements', builder: (_, _) => const AchievementsScreen()),
        GoRoute(parentNavigatorKey: _rootKey, path: '/settings', builder: (_, _) => const SettingsScreen()),
        GoRoute(parentNavigatorKey: _rootKey, path: '/info/:kind', builder: (_, s) => InfoScreen(kind: s.pathParameters['kind']!)),
      ],
    ));

class _Shell extends StatelessWidget {
  const _Shell(this.shell);
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: t.card,
          indicatorColor: t.selected,
          labelTextStyle: WidgetStateProperty.all(context.text.labelSmall),
          iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(color: s.contains(WidgetState.selected) ? t.primary : t.textSecondary)),
        ),
        child: NavigationBar(
          height: 66,
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.explore_rounded), label: 'Explore'),
            NavigationDestination(icon: Icon(Icons.today_rounded), label: 'Daily'),
            NavigationDestination(icon: Icon(Icons.favorite_rounded), label: 'Favorites'),
            NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
