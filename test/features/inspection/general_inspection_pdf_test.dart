import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/condition_rating.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/general_inspection_form_data.dart';
import 'package:inspectobot/features/inspection/domain/system_inspection_data.dart';
import 'package:inspectobot/features/pdf/domain/pdf_size_budget.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_media_resolver.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_report_engine.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_template_registry.dart';
import 'package:inspectobot/features/pdf/narrative/templates/general_inspection_template.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';

void main() {
  late NarrativeReportEngine engine;
  const retryStep = PdfSizeRetryStep(jpegQuality: 75, maxWidth: 1280);

  setUp(() {
    engine = NarrativeReportEngine(
      registry: const NarrativeTemplateRegistry(templates: {
        FormType.generalInspection: GeneralInspectionTemplate(),
      }),
      mediaResolver: const NarrativeMediaResolver(remoteReadBytes: null),
      theme: NarrativePrintTheme.standard(),
    );
  });

  PdfGenerationInput buildInput({
    Map<String, dynamic> formData = const {},
  }) {
    return PdfGenerationInput(
      inspectionId: 'insp-gen-pdf-1',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Test Client',
      propertyAddress: '123 Test Ave, Tampa, FL 33601',
      enabledForms: {FormType.generalInspection},
      capturedCategories: const {},
      narrativeFormData: {FormType.generalInspection: formData},
    );
  }

  GeneralInspectionFormData createPopulatedFormData() {
    return GeneralInspectionFormData(
      scopeAndPurpose:
          'Full home inspection per Florida Rule 61-30.801 F.A.C.',
      generalComments:
          'Property is in overall satisfactory condition with minor findings.',
      structural: SystemInspectionData.structural().copyWith(
        rating: ConditionRating.satisfactory,
        findings: 'Foundation and framing in good condition.',
        subsystems: [
          const SubsystemData(
            id: 'foundation',
            name: 'Foundation',
            rating: ConditionRating.satisfactory,
            findings: 'Slab foundation — no cracks observed.',
          ),
          const SubsystemData(
            id: 'framing',
            name: 'Framing',
            rating: ConditionRating.satisfactory,
            findings: 'Wood frame intact.',
          ),
          const SubsystemData(
            id: 'roof_structure',
            name: 'Roof Structure',
            rating: ConditionRating.satisfactory,
            findings: 'Truss system in good condition.',
          ),
        ],
      ),
      exterior: SystemInspectionData.exterior().copyWith(
        rating: ConditionRating.satisfactory,
        findings: 'Exterior in good condition.',
        subsystems: [
          const SubsystemData(
            id: 'siding',
            name: 'Siding',
            rating: ConditionRating.satisfactory,
            findings: 'Stucco siding — no damage.',
          ),
          const SubsystemData(
            id: 'trim',
            name: 'Trim',
            rating: ConditionRating.satisfactory,
            findings: 'Trim intact.',
          ),
          const SubsystemData(
            id: 'porches',
            name: 'Porches',
            rating: ConditionRating.satisfactory,
            findings: 'Screened porch in good condition.',
          ),
          const SubsystemData(
            id: 'driveways',
            name: 'Driveways',
            rating: ConditionRating.satisfactory,
            findings: 'Concrete driveway — minor surface cracks.',
          ),
        ],
      ),
      roofing: SystemInspectionData.roofing().copyWith(
        rating: ConditionRating.satisfactory,
        findings: 'Roof covering in good condition.',
        subsystems: [
          const SubsystemData(
            id: 'covering',
            name: 'Covering',
            rating: ConditionRating.satisfactory,
            findings: 'Shingle roof — no missing shingles.',
          ),
          const SubsystemData(
            id: 'flashing',
            name: 'Flashing',
            rating: ConditionRating.satisfactory,
            findings: 'Flashing properly sealed.',
          ),
          const SubsystemData(
            id: 'drainage',
            name: 'Drainage',
            rating: ConditionRating.satisfactory,
            findings: 'Gutters clear and functional.',
          ),
        ],
      ),
      plumbing: SystemInspectionData.plumbing().copyWith(
        rating: ConditionRating.satisfactory,
        findings: 'Plumbing system operational.',
        subsystems: [
          const SubsystemData(
            id: 'supply',
            name: 'Supply',
            rating: ConditionRating.satisfactory,
            findings: 'Adequate water pressure.',
          ),
          const SubsystemData(
            id: 'drain_waste',
            name: 'Drain/Waste',
            rating: ConditionRating.satisfactory,
            findings: 'Drains flowing properly.',
          ),
          const SubsystemData(
            id: 'water_heater',
            name: 'Water Heater',
            rating: ConditionRating.satisfactory,
            findings: '50-gallon electric — functional.',
          ),
        ],
      ),
      electrical: SystemInspectionData.electrical().copyWith(
        rating: ConditionRating.satisfactory,
        findings: 'Electrical system in good condition.',
        subsystems: [
          const SubsystemData(
            id: 'service',
            name: 'Service',
            rating: ConditionRating.satisfactory,
            findings: '200A service — adequate.',
          ),
          const SubsystemData(
            id: 'panels',
            name: 'Panels',
            rating: ConditionRating.satisfactory,
            findings: 'Panel properly labeled.',
          ),
          const SubsystemData(
            id: 'branch_circuits',
            name: 'Branch Circuits',
            rating: ConditionRating.satisfactory,
            findings: 'All circuits functional.',
          ),
          const SubsystemData(
            id: 'gfci',
            name: 'GFCI',
            rating: ConditionRating.satisfactory,
            findings: 'GFCI outlets tested — operational.',
          ),
        ],
      ),
      hvac: SystemInspectionData.hvac().copyWith(
        rating: ConditionRating.satisfactory,
        findings: 'HVAC system functional.',
        subsystems: [
          const SubsystemData(
            id: 'heating',
            name: 'Heating',
            rating: ConditionRating.satisfactory,
            findings: 'Heat pump — operational.',
          ),
          const SubsystemData(
            id: 'cooling',
            name: 'Cooling',
            rating: ConditionRating.satisfactory,
            findings: 'Central AC — adequate cooling.',
          ),
          const SubsystemData(
            id: 'distribution',
            name: 'Distribution',
            rating: ConditionRating.satisfactory,
            findings: 'Ductwork in good condition.',
          ),
        ],
      ),
      insulationVentilation:
          SystemInspectionData.insulationVentilation().copyWith(
        rating: ConditionRating.satisfactory,
        findings: 'Insulation and ventilation adequate.',
        subsystems: [
          const SubsystemData(
            id: 'attic',
            name: 'Attic',
            rating: ConditionRating.satisfactory,
            findings: 'R-30 insulation present.',
          ),
          const SubsystemData(
            id: 'wall',
            name: 'Wall',
            rating: ConditionRating.satisfactory,
            findings: 'Wall insulation adequate.',
          ),
          const SubsystemData(
            id: 'crawlspace',
            name: 'Crawlspace',
            rating: ConditionRating.satisfactory,
            findings: 'N/A — slab construction.',
          ),
        ],
      ),
      appliances: SystemInspectionData.appliances().copyWith(
        rating: ConditionRating.satisfactory,
        findings: 'All built-in appliances functional.',
      ),
      lifeSafety: SystemInspectionData.lifeSafety().copyWith(
        rating: ConditionRating.satisfactory,
        findings: 'Life safety devices present and functional.',
        subsystems: [
          const SubsystemData(
            id: 'smoke_detectors',
            name: 'Smoke Detectors',
            rating: ConditionRating.satisfactory,
            findings: 'Smoke detectors in all bedrooms.',
          ),
          const SubsystemData(
            id: 'co_detectors',
            name: 'CO Detectors',
            rating: ConditionRating.satisfactory,
            findings: 'CO detector near sleeping areas.',
          ),
          const SubsystemData(
            id: 'fire_sprinklers',
            name: 'Fire Sprinklers',
            rating: ConditionRating.notInspected,
            findings: 'No fire sprinkler system present.',
          ),
        ],
      ),
    );
  }

  group('General Inspection PDF generation', () {
    test('generates valid PDF bytes with all systems rated satisfactory',
        () async {
      final formData = createPopulatedFormData();
      final input = buildInput(formData: formData.toFormDataMap());

      final bytes = await engine.generate(
        input: input,
        formType: FormType.generalInspection,
        retryStep: retryStep,
      );

      expect(bytes, isNotNull);
      expect(bytes.length, greaterThan(0));
      // PDF magic bytes: %PDF
      expect(bytes[0], 0x25); // %
      expect(bytes[1], 0x50); // P
      expect(bytes[2], 0x44); // D
      expect(bytes[3], 0x46); // F
    });

    test('generates PDF with mixed rating levels', () async {
      final formData = GeneralInspectionFormData(
        scopeAndPurpose: 'General home inspection.',
        generalComments: 'Mixed conditions noted.',
        structural: SystemInspectionData.structural().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Good condition.',
        ),
        exterior: SystemInspectionData.exterior().copyWith(
          rating: ConditionRating.marginal,
          findings: 'Minor paint peeling on south wall.',
        ),
        roofing: SystemInspectionData.roofing().copyWith(
          rating: ConditionRating.deficient,
          findings: 'Multiple missing shingles; recommend replacement.',
        ),
        plumbing: SystemInspectionData.plumbing().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Functional.',
        ),
        electrical: SystemInspectionData.electrical().copyWith(
          rating: ConditionRating.marginal,
          findings: 'Open junction box in garage.',
        ),
        hvac: SystemInspectionData.hvac().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Operational.',
        ),
        insulationVentilation:
            SystemInspectionData.insulationVentilation().copyWith(
          rating: ConditionRating.deficient,
          findings: 'Missing insulation in attic section.',
        ),
        appliances: SystemInspectionData.appliances().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'All appliances operational.',
        ),
        lifeSafety: SystemInspectionData.lifeSafety().copyWith(
          rating: ConditionRating.marginal,
          findings: 'One smoke detector battery dead.',
        ),
      );

      final input = buildInput(formData: formData.toFormDataMap());

      final bytes = await engine.generate(
        input: input,
        formType: FormType.generalInspection,
        retryStep: retryStep,
      );

      expect(bytes, isNotNull);
      expect(bytes.length, greaterThan(0));
      expect(bytes[0], 0x25); // %PDF
      expect(bytes[1], 0x50);
    });

    test('generates PDF from empty form data without crashing', () async {
      final formData = GeneralInspectionFormData.empty();
      final input = buildInput(formData: formData.toFormDataMap());

      final bytes = await engine.generate(
        input: input,
        formType: FormType.generalInspection,
        retryStep: retryStep,
      );

      expect(bytes, isNotNull);
      expect(bytes.length, greaterThan(0));
      expect(bytes[0], 0x25);
    });

    test('generates PDF with subsystem ratings populated', () async {
      final formData = GeneralInspectionFormData(
        scopeAndPurpose: 'Subsystem-level inspection.',
        generalComments: '',
        structural: SystemInspectionData.structural().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Overall structural satisfactory.',
          subsystems: [
            const SubsystemData(
              id: 'foundation',
              name: 'Foundation',
              rating: ConditionRating.satisfactory,
              findings: 'Slab — no cracks.',
            ),
            const SubsystemData(
              id: 'framing',
              name: 'Framing',
              rating: ConditionRating.marginal,
              findings: 'Minor termite damage noted on sill plate.',
            ),
            const SubsystemData(
              id: 'roof_structure',
              name: 'Roof Structure',
              rating: ConditionRating.deficient,
              findings: 'Sagging truss — recommend structural evaluation.',
            ),
          ],
        ),
        exterior: SystemInspectionData.exterior(),
        roofing: SystemInspectionData.roofing(),
        plumbing: SystemInspectionData.plumbing(),
        electrical: SystemInspectionData.electrical(),
        hvac: SystemInspectionData.hvac(),
        insulationVentilation: SystemInspectionData.insulationVentilation(),
        appliances: SystemInspectionData.appliances(),
        lifeSafety: SystemInspectionData.lifeSafety(),
      );

      final input = buildInput(formData: formData.toFormDataMap());

      final bytes = await engine.generate(
        input: input,
        formType: FormType.generalInspection,
        retryStep: retryStep,
      );

      expect(bytes, isNotNull);
      expect(bytes.length, greaterThan(0));
      expect(bytes[0], 0x25); // %PDF
    });
  });

  group('GeneralInspectionTemplate metadata', () {
    test('all referencedFormDataKeys exist in form data map', () {
      const template = GeneralInspectionTemplate();
      final formData = createPopulatedFormData();
      final formDataMap = formData.toFormDataMap();

      for (final key in template.referencedFormDataKeys) {
        expect(
          formDataMap.containsKey(key),
          isTrue,
          reason: 'Expected form data map to contain key "$key"',
        );
      }
    });

    test('all requiredPhotoKeys end with _photos and there are exactly 9', () {
      const template = GeneralInspectionTemplate();
      final photoKeys = template.requiredPhotoKeys;

      expect(photoKeys.length, 9);
      for (final key in photoKeys) {
        expect(
          key.endsWith('_photos'),
          isTrue,
          reason: 'Expected photo key "$key" to end with "_photos"',
        );
      }
    });
  });
}
