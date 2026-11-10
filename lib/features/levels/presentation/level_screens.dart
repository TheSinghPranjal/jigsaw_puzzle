import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/app_services.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../../../data/levels/level_catalog.dart';
import '../../../data/repositories/game_repository.dart';
import '../../puzzle/screens/game_screen.dart';

class LevelPreviewScreen extends ConsumerWidget {
  const LevelPreviewScreen({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final level = catalog.level(id);
    final progress = ref.watch(progressProvider).valueOrNull ?? const <int, ProgressRow>{};
    final favorites = ref.watch(favoritesProvider).valueOrNull ?? const <int>{};
    final active = ref.watch(activeProvider).valueOrNull ?? const <ActivePuzzleRow>[];
    final settings = ref.watch(settingsProvider);
    final unlockedThrough = GameRepository.unlockedThrough(progress, catalog.levels.length);
    final row = progress[id];
    final done = row?.completed ?? false;
    final playable = done || id <= unlockedThrough;
    final saved = active.where((a) => a.puzzleKey == 'campaign:$id').firstOrNull;
    final isFav = favorites.contains(id);
    final t = context.tokens;
    final setup = PuzzleSetup.campaign(level, rotation: settings.rotation);

    return Scaffold(
      appBar: AppBar(
        title: Text('Level $id'),
        actions: [
          IconButton(
            tooltip: isFav ? 'Remove favorite' : 'Add favorite',
            icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFav ? const Color(0xFFF4A6B9) : null),
            onPressed: () => ref.read(repoProvider).setFavorite(id, !isFav),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
        GestureDetector(
          onTap: playable ? () => _showFull(context, level) : null,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(fit: StackFit.expand, children: [
              Art(level.image, radius: AppTokens.radiusL, dim: !playable, cacheWidth: 900),
              if (!playable) const Center(child: CircleAvatar(radius: 26, backgroundColor: Color(0xAA2A2438), child: Icon(Icons.lock_rounded, color: Colors.white))),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Text(level.title, style: context.text.headlineSmall),
        const SizedBox(height: 4),
        Text(level.description, style: context.text.bodyMedium?.copyWith(color: t.textSecondary)),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _Chip(Icons.extension_rounded, '${level.pieceCount} pieces'),
          _Chip(Icons.grid_on_rounded, '${level.rows} × ${level.cols}'),
          _Chip(Icons.speed_rounded, level.difficulty),
          _Chip(Icons.schedule_rounded, 'About ${level.estimatedMinutes} min'),
          if (settings.rotation) const _Chip(Icons.rotate_right_rounded, 'Rotation on'),
        ]),
        if (done) ...[
          const SizedBox(height: 14),
          AppCard(child: Row(children: [StarRow(row!.bestStars, size: 22), const Spacer(), if (row.bestSeconds != null) Text('Best ${formatDuration(row.bestSeconds!)}', style: context.text.titleSmall)])),
        ],
        const SizedBox(height: 18),
        if (!playable)
          Text('Complete Level ${id - 1} to unlock this puzzle.', textAlign: TextAlign.center, style: context.text.titleSmall?.copyWith(color: t.textSecondary))
        else ...[
          if (saved != null) ...[
            Padding(padding: const EdgeInsets.only(bottom: 8), child: ProgressBar(value: saved.placedCount / saved.pieceCount)),
            Text('${saved.placedCount} of ${saved.pieceCount} pieces placed', textAlign: TextAlign.center, style: context.text.bodySmall),
            const SizedBox(height: 10),
          ],
          PrimaryButton(key: const ValueKey('start'), label: saved != null ? 'Continue' : (done ? 'Play again' : 'Start'), icon: Icons.play_arrow_rounded, onPressed: () => context.pushReplacement('/play', extra: PlayArgs(setup))),
          if (saved != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => _restart(context, setup), child: const Text('Start over')),
          ],
        ],
      ]),
    );
  }

  Future<void> _restart(BuildContext context, PuzzleSetup setup) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start over?'),
        content: const Text('Your placed pieces on this puzzle will be cleared.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Start over'))],
      ),
    );
    if (ok == true && context.mounted) context.pushReplacement('/play', extra: PlayArgs(setup, restart: true));
  }

  void _showFull(BuildContext context, PuzzleLevel level) => showDialog(
        context: context,
        builder: (_) => Dialog(insetPadding: const EdgeInsets.all(12), clipBehavior: Clip.antiAlias, child: InteractiveViewer(maxScale: 5, child: AspectRatio(aspectRatio: 4 / 3, child: Image.asset(level.image, fit: BoxFit.cover)))),
      );
}

class _Chip extends StatelessWidget {
  const _Chip(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: t.selected, borderRadius: BorderRadius.circular(30)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: t.primary), const SizedBox(width: 5), Text(label, style: context.text.titleSmall?.copyWith(fontSize: 12))]),
    );
  }
}
