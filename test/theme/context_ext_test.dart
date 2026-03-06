import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/theme/app_theme.dart';
import 'package:inspectobot/theme/context_ext.dart';
import 'package:inspectobot/theme/extensions.dart';
import 'package:inspectobot/theme/palette.dart';

void main() {
  group('context.appTokens', () {
    testWidgets('returns AppTokens from theme', (tester) async {
      late AppTokens capturedTokens;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Builder(
            builder: (context) {
              capturedTokens = context.appTokens;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(capturedTokens, isA<AppTokens>());
      expect(capturedTokens.success, Palette.success);
      expect(capturedTokens.spacingLg, 16.0);
    });
  });
}
