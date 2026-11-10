import 'package:flutter/material.dart';

class ThemePalette {
  const ThemePalette(this.id, this.name, this.primary, this.secondary, this.background, this.card, this.accent, this.text, this.selected, this.progress);
  final String id, name;
  final Color primary, secondary, background, card, accent, text, selected, progress;
}

const themePalettes = [
  ThemePalette('easter_pastel', 'Easter Pastel', Color(0xFF8D78C8), Color(0xFFF4A6B9), Color(0xFFFFF9F1), Color(0xFFFFFFFF), Color(0xFFF1C76B), Color(0xFF303044), Color(0xFFEAE3FA), Color(0xFF8D78C8)),
  ThemePalette('lavender_dream', 'Lavender Dream', Color(0xFF7A62B8), Color(0xFFC6B4EC), Color(0xFFF7F3FF), Color(0xFFFFFFFF), Color(0xFFE6A8D8), Color(0xFF2E2A48), Color(0xFFE4DAF8), Color(0xFF9A82D8)),
  ThemePalette('spring_garden', 'Spring Garden', Color(0xFF5C9A6E), Color(0xFFA9D6B8), Color(0xFFF6FBF2), Color(0xFFFFFFFF), Color(0xFFF2C76A), Color(0xFF2B3C30), Color(0xFFDCF0E0), Color(0xFF6DB381)),
  ThemePalette('ocean_breeze', 'Ocean Breeze', Color(0xFF3F8FBF), Color(0xFF93C7EA), Color(0xFFF2F9FD), Color(0xFFFFFFFF), Color(0xFF6FD0C4), Color(0xFF243A4A), Color(0xFFD6ECF8), Color(0xFF4FA5D5)),
  ThemePalette('sunset_glow', 'Sunset Glow', Color(0xFFD9775A), Color(0xFFF4B28A), Color(0xFFFFF6EE), Color(0xFFFFFFFF), Color(0xFFF2B84B), Color(0xFF4A2F2A), Color(0xFFFBE2D2), Color(0xFFE58A62)),
];

ThemePalette paletteById(String id) => themePalettes.firstWhere((p) => p.id == id, orElse: () => themePalettes.first);

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({required this.primary, required this.primaryLight, required this.secondary, required this.background, required this.card, required this.accent, required this.text, required this.textSecondary, required this.border, required this.selected, required this.progress, required this.tray, required this.board});

  final Color primary, primaryLight, secondary, background, card, accent, text, textSecondary, border, selected, progress, tray, board;

  static const gold = Color(0xFFF1C76B), success = Color(0xFF58A873), danger = Color(0xFFE0707F);
  static const radiusS = 12.0, radiusM = 18.0, radiusL = 26.0;
  static const List<BoxShadow> softShadow = [BoxShadow(color: Color(0x14453A60), blurRadius: 18, offset: Offset(0, 8))];

  @override
  AppTokens copyWith() => this;

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    Color m(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      primary: m(primary, other.primary),
      primaryLight: m(primaryLight, other.primaryLight),
      secondary: m(secondary, other.secondary),
      background: m(background, other.background),
      card: m(card, other.card),
      accent: m(accent, other.accent),
      text: m(text, other.text),
      textSecondary: m(textSecondary, other.textSecondary),
      border: m(border, other.border),
      selected: m(selected, other.selected),
      progress: m(progress, other.progress),
      tray: m(tray, other.tray),
      board: m(board, other.board),
    );
  }
}

extension TokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  TextTheme get text => Theme.of(this).textTheme;
}

ThemeData buildTheme(ThemePalette p, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  Color tone(Color c, double amount) => Color.lerp(c, const Color(0xFF17151F), amount)!;
  final tokens = AppTokens(
    primary: dark ? Color.lerp(p.primary, Colors.white, .18)! : p.primary,
    primaryLight: dark ? tone(p.primary, .62) : p.selected,
    secondary: p.secondary,
    background: dark ? tone(p.primary, .9) : p.background,
    card: dark ? tone(p.primary, .8) : p.card,
    accent: p.accent,
    text: dark ? const Color(0xFFF3F0F8) : p.text,
    textSecondary: dark ? const Color(0xFFB4AFC2) : const Color(0xFF858394),
    border: dark ? tone(p.primary, .7) : const Color(0xFFEEE8E2),
    selected: dark ? tone(p.primary, .55) : p.selected,
    progress: p.progress,
    tray: dark ? tone(p.primary, .84) : Color.lerp(p.background, p.selected, .5)!,
    board: dark ? tone(p.primary, .74) : Color.lerp(p.card, p.selected, .35)!,
  );
  TextStyle body(double size, FontWeight w, [Color? c]) => TextStyle(fontFamily: 'Nunito', fontSize: size, fontWeight: w, color: c ?? tokens.text);
  TextStyle head(double size) => TextStyle(fontFamily: 'Lora', fontSize: size, fontWeight: FontWeight.w700, color: tokens.text, height: 1.2);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'Nunito',
    scaffoldBackgroundColor: tokens.background,
    colorScheme: ColorScheme.fromSeed(seedColor: p.primary, brightness: brightness, primary: tokens.primary, surface: tokens.card),
    extensions: [tokens],
    textTheme: TextTheme(
      displaySmall: head(32),
      headlineSmall: head(24),
      titleLarge: head(20),
      titleMedium: body(16, FontWeight.w800),
      titleSmall: body(14, FontWeight.w700),
      bodyLarge: body(16, FontWeight.w600),
      bodyMedium: body(14, FontWeight.w600),
      bodySmall: body(12, FontWeight.w600, tokens.textSecondary),
      labelLarge: body(15, FontWeight.w800),
      labelSmall: body(11, FontWeight.w700, tokens.textSecondary),
    ),
    appBarTheme: AppBarTheme(backgroundColor: tokens.background, foregroundColor: tokens.text, elevation: 0, scrolledUnderElevation: 0, centerTitle: true, titleTextStyle: head(19)),
    dialogTheme: DialogThemeData(backgroundColor: tokens.card, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusL))),
    sliderTheme: SliderThemeData(activeTrackColor: tokens.primary, thumbColor: tokens.primary, inactiveTrackColor: tokens.primaryLight),
    switchTheme: SwitchThemeData(trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? tokens.primary : tokens.border), thumbColor: const WidgetStatePropertyAll(Colors.white), trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent)),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: tokens.text, contentTextStyle: body(14, FontWeight.w700, tokens.background), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusS))),
  );
}
