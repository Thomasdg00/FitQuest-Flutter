import 'package:flutter/material.dart';

import 'app_color_schemes.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _theme(lightColorScheme);

  static ThemeData get dark => _theme(darkColorScheme);

  static ThemeData _theme(ColorScheme colorScheme) {
    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarThemeData(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.secondaryContainer,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 1,
        margin: const EdgeInsets.all(8),
        shape: roundedShape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: roundedShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: roundedShape,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
