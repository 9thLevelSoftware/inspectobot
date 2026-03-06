import 'package:flutter/material.dart';

import 'extensions.dart';
import 'palette.dart';
import 'tokens.dart';
import 'typography.dart';

/// Master theme factory for InspectoBot.
///
/// Assembles a complete [ThemeData] from the design token system:
/// [Palette] colors, [AppTypography] text styles, [AppTokens] extension,
/// and component themes.
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
      // Component themes
      // -----------------------------------------------------------------------

      // 7.1 AppBarTheme
      appBarTheme: AppBarTheme(
        backgroundColor: Palette.surface,
        foregroundColor: Palette.onSurface,
        elevation: AppElevation.level2,
        surfaceTintColor: Palette.surfaceTint,
        titleTextStyle: AppTypography.textTheme.titleLarge,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Palette.onSurface, size: 24),
      ),

      // 7.2 CardTheme
      cardTheme: CardThemeData(
        color: Palette.surfaceContainer,
        surfaceTintColor: Palette.surfaceTint,
        elevation: AppElevation.level1,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.md,
        ),
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.spacingXs),
        clipBehavior: Clip.antiAlias,
      ),

      // 7.3 InputDecorationTheme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Palette.surfaceVariant,
        contentPadding: AppEdgeInsets.inputPadding,
        border: OutlineInputBorder(
          borderRadius: AppRadii.sm,
          borderSide: const BorderSide(color: Palette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.sm,
          borderSide: const BorderSide(color: Palette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.sm,
          borderSide: const BorderSide(color: Palette.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.sm,
          borderSide: const BorderSide(color: Palette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.sm,
          borderSide: const BorderSide(color: Palette.error, width: 2),
        ),
        labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
          color: Palette.onSurfaceVariant,
        ),
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: Palette.disabled,
        ),
        errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: Palette.error,
        ),
        floatingLabelStyle: const TextStyle(color: Palette.primary),
      ),

      // 7.4 ElevatedButtonTheme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Palette.surfaceContainerHigh,
          foregroundColor: Palette.primary,
          elevation: AppElevation.level1,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingLg,
            vertical: AppSpacing.spacingMd,
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // 7.5 FilledButtonTheme (BLOCKER 1 - was missing)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Palette.primary,
          foregroundColor: Palette.onPrimary,
          disabledBackgroundColor: Palette.surfaceContainerHigh,
          disabledForegroundColor: Palette.disabled,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingLg,
            vertical: AppSpacing.spacingMd,
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // 7.6 OutlinedButtonTheme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Palette.primary,
          side: const BorderSide(color: Palette.outline),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingLg,
            vertical: AppSpacing.spacingMd,
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // 7.7 TextButtonTheme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Palette.primary,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingMd,
            vertical: AppSpacing.spacingSm,
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // 7.8 IconButtonTheme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: Palette.onSurfaceVariant,
          highlightColor: Palette.primary.withValues(alpha: 0.12),
        ),
      ),

      // 7.9 ChipTheme
      chipTheme: ChipThemeData(
        backgroundColor: Palette.surfaceContainerHigh,
        selectedColor: Palette.primaryContainer,
        disabledColor: Palette.surfaceVariant,
        labelStyle: AppTypography.textTheme.labelMedium!,
        side: const BorderSide(color: Palette.outline),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingSm,
          vertical: AppSpacing.spacingXs,
        ),
      ),

      // 7.10 BottomNavigationBarTheme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Palette.surface,
        selectedItemColor: Palette.primary,
        unselectedItemColor: Palette.onSurfaceVariant,
        selectedLabelStyle: AppTypography.textTheme.labelSmall,
        unselectedLabelStyle: AppTypography.textTheme.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: AppElevation.level2,
      ),

      // 7.11 TabBarTheme
      tabBarTheme: TabBarThemeData(
        labelColor: Palette.primary,
        unselectedLabelColor: Palette.onSurfaceVariant,
        labelStyle: AppTypography.textTheme.labelLarge,
        unselectedLabelStyle: AppTypography.textTheme.labelLarge,
        indicatorColor: Palette.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Palette.outlineVariant,
      ),

      // 7.12 DialogTheme
      dialogTheme: DialogThemeData(
        backgroundColor: Palette.surfaceContainerHigh,
        surfaceTintColor: Palette.surfaceTint,
        elevation: AppElevation.level3,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
        titleTextStyle: AppTypography.textTheme.headlineSmall,
        contentTextStyle: AppTypography.textTheme.bodyMedium,
      ),

      // 7.13 SnackBarTheme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Palette.inverseSurface,
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: Palette.onInverseSurface,
        ),
        actionTextColor: Palette.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
        behavior: SnackBarBehavior.floating,
        elevation: AppElevation.level3,
      ),

      // 7.14 FloatingActionButtonTheme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Palette.primary,
        foregroundColor: Palette.onPrimary,
        elevation: AppElevation.level3,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
      ),

      // 7.14 DividerTheme
      dividerTheme: const DividerThemeData(
        color: Palette.outlineVariant,
        thickness: 1,
        space: AppSpacing.spacingLg,
      ),

      // 7.14 BottomSheetTheme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadii.radiusLg),
            topRight: Radius.circular(AppRadii.radiusLg),
          ),
        ),
      ),

      // 7.14 SwitchTheme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Palette.primary;
            }
            return Palette.onSurfaceVariant;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Palette.primaryContainer;
            }
            return Palette.surfaceContainerHighest;
          },
        ),
      ),

      // 7.14 CheckboxTheme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Palette.primary;
            }
            return Colors.transparent;
          },
        ),
        checkColor: WidgetStateProperty.all(Palette.onPrimary),
        side: const BorderSide(color: Palette.outline, width: 2),
      ),

      // 7.14 ListTileTheme
      listTileTheme: const ListTileThemeData(
        textColor: Palette.onSurface,
        iconColor: Palette.onSurfaceVariant,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingLg,
          vertical: AppSpacing.spacingXs,
        ),
      ),

      // 7.14 ProgressIndicatorTheme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Palette.primary,
        circularTrackColor: Palette.surfaceContainerHigh,
        linearTrackColor: Palette.surfaceContainerHigh,
      ),
    );
  }
}
