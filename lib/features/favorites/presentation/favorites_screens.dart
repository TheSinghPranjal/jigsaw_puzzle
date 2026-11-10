import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/app_services.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});
  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String _tab = 'All';
  String _query = '';

  Future<void> _remove(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove favorite?'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove'))],
      ),
    );
    if (ok == true) await ref.read(repoProvider).setFavorite(id, false);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final favorites = ref.watch(favoritesProvider).valueOrNull ?? const <int>{};
    final progress = ref.watch(progressProvider).valueOrNull ?? const <int, ProgressRow>{};
    final active = ref.watch(activeProvider).valueOrNull ?? const <ActivePuzzleRow>[];
    final unfinished = {for (final a in active) a.levelId};
    final q = _query.trim().toLowerCase();
    final ids = favorites.where((id) {
      final inTab = switch (_tab) { 'Completed' => progress[id]?.completed ?? false, 'Unfinished' => unfinished.contains(id), _ => true };
      return inTab && (q.isEmpty || catalog.level(id).title.toLowerCase().contains(q));
    }).toList()
      ..sort();
    return SafeArea(
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 6),
            child: Row(children: [Expanded(child: Text('Favorites', style: context.text.headlineSmall)), TextButton.icon(onPressed: () => context.push('/history'), icon: const Icon(Icons.history_rounded, size: 18), label: const Text('History'))]),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 42,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
              for (final f in const ['All', 'Completed', 'Unfinished'])
                Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(f), selected: _tab == f, showCheckmark: false, onSelected: (_) => setState(() => _tab = f))),
            ]),
          ),
        ),
        if (favorites.length > 6)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(onChanged: (v) => setState(() => _query = v), decoration: InputDecoration(hintText: 'Search favorites', prefixIcon: const Icon(Icons.search_rounded), isDense: true, filled: true, fillColor: context.tokens.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radiusM), borderSide: BorderSide.none))),
            ),
          ),
        if (ids.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.favorite_border_rounded, size: 46, color: context.tokens.textSecondary), const SizedBox(height: 10), Text(favorites.isEmpty ? 'Tap the heart on any puzzle to save it here.' : 'No favorites in this list yet.', textAlign: TextAlign.center, style: context.text.bodyMedium)]),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.builder(
              gridDelegate: levelGridDelegate(context),
              itemCount: ids.length,
              itemBuilder: (_, i) => GestureDetector(onLongPress: () => _remove(ids[i]), child: LevelTile(catalog.level(ids[i]))),
            ),
          ),
      ]),
    );
  }
}

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final rows = ref.watch(historyProvider).valueOrNull ?? const <HistoryRow>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Puzzle history')),
      body: rows.isEmpty
          ? Center(child: Text('Completed puzzles will appear here.', style: context.text.bodyMedium))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final h = rows[i];
                final l = catalog.level(h.levelId);
                return AppCard(
                  padding: const EdgeInsets.all(8),
                  onTap: h.isDaily ? null : () => context.push('/level/${l.id}'),
                  child: Row(children: [
                    SizedBox(width: 76, height: 57, child: Art(l.thumbnail, radius: 10, cacheWidth: 200)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(h.isDaily ? 'Daily · ${l.title}' : l.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
                        Text('${DateFormat.yMMMd().format(h.at)} · ${formatDuration(h.seconds)}', style: context.text.bodySmall),
                      ]),
                    ),
                    StarRow(h.stars),
                  ]),
                );
              },
            ),
    );
  }
}
