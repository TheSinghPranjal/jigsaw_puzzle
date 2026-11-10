import 'dart:io';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart';
import '../../data/levels/level_catalog.dart';
import '../../data/repositories/game_repository.dart';

class AppSettings {
  const AppSettings({
    this.onboarded = false,
    this.themeId = 'easter_pastel',
    this.mode = 'light',
    this.musicOn = true,
    this.soundOn = true,
    this.musicVolume = .5,
    this.soundVolume = .8,
    this.haptics = true,
    this.showTimer = true,
    this.rotation = false,
    this.showGuide = true,
  });

  final bool onboarded, musicOn, soundOn, haptics, showTimer, rotation, showGuide;
  final String themeId, mode;
  final double musicVolume, soundVolume;

  AppSettings copyWith({bool? onboarded, String? themeId, String? mode, bool? musicOn, bool? soundOn, double? musicVolume, double? soundVolume, bool? haptics, bool? showTimer, bool? rotation, bool? showGuide}) => AppSettings(
        onboarded: onboarded ?? this.onboarded,
        themeId: themeId ?? this.themeId,
        mode: mode ?? this.mode,
        musicOn: musicOn ?? this.musicOn,
        soundOn: soundOn ?? this.soundOn,
        musicVolume: musicVolume ?? this.musicVolume,
        soundVolume: soundVolume ?? this.soundVolume,
        haptics: haptics ?? this.haptics,
        showTimer: showTimer ?? this.showTimer,
        rotation: rotation ?? this.rotation,
        showGuide: showGuide ?? this.showGuide,
      );
}

class SettingsNotifier extends Notifier<AppSettings> {
  late SharedPreferences _prefs;

  @override
  AppSettings build() {
    _prefs = ref.watch(prefsProvider);
    return AppSettings(
      onboarded: _prefs.getBool('onboarded') ?? false,
      themeId: _prefs.getString('themeId') ?? 'easter_pastel',
      mode: _prefs.getString('mode') ?? 'light',
      musicOn: _prefs.getBool('musicOn') ?? true,
      soundOn: _prefs.getBool('soundOn') ?? true,
      musicVolume: _prefs.getDouble('musicVolume') ?? .5,
      soundVolume: _prefs.getDouble('soundVolume') ?? .8,
      haptics: _prefs.getBool('haptics') ?? true,
      showTimer: _prefs.getBool('showTimer') ?? true,
      rotation: _prefs.getBool('rotation') ?? false,
      showGuide: _prefs.getBool('showGuide') ?? true,
    );
  }

  void update(AppSettings next) {
    state = next;
    _prefs
      ..setBool('onboarded', next.onboarded)
      ..setString('themeId', next.themeId)
      ..setString('mode', next.mode)
      ..setBool('musicOn', next.musicOn)
      ..setBool('soundOn', next.soundOn)
      ..setDouble('musicVolume', next.musicVolume)
      ..setDouble('soundVolume', next.soundVolume)
      ..setBool('haptics', next.haptics)
      ..setBool('showTimer', next.showTimer)
      ..setBool('rotation', next.rotation)
      ..setBool('showGuide', next.showGuide);
  }
}

enum MusicTrack {
  menu('audio/music/menu_ambient.m4a'),
  puzzle('audio/music/calm_puzzle.m4a'),
  daily('audio/music/daily_puzzle.m4a');

  const MusicTrack(this.asset);
  final String asset;
}

enum Sfx {
  button('audio/sound_effects/button.m4a'),
  place('audio/sound_effects/piece_place.m4a'),
  correct('audio/sound_effects/piece_correct.m4a'),
  wrong('audio/sound_effects/piece_wrong.m4a'),
  victory('audio/sound_effects/victory.m4a'),
  reward('audio/sound_effects/reward.m4a');

  const Sfx(this.asset);
  final String asset;
}

/// Audio failures never reach gameplay; the game simply stays silent.
class AudioService {
  AudioService(this.read);
  final AppSettings Function() read;
  AudioPlayer? _music;
  final Map<Sfx, AudioPlayer> _sfx = {};
  MusicTrack? _track;
  bool _suspended = false;

  Future<void> play(MusicTrack track) async {
    _track = track;
    await _apply(restart: true);
  }

  /// Applies current settings; called whenever they change.
  Future<void> refresh() => _apply(restart: false);

  Future<void> suspend(bool value) async {
    _suspended = value;
    await _apply(restart: false);
  }

  Future<void> _apply({required bool restart}) async {
    try {
      final s = read();
      final track = _track;
      if (track == null || !s.musicOn || _suspended) {
        await _music?.pause();
        return;
      }
      final m = _music ??= AudioPlayer()..setReleaseMode(ReleaseMode.loop);
      await m.setVolume(s.musicVolume);
      if (restart || m.state != PlayerState.playing) {
        if (restart) await m.stop();
        await m.play(AssetSource(track.asset), volume: s.musicVolume);
      }
    } catch (e) {
      debugPrint('music unavailable: $e');
    }
  }

  Future<void> sfx(Sfx sound) async {
    try {
      final s = read();
      if (!s.soundOn) return;
      final pl = _sfx[sound] ??= AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
      await pl.stop();
      await pl.play(AssetSource(sound.asset), volume: s.soundVolume);
    } catch (e) {
      debugPrint('sound unavailable: $e');
    }
  }
}

/// Exports the original artwork itself, never a screenshot of the UI.
class ImageExporter {
  static Future<File> _exportPng(PuzzleLevel level) async {
    final data = await rootBundle.load(level.image);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final png = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    frame.image.dispose();
    codec.dispose();
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'easter_jigsaw_${level.imageId}.png'));
    return file.writeAsBytes(png!.buffer.asUint8List(), flush: true);
  }

  static Future<void> share(PuzzleLevel level) async {
    final f = await _exportPng(level);
    await SharePlus.instance.share(ShareParams(files: [XFile(f.path, mimeType: 'image/png')], text: level.title));
  }

  /// Returns null on success, or a message suitable for showing the player.
  static Future<String?> saveToPhotos(PuzzleLevel level) async {
    try {
      if (!await Gal.hasAccess(toAlbum: false) && !await Gal.requestAccess(toAlbum: false)) {
        return 'Allow photo access in Settings to save images.';
      }
      final f = await _exportPng(level);
      await Gal.putImage(f.path);
      return null;
    } on GalException catch (e) {
      return e.type.message;
    }
  }
}

final prefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('override at startup'));
final catalogProvider = Provider<LevelCatalog>((ref) => throw UnimplementedError('override at startup'));
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('override at startup'));
final repoProvider = Provider<GameRepository>((ref) => GameRepository(ref.watch(databaseProvider), ref.watch(catalogProvider)));
final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
final audioProvider = Provider<AudioService>((ref) => AudioService(() => ref.read(settingsProvider)));

final progressProvider = StreamProvider((ref) => ref.watch(repoProvider).watchProgress());
final favoritesProvider = StreamProvider((ref) => ref.watch(repoProvider).watchFavorites());
final activeProvider = StreamProvider((ref) => ref.watch(repoProvider).watchActive());
final coinsProvider = StreamProvider((ref) => ref.watch(repoProvider).watchCoins());
final profileProvider = StreamProvider((ref) => ref.watch(repoProvider).watchProfile());
final dailiesProvider = StreamProvider((ref) => ref.watch(repoProvider).watchDailies());
final historyProvider = StreamProvider((ref) => ref.watch(repoProvider).watchHistory());
final achievementsProvider = StreamProvider((ref) => ref.watch(repoProvider).watchAchievements());
final ledgerProvider = StreamProvider((ref) => ref.watch(repoProvider).watchLedger());
