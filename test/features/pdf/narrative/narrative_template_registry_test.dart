import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_exceptions.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_section.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_template.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_template_registry.dart';

/// Minimal template stub for registry tests.
class _StubTemplate extends NarrativeTemplate {
  const _StubTemplate({
    required super.formType,
    super.revisionLabel = 'Rev 1.0',
    super.title = 'Stub Report',
  });

  @override
  List<NarrativeSection> buildSections({
    required Map<String, dynamic> formData,
    required Map<String, dynamic> branchContext,
  }) =>
      [];

  @override
  Set<String> get requiredPhotoKeys => {};

  @override
  Set<String> get referencedFormDataKeys => {};
}

void main() {
  group('NarrativeTemplateRegistry', () {
    late NarrativeTemplateRegistry registry;

    setUp(() {
      registry = const NarrativeTemplateRegistry(
        templates: {
          FormType.generalInspection: _StubTemplate(
            formType: FormType.generalInspection,
            title: 'General Inspection Report',
          ),
          FormType.moldAssessment: _StubTemplate(
            formType: FormType.moldAssessment,
            title: 'Mold Assessment Report',
          ),
        },
      );
    });

    test('lookup returns template for registered FormType', () {
      final result = registry.lookup(FormType.generalInspection);

      expect(result, isNotNull);
      expect(result!.formType, FormType.generalInspection);
      expect(result.title, 'General Inspection Report');
    });

    test('lookup returns null for unregistered FormType', () {
      final result = registry.lookup(FormType.fourPoint);

      expect(result, isNull);
    });

    test('require returns template for registered FormType', () {
      final result = registry.require(FormType.moldAssessment);

      expect(result.formType, FormType.moldAssessment);
      expect(result.title, 'Mold Assessment Report');
    });

    test('require throws NarrativeTemplateNotFoundError for unregistered FormType', () {
      expect(
        () => registry.require(FormType.windMitigation),
        throwsA(isA<NarrativeTemplateNotFoundError>()),
      );
    });

    test('supports returns true for registered FormType', () {
      expect(registry.supports(FormType.generalInspection), isTrue);
      expect(registry.supports(FormType.moldAssessment), isTrue);
    });

    test('supports returns false for unregistered FormType', () {
      expect(registry.supports(FormType.fourPoint), isFalse);
      expect(registry.supports(FormType.roofCondition), isFalse);
    });

    test('empty registry supports nothing', () {
      const emptyRegistry = NarrativeTemplateRegistry();

      expect(emptyRegistry.supports(FormType.generalInspection), isFalse);
      expect(emptyRegistry.lookup(FormType.generalInspection), isNull);
      expect(
        () => emptyRegistry.require(FormType.generalInspection),
        throwsA(isA<NarrativeTemplateNotFoundError>()),
      );
    });
  });
}
