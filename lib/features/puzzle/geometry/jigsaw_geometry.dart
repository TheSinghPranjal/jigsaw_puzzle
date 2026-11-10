import 'dart:math' as math;

/// Small seeded generator, so a seed produces identical puzzles on every
/// platform and Dart version (`dart:math` Random makes no such promise).
class SeededRandom {
  SeededRandom(int seed) : _state = seed & 0xffffffff;
  int _state;

  double nextDouble() {
    _state = (_state + 0x6D2B79F5) & 0xffffffff;
    var t = _state;
    t = _imul(t ^ (t >>> 15), t | 1);
    t ^= (t + _imul(t ^ (t >>> 7), t | 61)) & 0xffffffff;
    return ((t ^ (t >>> 14)) & 0xffffffff) / 4294967296.0;
  }

  double range(double a, double b) => a + (b - a) * nextDouble();
  int nextInt(int max) => (nextDouble() * max).floor();
  bool nextBool() => nextDouble() < .5;

  static int _imul(int a, int b) => (a * b) & 0xffffffff;
}

class Pt {
  const Pt(this.x, this.y);
  final double x, y;
  @override
  bool operator ==(Object other) => other is Pt && other.x == x && other.y == y;
  @override
  int get hashCode => Object.hash(x, y);
  @override
  String toString() => '($x, $y)';
}

class Cubic {
  const Cubic(this.c1, this.c2, this.end);
  final Pt c1, c2, end;
}

/// One side of a piece. A straight outer edge has no [segments].
class EdgeCurve {
  const EdgeCurve(this.start, this.end, this.segments);
  final Pt start, end;
  final List<Cubic> segments;

  bool get isFlat => segments.isEmpty;

  /// The same boundary walked the other way. Neighbouring pieces use one curve
  /// each way round, which is what makes them fit exactly.
  EdgeCurve get reversed {
    final out = <Cubic>[];
    for (var i = segments.length - 1; i >= 0; i--) {
      final s = segments[i];
      out.add(Cubic(s.c2, s.c1, i == 0 ? start : segments[i - 1].end));
    }
    return EdgeCurve(end, start, out);
  }

  /// Sample points along the edge, including both ends.
  List<Pt> flatten([int perSegment = 16]) {
    if (isFlat) return [start, end];
    final out = <Pt>[start];
    var p0 = start;
    for (final s in segments) {
      for (var i = 1; i <= perSegment; i++) {
        final t = i / perSegment, u = 1 - t;
        final a = u * u * u, b = 3 * u * u * t, c = 3 * u * t * t, d = t * t * t;
        out.add(Pt(a * p0.x + b * s.c1.x + c * s.c2.x + d * s.end.x, a * p0.y + b * s.c1.y + c * s.c2.y + d * s.end.y));
      }
      p0 = s.end;
    }
    return out;
  }
}

/// Everything needed to rebuild a puzzle exactly. Stored per level.
class PuzzleSpec {
  const PuzzleSpec({
    required this.rows,
    required this.cols,
    required this.seed,
    required this.width,
    required this.height,
    this.merges = const [],
  });

  final int rows, cols, seed;
  final double width, height;

  /// `[row, col]` pairs: that cell is joined with the cell to its right.
  final List<List<int>> merges;

  int get pieceCount => rows * cols - merges.length;
}

class PieceShape {
  const PieceShape({
    required this.id,
    required this.row,
    required this.col,
    required this.span,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.edges,
    required this.isBorder,
    required this.neighbors,
  });

  final int id, row, col;

  /// 1, or 2 for a piece covering two cells side by side.
  final int span;
  final double left, top, width, height;

  /// Clockwise boundary starting at the top-left corner.
  final List<EdgeCurve> edges;
  final bool isBorder;
  final List<int> neighbors;

  double get centerX => left + width / 2;
  double get centerY => top + height / 2;
}

/// Pure geometry: no Flutter imports, so it is fully unit-testable.
class JigsawGeometry {
  JigsawGeometry._(this.spec, this.pieces, this.cellWidth, this.cellHeight, this.tabPad, this._h, this._v);

  final PuzzleSpec spec;
  final List<PieceShape> pieces;
  final double cellWidth, cellHeight;

  /// How far any tab can reach outside a cell. Texture padding uses this.
  final double tabPad;

  final List<List<EdgeCurve?>> _h, _v;

  /// Interior seams only. Used to draw empty-board outlines in one stroke.
  Iterable<EdgeCurve> get seams sync* {
    for (final row in _h) {
      for (final e in row) {
        if (e != null && !e.isFlat) yield e;
      }
    }
    for (final row in _v) {
      for (final e in row) {
        if (e != null && !e.isFlat) yield e;
      }
    }
  }

  static JigsawGeometry generate(PuzzleSpec spec) {
    final rows = spec.rows, cols = spec.cols;
    final cw = spec.width / cols, ch = spec.height / rows;
    final unit = math.min(cw, ch);
    final rnd = SeededRandom(spec.seed);

    // Merged cells: (row, col) joined with (row, col + 1).
    final mergeRight = <int>{for (final m in spec.merges) m[0] * cols + m[1]};
    bool merged(int r, int c) => mergeRight.contains(r * cols + c);

    // _h[r][c]: top side of cell (r, c), running left to right.
    final h = List.generate(rows + 1, (r) {
      return List<EdgeCurve?>.generate(cols, (c) {
        final a = Pt(c * cw, r * ch), b = Pt((c + 1) * cw, r * ch);
        if (r == 0 || r == rows) return EdgeCurve(a, b, const []);
        return _seam(a, b, unit, rnd);
      });
    });
    // _v[r][c]: left side of cell (r, c), running top to bottom. Null when merged away.
    final v = List.generate(rows, (r) {
      return List<EdgeCurve?>.generate(cols + 1, (c) {
        final a = Pt(c * cw, r * ch), b = Pt(c * cw, (r + 1) * ch);
        if (c == 0 || c == cols) return EdgeCurve(a, b, const []);
        if (merged(r, c - 1)) return null;
        return _seam(a, b, unit, rnd);
      });
    });

    final ids = List.generate(rows, (_) => List<int>.filled(cols, -1));
    final cells = <List<int>>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (c > 0 && merged(r, c - 1)) {
          ids[r][c] = ids[r][c - 1];
          continue;
        }
        ids[r][c] = cells.length;
        cells.add([r, c]);
      }
    }

    final pieces = <PieceShape>[];
    for (final cell in cells) {
      final r = cell[0], c = cell[1];
      final span = merged(r, c) ? 2 : 1;
      final tops = [for (var i = 0; i < span; i++) h[r][c + i]!];
      final bottoms = [for (var i = span - 1; i >= 0; i--) h[r + 1][c + i]!.reversed];
      final edges = <EdgeCurve>[...tops, v[r][c + span]!, ...bottoms, v[r][c]!.reversed];
      final near = <int>{};
      void add(int rr, int cc) {
        if (rr >= 0 && rr < rows && cc >= 0 && cc < cols && ids[rr][cc] != ids[r][c]) near.add(ids[rr][cc]);
      }

      for (var i = 0; i < span; i++) {
        add(r - 1, c + i);
        add(r + 1, c + i);
      }
      add(r, c - 1);
      add(r, c + span);
      pieces.add(PieceShape(
        id: ids[r][c],
        row: r,
        col: c,
        span: span,
        left: c * cw,
        top: r * ch,
        width: cw * span,
        height: ch,
        edges: edges,
        isBorder: r == 0 || r == rows - 1 || c == 0 || c + span == cols,
        neighbors: near.toList()..sort(),
      ));
    }
    return JigsawGeometry._(spec, pieces, cw, ch, unit * _maxReach, h, v);
  }

  /// Largest normal offset a control point can have, as a fraction of [unit],
  /// plus a little breathing room for strokes.
  static const double _maxReach = .36;

  static EdgeCurve _seam(Pt a, Pt b, double unit, SeededRandom rnd) {
    final dx = b.x - a.x, dy = b.y - a.y;
    final len = math.sqrt(dx * dx + dy * dy);
    final ux = dx / len, uy = dy / len;
    final nx = -uy, ny = ux;
    final flip = rnd.nextBool() ? 1.0 : -1.0;

    // A knob near the middle of the edge, sized to the shorter cell side so
    // narrow cells still get well-formed tabs.
    final t = rnd.range(.082, .098);
    final centre = rnd.range(.44, .56) * len;
    final lift = rnd.range(-.012, .012);
    final skew = rnd.range(-.016, .016);

    Pt p(double along, double normal) {
      final n = normal * unit * flip;
      return Pt(a.x + ux * along + nx * n, a.y + uy * along + ny * n);
    }

    double knob(double k) => centre + k * unit;

    final segments = [
      Cubic(p(len * .2, 0), p(knob(skew), -t + lift), p(knob(-t), t + lift)),
      Cubic(p(knob(-2 * t - skew), 3 * t + lift), p(knob(2 * t - skew), 3 * t + lift), p(knob(t), t + lift)),
      Cubic(p(knob(skew), -t + lift), p(len * .8, 0), b),
    ];
    return EdgeCurve(a, b, segments);
  }
}
