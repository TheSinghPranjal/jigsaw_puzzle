import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../core/database/app_database.dart';
import '../../data/levels/level_catalog.dart';
import '../../data/repositories/game_repository.dart';
import '../services/app_services.dart';
import '../utils/format.dart';

void showHint(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.height = 8});
  final double value, height;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(children: [
        Container(height: height, color: t.primaryLight),
        AnimatedFractionallySizedBox(duration: const Duration(milliseconds: 300), widthFactor: value.clamp(0, 1), child: Container(height: height, color: t.progress)),
      ]),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(backgroundColor: t.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusM))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Text(label, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16)),
      ]),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(14)});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(AppTokens.radiusM), boxShadow: AppTokens.softShadow),
      child: Material(
        color: Colors.transparent,
        child: InkWell(borderRadius: BorderRadius.circular(AppTokens.radiusM), onTap: onTap, child: Padding(padding: padding, child: child)),
      ),
    );
  }
}

class Art extends StatelessWidget {
  const Art(this.asset, {super.key, this.radius = AppTokens.radiusM, this.dim = false, this.cacheWidth = 480});
  final String asset;
  final double radius;
  final bool dim;
  final int cacheWidth;
  @override
  Widget build(BuildContext context) {
    final image = Image.asset(asset, fit: BoxFit.cover, cacheWidth: cacheWidth, gaplessPlayback: true, color: dim ? const Color(0x99FFFFFF) : null, colorBlendMode: dim ? BlendMode.modulate : null);
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: SizedBox.expand(child: image));
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 10, 8),
        child: Row(children: [
          Expanded(child: Text(title, style: context.text.titleLarge)),
          if (action != null) TextButton(onPressed: onAction, child: Text(action!, style: TextStyle(color: context.tokens.primary, fontWeight: FontWeight.w800))),
        ]),
      );
}

class CoinBadge extends ConsumerWidget {
  const CoinBadge({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider).valueOrNull ?? 0;
    final t = context.tokens;
    return GestureDetector(
      onTap: () => context.push('/rewards'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(40), boxShadow: AppTokens.softShadow),
        child: Row(mainAxisSize: MainAxisSize.min, children: [const CoinIcon(size: 18), const SizedBox(width: 5), Text('$coins', style: context.text.titleSmall)]),
      ),
    );
  }
}

class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 20});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFFBE29A), Color(0xFFE8B04A)], begin: Alignment.topLeft, end: Alignment.bottomRight), border: Border.all(color: const Color(0xFFD99F3A))),
        child: Icon(Icons.extension_rounded, size: size * .62, color: const Color(0xFFB77F22)),
      );
}

class StarRow extends StatelessWidget {
  const StarRow(this.stars, {super.key, this.size = 13});
  final int stars;
  final double size;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < 3; i++) Icon(i < stars ? Icons.star_rounded : Icons.star_outline_rounded, size: size, color: i < stars ? AppTokens.gold : context.tokens.border),
      ]);
}

enum LevelState { locked, current, completed, perfect }

LevelState levelStateOf(int id, Map<int, ProgressRow> progress, int unlocked) {
  final p = progress[id];
  if (p?.completed ?? false) return p!.bestStars == 3 ? LevelState.perfect : LevelState.completed;
  return id == unlocked ? LevelState.current : LevelState.locked;
}

class LevelTile extends ConsumerWidget {
  const LevelTile(this.level, {super.key});
  final PuzzleLevel level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final progress = ref.watch(progressProvider).valueOrNull ?? const <int, ProgressRow>{};
    final favorites = ref.watch(favoritesProvider).valueOrNull ?? const <int>{};
    final total = ref.watch(catalogProvider).levels.length;
    final unlocked = GameRepository.unlockedThrough(progress, total);
    final state = levelStateOf(level.id, progress, unlocked);
    final locked = state == LevelState.locked;
    final row = progress[level.id];
    return GestureDetector(
      key: ValueKey('level-${level.id}'),
      onTap: () => context.push('/level/${level.id}'),
      child: Container(
        decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(14), boxShadow: AppTokens.softShadow, border: state == LevelState.current ? Border.all(color: t.primary, width: 2) : null),
        padding: const EdgeInsets.all(5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(fit: StackFit.expand, children: [
              Art(level.thumbnail, radius: 10, dim: locked, cacheWidth: 240),
              if (locked) const Center(child: CircleAvatar(radius: 14, backgroundColor: Color(0xAA2A2438), child: Icon(Icons.lock_rounded, size: 15, color: Colors.white))),
              if (state == LevelState.completed || state == LevelState.perfect)
                Positioned(right: 3, top: 3, child: CircleAvatar(radius: 9, backgroundColor: state == LevelState.perfect ? AppTokens.gold : AppTokens.success, child: const Icon(Icons.check_rounded, size: 12, color: Colors.white))),
              if (favorites.contains(level.id)) const Positioned(left: 3, top: 3, child: Icon(Icons.favorite_rounded, size: 15, color: Color(0xFFF4A6B9))),
            ]),
          ),
          const SizedBox(height: 4),
          Row(children: [
            Text('${level.id}', style: context.text.titleSmall),
            const Spacer(),
            Icon(Icons.extension_rounded, size: 11, color: t.textSecondary),
            Text(' ${level.pieceCount}', style: context.text.labelSmall),
          ]),
          SizedBox(
            height: 15,
            child: row?.completed ?? false
                ? Row(children: [StarRow(row!.bestStars, size: 11), const Spacer(), if (row.bestSeconds != null) Text(formatDuration(row.bestSeconds!), style: context.text.labelSmall?.copyWith(fontSize: 9))])
                : Text(state == LevelState.current ? 'Play now' : 'Locked', style: context.text.labelSmall?.copyWith(fontSize: 10, color: state == LevelState.current ? t.primary : t.textSecondary)),
          ),
        ]),
      ),
    );
  }
}

SliverGridDelegate levelGridDelegate(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final count = (width / 124).floor().clamp(3, 7);
  return SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: .86);
}
