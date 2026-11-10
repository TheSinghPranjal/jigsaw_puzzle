import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/services/app_services.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../../../data/repositories/game_repository.dart';

class CompletionScreen extends ConsumerStatefulWidget {
  const CompletionScreen({super.key, required this.result});
  final CompletionResult result;
  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..forward();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.result.coins > 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) ref.read(audioProvider).sfx(Sfx.reward);
      });
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() f) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await f();
    } catch (e) {
      debugPrint('export failed: $e');
      if (mounted) showHint(context, 'That did not work. Please try again.');
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final level = r.setup.level;
    final t = context.tokens;
    final catalog = ref.watch(catalogProvider);
    final favs = ref.watch(favoritesProvider).valueOrNull ?? const <int>{};
    final isFav = favs.contains(level.id);
    final coinCurve = CurvedAnimation(parent: _anim, curve: const Interval(.15, .6, curve: Curves.easeOut));

    return Scaffold(
      body: Stack(children: [
        SafeArea(
          child: ListView(padding: const EdgeInsets.all(18), children: [
            Text('Puzzle complete!', key: const ValueKey('complete-title'), textAlign: TextAlign.center, style: context.text.displaySmall?.copyWith(fontSize: 28)),
            const SizedBox(height: 14),
            ScaleTransition(
              scale: CurvedAnimation(parent: _anim, curve: const Interval(0, .3, curve: Curves.easeOutBack)),
              child: AspectRatio(aspectRatio: 4 / 3, child: Art(level.image, radius: AppTokens.radiusL, cacheWidth: 1000)),
            ),
            const SizedBox(height: 12),
            Text(r.setup.title, textAlign: TextAlign.center, style: context.text.titleLarge),
            const SizedBox(height: 10),
            Center(child: StarRow(r.stars, size: 40)),
            const SizedBox(height: 12),
            AppCard(
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _Stat('Time', formatDuration(r.seconds)),
                  _Stat('Pieces', '${r.setup.spec.pieceCount}'),
                  AnimatedBuilder(
                    animation: coinCurve,
                    builder: (context, _) => _Stat('Coins', '+${(r.coins * coinCurve.value).round()}'),
                  ),
                ]),
                if (r.lines.isNotEmpty) const Divider(height: 22),
                for (final l in r.lines)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(children: [Expanded(child: Text(l.label, style: context.text.bodyMedium)), Text('+${l.amount}', style: context.text.titleSmall), const SizedBox(width: 4), const CoinIcon(size: 14)]),
                  ),
              ]),
            ),
            if (r.collectionCompleted != null) ...[const SizedBox(height: 10), _Banner(Icons.collections_rounded, 'Collection complete: ${r.collectionCompleted}')],
            for (final a in r.newAchievements) ...[const SizedBox(height: 10), _Banner(Icons.emoji_events_rounded, 'Achievement unlocked: ${a.title}')],
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _Action(Icons.ios_share_rounded, 'Share', () => _run(() => ImageExporter.share(level))),
              _Action(Icons.download_rounded, 'Save', () => _run(() async {
                    final messenger = ScaffoldMessenger.of(context);
                    final err = await ImageExporter.saveToPhotos(level);
                    messenger.showSnackBar(SnackBar(content: Text(err ?? 'Saved to your photos')));
                  })),
              _Action(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, 'Favorite', () => ref.read(repoProvider).setFavorite(level.id, !isFav)),
            ]),
            const SizedBox(height: 12),
            if (r.setup.isDaily)
              PrimaryButton(label: 'Back to Daily', onPressed: () => context.go('/daily'))
            else ...[
              if (r.nextLevel != null) PrimaryButton(key: const ValueKey('next-puzzle'), label: 'Next puzzle', icon: Icons.arrow_forward_rounded, onPressed: () => context.pushReplacement('/level/${r.nextLevel}')),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: () => context.go('/explore/collection/${catalog.collectionOf(level).id}'), child: const Text('Return to collection')),
            ],
            TextButton(onPressed: () => context.go('/home'), child: Text('Home', style: TextStyle(color: t.textSecondary))),
          ]),
        ),
        Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _Confetti(_anim)))),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(children: [Text(value, style: context.text.titleLarge), Text(label, style: context.text.bodySmall)]);
}

class _Banner extends StatelessWidget {
  const _Banner(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => AppCard(child: Row(children: [Icon(icon, color: AppTokens.gold), const SizedBox(width: 10), Expanded(child: Text(text, style: context.text.titleSmall))]));
}

class _Action extends StatelessWidget {
  const _Action(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [Icon(icon, color: context.tokens.primary), const SizedBox(height: 2), Text(label, style: context.text.labelSmall)])),
      );
}

class _Confetti extends CustomPainter {
  _Confetti(this.a) : super(repaint: a);
  final Animation<double> a;
  static const _colors = [Color(0xFFF4A6B9), Color(0xFF93C7EA), Color(0xFFA9D6B8), Color(0xFFF1C76B), Color(0xFF8D78C8)];

  @override
  void paint(Canvas canvas, Size size) {
    final t = a.value;
    if (t >= 1) return;
    final r = math.Random(7);
    final p = Paint();
    for (var i = 0; i < 120; i++) {
      final x = r.nextDouble() * size.width, delay = r.nextDouble() * .35, speed = .7 + r.nextDouble() * .7, sway = r.nextDouble() * 6.28;
      final life = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (life <= 0) continue;
      p.color = _colors[i % 5].withValues(alpha: (1 - life * life).clamp(0, 1));
      canvas.save();
      canvas.translate(x + math.sin(life * 8 + sway) * 26, -20 + life * size.height * speed * 1.2);
      canvas.rotate(life * 12 + sway);
      canvas.drawRect(const Rect.fromLTWH(-4, -7, 8, 14), p);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_Confetti old) => false;
}
