import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../geometry/jigsaw_geometry.dart';

/// Converts a geometry edge list to a Flutter path in board coordinates.
Path pathForPiece(PieceShape p) {
  final path = Path()..moveTo(p.edges.first.start.x, p.edges.first.start.y);
  for (final e in p.edges) {
    if (e.isFlat) {
      path.lineTo(e.end.x, e.end.y);
    } else {
      for (final s in e.segments) {
        path.cubicTo(s.c1.x, s.c1.y, s.c2.x, s.c2.y, s.end.x, s.end.y);
      }
    }
  }
  return path..close();
}

/// Decodes an asset at its native size. The engine decodes off the UI thread.
Future<ui.Image> loadAssetImage(String asset) async {
  final data = await rootBundle.load(asset);
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  final frame = await codec.getNextFrame();
  codec.dispose();
  return frame.image;
}

/// All piece textures packed into a single image.
///
/// One texture means placed pieces draw in a single atlas call whatever the
/// piece count, and the rasterising happens on the raster thread via
/// `toImage`, so a 500-piece load never stalls the UI thread.
class PieceAtlas {
  PieceAtlas._(this.geometry, this.image, this.baseImage, this._rects, this.paths);

  final JigsawGeometry geometry;
  final ui.Image image;

  /// Empty board: a faint guide image plus every cut line.
  final ui.Image baseImage;
  final List<Rect> _rects;
  final List<Path> paths;

  Rect rectOf(int id) => _rects[id];

  /// Board position of the texture's top-left corner.
  Offset boardOrigin(int id) {
    final p = geometry.pieces[id];
    return Offset(p.left - geometry.tabPad, p.top - geometry.tabPad);
  }

  void dispose() {
    image.dispose();
    baseImage.dispose();
  }

  static Future<PieceAtlas> build(ui.Image src, JigsawGeometry g, Color boardColor) async {
    final pad = g.tabPad;
    final stepX = g.cellWidth + pad * 2, stepY = g.cellHeight + pad * 2;
    final atlasW = (g.spec.cols * stepX).ceil(), atlasH = (g.spec.rows * stepY).ceil();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final shader = ui.ImageShader(src, TileMode.clamp, TileMode.clamp, Matrix4.identity().storage, filterQuality: FilterQuality.medium);
    final fill = Paint()..shader = shader..isAntiAlias = true;
    // A hairline of the image around each piece covers anti-aliasing seams.
    final overlap = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final shade = Paint()
      ..color = const Color(0x3A1C1420)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final light = Paint()
      ..color = const Color(0x40FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rects = <Rect>[];
    final paths = <Path>[];
    for (final p in g.pieces) {
      final x = p.col * stepX, y = p.row * stepY;
      final width = p.width + pad * 2, height = p.height + pad * 2;
      rects.add(Rect.fromLTWH(x, y, width, height));
      final path = pathForPiece(p);
      paths.add(path);
      canvas.save();
      canvas.translate(x + pad - p.left, y + pad - p.top);
      canvas.drawPath(path, overlap);
      canvas.drawPath(path, fill);
      canvas.drawPath(path.shift(const Offset(-.7, -.7)), light);
      canvas.drawPath(path, shade);
      canvas.restore();
    }
    final atlas = await recorder.endRecording().toImage(atlasW, atlasH);

    final base = ui.PictureRecorder();
    final c2 = Canvas(base);
    final size = Size(g.spec.width, g.spec.height);
    c2.drawRect(Offset.zero & size, Paint()..color = boardColor);
    c2.drawImageRect(src, Rect.fromLTWH(0, 0, src.width.toDouble(), src.height.toDouble()), Offset.zero & size, Paint()..color = const Color(0x2EFFFFFF));
    final cuts = Path();
    for (final e in g.seams) {
      cuts.moveTo(e.start.x, e.start.y);
      for (final s in e.segments) {
        cuts.cubicTo(s.c1.x, s.c1.y, s.c2.x, s.c2.y, s.end.x, s.end.y);
      }
    }
    c2.drawPath(cuts, Paint()..color = const Color(0x55786E86)..style = PaintingStyle.stroke..strokeWidth = 1.4);
    final baseImage = await base.endRecording().toImage(size.width.ceil(), size.height.ceil());
    return PieceAtlas._(g, atlas, baseImage, rects, paths);
  }

  /// Packed transform and source arrays for [Canvas.drawRawAtlas].
  (Float32List, Float32List) spriteData(Iterable<int> ids) {
    final list = ids.toList(growable: false);
    final transforms = Float32List(list.length * 4);
    final rects = Float32List(list.length * 4);
    for (var i = 0; i < list.length; i++) {
      final o = boardOrigin(list[i]);
      final r = _rects[list[i]];
      transforms[i * 4] = 1;
      transforms[i * 4 + 1] = 0;
      transforms[i * 4 + 2] = o.dx;
      transforms[i * 4 + 3] = o.dy;
      rects[i * 4] = r.left;
      rects[i * 4 + 1] = r.top;
      rects[i * 4 + 2] = r.right;
      rects[i * 4 + 3] = r.bottom;
    }
    return (transforms, rects);
  }
}
