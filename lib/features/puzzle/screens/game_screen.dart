import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/services/app_services.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../../../data/levels/level_catalog.dart';
import '../../../data/repositories/game_repository.dart';
import '../controllers/puzzle_controller.dart';
import '../engine/puzzle_session.dart';
import '../geometry/jigsaw_geometry.dart';
import '../rendering/piece_atlas.dart';
import '../widgets/board_widgets.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.setup, this.restart = false});
  final PuzzleSetup setup;
  final bool restart;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  PuzzleController? c;
  PuzzleSnapshot? _restored;
  String? _error;
  bool _paused = false, _finishing = false;
  bool _restoredBanner = false;
  late final AudioService _audio;

  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final AnimationController _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 240));
  final _rootKey = GlobalKey(), _boardKey = GlobalKey(), _trayKey = GlobalKey();
  int? _dragId;
  Offset _dragCenter = Offset.zero;
  static const _lift = 62.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audio = ref.read(audioProvider);
    _load();
    _audio.play(widget.setup.isDaily ? MusicTrack.daily : MusicTrack.puzzle);
  }

  Future<void> _load() async {
    final setup = widget.setup;
    final repo = ref.read(repoProvider);
    try {
      final image = await loadAssetImage(setup.level.image);
      final g = JigsawGeometry.generate(setup.spec);
      if (!mounted) return;
      final atlas = await PieceAtlas.build(image, g, context.tokens.board);
      image.dispose();
      if (widget.restart) await repo.clearActive(setup.key);
      final snap = widget.restart ? null : await repo.loadActive(setup.key);
      final restored = snap == null ? null : PuzzleSession.restore(g, snap, rotationEnabled: setup.rotation);
      final session = restored ?? PuzzleSession.start(g, rotationEnabled: setup.rotation);
      if (!mounted) {
        atlas.dispose();
        return;
      }
      final ctl = PuzzleController(session, atlas, onSave: (s) => repo.saveActive(setup, s), onFeedback: _feedback)..init();
      setState(() {
        c = ctl;
        _restored = restored == null ? null : snap;
        _restoredBanner = restored != null && restored.placed.isNotEmpty;
      });
      ctl.hintTarget.addListener(() {
        if (ctl.hintTarget.value == null && _pulse.isAnimating) _pulse.stop();
      });
      ctl.startTimer();
      ctl.save();
      if (_restoredBanner) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _restoredBanner = false);
        });
      }
    } catch (e, st) {
      debugPrint('puzzle load failed: $e\n$st');
      if (mounted) setState(() => _error = 'This puzzle could not be opened.');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctl = c;
    final audio = ref.read(audioProvider);
    if (state == AppLifecycleState.resumed) {
      audio.suspend(false);
      if (!_paused) ctl?.startTimer();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      audio.suspend(true);
      ctl?.stopTimer();
      ctl?.save();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final ctl = c;
    if (ctl != null) {
      ctl.save();
      ctl.dispose();
      ctl.atlas.dispose();
    }
    _pulse.dispose();
    _fly.dispose();
    _audio.play(MusicTrack.menu);
    super.dispose();
  }

  void _feedback(DropFeedback f) {
    final audio = ref.read(audioProvider);
    final haptics = ref.read(settingsProvider).haptics;
    switch (f) {
      case DropFeedback.placed:
      case DropFeedback.completed:
        audio.sfx(Sfx.correct);
        if (haptics) HapticFeedback.lightImpact();
        _pulse.forward(from: 0);
      case DropFeedback.wrongSpot:
      case DropFeedback.wrongRotation:
        audio.sfx(Sfx.wrong);
        if (haptics) HapticFeedback.selectionClick();
      case DropFeedback.none:
        break;
    }
  }

  Offset _toRoot(Offset global) => (_rootKey.currentContext!.findRenderObject() as RenderBox).globalToLocal(global);

  void _dragStart(int id, Offset global) {
    final ctl = c!;
    _fly.stop();
    _dragId = id;
    ctl.select(id);
    _dragCenter = _toRoot(global) - const Offset(0, _lift);
    ctl.drag.value = DragVisual(id, _dragCenter, ctl.view.value.scale);
    ref.read(audioProvider).sfx(Sfx.place);
  }

  void _dragUpdate(Offset global) {
    final ctl = c!;
    final id = _dragId;
    if (id == null) return;
    _dragCenter = _toRoot(global) - const Offset(0, _lift);
    ctl.drag.value = DragVisual(id, _dragCenter, ctl.view.value.scale);
  }

  void _dragEnd() {
    final ctl = c;
    final id = _dragId;
    if (ctl == null || id == null) return;
    _dragId = null;
    final boardBox = _boardKey.currentContext!.findRenderObject() as RenderBox;
    final rootBox = _rootKey.currentContext!.findRenderObject() as RenderBox;
    final local = boardBox.globalToLocal(rootBox.localToGlobal(_dragCenter));
    final inside = (Offset.zero & boardBox.size).contains(local);
    final result = ctl.drop(id, inside ? local : null);
    if (result == DropFeedback.placed || result == DropFeedback.completed) {
      ctl.drag.value = null;
      if (result == DropFeedback.completed) _finish();
      return;
    }
    if (result == DropFeedback.wrongRotation && mounted) {
      showHint(context, 'Right spot! Rotate the piece to fit.');
    }
    _flyBack(id, result != DropFeedback.none);
  }

  /// Animates a rejected piece down into the tray.
  void _flyBack(int id, bool wrong) {
    final ctl = c!;
    final trayBox = _trayKey.currentContext!.findRenderObject() as RenderBox;
    final rootBox = _rootKey.currentContext!.findRenderObject() as RenderBox;
    final target = rootBox.globalToLocal(trayBox.localToGlobal(trayBox.size.center(Offset.zero)));
    final from = _dragCenter, s0 = ctl.view.value.scale;
    late VoidCallback tick;
    tick = () {
      final t = Curves.easeIn.transform(_fly.value);
      ctl.drag.value = DragVisual(id, Offset.lerp(from, target, t)!, s0, opacity: 1 - t * .7, wrong: wrong);
    };
    _fly
      ..removeListener(tick)
      ..addListener(tick);
    _fly.forward(from: 0).whenComplete(() {
      _fly.removeListener(tick);
      if (mounted && _dragId == null) ctl.drag.value = null;
    });
  }

  Future<void> _finish() async {
    final ctl = c!;
    if (_finishing || !ctl.session.verifyComplete()) return;
    _finishing = true;
    ctl.stopTimer();
    final repo = ref.read(repoProvider);
    final setup = widget.setup;
    final s = ctl.session;
    final CompletionResult result = setup.isDaily
        ? await repo.completeDaily(setup, seconds: s.elapsedSeconds, hints: s.hintsUsed)
        : await repo.completeLevel(setup, runId: s.startedAtMs, seconds: s.elapsedSeconds, hints: s.hintsUsed);
    ref.read(audioProvider).sfx(Sfx.victory);
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) context.pushReplacement('/complete', extra: result);
  }

  Future<void> _pause() async {
    final ctl = c;
    if (ctl == null) return;
    setState(() => _paused = true);
    ctl.stopTimer();
    await ctl.save();
    if (!mounted) return;
    final action = await showDialog<String>(context: context, barrierDismissible: false, builder: (_) => _PauseDialog(setup: widget.setup));
    if (!mounted) return;
    setState(() => _paused = false);
    switch (action) {
      case 'restart':
        await ctl.onSave(ctl.snapshot());
        if (mounted) context.pushReplacement('/play', extra: PlayArgs(widget.setup, restart: true));
      case 'exit':
        if (mounted) context.pop();
      default:
        ctl.startTimer();
    }
  }

  void _showReference() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(14),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          InteractiveViewer(maxScale: 5, child: AspectRatio(aspectRatio: 4 / 3, child: Image.asset(widget.setup.level.image, fit: BoxFit.cover))),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Back to puzzle')),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ctl = c;
    if (_error != null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(_error!)));
    }
    if (ctl == null) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(color: t.primary),
            const SizedBox(height: 18),
            Text('Cutting ${widget.setup.spec.pieceCount} pieces…', style: context.text.titleMedium),
          ]),
        ),
      );
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _pause();
      },
      child: Scaffold(
        key: _rootKey,
        body: Stack(children: [
          SafeArea(
            child: Column(children: [
              _TopBar(c: ctl, title: widget.setup.title, onBack: _pause, onPause: _pause),
              Expanded(
                child: Stack(children: [
                  Positioned.fill(
                    child: LayoutBuilder(builder: (context, box) {
                      final size = box.biggest;
                      if (ctl.viewport != size) {
                        final r = _restored;
                        ctl.layout(size, restoredZoom: r?.zoom, restoredCenter: r == null ? null : Offset(r.panX, r.panY));
                      }
                      return GestureDetector(
                        key: _boardKey,
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: (_) => ctl.scaleStart(),
                        onScaleUpdate: (d) => ctl.scaleUpdate(d.scale, d.localFocalPoint, Offset.zero),
                        onDoubleTapDown: (d) => ctl.zoom >= ctl.maxZoom * .9 ? ctl.fit() : ctl.zoomBy(1.8, d.localPosition),
                        onDoubleTap: () {},
                        child: RepaintBoundary(child: CustomPaint(size: size, painter: BoardPainter(ctl, _pulse, t))),
                      );
                    }),
                  ),
                  Positioned(right: 10, top: 10, child: _ZoomControls(c: ctl)),
                  if (_restoredBanner) const Positioned(top: 10, left: 12, child: _RestoredBadge()),
                ]),
              ),
              _BottomPanel(
                c: ctl,
                trayKey: _trayKey,
                onHint: () {
                  ref.read(audioProvider).sfx(Sfx.button);
                  _pulse.repeat();
                  ctl.hint();
                },
                onReference: _showReference,
                dragStart: _dragStart,
                dragUpdate: _dragUpdate,
                dragEnd: _dragEnd,
              ),
            ]),
          ),
          Positioned.fill(child: IgnorePointer(child: RepaintBoundary(child: CustomPaint(painter: DragPainter(ctl))))),
        ]),
      ),
    );
  }
}

class PlayArgs {
  const PlayArgs(this.setup, {this.restart = false});
  final PuzzleSetup setup;
  final bool restart;
}

class _RestoredBadge extends StatelessWidget {
  const _RestoredBadge();
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(40), boxShadow: AppTokens.softShadow),
      child: Row(children: [Icon(Icons.restore_rounded, size: 16, color: t.primary), const SizedBox(width: 6), Text('Puzzle restored', style: context.text.bodySmall)]),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.c, required this.title, required this.onBack, required this.onPause});
  final PuzzleController c;
  final String title;
  final VoidCallback onBack, onPause;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final showTimer = ref.watch(settingsProvider.select((s) => s.showTimer));
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 6),
      child: Row(children: [
        IconButton(tooltip: 'Back', onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded)),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
            const SizedBox(height: 4),
            ValueListenableBuilder(
              valueListenable: c.boardVersion,
              builder: (context, _, _) => Row(children: [
                Expanded(child: ProgressBar(value: c.session.progress, height: 6)),
                const SizedBox(width: 8),
                Text('${(c.session.progress * 100).round()}%', key: const ValueKey('progress-label'), style: context.text.labelSmall),
              ]),
            ),
          ]),
        ),
        const SizedBox(width: 10),
        if (showTimer)
          ValueListenableBuilder(
            valueListenable: c.elapsed,
            builder: (context, v, _) => Text(formatDuration(v), style: context.text.titleSmall?.copyWith(color: t.textSecondary, fontFeatures: const [FontFeature.tabularFigures()])),
          ),
        IconButton(tooltip: 'Pause', onPressed: onPause, icon: const Icon(Icons.pause_circle_outline_rounded)),
      ]),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({required this.c});
  final PuzzleController c;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget b(IconData i, String tip, VoidCallback f) => IconButton(tooltip: tip, visualDensity: VisualDensity.compact, onPressed: f, icon: Icon(i, size: 20, color: t.text));
    return Container(
      decoration: BoxDecoration(color: t.card.withValues(alpha: .92), borderRadius: BorderRadius.circular(16), boxShadow: AppTokens.softShadow),
      child: Column(children: [b(Icons.add_rounded, 'Zoom in', () => c.zoomBy(1.4)), b(Icons.remove_rounded, 'Zoom out', () => c.zoomBy(1 / 1.4)), b(Icons.fit_screen_rounded, 'Fit to screen', c.fit)]),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.c, required this.trayKey, required this.onHint, required this.onReference, required this.dragStart, required this.dragUpdate, required this.dragEnd});
  final PuzzleController c;
  final Key trayKey;
  final VoidCallback onHint, onReference, dragEnd;
  final void Function(int, Offset) dragStart;
  final void Function(Offset) dragUpdate;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(color: t.tray, borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTokens.radiusL)), boxShadow: const [BoxShadow(color: Color(0x18453A60), blurRadius: 16, offset: Offset(0, -4))]),
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            ValueListenableBuilder(
              valueListenable: c.trayVersion,
              builder: (context, _, _) => Text('${c.session.tray.length} pieces left', key: const ValueKey('remaining-label'), style: context.text.labelSmall),
            ),
            const Spacer(),
            ValueListenableBuilder(
              valueListenable: c.edgesOnly,
              builder: (context, on, _) => GestureDetector(
                onTap: c.toggleEdges,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: on ? t.primary : t.card, borderRadius: BorderRadius.circular(30)),
                  child: Row(children: [
                    Icon(Icons.crop_free_rounded, size: 14, color: on ? Colors.white : t.text),
                    const SizedBox(width: 4),
                    Text('Edges', style: context.text.labelSmall?.copyWith(color: on ? Colors.white : t.text)),
                  ]),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 4),
        SizedBox(
          key: trayKey,
          height: 88,
          child: PieceTray(c: c, onDragStart: dragStart, onDragUpdate: dragUpdate, onDragEnd: dragEnd, onTapPiece: (id) => c.select(c.selected.value == id ? null : id)),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _Tool(Icons.shuffle_rounded, 'Shuffle', c.shuffle),
          PopupMenuButton<TraySort>(
            tooltip: 'Sort',
            onSelected: c.sort,
            itemBuilder: (_) => const [
              PopupMenuItem(value: TraySort.edgesFirst, child: Text('Edges first')),
              PopupMenuItem(value: TraySort.byPosition, child: Text('By position')),
            ],
            child: const _ToolLabel(Icons.sort_rounded, 'Sort'),
          ),
          _Tool(Icons.lightbulb_outline_rounded, 'Hint', onHint),
          _Tool(Icons.image_outlined, 'Picture', onReference),
          if (c.session.rotationEnabled) _Tool(Icons.rotate_right_rounded, 'Rotate', c.rotateSelected),
        ]),
      ]),
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: _ToolLabel(icon, label));
}

class _ToolLabel extends StatelessWidget {
  const _ToolLabel(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 22, color: context.tokens.text), const SizedBox(height: 1), Text(label, style: context.text.labelSmall)]),
      );
}

class _PauseDialog extends ConsumerStatefulWidget {
  const _PauseDialog({required this.setup});
  final PuzzleSetup setup;
  @override
  ConsumerState<_PauseDialog> createState() => _PauseDialogState();
}

class _PauseDialogState extends ConsumerState<_PauseDialog> {
  Future<bool> _confirm(String title, String body, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(action))],
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    return AlertDialog(
      title: const Text('Paused', textAlign: TextAlign.center),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.check_circle_rounded, size: 16, color: AppTokens.success),
          const SizedBox(width: 5),
          Text('Your progress is saved', style: context.text.bodySmall),
        ]),
        const SizedBox(height: 8),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Music'), value: s.musicOn, onChanged: (v) {
          n.update(s.copyWith(musicOn: v));
          ref.read(audioProvider).refresh();
        }),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Sound effects'), value: s.soundOn, onChanged: (v) => n.update(s.copyWith(soundOn: v))),
        const SizedBox(height: 8),
        PrimaryButton(label: 'Resume', icon: Icons.play_arrow_rounded, onPressed: () => Navigator.pop(context, 'resume')),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            final nav = Navigator.of(context);
            if (await _confirm('Restart puzzle?', 'Your placed pieces will be cleared.', 'Restart')) nav.pop('restart');
          },
          child: const Text('Restart'),
        ),
        const SizedBox(height: 6),
        OutlinedButton(onPressed: () => Navigator.pop(context, 'exit'), child: const Text('Save and exit')),
      ]),
    );
  }
}
