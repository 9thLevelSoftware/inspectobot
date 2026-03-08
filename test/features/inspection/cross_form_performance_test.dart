@Tags(['performance'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/evidence_sharing_matrix.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';

void main() {
  group('Wizard construction performance', () {
    test('constructs 7-form wizard state in under 500ms', () {
      final allForms = FormType.values.toSet();
      final stopwatch = Stopwatch();

      // Warm-up run
      InspectionWizardState(
        enabledForms: allForms,
        snapshot: WizardProgressSnapshot.empty,
      );

      stopwatch.start();
      for (var i = 0; i < 10; i++) {
        final state = InspectionWizardState(
          enabledForms: allForms,
          snapshot: WizardProgressSnapshot.empty,
        );
        // Access steps to ensure construction is not lazy
        expect(state.steps, isNotEmpty);
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      // 10 iterations should complete in under 500ms total
      expect(
        totalMs,
        lessThan(500),
        reason:
            '10 wizard constructions took ${totalMs}ms, expected <500ms',
      );
    });
  });

  group('Evidence sharing matrix lookup performance', () {
    test('1000 formsAcceptingCategoryFiltered lookups in under 100ms', () {
      final allForms = FormType.values.toSet();
      final categories = RequiredPhotoCategory.values;
      final stopwatch = Stopwatch();

      // Warm-up
      EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
        RequiredPhotoCategory.exteriorFront,
        allForms,
      );

      stopwatch.start();
      for (var i = 0; i < 1000; i++) {
        final category = categories[i % categories.length];
        final result = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
          category,
          allForms,
        );
        // Prevent optimization from eliminating the call
        expect(result, isNotNull);
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      expect(
        totalMs,
        lessThan(100),
        reason:
            '1000 matrix lookups took ${totalMs}ms, expected <100ms',
      );
    });
  });

  group('FormProgressSummary computation performance', () {
    test('build summaries for all 7 forms in under 200ms', () {
      final allForms = FormType.values.toSet();
      final stopwatch = Stopwatch();

      // Warm-up
      final warmupState = InspectionWizardState(
        enabledForms: allForms,
        snapshot: WizardProgressSnapshot.empty,
      );
      warmupState.buildFormSummaries();

      stopwatch.start();
      for (var i = 0; i < 10; i++) {
        final state = InspectionWizardState(
          enabledForms: allForms,
          snapshot: WizardProgressSnapshot.empty,
        );
        final summaries = state.buildFormSummaries();
        expect(summaries.length, 7);
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      expect(
        totalMs,
        lessThan(200),
        reason:
            '10 summary computations took ${totalMs}ms, expected <200ms',
      );
    });
  });
}
