import 'package:flutter/material.dart';

import 'extensions.dart';
import 'palette.dart';
import 'tokens.dart';
import 'typography.dart';

/// Master theme factory for InspectoBot.
///
/// Assembles a complete [ThemeData] from the design token system:
/// [Palette] colors, [AppTypography] text styles, [AppTokens] extension,
/// and 16 component themes.
///
/// Usage: `theme: AppTheme.dark()` in [MaterialApp].
abstract final class AppTheme {
  /// Dark theme -- the only supported theme for InspectoBot.
  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Palette.primary,
      onPrimary: Palette.onPrimary,
      primaryContainer: Palette.primaryContainer,
      onPrimaryContainer: Palette.onPrimaryContainer,
      secondary: Palette.secondary,
      onSecondary: Palette.onSecondary,
      secondaryContainer: Palette.secondaryContainer,
      onSecondaryContainer: Palette.onSecondaryContainer,
      tertiary: Palette.tertiary,
      onTertiary: Palette.onTertiary,
      tertiaryContainer: Palette.tertiaryContainer,
      onTertiaryContainer: Palette.onTertiaryContainer,
      error: Palette.error,
      onError: Palette.onError,
      errorContainer: Palette.errorContainer,
      onErrorContainer: Palette.onErrorContainer,
      surface: Palette.surface,
      onSurface: Palette.onSurface,
      onSurfaceVariant: Palette.onSurfaceVariant,
      outline: Palette.outline,
      outlineVariant: Palette.outlineVariant,
      shadow: Palette.shadow,
      scrim: Palette.scrim,
      inverseSurface: Palette.inverseSurface,
      onInverseSurface: Palette.onInverseSurface,
      inversePrimary: Palette.inversePrimary,
      surfaceTint: Palette.surfaceTint,
      surfaceContainerLowest: Palette.surfaceContainerLowest,
      surfaceContainerLow: Palette.surfaceContainerLow,
      surfaceContainer: Palette.surfaceContainer,
      surfaceContainerHigh: Palette.surfaceContainerHigh,
      surfaceContainerHighest: Palette.surfaceContainerHighest,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Palette.background,
      textTheme: AppTypography.textTheme,
      extensions: <ThemeExtension>[AppTokens.dark()],

      // -----------------------------------------------------------------------
      // Component themes (16)
      // -----------------------------------------------------------------------

      // 1. AppBarTheme
      appBarTheme: const AppBarTheme(
        backgroundColor: Palette.surface,
        foregroundColor: Palette.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),

      // 2. CardTheme
      cardTheme: CardThemeData(
        color: Palette.surface,
        elevation: AppElevation.level1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.radiusMd),
        ),
      ),

      // 3. InputDecorationTheme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Palette.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.radiusSm),
          borderSide: const BorderSide(color: Palette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.radiusSm),
          borderSide: const BorderSide(color: Palette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.radiusSm),
          borderSide: const BorderSide(color: Palette.primary, width: 2),
        ),
        hintStyle: const TextStyle(color: Palette.onSurfaceVariant),
        contentPadding: AppEdgeInsets.inputPadding,
      ),

      // 4. ElevatedButtonTheme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Palette.primary,
          foregroundColor: Palette.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.radiusSm),
          ),
          minimumSize: const Size(0, 48),
        ),
      ),

      // 5. OutlinedButtonTheme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Palette.primary,
          side: const BorderSide(color: Palette.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.radiusSm),
          ),
          minimumSize: const Size(0, 48),
        ),
      ),

      // 6. TextButtonTheme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Palette.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.radiusSm),
          ),
          minimumSize: const Size(0, 48),
        ),
      ),

      // 7. IconButtonTheme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),

      // 8. ChipTheme
      chipTheme: ChipThemeData(
        backgroundColor: Palette.surfaceVariant,
        labelStyle: const TextStyle(color: Palette.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.radiusSm),
        ),
      ),

      // 9. BottomNavigationBarTheme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Palette.surface,
        selectedItemColor: Palette.primary,
        unselectedItemColor: Palette.onSurfaceVariant,
      ),

      // 10. TabBarTheme
      tabBarTheme: const TabBarThemeData(
        indicatorColor: Palette.primary,
        labelColor: Palette.onSurface,
        unselectedLabelColor: Palette.onSurfaceVariant,
      ),

      // 11. DialogTheme
      dialogTheme: DialogThemeData(
        backgroundColor: Palette.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.radiusLg),
        ),
      ),

      // 12. SnackBarTheme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Palette.inverseSurface,
        contentTextStyle: TextStyle(color: Palette.onInverseSurface),
      ),

      // 13. FloatingActionButtonTheme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Palette.primaryContainer,
        foregroundColor: Palette.onPrimaryContainer,
      ),

      // 14. DividerTheme
      dividerTheme: const DividerThemeData(
        color: Palette.outlineVariant,
        thickness: 1,
      ),

      // 15. BottomSheetTheme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadii.radiusLg),
            topRight: Radius.circular(AppRadii.radiusLg),
          ),
        ),
      ),

      // 16. SwitchThemeData
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Palette.primary;
            }
            return Palette.surfaceVariant;
          },
        ),
      ),
    );
  }
}
