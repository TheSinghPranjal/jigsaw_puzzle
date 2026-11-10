import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/common.dart';
import '../../../data/levels/level_catalog.dart';
import '../../../data/repositories/game_repository.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});
  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _query = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final progress = ref.watch(progressProvider).valueOrNull ?? const <int, ProgressRow>{};
    final unlocked = GameRepository.unlockedThrough(progress, catalog.levels.length);
    int doneIn(PuzzleCollection c) => catalog.levelsOf(c).where((l) => progress[l.id]?.completed ?? false).length;

    bool matches(PuzzleCollection c) {
      final done = doneIn(c);
      return switch (_filter) {
        'In progress' => done > 0 && done < 50,
        'Completed' => done == 50,
        'Locked' => c.firstLevel > unlocked,
        _ => true,
      };
    }

    final q = _query.trim().toLowerCase();
    final results = q.isEmpty ? const <PuzzleLevel>[] : catalog.levels.where((l) => l.title.toLowerCase().contains(q) || '${l.id}' == q).take(30).toList();
    final shown = catalog.collections.where(matches).toList();

    return SafeArea(
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(children: [
              Expanded(child: Text('Explore', style: context.text.headlineSmall)),
              TextButton.icon(onPressed: () => context.go('/explore/map'), icon: const Icon(Icons.map_rounded, size: 18), label: const Text('Chapter map')),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(hintText: 'Search puzzles or a level number', prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: context.tokens.card, isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radiusM), borderSide: BorderSide.none)),
            ),
          ),
        ),
        if (q.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: results.isEmpty
                ? SliverToBoxAdapter(child: Center(child: Text('No puzzles match "$_query"', style: context.text.bodySmall)))
                : SliverGrid.builder(gridDelegate: levelGridDelegate(context), itemCount: results.length, itemBuilder: (_, i) => LevelTile(results[i])),
          )
        else ...[
          SliverToBoxAdapter(
            child: SizedBox(
              height: 42,
              child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
                for (final f in const ['All', 'In progress', 'Completed', 'Locked'])
                  Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(f), selected: _filter == f, showCheckmark: false, onSelected: (_) => setState(() => _filter = f))),
              ]),
            ),
          ),
          if (shown.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Nothing here yet', style: context.text.bodySmall))),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            sliver: SliverList.separated(
              itemCount: shown.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (_, i) => _CollectionCard(shown[i], done: doneIn(shown[i]), locked: shown[i].firstLevel > unlocked),
            ),
          ),
        ],
      ]),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard(this.c, {required this.done, required this.locked});
  final PuzzleCollection c;
  final int done;
  final bool locked;

  @override
  Widget build(BuildContext context) => GestureDetector(
        key: ValueKey('collection-${c.id}'),
        onTap: () => context.go('/explore/collection/${c.id}'),
        child: AppCard(
          padding: const EdgeInsets.all(8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(fit: StackFit.expand, children: [
                Art(c.cover, dim: locked, cacheWidth: 720),
                if (locked) const Center(child: CircleAvatar(backgroundColor: Color(0xAA2A2438), child: Icon(Icons.lock_rounded, color: Colors.white))),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.title, style: context.text.titleLarge?.copyWith(fontSize: 18)),
                const SizedBox(height: 3),
                Text(c.description, style: context.text.bodySmall),
                const SizedBox(height: 9),
                Row(children: [
                  Expanded(child: ProgressBar(value: done / 50)),
                  const SizedBox(width: 10),
                  Text('$done / 50 · ${(done * 2)}%', style: context.text.labelSmall),
                ]),
              ]),
            ),
          ]),
        ),
      );
}

class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final c = catalog.collection(id);
    final levels = catalog.levelsOf(c);
    final progress = ref.watch(progressProvider).valueOrNull ?? const <int, ProgressRow>{};
    final done = levels.where((l) => progress[l.id]?.completed ?? false).length;
    final unlocked = GameRepository.unlockedThrough(progress, catalog.levels.length);
    final locked = levels.where((l) => l.id > unlocked).length;
    return Scaffold(
      appBar: AppBar(title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AspectRatio(aspectRatio: 16 / 9, child: Art(c.cover, cacheWidth: 900)),
              const SizedBox(height: 10),
              Text(c.description, style: context.text.bodyMedium),
              const SizedBox(height: 10),
              ProgressBar(value: done / levels.length),
              const SizedBox(height: 5),
              Text('$done of ${levels.length} complete · $locked locked', style: context.text.bodySmall),
            ]),
          ),
        ),
        for (var ch = 0; ch < 5; ch++) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Text('Chapter ${levels[ch * 10].tier} · ${levels[ch * 10].pieceCount} pieces', style: context.text.titleMedium),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(gridDelegate: levelGridDelegate(context), itemCount: 10, itemBuilder: (_, i) => LevelTile(levels[ch * 10 + i])),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ]),
    );
  }
}

/// All 500 levels by 10-level chapter, instead of one enormous map.
class ChapterMapScreen extends ConsumerStatefulWidget {
  const ChapterMapScreen({super.key});
  @override
  ConsumerState<ChapterMapScreen> createState() => _ChapterMapScreenState();
}

class _ChapterMapScreenState extends ConsumerState<ChapterMapScreen> {
  int? _tier;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final progress = ref.watch(progressProvider).valueOrNull ?? const <int, ProgressRow>{};
    final unlocked = GameRepository.unlockedThrough(progress, catalog.levels.length);
    final tier = _tier ?? (unlocked + 9) ~/ 10;
    final levels = catalog.levels.where((l) => l.tier == tier).toList();
    final t = context.tokens;
    return Scaffold(
      appBar: AppBar(title: const Text('Chapter map')),
      body: Column(children: [
        SizedBox(
          height: 74,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            controller: ScrollController(initialScrollOffset: ((tier - 3) * 64).clamp(0, 50.0 * 64).toDouble()),
            itemCount: 50,
            itemBuilder: (context, i) {
              final n = i + 1;
              final sel = n == tier;
              final open = (n - 1) * 10 + 1 <= unlocked;
              return GestureDetector(
                onTap: () => setState(() => _tier = n),
                child: Container(
                  width: 58,
                  margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                  decoration: BoxDecoration(color: sel ? t.primary : t.card, borderRadius: BorderRadius.circular(14), boxShadow: AppTokens.softShadow),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    open
                        ? Text('$n', style: context.text.titleMedium?.copyWith(color: sel ? Colors.white : t.text))
                        : Icon(Icons.lock_rounded, size: 16, color: sel ? Colors.white : t.textSecondary),
                    Text('${n * 10}p', style: context.text.labelSmall?.copyWith(color: sel ? Colors.white70 : t.textSecondary, fontSize: 10)),
                  ]),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Align(alignment: Alignment.centerLeft, child: Text('Levels ${levels.first.id}–${levels.last.id} · ${levels.first.pieceCount} pieces · ${levels.first.difficulty}', style: context.text.titleSmall)),
        ),
        Expanded(child: GridView.builder(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), gridDelegate: levelGridDelegate(context), itemCount: levels.length, itemBuilder: (_, i) => LevelTile(levels[i]))),
      ]),
    );
  }
}
