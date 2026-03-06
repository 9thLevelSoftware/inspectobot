import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/app_button.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppButton', () {
    testWidgets('filled variant renders FilledButton', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Save',
          onPressed: () {},
          variant: AppButtonVariant.filled,
        ),
      ));

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('outlined variant renders OutlinedButton', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Cancel',
          onPressed: () {},
          variant: AppButtonVariant.outlined,
        ),
      ));

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('text variant renders TextButton', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Skip',
          onPressed: () {},
          variant: AppButtonVariant.text,
        ),
      ));

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('icon variant renders IconButton', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Delete',
          onPressed: () {},
          variant: AppButtonVariant.icon,
          icon: Icons.delete,
        ),
      ));

      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('isLoading disables the button', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Submit',
          onPressed: () => tapped = true,
          isLoading: true,
          variant: AppButtonVariant.filled,
        ),
      ));

      // The button is disabled (onPressed == null), so tapping should not
      // trigger the callback. Tap by text since the .icon() constructor may
      // wrap in an internal subclass.
      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('isLoading shows loadingLabel when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Submit',
          onPressed: () {},
          isLoading: true,
          loadingLabel: 'Submitting...',
          variant: AppButtonVariant.filled,
        ),
      ));

      expect(find.text('Submitting...'), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('isLoading shows original label when loadingLabel is null',
        (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Submit',
          onPressed: () {},
          isLoading: true,
          variant: AppButtonVariant.filled,
        ),
      ));

      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('icon is displayed for filled variant with icon',
        (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Add',
          onPressed: () {},
          variant: AppButtonVariant.filled,
          icon: Icons.add,
        ),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('button has minimum height of 48dp', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Test',
          onPressed: () {},
          variant: AppButtonVariant.filled,
        ),
      ));

      // Find the first ConstrainedBox that is a descendant of AppButton
      // (our wrapper; the button itself also contains one internally).
      final finder = find.descendant(
        of: find.byType(AppButton),
        matching: find.byType(ConstrainedBox),
      );
      final constrainedBox = tester.widget<ConstrainedBox>(finder.first);
      expect(constrainedBox.constraints.minHeight, 48.0);
    });

    testWidgets('isLoading shows CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Submit',
          onPressed: () {},
          isLoading: true,
          variant: AppButtonVariant.filled,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('isThumbZone=true button has 56dp min height', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Thumb',
          onPressed: () {},
          variant: AppButtonVariant.filled,
          isThumbZone: true,
        ),
      ));

      final finder = find.descendant(
        of: find.byType(AppButton),
        matching: find.byType(ConstrainedBox),
      );
      final constrainedBox = tester.widget<ConstrainedBox>(finder.first);
      expect(constrainedBox.constraints.minHeight, 56.0);
    });

    testWidgets('isThumbZone=true icon variant also has 56dp min height',
        (tester) async {
      await tester.pumpWidget(_wrap(
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
      final constrainedBox = tester.widget<ConstrainedBox>(finder.first);
      expect(constrainedBox.constraints.minHeight, 56.0);
    });
  });
}
