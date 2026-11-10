import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/common.dart';
import '../../../data/levels/level_catalog.dart';
import '../../../data/repositories/game_repository.dart';
import '../../puzzle/screens/game_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final repo = ref.watch(repoProvider);
    final progress = ref.watch(progressProvider).valueOrNull ?? const <int, ProgressRow>{};
    final active = ref.watch(activeProvider).valueOrNull ?? const <ActivePuzzleRow>[];
    final favorites = ref.watch(favoritesProvider).valueOrNull ?? const <int>{};
    final history = ref.watch(historyProvider).valueOrNull ?? const <HistoryRow>[];
    final dailies = ref.watch(dailiesProvider).valueOrNull ?? const <DailyRow>[];
    final achievements = ref.watch(achievementsProvider).valueOrNull ?? const <String, AchievementRow>{};
    final name = ref.watch(profileProvider).valueOrNull?.playerName ?? 'Puzzler';
    final t = context.tokens;

    final currentId = GameRepository.unlockedThrough(progress, catalog.levels.length);
    final current = catalog.level(currentId);
    final completed = progress.values.where((p) => p.completed).length;
    final today = repo.todayKey;
    final dailyDone = dailies.any((d) => d.date == today && d.completed);
    final daily = repo.dailyLevel(today);
    final unclaimed = achievements.values.where((a) => a.completed && !a.claimed).length;
    final savedCurrent = active.where((a) => a.puzzleKey == 'campaign:$currentId').firstOrNull;
    final recent = <int>{for (final h in history) h.levelId}.take(10).toList();
    final others = active.where((a) => a.puzzleKey != 'campaign:$currentId').toList();

    return SafeArea(
      child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
          child: Row(children: [
            Image.asset('assets/branding/logo/logo.png', width: 38),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Hello, $name', style: context.text.titleMedium), Text('Easter Jigsaw Journey', style: context.text.bodySmall)])),
            const CoinBadge(),
            IconButton(tooltip: 'Settings', onPressed: () => context.push('/settings'), icon: const Icon(Icons.settings_rounded)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: GestureDetector(
            key: const ValueKey('hero'),
            onTap: () => context.push('/level/$currentId'),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(fit: StackFit.expand, children: [
                Art(current.image, radius: AppTokens.radiusL, cacheWidth: 900),
                DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppTokens.radiusL), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [.3, .62, 1], colors: [Colors.transparent, Color(0x88201830), Color(0xD8201830)]))),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Level $currentId · ${current.pieceCount} pieces', style: context.text.bodySmall?.copyWith(color: Colors.white)),
                    Text(current.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.titleLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: ProgressBar(value: completed / catalog.levels.length, height: 7)),
                      const SizedBox(width: 10),
                      Text('$completed / ${catalog.levels.length}', style: context.text.labelSmall?.copyWith(color: Colors.white)),
                    ]),
                    const SizedBox(height: 10),
                    Text(savedCurrent != null ? 'Continue playing  ›' : 'Play level  ›', style: context.text.titleMedium?.copyWith(color: Colors.white)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
        if (unclaimed > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AppCard(
              onTap: () => context.push('/achievements'),
              child: Row(children: [const Icon(Icons.emoji_events_rounded, color: AppTokens.gold), const SizedBox(width: 10), Expanded(child: Text('$unclaimed reward${unclaimed == 1 ? '' : 's'} ready to claim', style: context.text.titleSmall)), const Icon(Icons.chevron_right_rounded)]),
            ),
          ),
        SectionHeader('Daily puzzle', action: 'All dailies', onAction: () => context.go('/daily')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppCard(
            onTap: () => context.go('/daily'),
            child: Row(children: [
              SizedBox(width: 92, height: 69, child: Art(daily.thumbnail, radius: 12, cacheWidth: 240)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(daily.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
                  const SizedBox(height: 4),
                  Text(dailyDone ? 'Completed today' : 'Earn ${Scoring.dailyCoins} coins', style: context.text.bodySmall?.copyWith(color: dailyDone ? AppTokens.success : t.textSecondary)),
                ]),
              ),
              Icon(dailyDone ? Icons.check_circle_rounded : Icons.chevron_right_rounded, color: dailyDone ? AppTokens.success : t.textSecondary),
            ]),
          ),
        ),
        if (others.isNotEmpty) ...[
          const SectionHeader('Unfinished'),
          SizedBox(
            height: 128,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
              for (final a in others)
                _ThumbCard(
                  catalog.level(a.levelId),
                  subtitle: '${(a.placedCount * 100 / a.pieceCount).round()}% done',
                  onTap: () {
                    if (a.puzzleKey.startsWith('daily:')) {
                      context.go('/daily');
                    } else {
                      context.push('/play', extra: PlayArgs(PuzzleSetup.campaign(catalog.level(a.levelId), rotation: ref.read(settingsProvider).rotation)));
                    }
                  },
                ),
            ]),
          ),
        ],
        SectionHeader('Collections', action: 'See all', onAction: () => context.go('/explore')),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: catalog.collections.length,
            itemBuilder: (context, i) {
              final c = catalog.collections[i];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => context.go('/explore/collection/${c.id}'),
                  child: SizedBox(
                    width: 150,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(height: 104, child: Art(c.cover, cacheWidth: 360)),
                      const SizedBox(height: 5),
                      Text(c.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.labelSmall?.copyWith(color: t.text, fontSize: 12)),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
        if (favorites.isNotEmpty) ...[
          SectionHeader('Favorites', action: 'See all', onAction: () => context.go('/favorites')),
          SizedBox(height: 128, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [for (final id in favorites.take(10)) _ThumbCard(catalog.level(id))])),
        ],
        if (recent.isNotEmpty) ...[
          SectionHeader('Recently played', action: 'History', onAction: () => context.push('/history')),
          SizedBox(height: 128, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [for (final id in recent) _ThumbCard(catalog.level(id))])),
        ],
      ]),
    );
  }
}

class _ThumbCard extends StatelessWidget {
  const _ThumbCard(this.level, {this.subtitle, this.onTap});
  final PuzzleLevel level;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: GestureDetector(
          onTap: onTap ?? () => context.push('/level/${level.id}'),
          child: SizedBox(
            width: 124,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 92, child: Art(level.thumbnail, cacheWidth: 300)),
              const SizedBox(height: 4),
              Text(subtitle ?? 'Level ${level.id}', style: context.text.labelSmall),
            ]),
          ),
        ),
      );
}
