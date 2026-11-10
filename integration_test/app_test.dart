import 'dart:io';
import 'dart:ui';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jigsaw_puzzle/app/app.dart';
import 'package:jigsaw_puzzle/app/router/app_router.dart';
import 'package:jigsaw_puzzle/core/database/app_database.dart';
import 'package:jigsaw_puzzle/core/services/app_services.dart';
import 'package:jigsaw_puzzle/data/levels/level_catalog.dart';
import 'package:jigsaw_puzzle/features/puzzle/controllers/puzzle_controller.dart';
import 'package:jigsaw_puzzle/features/puzzle/screens/game_screen.dart';
import 'package:jigsaw_puzzle/features/puzzle/widgets/board_widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const phase = String.fromEnvironment('PHASE', defaultValue: 'main');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  Future<void> wait(WidgetTester t, int ms) async {
    final end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await t.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> shot(WidgetTester t, String name) async {
    // ignore: avoid_print
    print('SHOT $name');
    await wait(t, 1500);
  }

  Finder boardFinder() => find.byWidgetPredicate((w) => w is CustomPaint && w.painter is BoardPainter);
  PuzzleController controller(WidgetTester t) => (t.widget<CustomPaint>(boardFinder()).painter! as BoardPainter).c;

  Future<PuzzleController> waitForBoard(WidgetTester t) async {
    final sw = Stopwatch()..start();
    while (boardFinder().evaluate().isEmpty) {
      if (sw.elapsed.inSeconds > 60) fail('board never loaded');
      await t.pump(const Duration(milliseconds: 16));
    }
    await wait(t, 200);
    return controller(t);
  }

  /// A genuine finger drag: up out of the tray, across, and release.
  Future<void> dragPiece(WidgetTester t, PuzzleController c, int id, Offset boardPoint) async {
    final tile = find.byKey(ValueKey('piece-$id'));
    final gesture = await t.startGesture(t.getCenter(tile));
    await t.pump(const Duration(milliseconds: 16));
    final origin = t.getTopLeft(boardFinder());
    final target = origin + c.view.value.toScreen(boardPoint) + const Offset(0, 62);
    await gesture.moveBy(const Offset(0, -40));
    await t.pump(const Duration(milliseconds: 16));
    final start = t.getCenter(tile) + const Offset(0, -40);
    for (var i = 1; i <= 6; i++) {
      await gesture.moveTo(Offset.lerp(start, target, i / 6)!);
      await t.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await t.pump(const Duration(milliseconds: 32));
  }

  Future<ProviderContainer> boot(WidgetTester t, AppDatabase db) async {
    SharedPreferences.setMockInitialValues({'onboarded': true, 'musicOn': false});
    final prefs = await SharedPreferences.getInstance();
    final catalog = await LevelCatalog.load();
    await t.pumpWidget(ProviderScope(overrides: [prefsProvider.overrideWithValue(prefs), catalogProvider.overrideWithValue(catalog), databaseProvider.overrideWithValue(db)], child: const EasterJigsawApp()));
    await wait(t, 2000);
    return ProviderScope.containerOf(t.element(find.byType(EasterJigsawApp)));
  }

  Future<File> dbFile() async => File(p.join((await getApplicationDocumentsDirectory()).path, 'kill_test.sqlite'));

  if (phase == 'kill1') {
    testWidgets('place pieces, then the process dies', (t) async {
      final f = await dbFile();
      if (f.existsSync()) f.deleteSync();
      final container = await boot(t, AppDatabase(NativeDatabase(f)));
      final setup = PuzzleSetup.campaign(container.read(catalogProvider).level(120));
      container.read(routerProvider).push('/play', extra: PlayArgs(setup));
      await wait(t, 500);
      final c = await waitForBoard(t);
      for (var i = 0; i < 3; i++) {
        final id = c.session.tray.first;
        final s = c.session.piece(id);
        c.centerOn(Offset(s.centerX, s.centerY));
        await t.pump(const Duration(milliseconds: 32));
        await dragPiece(t, c, id, Offset(s.centerX, s.centerY));
        await wait(t, 150);
      }
      c.zoomBy(1.5);
      await wait(t, 1200); // timer ticks, and the last save reaches disk
      expect(c.session.placed.length, 3);
      // ignore: avoid_print
      print('KILL1 placed=${c.session.placed.toList()..sort()} elapsed=${c.session.elapsedSeconds}');
      await c.save();
      await wait(t, 400);
      exit(0); // no navigation, dispose or clean shutdown
    });
    return;
  }

  if (phase == 'kill2') {
    testWidgets('relaunch restores the puzzle', (t) async {
      final f = await dbFile();
      expect(f.existsSync(), isTrue);
      final container = await boot(t, AppDatabase(NativeDatabase(f)));
      final setup = PuzzleSetup.campaign(container.read(catalogProvider).level(120));
      container.read(routerProvider).push('/play', extra: PlayArgs(setup));
      await wait(t, 500);
      final c = await waitForBoard(t);
      // ignore: avoid_print
      print('KILL2 placed=${c.session.placed.toList()..sort()} elapsed=${c.session.elapsedSeconds} zoom=${c.zoom}');
      expect(c.session.placed.length, 3);
      expect(c.session.tray.length, setup.spec.pieceCount - 3);
      expect(c.session.elapsedSeconds, greaterThan(0));
      expect(c.zoom, greaterThan(1));
      await shot(t, 'restored');
    });
    return;
  }

  testWidgets('full journey on real assets', (t) async {
    final db = AppDatabase(NativeDatabase.memory());
    final container = await boot(t, db);
    final catalog = container.read(catalogProvider);
    final router = container.read(routerProvider);
    expect(router.routeInformationProvider.value.uri.path, '/home');
    await shot(t, 'home');

    await t.tap(find.text('Explore'));
    await wait(t, 700);
    await shot(t, 'explore');
    await t.tap(find.byKey(const ValueKey('collection-palm_sunday')));
    await wait(t, 900);
    await shot(t, 'collection');

    // A locked level must not offer Start.
    router.push('/level/2');
    await wait(t, 700);
    expect(find.byKey(const ValueKey('start')), findsNothing);
    expect(find.textContaining('Complete Level 1'), findsOneWidget);
    await shot(t, 'locked');
    router.pop();
    await wait(t, 400);

    router.push('/level/1');
    await wait(t, 800);
    await shot(t, 'preview');
    await t.tap(find.byKey(const ValueKey('start')));
    await wait(t, 400);
    var c = await waitForBoard(t);
    expect(c.session.total, 10);
    await shot(t, 'game_start');

    // Wrong drop goes back to the tray.
    final wrongId = c.session.tray.first;
    final wrongTarget = c.session.geometry.pieces.reduce((a, b) {
      final me = c.session.piece(wrongId);
      double d(q) => (q.centerX - me.centerX).abs() + (q.centerY - me.centerY).abs();
      return d(a) > d(b) ? a : b;
    });
    await dragPiece(t, c, wrongId, Offset(wrongTarget.centerX, wrongTarget.centerY));
    await wait(t, 500);
    expect(c.session.placed, isEmpty);
    expect(c.session.tray, contains(wrongId));
    expect(c.drag.value, isNull);

    // Hint highlights but never places.
    await t.tap(find.text('Hint'));
    await wait(t, 500);
    expect(c.hintTarget.value, isNotNull);
    expect(c.session.placed, isEmpty);
    await shot(t, 'hint');

    var placedSoFar = 0;
    while (c.session.tray.length > 1) {
      final id = c.session.tray.first;
      final s = c.session.piece(id);
      await dragPiece(t, c, id, Offset(s.centerX + 8, s.centerY - 6));
      placedSoFar++;
      await wait(t, 120);
      expect(c.session.placed.length, placedSoFar);
      if (placedSoFar == 5) await shot(t, 'game_mid');
    }
    expect(find.byKey(const ValueKey('remaining-label')), findsOneWidget);
    final last = c.session.tray.first;
    final s = c.session.piece(last);
    await dragPiece(t, c, last, Offset(s.centerX, s.centerY));
    await wait(t, 2000);
    expect(find.byKey(const ValueKey('complete-title')), findsOneWidget);
    await wait(t, 1500);
    await shot(t, 'complete');

    final coins = (await db.select(db.playerProfiles).get()).single.totalCoins;
    expect(coins, 20);
    expect((await db.select(db.puzzleProgress).get()).single.bestStars, 2, reason: 'one hint means 2 stars');

    await t.tap(find.byKey(const ValueKey('next-puzzle')));
    await wait(t, 900);
    expect(find.byKey(const ValueKey('start')), findsOneWidget, reason: 'level 2 is now open');
    router.go('/daily');
    await wait(t, 900);
    await shot(t, 'daily');
    router.push('/settings');
    await wait(t, 700);
    await t.ensureVisible(find.byKey(const ValueKey('theme-ocean_breeze')));
    await wait(t, 300);
    await t.tap(find.byKey(const ValueKey('theme-ocean_breeze')));
    await wait(t, 500);
    expect(container.read(settingsProvider).themeId, 'ocean_breeze');
    await shot(t, 'settings');
    router.pop();
    await wait(t, 700);
    await t.tap(find.text('Profile'));
    await wait(t, 700);
    await shot(t, 'profile');

    // Performance on each piece count: load, then scripted drag, pan and zoom.
    final results = <String>[];
    for (final level in const [10, 50, 100, 250, 500]) {
      final setup = PuzzleSetup.campaign(catalog.level(level));
      final sw = Stopwatch()..start();
      router.push('/play', extra: PlayArgs(setup));
      await t.pump();
      final ctl = await waitForBoard(t);
      final loadMs = sw.elapsedMilliseconds;
      expect(ctl.session.total, level);
      final timings = <FrameTiming>[];
      void cb(List<FrameTiming> l) => timings.addAll(l);
      SchedulerBinding.instance.addTimingsCallback(cb);
      for (var i = 0; i < 5; i++) {
        final id = ctl.session.tray.first;
        final sh = ctl.session.piece(id);
        ctl.centerOn(Offset(sh.centerX, sh.centerY));
        await t.pump(const Duration(milliseconds: 32));
        await dragPiece(t, ctl, id, Offset(sh.centerX, sh.centerY));
        await wait(t, 60);
      }
      expect(ctl.session.placed.length, 5);
      for (var i = 0; i < 90; i++) {
        ctl.scaleStart();
        ctl.scaleUpdate(1 + (i % 30) / 60, const Offset(180, 200), Offset.zero);
        ctl.centerOn(Offset(800 + 300.0 * (i % 7 - 3), 600 + 200.0 * (i % 5 - 2)));
        await t.pump(const Duration(milliseconds: 16));
      }
      await wait(t, 400);
      SchedulerBinding.instance.removeTimingsCallback(cb);
      double avg(Iterable<int> v) => v.isEmpty ? 0 : v.reduce((a, b) => a + b) / v.length / 1000;
      final ui = timings.map((e) => e.buildDuration.inMicroseconds).toList()..sort();
      final raster = timings.map((e) => e.rasterDuration.inMicroseconds).toList()..sort();
      int p95(List<int> l) => l.isEmpty ? 0 : l[(l.length * .95).floor().clamp(0, l.length - 1)];
      results.add('BENCH $level pieces: load ${loadMs}ms, frames ${timings.length}, ui avg ${avg(ui).toStringAsFixed(1)}ms p95 ${(p95(ui) / 1000).toStringAsFixed(1)}ms, raster avg ${avg(raster).toStringAsFixed(1)}ms p95 ${(p95(raster) / 1000).toStringAsFixed(1)}ms');
      if (level == 500) {
        ctl.fit();
        await wait(t, 200);
        ctl.zoomBy(2.6);
        await shot(t, 'game_500');
      }
      router.pop();
      await wait(t, 300);
    }
    // ignore: avoid_print
    results.forEach(print);
  });
}
