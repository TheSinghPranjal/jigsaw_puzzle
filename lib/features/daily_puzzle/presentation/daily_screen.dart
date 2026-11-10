import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/common.dart';
import '../../../data/levels/level_catalog.dart';
import '../../../data/repositories/game_repository.dart';
import '../../puzzle/screens/game_screen.dart';

class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen({super.key});
  @override
  ConsumerState<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends ConsumerState<DailyScreen> {
  DailyDifficulty? _difficulty;

  void _play(String date, DailyDifficulty d) {
    final repo = ref.read(repoProvider);
    final level = repo.dailyLevel(date);
    if (date == repo.todayKey) repo.rememberDailyDifficulty(date, level.id, d);
    context.push('/play', extra: PlayArgs(PuzzleSetup.daily(level, date, d, rotation: ref.read(settingsProvider).rotation)));
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repoProvider);
    final rows = ref.watch(dailiesProvider).valueOrNull ?? const <DailyRow>[];
    final active = ref.watch(activeProvider).valueOrNull ?? const <ActivePuzzleRow>[];
    final t = context.tokens;
    final today = repo.todayKey;
    final level = repo.dailyLevel(today);
    final row = rows.where((r) => r.date == today).firstOrNull;
    final done = row?.completed ?? false;
    final difficulty = _difficulty ?? DailyDifficulty.values.firstWhere((d) => d.name == row?.selectedDifficulty, orElse: () => DailyDifficulty.medium);
    final saved = active.any((a) => a.puzzleKey == 'daily:$today');
    final completed = {for (final r in rows.where((r) => r.completed)) r.date};
    final todayDate = parseDateKey(today);
    final past = [for (var i = 1; i <= 30; i++) dateKey(DateTime(todayDate.year, todayDate.month, todayDate.day - i))];

    var streak = 0;
    var cursor = completed.contains(today) ? todayDate : DateTime(todayDate.year, todayDate.month, todayDate.day - 1);
    while (completed.contains(dateKey(cursor))) {
      streak++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }

    return SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
        Row(children: [Expanded(child: Text('Daily puzzle', style: context.text.headlineSmall)), const CoinBadge()]),
        Text(DateFormat.yMMMMEEEEd().format(todayDate), style: context.text.bodySmall),
        const SizedBox(height: 12),
        AspectRatio(aspectRatio: 4 / 3, child: Art(level.image, radius: AppTokens.radiusL, cacheWidth: 900)),
        const SizedBox(height: 10),
        Text(level.title, style: context.text.titleLarge),
        const SizedBox(height: 10),
        SegmentedButton<DailyDifficulty>(
          showSelectedIcon: false,
          segments: [for (final d in DailyDifficulty.values) ButtonSegment(value: d, label: FittedBox(child: Text(d.label)))],
          selected: {difficulty},
          onSelectionChanged: (s) => setState(() => _difficulty = s.first),
        ),
        const SizedBox(height: 4),
        Center(child: Text('${difficulty.pieces} pieces · does not affect your campaign', style: context.text.bodySmall)),
        const SizedBox(height: 10),
        PrimaryButton(label: done ? 'Play again' : (saved ? 'Continue' : 'Play for ${Scoring.dailyCoins} coins'), icon: Icons.play_arrow_rounded, onPressed: () => _play(today, difficulty)),
        if (done) Padding(padding: const EdgeInsets.only(top: 8), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check_circle_rounded, size: 16, color: AppTokens.success), const SizedBox(width: 5), Text("Today's reward collected", style: context.text.bodySmall)])),
        const SizedBox(height: 16),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.local_fire_department_rounded, color: Color(0xFFE99A5B)), const SizedBox(width: 6), Text('$streak day streak', style: context.text.titleMedium), const Spacer(), Text('${Scoring.streakCoins} coins every ${Scoring.streakEvery} days', style: context.text.bodySmall)]),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (var i = 6; i >= 0; i--)
                Builder(builder: (context) {
                  final d = DateTime(todayDate.year, todayDate.month, todayDate.day - i);
                  final on = completed.contains(dateKey(d));
                  return Column(children: [
                    CircleAvatar(radius: 14, backgroundColor: on ? t.primary : t.primaryLight, child: on ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null),
                    const SizedBox(height: 3),
                    Text(DateFormat.E().format(d).substring(0, 1), style: context.text.labelSmall),
                  ]);
                }),
            ]),
          ]),
        ),
        SectionHeaderInline('Previous days', subtitle: 'Replay for fun. Rewards are for today only.'),
        SizedBox(
          height: 118,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: past.length,
            itemBuilder: (context, i) {
              final date = past[i];
              final l = repo.dailyLevel(date);
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => _play(date, DailyDifficulty.easy),
                  child: SizedBox(
                    width: 112,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(
                        height: 84,
                        child: Stack(fit: StackFit.expand, children: [
                          Art(l.thumbnail, cacheWidth: 280),
                          if (completed.contains(date)) const Positioned(right: 4, top: 4, child: CircleAvatar(radius: 9, backgroundColor: AppTokens.success, child: Icon(Icons.check_rounded, size: 12, color: Colors.white))),
                        ]),
                      ),
                      const SizedBox(height: 4),
                      Text(DateFormat.MMMd().format(parseDateKey(date)), style: context.text.labelSmall),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class SectionHeaderInline extends StatelessWidget {
  const SectionHeaderInline(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: context.text.titleLarge), if (subtitle != null) Text(subtitle!, style: context.text.bodySmall)]),
      );
}
