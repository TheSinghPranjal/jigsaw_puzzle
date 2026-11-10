import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../controllers/puzzle_controller.dart';

class BoardPainter extends CustomPainter {
  BoardPainter(this.c, this.pulse, this.tokens) : super(repaint: Listenable.merge([c.view, c.boardVersion, c.hintTarget, pulse]));

  final PuzzleController c;
  final Animation<double> pulse;
  final AppTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final v = c.view.value;
    final boardRect = Rect.fromLTWH(0, 0, c.boardW, c.boardH);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(v.tx, v.ty);
    canvas.scale(v.scale);
    canvas.drawRRect(RRect.fromRectAndRadius(boardRect.inflate(14 / v.scale), Radius.circular(18 / v.scale)), Paint()..color = tokens.card);
    canvas.drawImage(c.atlas.baseImage, Offset.zero, Paint()..filterQuality = FilterQuality.medium);
    if (c.placedTransforms.isNotEmpty) {
      canvas.drawRawAtlas(c.atlas.image, c.placedTransforms, c.placedRects, null, null, null, Paint()..filterQuality = FilterQuality.medium);
    }
    final last = c.lastPlaced;
    if (last != null && pulse.status != AnimationStatus.dismissed && c.hintTarget.value == null) {
      canvas.drawPath(c.atlas.paths[last], Paint()
        ..color = AppTokens.success.withValues(alpha: (1 - pulse.value).clamp(0, 1))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5 / v.scale);
    }
    final hint = c.hintTarget.value;
    if (hint != null) {
      final path = c.atlas.paths[hint];
      final a = .35 + .4 * math.sin(pulse.value * math.pi);
      canvas.drawPath(path, Paint()..color = AppTokens.gold.withValues(alpha: a * .55));
      canvas.drawPath(path, Paint()
        ..color = AppTokens.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 / v.scale);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(BoardPainter old) => old.c != c || old.tokens != tokens;
}

/// The single piece under the finger, on its own layer.
class DragPainter extends CustomPainter {
  DragPainter(this.c) : super(repaint: c.drag);
  final PuzzleController c;

  @override
  void paint(Canvas canvas, Size size) {
    final d = c.drag.value;
    if (d == null) return;
    final r = c.atlas.rectOf(d.id);
    final w = r.width * d.scale, h = r.height * d.scale;
    final rot = c.session.rotationOf(d.id);
    canvas.save();
    canvas.translate(d.center.dx, d.center.dy);
    if (rot != 0) canvas.rotate(rot * math.pi / 2);
    final dst = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    canvas.drawRect(dst.deflate(w * .18).shift(const Offset(3, 10)), Paint()
      ..color = const Color(0x55201830)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
    canvas.drawImageRect(c.atlas.image, r, dst, Paint()
      ..color = Color.fromRGBO(255, 255, 255, d.opacity)
      ..filterQuality = FilterQuality.medium);
    if (d.wrong) {
      canvas.drawRRect(RRect.fromRectAndRadius(dst.deflate(w * .16), const Radius.circular(10)), Paint()
        ..color = AppTokens.danger.withValues(alpha: d.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(DragPainter old) => old.c != c;
}

class PieceTilePainter extends CustomPainter {
  PieceTilePainter(this.image, this.src, this.rotation);
  final ui.Image image;
  final Rect src;
  final int rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / src.width, size.height / src.height);
    canvas.translate(size.width / 2, size.height / 2);
    if (rotation != 0) canvas.rotate(rotation * math.pi / 2);
    canvas.drawImageRect(image, src, Rect.fromCenter(center: Offset.zero, width: src.width * s, height: src.height * s), Paint()..filterQuality = FilterQuality.medium);
  }

  @override
  bool shouldRepaint(PieceTilePainter old) => old.src != src || old.rotation != rotation || old.image != image;
}

/// Lazy horizontal list; only pieces near the viewport are built.
class PieceTray extends StatelessWidget {
  const PieceTray({super.key, required this.c, required this.onDragStart, required this.onDragUpdate, required this.onDragEnd, required this.onTapPiece});

  final PuzzleController c;
  final void Function(int id, Offset global) onDragStart;
  final void Function(Offset global) onDragUpdate;
  final VoidCallback onDragEnd;
  final void Function(int id) onTapPiece;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ValueListenableBuilder(
      valueListenable: c.trayVersion,
      builder: (context, _, _) {
        final ids = c.session.visibleTray(edgesOnly: c.edgesOnly.value);
        if (ids.isEmpty) {
          return Center(child: Text(c.session.tray.isEmpty ? 'All pieces placed!' : 'No edge pieces left. Turn off the filter to see the rest.', style: context.text.bodySmall, textAlign: TextAlign.center));
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: ids.length,
          itemExtent: 82,
          itemBuilder: (context, i) {
            final id = ids[i];
            return GestureDetector(
              key: ValueKey('piece-$id'),
              behavior: HitTestBehavior.opaque,
              onTap: () => onTapPiece(id),
              onVerticalDragStart: (d) => onDragStart(id, d.globalPosition),
              onVerticalDragUpdate: (d) => onDragUpdate(d.globalPosition),
              onVerticalDragEnd: (_) => onDragEnd(),
              onVerticalDragCancel: onDragEnd,
              child: ValueListenableBuilder(
                valueListenable: c.selected,
                builder: (context, sel, child) => AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                  decoration: BoxDecoration(
                    color: sel == id ? t.selected : t.card,
                    borderRadius: BorderRadius.circular(AppTokens.radiusS),
                    border: Border.all(color: sel == id ? t.primary : t.border, width: sel == id ? 2 : 1),
                  ),
                  child: child,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: CustomPaint(painter: PieceTilePainter(c.atlas.image, c.atlas.rectOf(id), c.session.rotationOf(id))),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
