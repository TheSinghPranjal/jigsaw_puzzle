import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/common.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final audio = ref.read(audioProvider);
    final t = context.tokens;
    Widget heading(String text) => Padding(padding: const EdgeInsets.fromLTRB(4, 18, 4, 8), child: Text(text, style: context.text.titleLarge));
    void music(AppSettings next) {
      n.update(next);
      audio.refresh();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 28), children: [
        heading('Theme'),
        SizedBox(
          height: 96,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final p in themePalettes)
              GestureDetector(
                key: ValueKey('theme-${p.id}'),
                onTap: () => n.update(s.copyWith(themeId: p.id)),
                child: Container(
                  width: 112,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: p.background, borderRadius: BorderRadius.circular(AppTokens.radiusM), border: Border.all(color: s.themeId == p.id ? t.primary : t.border, width: s.themeId == p.id ? 2.5 : 1)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [for (final c in [p.primary, p.secondary, p.accent]) Container(width: 18, height: 18, margin: const EdgeInsets.only(right: 3), decoration: BoxDecoration(color: c, shape: BoxShape.circle))]),
                    const Spacer(),
                    Text(p.name, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 12, color: p.text)),
                  ]),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 10),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [ButtonSegment(value: 'light', label: Text('Light')), ButtonSegment(value: 'dark', label: Text('Dark')), ButtonSegment(value: 'system', label: Text('System'))],
          selected: {s.mode},
          onSelectionChanged: (v) => n.update(s.copyWith(mode: v.first)),
        ),
        heading('Sound'),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Column(children: [
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Music'), value: s.musicOn, onChanged: (v) => music(s.copyWith(musicOn: v))),
            Slider(value: s.musicVolume, onChanged: s.musicOn ? (v) => music(s.copyWith(musicVolume: v)) : null),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Sound effects'), value: s.soundOn, onChanged: (v) => n.update(s.copyWith(soundOn: v))),
            Slider(value: s.soundVolume, onChanged: s.soundOn ? (v) => n.update(s.copyWith(soundVolume: v)) : null),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Haptics'), value: s.haptics, onChanged: (v) => n.update(s.copyWith(haptics: v))),
          ]),
        ),
        heading('Gameplay'),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Column(children: [
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Show timer'), value: s.showTimer, onChanged: (v) => n.update(s.copyWith(showTimer: v))),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Rotation challenge'), subtitle: const Text('Pieces start turned. Applies to new puzzles.'), value: s.rotation, onChanged: (v) => n.update(s.copyWith(rotation: v))),
          ]),
        ),
        heading('More'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            const ListTile(leading: Icon(Icons.language_rounded), title: Text('Language'), trailing: Text('English')),
            for (final (icon, label, route) in const [(Icons.privacy_tip_rounded, 'Privacy', 'privacy'), (Icons.help_rounded, 'Help and support', 'help'), (Icons.info_rounded, 'About', 'about')])
              ListTile(leading: Icon(icon), title: Text(label), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => context.push('/info/$route')),
          ]),
        ),
      ]),
    );
  }
}

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.kind});
  final String kind;

  @override
  Widget build(BuildContext context) {
    final (title, body) = switch (kind) {
      'privacy' => ('Privacy', 'Easter Jigsaw Journey needs no account and sends nothing to a server. Your progress, favorites and coins stay on this device.\n\nPhoto access is requested only when you choose to save a finished picture.'),
      'help' => ('Help and support', 'Drag a piece up from the tray and drop it where it belongs. It snaps in when it is close enough.\n\nPinch to zoom, drag the board to move around, and double-tap to zoom in.\n\nTap a piece and press Hint to see where it goes. Puzzles finished without hints earn three stars.\n\nYour puzzle saves after every piece, so you can leave at any time.'),
      _ => ('About', 'Easter Jigsaw Journey\nVersion 1.0.0\n\nAll artwork and music in this game are original and were generated for it.'),
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(padding: const EdgeInsets.all(20), children: [AppCard(child: Text(body, style: context.text.bodyLarge?.copyWith(height: 1.45)))]),
    );
  }
}
