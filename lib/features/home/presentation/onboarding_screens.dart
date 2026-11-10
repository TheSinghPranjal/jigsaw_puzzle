import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/common.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(audioProvider).play(MusicTrack.menu);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) context.go(ref.read(settingsProvider).onboarded ? '/home' : '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: .82, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutBack,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Image.asset('assets/branding/logo/logo.png', width: 150),
              const SizedBox(height: 14),
              Text('Easter Jigsaw', style: context.text.displaySmall),
              Text('Journey', style: context.text.headlineSmall?.copyWith(color: context.tokens.primary)),
            ]),
          ),
        ),
      );
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;
  static const _pages = 5;

  void _next() {
    if (_index == _pages - 1) {
      final n = ref.read(settingsProvider.notifier);
      n.update(ref.read(settingsProvider).copyWith(onboarded: true));
      context.go('/home');
    } else {
      _page.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final t = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView(
              controller: _page,
              onPageChanged: (i) => setState(() => _index = i),
              children: [
                const _IntroPage('assets/thumbnails/collections/spring.webp', 'A peaceful journey', 'Five hundred original scenes to piece together, at your own pace.'),
                const _IntroPage('assets/thumbnails/collections/resurrection.webp', 'Stories of Easter', 'Ten collections, from Palm Sunday to quiet spring mornings.'),
                _Page(
                  title: 'Pick a theme',
                  child: Column(children: [
                    for (final p in themePalettes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          onTap: () => n.update(s.copyWith(themeId: p.id)),
                          child: Row(children: [
                            for (final c in [p.primary, p.secondary, p.accent]) Container(width: 22, height: 22, margin: const EdgeInsets.only(right: 5), decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(p.name, style: context.text.titleMedium)),
                            if (s.themeId == p.id) Icon(Icons.check_circle_rounded, color: t.primary),
                          ]),
                        ),
                      ),
                  ]),
                ),
                _Page(
                  title: 'Music while you play?',
                  child: Column(children: [
                    SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Calm background music'), value: s.musicOn, onChanged: (v) {
                      n.update(s.copyWith(musicOn: v));
                      ref.read(audioProvider).refresh();
                    }),
                    SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Sound effects'), value: s.soundOn, onChanged: (v) => n.update(s.copyWith(soundOn: v))),
                    Text('You can change this any time in Settings.', style: context.text.bodySmall),
                  ]),
                ),
                const _IntroPage('assets/thumbnails/collections/palm_sunday.webp', "You're all set", 'No account needed, and every puzzle plays offline.'),
              ],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < _pages; i++) AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.all(4), width: i == _index ? 22 : 8, height: 8, decoration: BoxDecoration(color: i == _index ? t.primary : t.primaryLight, borderRadius: BorderRadius.circular(8))),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: SizedBox(width: double.infinity, child: PrimaryButton(label: _index == _pages - 1 ? 'Start playing' : 'Continue', onPressed: _next)),
          ),
        ]),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(24), children: [Text(title, style: context.text.headlineSmall), const SizedBox(height: 18), child]);
}

class _IntroPage extends StatelessWidget {
  const _IntroPage(this.asset, this.title, this.body);
  final String asset, title, body;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AspectRatio(aspectRatio: 4 / 3, child: Art(asset, radius: AppTokens.radiusL)),
          const SizedBox(height: 26),
          Text(title, style: context.text.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(body, style: context.text.bodyLarge?.copyWith(color: context.tokens.textSecondary), textAlign: TextAlign.center),
        ]),
      );
}
