import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/services/app_services.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../../../data/repositories/game_repository.dart';

final _statsProvider = FutureProvider.autoDispose<PlayerStats>((ref) {
  // Refresh whenever anything the numbers depend on changes.
  ref.watch(progressProvider);
  ref.watch(dailiesProvider);
  ref.watch(favoritesProvider);
  ref.watch(coinsProvider);
  return ref.watch(repoProvider).stats();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _rename(BuildContext context, WidgetRef ref, String current) async {
    final field = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(controller: field, autofocus: true, maxLength: 20),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, field.text.trim()), child: const Text('Save'))],
      ),
    );
    if (name != null && name.isNotEmpty) await ref.read(repoProvider).setPlayerName(name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileProvider).valueOrNull?.playerName ?? 'Puzzler';
    final s = ref.watch(_statsProvider).valueOrNull;
    final t = context.tokens;
    Widget link(IconData i, String label, String route) => ListTile(leading: Icon(i, color: t.primary), title: Text(label, style: context.text.titleSmall), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => context.push(route));
    Widget stat(String label, String value) => Expanded(child: AppCard(child: Column(children: [Text(value, style: context.text.titleLarge), const SizedBox(height: 2), Text(label, textAlign: TextAlign.center, style: context.text.bodySmall)])));
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          CircleAvatar(radius: 32, backgroundColor: t.primaryLight, child: Image.asset('assets/branding/logo/logo.png', width: 44)),
          const SizedBox(width: 14),
          Expanded(child: Text(name, style: context.text.headlineSmall)),
          IconButton(tooltip: 'Edit name', onPressed: () => _rename(context, ref, name), icon: const Icon(Icons.edit_rounded)),
        ]),
        const SizedBox(height: 14),
        Row(children: [stat('Levels', '${s?.levels ?? 0}'), const SizedBox(width: 8), stat('Stars', '${s?.stars ?? 0}'), const SizedBox(width: 8), stat('Coins', '${s?.coins ?? 0}')]),
        const SizedBox(height: 8),
        Row(children: [stat('Dailies', '${s?.dailies ?? 0}'), const SizedBox(width: 8), stat('Best streak', '${s?.bestStreak ?? 0}'), const SizedBox(width: 8), stat('Time played', formatDuration(s?.totalSeconds ?? 0))]),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            link(Icons.emoji_events_rounded, 'Achievements', '/achievements'),
            link(Icons.savings_rounded, 'Rewards', '/rewards'),
            link(Icons.history_rounded, 'Puzzle history', '/history'),
            link(Icons.settings_rounded, 'Settings', '/settings'),
          ]),
        ),
      ]),
    );
  }
}
