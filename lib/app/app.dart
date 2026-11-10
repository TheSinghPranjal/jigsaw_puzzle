import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/app_services.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class EasterJigsawApp extends ConsumerWidget {
  const EasterJigsawApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final palette = paletteById(s.themeId);
    return MaterialApp.router(
      title: 'Easter Jigsaw Journey',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(palette, Brightness.light),
      darkTheme: buildTheme(palette, Brightness.dark),
      themeMode: switch (s.mode) { 'dark' => ThemeMode.dark, 'system' => ThemeMode.system, _ => ThemeMode.light },
      routerConfig: ref.watch(routerProvider),
    );
  }
}
