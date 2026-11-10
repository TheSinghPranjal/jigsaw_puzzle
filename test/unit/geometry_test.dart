import 'package:flutter_test/flutter_test.dart';
import 'package:jigsaw_puzzle/features/puzzle/geometry/jigsaw_geometry.dart';

double polygonArea(List<Pt> pts) {
  var a = 0.0;
  for (var i = 0; i < pts.length; i++) {
    final p = pts[i], q = pts[(i + 1) % pts.length];
    a += p.x * q.y - q.x * p.y;
  }
  return a.abs() / 2;
}

List<Pt> outline(PieceShape p) => [for (final e in p.edges) ...e.flatten(40).sublist(1)];

void main() {
  const specs = [
    PuzzleSpec(rows: 2, cols: 5, seed: 7, width: 1600, height: 1200),
    PuzzleSpec(rows: 10, cols: 10, seed: 99, width: 1600, height: 1200),
    PuzzleSpec(rows: 20, cols: 25, seed: 3958, width: 1600, height: 1200),
    PuzzleSpec(rows: 19, cols: 25, seed: 12, width: 1600, height: 1200, merges: [[1, 3], [5, 8], [9, 2], [13, 20], [17, 11]]),
  ];

  for (final spec in specs) {
    group('${spec.rows}x${spec.cols} merges=${spec.merges.length}', () {
      final g = JigsawGeometry.generate(spec);

      test('makes exactly the requested number of pieces with unique ids', () {
        expect(g.pieces.length, spec.pieceCount);
        expect(g.pieces.map((p) => p.id).toSet().length, spec.pieceCount);
      });

      test('piece outlines are closed loops', () {
        for (final p in g.pieces) {
          for (var i = 0; i < p.edges.length; i++) {
            final next = p.edges[(i + 1) % p.edges.length];
            expect(p.edges[i].end, next.start);
          }
        }
      });

      test('areas sum to the board, so there are no gaps or overlaps', () {
        final total = g.pieces.fold<double>(0, (a, p) => a + polygonArea(outline(p)));
        expect(total, closeTo(spec.width * spec.height, spec.width * spec.height * 1e-3));
      });

      test('every shared edge is the exact reverse of its neighbour', () {
        final index = <String, EdgeCurve>{};
        String key(EdgeCurve e) => '${e.start}|${e.end}';
        for (final p in g.pieces) {
          for (final e in p.edges.where((e) => !e.isFlat)) {
            index[key(e)] = e;
          }
        }
        for (final e in index.values) {
          final twin = index['${e.end}|${e.start}'];
          expect(twin, isNotNull, reason: 'edge without a neighbour');
          final a = e.flatten(), b = twin!.flatten().reversed.toList();
          expect(a.length, b.length);
          for (var i = 0; i < a.length; i++) {
            expect(a[i].x, closeTo(b[i].x, 1e-6));
            expect(a[i].y, closeTo(b[i].y, 1e-6));
          }
        }
      });

      test('outer boundary is flat and interior edges have tabs', () {
        for (final p in g.pieces) {
          for (final e in p.edges) {
            final onBorder = (e.start.x == e.end.x && (e.start.x == 0 || e.start.x == spec.width)) || (e.start.y == e.end.y && (e.start.y == 0 || e.start.y == spec.height));
            expect(e.isFlat, onBorder);
          }
        }
      });

      test('tabs stay inside the texture padding', () {
        for (final p in g.pieces) {
          for (final q in outline(p)) {
            expect(q.x, inInclusiveRange(p.left - g.tabPad, p.left + p.width + g.tabPad));
            expect(q.y, inInclusiveRange(p.top - g.tabPad, p.top + p.height + g.tabPad));
          }
        }
      });

      test('same seed reproduces the same geometry', () {
        final again = JigsawGeometry.generate(spec);
        for (var i = 0; i < g.pieces.length; i++) {
          expect(again.pieces[i].edges.first.flatten(), g.pieces[i].edges.first.flatten());
          expect(again.pieces[i].edges[1].flatten(), g.pieces[i].edges[1].flatten());
        }
      });
    });
  }

  test('different seeds cut differently', () {
    final a = JigsawGeometry.generate(const PuzzleSpec(rows: 4, cols: 5, seed: 1, width: 1600, height: 1200));
    final b = JigsawGeometry.generate(const PuzzleSpec(rows: 4, cols: 5, seed: 2, width: 1600, height: 1200));
    expect(a.seams.first.flatten(), isNot(b.seams.first.flatten()));
  });

  test('benchmark: generating geometry', () {
    for (final (r, c) in const [(2, 5), (5, 10), (10, 10), (10, 25), (20, 25)]) {
      final sw = Stopwatch()..start();
      JigsawGeometry.generate(PuzzleSpec(rows: r, cols: c, seed: 5, width: 1600, height: 1200));
      // ignore: avoid_print
      print('geometry ${r * c} pieces: ${sw.elapsedMicroseconds / 1000} ms');
    }
  });
}
