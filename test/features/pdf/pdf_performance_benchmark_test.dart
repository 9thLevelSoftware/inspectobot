@Tags(['performance'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/evidence_sharing_matrix.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';

/// Performance benchmarks for PDF generation input preparation.
///
/// These tests measure the computational cost of building PDF generation inputs
/// at various form-count scales. The actual PDF rendering (which depends on
/// platform-specific PDF libraries and asset I/O) is not measured here — those
/// are integration-level concerns that require a running Flutter engine.
///
/// What IS measured:
/// - PdfGenerationInput construction with N forms
/// - Wizard state + summary computation for N-form sessions
/// - Evidence sharing matrix lookups at scale
/// - Canonical payload serialization for N-form inputs
///
/// Thresholds are set at 1.5x a generous baseline to allow for CI variability.
void main() {
  /// Builds a PdfGenerationInput for the given form set with synthetic data.
  PdfGenerationInput buildInput(Set<FormType> forms) {
    final capturedCategories = <RequiredPhotoCategory>{};
    final wizardCompletion = <String, bool>{};
    final fieldValues = <String, String>{};
    final evidenceMediaPaths = <String, List<String>>{};

    for (final form in forms) {
      final reqs = FormRequirements.forFormRequirements(form);
      for (final req in reqs) {
        wizardCompletion[req.key] = true;
        if (req.category != null) {
          capturedCategories.add(req.category!);
        }
        evidenceMediaPaths[req.key] = ['/tmp/mock_${req.key.replaceAll(':', '_')}.jpg'];
      }
    }

    // Add synthetic field values
    for (var i = 0; i < forms.length * 10; i++) {
      fieldValues['field_$i'] = 'value_$i';
    }

    return PdfGenerationInput(
      inspectionId: 'perf-insp-001',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Performance Test Client',
      propertyAddress: '123 Benchmark Ave, Tampa, FL 33601',
      enabledForms: forms,
      capturedCategories: capturedCategories,
      wizardCompletion: wizardCompletion,
      fieldValues: fieldValues,
      evidenceMediaPaths: evidenceMediaPaths,
    );
  }

  group('PdfGenerationInput construction performance', () {
    test('single fillable PDF input (4-Point) — baseline', () {
      final stopwatch = Stopwatch();
      final forms = {FormType.fourPoint};

      // Warm-up
      buildInput(forms);

      stopwatch.start();
      for (var i = 0; i < 100; i++) {
        final input = buildInput(forms);
        expect(input.enabledForms, isNotEmpty);
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      // 100 iterations of single-form input construction should be fast
      expect(
        totalMs,
        lessThan(500),
        reason: '100 single-form input constructions took ${totalMs}ms, expected <500ms',
      );
    });

    test('single narrative PDF input (Mold Assessment) — baseline', () {
      final stopwatch = Stopwatch();
      final forms = {FormType.moldAssessment};

      buildInput(forms);

      stopwatch.start();
      for (var i = 0; i < 100; i++) {
        final input = buildInput(forms);
        expect(input.enabledForms, isNotEmpty);
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      expect(
        totalMs,
        lessThan(500),
        reason: '100 narrative-form input constructions took ${totalMs}ms, expected <500ms',
      );
    });

    test('3-form session input (4-Point + Roof + Wind)', () {
      final stopwatch = Stopwatch();
      final forms = {FormType.fourPoint, FormType.roofCondition, FormType.windMitigation};

      buildInput(forms);

      stopwatch.start();
      for (var i = 0; i < 50; i++) {
        final input = buildInput(forms);
        expect(input.enabledForms.length, 3);
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      // Should scale roughly linearly; 1.5x of 3x single baseline
      expect(
        totalMs,
        lessThan(750),
        reason: '50 3-form input constructions took ${totalMs}ms, expected <750ms',
      );
    });

    test('5-form session input (4-Point + Roof + Wind + WDO + Sinkhole)', () {
      final stopwatch = Stopwatch();
      final forms = {
        FormType.fourPoint,
        FormType.roofCondition,
        FormType.windMitigation,
        FormType.wdo,
        FormType.sinkholeInspection,
      };

      buildInput(forms);

      stopwatch.start();
      for (var i = 0; i < 50; i++) {
        final input = buildInput(forms);
        expect(input.enabledForms.length, 5);
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      expect(
        totalMs,
        lessThan(1000),
        reason: '50 5-form input constructions took ${totalMs}ms, expected <1000ms',
      );
    });

    test('7-form session input (all forms) — worst case', () {
      final stopwatch = Stopwatch();
      final forms = FormType.values.toSet();

      buildInput(forms);

      stopwatch.start();
      for (var i = 0; i < 50; i++) {
        final input = buildInput(forms);
        expect(input.enabledForms.length, 7);
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      expect(
        totalMs,
        lessThan(1500),
        reason: '50 7-form input constructions took ${totalMs}ms, expected <1500ms',
      );
    });
  });

  group('Canonical payload serialization performance', () {
    test('single form toCanonicalPayload in under 200ms for 100 iterations', () {
      final input = buildInput({FormType.fourPoint});
      final stopwatch = Stopwatch();

      // Warm-up
      input.toCanonicalPayload();

      stopwatch.start();
      for (var i = 0; i < 100; i++) {
        final payload = input.toCanonicalPayload();
        expect(payload, isNotEmpty);
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      expect(
        totalMs,
        lessThan(200),
        reason: '100 single-form serializations took ${totalMs}ms, expected <200ms',
      );
    });

    test('7-form toCanonicalPayload in under 500ms for 50 iterations', () {
      final input = buildInput(FormType.values.toSet());
      final stopwatch = Stopwatch();

      input.toCanonicalPayload();

      stopwatch.start();
      for (var i = 0; i < 50; i++) {
        final payload = input.toCanonicalPayload();
        expect(payload['enabled_forms'], hasLength(7));
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      expect(
        totalMs,
        lessThan(500),
        reason: '50 7-form serializations took ${totalMs}ms, expected <500ms',
      );
    });
  });

  group('Wizard summary computation at scale', () {
    test('1-form summary computation: 100 iterations in under 200ms', () {
      final stopwatch = Stopwatch();
      final forms = {FormType.fourPoint};

      // Warm-up
      InspectionWizardState(
        enabledForms: forms,
        snapshot: WizardProgressSnapshot.empty,
      ).buildFormSummaries();

      stopwatch.start();
      for (var i = 0; i < 100; i++) {
        final state = InspectionWizardState(
          enabledForms: forms,
          snapshot: WizardProgressSnapshot.empty,
        );
        final summaries = state.buildFormSummaries();
        expect(summaries, hasLength(1));
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      expect(
        totalMs,
        lessThan(200),
        reason: '100 1-form summary computations took ${totalMs}ms, expected <200ms',
      );
    });

    test('3-form summary computation: 50 iterations in under 300ms', () {
      final stopwatch = Stopwatch();
      final forms = {FormType.fourPoint, FormType.roofCondition, FormType.windMitigation};

      InspectionWizardState(
        enabledForms: forms,
        snapshot: WizardProgressSnapshot.empty,
      ).buildFormSummaries();

      stopwatch.start();
      for (var i = 0; i < 50; i++) {
        final state = InspectionWizardState(
          enabledForms: forms,
          snapshot: WizardProgressSnapshot.empty,
        );
        final summaries = state.buildFormSummaries();
        expect(summaries, hasLength(3));
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      expect(
        totalMs,
        lessThan(300),
        reason: '50 3-form summary computations took ${totalMs}ms, expected <300ms',
      );
    });

    test('5-form summary computation: 50 iterations in under 500ms', () {
      final stopwatch = Stopwatch();
      final forms = {
        FormType.fourPoint,
        FormType.roofCondition,
        FormType.windMitigation,
        FormType.wdo,
        FormType.sinkholeInspection,
      };

      InspectionWizardState(
        enabledForms: forms,
        snapshot: WizardProgressSnapshot.empty,
      ).buildFormSummaries();

      stopwatch.start();
      for (var i = 0; i < 50; i++) {
        final state = InspectionWizardState(
          enabledForms: forms,
          snapshot: WizardProgressSnapshot.empty,
        );
        final summaries = state.buildFormSummaries();
        expect(summaries, hasLength(5));
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      expect(
        totalMs,
        lessThan(500),
        reason: '50 5-form summary computations took ${totalMs}ms, expected <500ms',
      );
    });

    test('7-form summary computation: 50 iterations in under 750ms', () {
      final stopwatch = Stopwatch();
      final forms = FormType.values.toSet();

      InspectionWizardState(
        enabledForms: forms,
        snapshot: WizardProgressSnapshot.empty,
      ).buildFormSummaries();

      stopwatch.start();
      for (var i = 0; i < 50; i++) {
        final state = InspectionWizardState(
          enabledForms: forms,
          snapshot: WizardProgressSnapshot.empty,
        );
        final summaries = state.buildFormSummaries();
        expect(summaries, hasLength(7));
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      expect(
        totalMs,
        lessThan(750),
        reason: '50 7-form summary computations took ${totalMs}ms, expected <750ms',
      );
    });
  });

  group('Evidence sharing matrix lookup at scale', () {
    test('all categories x all forms filtered lookup: 1000 iterations under 200ms', () {
      final allForms = FormType.values.toSet();
      final categories = RequiredPhotoCategory.values;
      final stopwatch = Stopwatch();

      // Warm-up
      for (final cat in categories) {
        EvidenceSharingMatrix.formsAcceptingCategoryFiltered(cat, allForms);
      }

      stopwatch.start();
      for (var i = 0; i < 1000; i++) {
        final category = categories[i % categories.length];
        final result = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
          category,
          allForms,
        );
        expect(result, isNotNull);
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      expect(
        totalMs,
        lessThan(200),
        reason: '1000 filtered matrix lookups took ${totalMs}ms, expected <200ms',
      );
    });

    test('equivalentCategories bulk lookup: 5000 iterations under 100ms', () {
      final categories = RequiredPhotoCategory.values;
      final stopwatch = Stopwatch();

      // Warm-up
      for (final cat in categories) {
        EvidenceSharingMatrix.equivalentCategories(cat);
      }

      stopwatch.start();
      for (var i = 0; i < 5000; i++) {
        final category = categories[i % categories.length];
        final result = EvidenceSharingMatrix.equivalentCategories(category);
        // Just prevent optimization
        if (result.length > 100) fail('Unreachable');
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      expect(
        totalMs,
        lessThan(100),
        reason: '5000 equivalentCategories lookups took ${totalMs}ms, expected <100ms',
      );
    });

    test('isSharedCategory check: all categories in under 50ms for 10000 iterations', () {
      final categories = RequiredPhotoCategory.values;
      final stopwatch = Stopwatch();

      // Warm-up
      for (final cat in categories) {
        EvidenceSharingMatrix.isSharedCategory(cat);
      }

      stopwatch.start();
      for (var i = 0; i < 10000; i++) {
        final category = categories[i % categories.length];
        EvidenceSharingMatrix.isSharedCategory(category);
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      expect(
        totalMs,
        lessThan(50),
        reason: '10000 isSharedCategory checks took ${totalMs}ms, expected <50ms',
      );
    });
  });
}
