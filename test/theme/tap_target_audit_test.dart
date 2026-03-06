import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/app_button.dart';
import 'package:inspectobot/common/widgets/section_group.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrapInApp(Widget child) => MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  // ---------------------------------------------------------------------------
  // AppButton tap target sizes
  // ---------------------------------------------------------------------------
  group('AppButton tap targets', () {
    testWidgets('default filled button has >= 48dp min height', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        AppButton(
          label: 'Save',
          onPressed: () {},
          variant: AppButtonVariant.filled,
        ),
      ));

      final finder = find.descendant(
        of: find.byType(AppButton),
        matching: find.byType(ConstrainedBox),
      );
      final box = tester.widget<ConstrainedBox>(finder.first);
      expect(
        box.constraints.minHeight,
        greaterThanOrEqualTo(AppSpacing.minTapTarget),
        reason: 'Default AppButton must have >= 48dp min height',
      );
    });

    testWidgets('isThumbZone filled button has >= 56dp min height',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        AppButton(
          label: 'Submit',
          onPressed: () {},
          variant: AppButtonVariant.filled,
          isThumbZone: true,
        ),
      ));

      final finder = find.descendant(
        of: find.byType(AppButton),
        matching: find.byType(ConstrainedBox),
      );
      final box = tester.widget<ConstrainedBox>(finder.first);
      expect(
        box.constraints.minHeight,
        greaterThanOrEqualTo(AppSpacing.thumbZoneTapTarget),
        reason: 'isThumbZone AppButton must have >= 56dp min height',
      );
    });

    testWidgets('isThumbZone icon variant has >= 56dp min height',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        AppButton(
          label: 'Delete',
          onPressed: () {},
          variant: AppButtonVariant.icon,
          icon: Icons.delete,
          isThumbZone: true,
        ),
      ));

      final finder = find.descendant(
        of: find.byType(AppButton),
        matching: find.byType(ConstrainedBox),
      );
      final box = tester.widget<ConstrainedBox>(finder.first);
      expect(
        box.constraints.minHeight,
        greaterThanOrEqualTo(AppSpacing.thumbZoneTapTarget),
        reason: 'isThumbZone icon AppButton must have >= 56dp min height',
      );
    });

    testWidgets('outlined variant has >= 48dp min height', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        AppButton(
          label: 'Cancel',
          onPressed: () {},
          variant: AppButtonVariant.outlined,
        ),
      ));

      final finder = find.descendant(
        of: find.byType(AppButton),
        matching: find.byType(ConstrainedBox),
      );
      final box = tester.widget<ConstrainedBox>(finder.first);
      expect(
        box.constraints.minHeight,
        greaterThanOrEqualTo(AppSpacing.minTapTarget),
        reason: 'Outlined AppButton must have >= 48dp min height',
      );
    });

    testWidgets('text variant has >= 48dp min height', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        AppButton(
          label: 'Skip',
          onPressed: () {},
          variant: AppButtonVariant.text,
        ),
      ));

      final finder = find.descendant(
        of: find.byType(AppButton),
        matching: find.byType(ConstrainedBox),
      );
      final box = tester.widget<ConstrainedBox>(finder.first);
      expect(
        box.constraints.minHeight,
        greaterThanOrEqualTo(AppSpacing.minTapTarget),
        reason: 'Text AppButton must have >= 48dp min height',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // SectionGroup spacing (glove-friendly gap)
  // ---------------------------------------------------------------------------
  group('SectionGroup tap target spacing', () {
    testWidgets('divider height is >= minTapTargetSpacing between items',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: SectionGroup(
                children: const [
                  SizedBox(height: 48, child: Text('Item 1')),
                  SizedBox(height: 48, child: Text('Item 2')),
                  SizedBox(height: 48, child: Text('Item 3')),
                ],
              ),
            ),
          ),
        ),
      );

      // SectionGroup uses Divider(height: gap * 2) between children.
      // gap defaults to AppSpacing.minTapTargetSpacing (8dp).
      // So divider height = 16dp, which is >= 8dp.
      final dividers = tester.widgetList<Divider>(find.byType(Divider));
      for (final divider in dividers) {
        expect(
          divider.height,
          greaterThanOrEqualTo(AppSpacing.minTapTargetSpacing),
          reason:
              'Divider between SectionGroup items must be >= ${AppSpacing.minTapTargetSpacing}dp',
        );
      }
    });

    testWidgets('SizedBox gaps >= minTapTargetSpacing when dividers off',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: SectionGroup(
                showDividers: false,
                children: const [
                  SizedBox(height: 48, child: Text('A')),
                  SizedBox(height: 48, child: Text('B')),
                ],
              ),
            ),
          ),
        ),
      );

      // When showDividers = false, SectionGroup inserts SizedBox(height: gap).
      // gap defaults to minTapTargetSpacing = 8dp.
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final spacers = sizedBoxes.where(
        (sb) =>
            sb.height != null &&
            sb.height! >= AppSpacing.minTapTargetSpacing &&
            sb.height! <= 16, // filter out the 48dp item boxes
      );
      expect(
        spacers,
        isNotEmpty,
        reason: 'At least one spacing SizedBox >= ${AppSpacing.minTapTargetSpacing}dp '
            'must separate SectionGroup items',
      );
    });
  });
}
