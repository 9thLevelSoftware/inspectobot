import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/mold_moisture_step.dart';
import 'package:inspectobot/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(
      body: SizedBox(
        height: 800,
        width: 600,
        child: child,
      ),
    ),
  );
}

void main() {
  group('MoldMoistureStep', () {
    testWidgets('renders correctly with initial values', (tester) async {
      final data = MoldFormData.empty().copyWith(
        moistureSources: 'Leaky pipe under kitchen sink',
        airSamplesTaken: false,
      );

      await tester.pumpWidget(_wrap(
        MoldMoistureStep(
          formData: data,
          onChanged: (_) {},
        ),
      ));

      // Verify section header
      expect(find.text('Moisture Sources'), findsAtLeastNWidgets(1));

      // Verify description text
      expect(
        find.textContaining('plumbing leaks'),
        findsOneWidget,
      );

      // Verify TextFormField with initial value
      expect(find.text('Leaky pipe under kitchen sink'), findsOneWidget);

      // Verify SwitchListTile is present
      expect(
        find.text('Air samples were collected during this assessment'),
        findsOneWidget,
      );
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('onChanged fires when moistureSources text changes', (tester) async {
      MoldFormData? updated;

      await tester.pumpWidget(_wrap(
        MoldMoistureStep(
          formData: MoldFormData.empty(),
          onChanged: (data) => updated = data,
        ),
      ));

      await tester.enterText(
        find.byType(TextFormField).first,
        'New moisture source',
      );

      expect(updated, isNotNull);
      expect(updated!.moistureSources, 'New moisture source');
    });

    testWidgets('toggle fires onChanged with updated airSamplesTaken flag', (tester) async {
      MoldFormData? updated;

      await tester.pumpWidget(_wrap(
        MoldMoistureStep(
          formData: MoldFormData.empty().copyWith(airSamplesTaken: false),
          onChanged: (data) => updated = data,
        ),
      ));

      // Tap the switch
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(updated, isNotNull);
      expect(updated!.airSamplesTaken, isTrue);
    });

    testWidgets('renders with airSamplesTaken initially true', (tester) async {
      final data = MoldFormData.empty().copyWith(airSamplesTaken: true);

      await tester.pumpWidget(_wrap(
        MoldMoistureStep(
          formData: data,
          onChanged: (_) {},
        ),
      ));

      final switchWidget = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('TextFormField supports multiline input', (tester) async {
      await tester.pumpWidget(_wrap(
        MoldMoistureStep(
          formData: MoldFormData.empty(),
          onChanged: (_) {},
        ),
      ));

      final textField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      expect(textField.maxLines, isNull);
      expect(textField.minLines, 6);
      expect(textField.textInputAction, TextInputAction.newline);
    });
  });
}
