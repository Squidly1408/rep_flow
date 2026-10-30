import 'package:flutter/material.dart';

const _inkLight = Color(0xFF111111);
const _paperLight = Color(0xFFFAFAFA);
const _inkDark = Color(0xFFF2F2F2);
const _paperDark = Color(0xFF0E0E0E);

/// Returns [c] at the given opacity (0–1).
Color fade(Color c, double opacity) => c.withAlpha((opacity * 255).round());

/// Secondary text / hairline colour derived from the current ink colour.
Color muted(BuildContext context, [double opacity = 0.45]) =>
    fade(Theme.of(context).colorScheme.onSurface, opacity);

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final ink = dark ? _inkDark : _inkLight;
  final paper = dark ? _paperDark : _paperLight;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: ink,
    onPrimary: paper,
    secondary: ink,
    onSecondary: paper,
    error: const Color(0xFFD64545),
    onError: Colors.white,
    surface: paper,
    onSurface: ink,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);

  return base.copyWith(
    scaffoldBackgroundColor: paper,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: paper,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: ink,
        fontSize: 20,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ink,
        foregroundColor: paper,
        disabledBackgroundColor: fade(ink, 0.12),
        disabledForegroundColor: fade(ink, 0.35),
        minimumSize: const Size.fromHeight(60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: ink),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: ink),
    ),
    dividerTheme: DividerThemeData(
      color: fade(ink, 0.08),
      thickness: 1,
      space: 1,
    ),
    textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
  );
}
