import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/pdf/domain/pdf_size_budget.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_exceptions.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_media_resolver.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_report_engine.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_template_registry.dart';
import 'package:inspectobot/features/pdf/narrative/templates/general_inspection_template.dart';
import 'package:inspectobot/features/pdf/narrative/templates/mold_assessment_template.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';

void main() {
  late NarrativeReportEngine engine;
  const retryStep = PdfSizeRetryStep(jpegQuality: 75, maxWidth: 1280);

  setUp(() {
    engine = NarrativeReportEngine(
      registry: const NarrativeTemplateRegistry(templates: {
        FormType.moldAssessment: MoldAssessmentTemplate(),
        FormType.generalInspection: GeneralInspectionTemplate(),
      }),
      mediaResolver: const NarrativeMediaResolver(),
      theme: NarrativePrintTheme.standard(),
    );
  });

  group('NarrativeReportEngine.supports', () {
    test('returns true for moldAssessment', () {
      expect(engine.supports(FormType.moldAssessment), isTrue);
    });

    test('returns true for generalInspection', () {
      expect(engine.supports(FormType.generalInspection), isTrue);
    });

    test('returns false for fourPoint', () {
      expect(engine.supports(FormType.fourPoint), isFalse);
    });

    test('returns false for windMitigation', () {
      expect(engine.supports(FormType.windMitigation), isFalse);
    });
  });

  group('NarrativeReportEngine.generate', () {
    PdfGenerationInput buildInput({
      FormType formType = FormType.moldAssessment,
      Map<String, dynamic> formData = const {},
    }) {
      return PdfGenerationInput(
        inspectionId: 'insp-narrative-1',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Test Client',
        propertyAddress: '100 Narrative Ln',
        enabledForms: {formType},
        capturedCategories: const {},
        narrativeFormData: {formType: formData},
      );
    }

    test('produces valid PDF bytes for mold assessment', () async {
      final input = buildInput(
        formType: FormType.moldAssessment,
        formData: {
          'scope_of_assessment': 'Visual mold assessment of entire unit.',
          'visual_observations': 'Visible mold growth on bathroom ceiling.',
        },
      );

      final bytes = await engine.generate(
        input: input,
        formType: FormType.moldAssessment,
        retryStep: retryStep,
      );

      expect(bytes, isNotEmpty);
      // PDF magic bytes: %PDF
      expect(bytes[0], 0x25); // %
      expect(bytes[1], 0x50); // P
      expect(bytes[2], 0x44); // D
      expect(bytes[3], 0x46); // F
    });

    test('produces valid PDF bytes for general inspection', () async {
      final input = buildInput(
        formType: FormType.generalInspection,
        formData: {
          'scope_and_purpose': 'Full home inspection per Rule 61-30.801.',
        },
      );

      final bytes = await engine.generate(
        input: input,
        formType: FormType.generalInspection,
        retryStep: retryStep,
      );

      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x25);
      expect(bytes[1], 0x50);
    });

    test('throws NarrativeTemplateNotFoundError for unregistered form type',
        () async {
      final input = PdfGenerationInput(
        inspectionId: 'insp-narrative-2',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Test Client',
        propertyAddress: '200 Missing Template Dr',
        enabledForms: {FormType.fourPoint},
        capturedCategories: const {},
      );

      expect(
        () => engine.generate(
          input: input,
          formType: FormType.fourPoint,
          retryStep: retryStep,
        ),
        throwsA(isA<NarrativeTemplateNotFoundError>()),
      );
    });

    test('produces PDF with empty formData (graceful degradation)', () async {
      final input = buildInput(
        formType: FormType.moldAssessment,
        formData: const {},
      );

      final bytes = await engine.generate(
        input: input,
        formType: FormType.moldAssessment,
        retryStep: retryStep,
      );

      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x25);
    });

    test('generates PDF without signature bytes (null)', () async {
      final input = PdfGenerationInput(
        inspectionId: 'insp-no-sig-1',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'No Signature Test',
        propertyAddress: '300 NoSig Rd',
        enabledForms: {FormType.moldAssessment},
        capturedCategories: const {},
        narrativeFormData: {
          FormType.moldAssessment: {'scope_of_assessment': 'Test scope.'},
        },
      );

      final bytes = await engine.generate(
        input: input,
        formType: FormType.moldAssessment,
        retryStep: retryStep,
      );

      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x25); // %PDF
    });
  });
}
