import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _fontFamily = 'SpaceGrotesk';

  static final ThemeData dark = _build();

  static ThemeData _build() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF97CE4C),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF97CE4C),
          onPrimary: const Color(0xFF0B0F0A),
          error: const Color(0xFFFF8A7A),
          onError: const Color(0xFF0B0F0A),
          surface: const Color(0xFF0B0F0A),
          onSurface: const Color(0xFFEDF2E6),
          onSurfaceVariant: const Color(0xFF9EAA95),
          surfaceContainerLow: const Color(0xFF11160F),
          surfaceContainer: const Color(0xFF151B13),
          surfaceContainerHigh: const Color(0xFF1D2519),
          surfaceContainerHighest: const Color(0xFF232C20),
          outline: const Color(0xFF8C9785),
          outlineVariant: const Color(0xFF222B1F),
        );
    final base = ThemeData(
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
    );
    final textTheme = base.textTheme.copyWith(
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        fontSize: 34,
        height: 40 / 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontSize: 17,
        height: 22 / 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontSize: 15,
        height: 22 / 15,
        letterSpacing: 0,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        fontSize: 13,
        height: 18 / 13,
        letterSpacing: 0,
        color: colorScheme.onSurfaceVariant,
      ),
      labelMedium: base.textTheme.labelMedium?.copyWith(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
    const buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
    );
    const buttonSize = Size(64, 48);
    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: buttonShape,
          backgroundColor: colorScheme.surfaceContainer,
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: textTheme.labelLarge),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
