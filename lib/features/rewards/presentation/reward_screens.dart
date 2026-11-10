import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/common.dart';
import '../../../data/repositories/game_repository.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});
  static const _dailyGift = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider).valueOrNull ?? 0;
    final ledger = ref.watch(ledgerProvider).valueOrNull ?? const <RewardRow>[];
    final repo = ref.watch(repoProvider);
    final giftKey = 'login:${repo.todayKey}';
    final claimed = ledger.any((r) => r.idempotencyKey == giftKey);
    return Scaffold(
      appBar: AppBar(title: const Text('Rewards')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        AppCard(child: Row(children: [const CoinIcon(size: 42), const SizedBox(width: 14), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$coins', style: context.text.displaySmall), Text('coins earned', style: context.text.bodySmall)])])),
        const SizedBox(height: 12),
        AppCard(
          child: Row(children: [
            Icon(Icons.card_giftcard_rounded, color: context.tokens.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(claimed ? "Today's gift collected" : 'Daily gift: $_dailyGift coins', style: context.text.titleSmall)),
            FilledButton(
              onPressed: claimed
                  ? null
                  : () async {
                      if (await repo.grant(key: giftKey, type: 'login', eventId: giftKey, amount: _dailyGift)) ref.read(audioProvider).sfx(Sfx.reward);
                    },
              child: Text(claimed ? 'Done' : 'Claim'),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        for (final r in ledger.take(50))
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(_label(r), style: context.text.bodyMedium),
            subtitle: Text(DateFormat.yMMMd().add_jm().format(r.timestamp), style: context.text.bodySmall),
            trailing: Text('+${r.amount}', style: context.text.titleSmall),
          ),
        if (ledger.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('Finish a puzzle to earn your first coins.', style: context.text.bodySmall))),
      ]),
    );
  }

  String _label(RewardRow r) => switch (r.rewardType) {
        'level' => 'Completed ${r.eventId.replaceFirst('level:', 'Level ')}',
        'first' => 'First completion bonus',
        'daily' => 'Daily puzzle',
        'streak' => 'Daily streak',
        'milestone' => 'Level milestone',
        'collection' => 'Collection completed',
        'achievement' => 'Achievement reward',
        'login' => 'Daily gift',
        _ => r.rewardType,
      };
}

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final states = ref.watch(achievementsProvider).valueOrNull ?? const <String, AchievementRow>{};
    final t = context.tokens;
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: achievementDefs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final d = achievementDefs[i];
          final s = states[d.id];
          final done = s?.completed ?? false, claimed = s?.claimed ?? false;
          return AppCard(
            child: Row(children: [
              CircleAvatar(radius: 23, backgroundColor: done ? AppTokens.gold : t.primaryLight, child: Icon(Icons.emoji_events_rounded, color: done ? Colors.white : t.textSecondary)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.title, style: context.text.titleSmall),
                  Text(d.description, style: context.text.bodySmall),
                  const SizedBox(height: 6),
                  ProgressBar(value: (s?.progress ?? 0) / d.target, height: 5),
                  const SizedBox(height: 2),
                  Text('${s?.progress ?? 0} / ${d.target}', style: context.text.labelSmall),
                ]),
              ),
              const SizedBox(width: 10),
              if (done && !claimed)
                FilledButton(
                  onPressed: () async {
                    if (await ref.read(repoProvider).claimAchievement(d)) ref.read(audioProvider).sfx(Sfx.reward);
                  },
                  child: Text('+${d.reward}'),
                )
              else if (claimed)
                const Icon(Icons.check_circle_rounded, color: AppTokens.success)
              else
                Row(children: [Text('${d.reward}', style: context.text.titleSmall), const SizedBox(width: 3), const CoinIcon(size: 14)]),
            ]),
          );
        },
      ),
    );
  }
}
