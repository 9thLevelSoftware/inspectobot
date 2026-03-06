import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/theme/app_theme.dart';
import 'package:inspectobot/theme/extensions.dart';
import 'package:inspectobot/theme/palette.dart';

void main() {
  group('AppTheme.dark()', () {
    late ThemeData theme;

    setUp(() {
      theme = AppTheme.dark();
    });

    test('creates valid ThemeData', () {
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
    });

    test('colorScheme.brightness is dark', () {
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('colorScheme.primary matches Palette.primary', () {
      expect(theme.colorScheme.primary, Palette.primary);
    });

    test('scaffoldBackgroundColor matches Palette.background', () {
      expect(theme.scaffoldBackgroundColor, Palette.background);
    });

    test('AppTokens extension is non-null', () {
      final tokens = theme.extension<AppTokens>();
      expect(tokens, isNotNull);
    });

    test('AppTokens has correct semantic colors', () {
      final tokens = theme.extension<AppTokens>()!;
      expect(tokens.success, Palette.success);
      expect(tokens.warning, Palette.warning);
      expect(tokens.info, Palette.info);
      expect(tokens.disabled, Palette.disabled);
    });

    test('filledButtonTheme uses primary background', () {
      final style = theme.filledButtonTheme.style;
      expect(style, isNotNull);
      // FilledButton should have primary bg for the primary action button
      final bgColor = style!.backgroundColor?.resolve(<WidgetState>{});
      expect(bgColor, Palette.primary);
    });

    test('elevatedButtonTheme uses surfaceContainerHigh background', () {
      final style = theme.elevatedButtonTheme.style;
      expect(style, isNotNull);
      final bgColor = style!.backgroundColor?.resolve(<WidgetState>{});
      expect(bgColor, Palette.surfaceContainerHigh);
    });

    test('cardTheme uses surfaceContainer color', () {
      expect(theme.cardTheme.color, Palette.surfaceContainer);
      expect(theme.cardTheme.clipBehavior, Clip.antiAlias);
    });

    test('scaffold background differs from surface', () {
      expect(theme.scaffoldBackgroundColor, isNot(theme.colorScheme.surface));
    });

    test('text theme uses specified sizes', () {
      expect(theme.textTheme.bodyMedium!.fontSize, 14.0);
      expect(theme.textTheme.bodyLarge!.fontSize, 16.0);
      expect(theme.textTheme.headlineLarge!.fontWeight, FontWeight.w700);
    });

    test('checkboxTheme is present', () {
      expect(theme.checkboxTheme.fillColor, isNotNull);
    });

    test('listTileTheme is present', () {
      expect(theme.listTileTheme.textColor, Palette.onSurface);
      expect(theme.listTileTheme.iconColor, Palette.onSurfaceVariant);
    });

    test('progressIndicatorTheme is present', () {
      expect(theme.progressIndicatorTheme.color, Palette.primary);
    });

    test('floatingActionButtonTheme uses primary colors', () {
      expect(
        theme.floatingActionButtonTheme.backgroundColor,
        Palette.primary,
      );
      expect(
        theme.floatingActionButtonTheme.foregroundColor,
        Palette.onPrimary,
      );
    });
  });
}
