import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/condition_rating.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/general_inspection_form_data.dart';
import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/features/inspection/domain/system_inspection_data.dart';
import 'package:inspectobot/features/pdf/domain/pdf_size_budget.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_media_resolver.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_print_theme.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_report_engine.dart';
import 'package:inspectobot/features/pdf/narrative/narrative_template_registry.dart';
import 'package:inspectobot/features/pdf/narrative/templates/general_inspection_template.dart';
import 'package:inspectobot/features/pdf/narrative/templates/mold_assessment_template.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';

/// End-to-end integration tests for narrative PDF generation across
/// moldAssessment and generalInspection form types.
///
/// These tests exercise the full NarrativeReportEngine pipeline:
/// template lookup → media resolution → render context → NarrativePdfRenderer.
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

  // ---------------------------------------------------------------------------
  // Mold Assessment E2E
  // ---------------------------------------------------------------------------

  group('moldAssessment E2E', () {
    test('generates multi-page PDF with fully populated mold data', () async {
      final moldData = MoldFormData(
        scopeOfAssessment:
            'Visual mold assessment of entire 1,800 sq ft residential unit '
            'including all interior living spaces, bathrooms, kitchen, '
            'garage, and accessible attic areas.',
        visualObservations:
            'Visible mold growth observed on bathroom ceiling (approx. 4 sq ft '
            'area, dark green/black coloration). Additional suspected growth '
            'behind master bathroom vanity cabinet.',
        moistureSources:
            'Active roof leak identified above master bathroom — water staining '
            'on ceiling drywall. Elevated moisture readings (>25%) on bathroom '
            'wall behind shower. Condensation on HVAC supply ducts in attic.',
        moldTypeLocation:
            'Suspected Stachybotrys chartarum on bathroom ceiling. Suspected '
            'Cladosporium on vanity cabinet rear. Both areas documented with '
            'photo evidence.',
        remediationRecommendations:
            '1. Repair active roof leak before remediation. '
            '2. Containment barrier installation required. '
            '3. HEPA air scrubber during removal. '
            '4. Remove affected drywall 2 ft beyond visible growth. '
            '5. Apply antimicrobial treatment. '
            '6. Post-remediation verification assessment recommended.',
        additionalFindings:
            'HVAC system contributing to moisture distribution. Recommend '
            'duct sealing and dehumidification assessment.',
        remediationRecommended: true,
        airSamplesTaken: true,
      );

      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-mold-full',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Mold Assessment Client',
        propertyAddress: '100 Mold Ln, Tampa, FL 33601',
        enabledForms: {FormType.moldAssessment},
        capturedCategories: const {},
        narrativeFormData: {
          FormType.moldAssessment: moldData.toFormDataMap(),
        },
        branchContext: const <String, dynamic>{
          'mold_visible_found': true,
          'mold_moisture_source_found': true,
          'mold_samples_taken': true,
          'mold_air_samples_taken': true,
          'mold_remediation_recommended': true,
        },
        fieldValues: const <String, String>{
          'inspector_name': 'John Smith, MRSA',
          'inspector_license': 'MRSA-12345',
          'inspector_company': 'Florida Mold Pros Inc.',
        },
      );

      final bytes = await engine.generate(
        input: input,
        formType: FormType.moldAssessment,
        retryStep: retryStep,
      );

      expect(bytes, isNotEmpty);
      // PDF magic bytes
      expect(bytes[0], 0x25); // %
      expect(bytes[1], 0x50); // P
      expect(bytes[2], 0x44); // D
      expect(bytes[3], 0x46); // F
      // Multi-page report should be substantial
      expect(bytes.length, greaterThan(1000));
    });

    test('generates PDF with minimal mold data (empty form data)', () async {
      final moldData = MoldFormData.empty();

      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-mold-min',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Minimal Mold Client',
        propertyAddress: '1 Min Mold St',
        enabledForms: {FormType.moldAssessment},
        capturedCategories: const {},
        narrativeFormData: {
          FormType.moldAssessment: moldData.toFormDataMap(),
        },
      );

      final bytes = await engine.generate(
        input: input,
        formType: FormType.moldAssessment,
        retryStep: retryStep,
      );

      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x25);
      // Still generates with boilerplate sections (ToC, disclaimer, signature)
      expect(bytes.length, greaterThan(500));
    });

    test('generates PDF with remediation recommended but no air samples',
        () async {
      final moldData = MoldFormData(
        scopeOfAssessment: 'Limited visual assessment of master bedroom.',
        visualObservations: 'Minor mold growth behind dresser.',
        moistureSources: 'No active moisture source identified.',
        moldTypeLocation: 'Suspected Aspergillus on drywall.',
        remediationRecommendations: 'Clean affected area, improve ventilation.',
        additionalFindings: '',
        remediationRecommended: true,
        airSamplesTaken: false,
      );

      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-mold-partial',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Partial Mold Client',
        propertyAddress: '50 Partial Mold Ave',
        enabledForms: {FormType.moldAssessment},
        capturedCategories: const {},
        narrativeFormData: {
          FormType.moldAssessment: moldData.toFormDataMap(),
        },
        branchContext: const <String, dynamic>{
          'mold_visible_found': true,
          'mold_remediation_recommended': true,
        },
      );

      final bytes = await engine.generate(
        input: input,
        formType: FormType.moldAssessment,
        retryStep: retryStep,
      );

      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x25);
    });

    test('generates PDF with post-remediation assessment flag', () async {
      final moldData = MoldFormData(
        scopeOfAssessment: 'Post-remediation clearance assessment.',
        visualObservations: 'No visible mold growth after remediation.',
        moistureSources: 'Roof leak repaired. Moisture readings normal.',
        moldTypeLocation: 'N/A — no mold found post-remediation.',
        remediationRecommendations: 'None — remediation successful.',
        additionalFindings: 'Recommend annual moisture monitoring.',
        remediationRecommended: false,
        airSamplesTaken: true,
      );

      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-mold-post',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Post Remediation Client',
        propertyAddress: '75 Post Remediation Dr',
        enabledForms: {FormType.moldAssessment},
        capturedCategories: const {},
        narrativeFormData: {
          FormType.moldAssessment: moldData.toFormDataMap(),
        },
        branchContext: const <String, dynamic>{
          'mold_post_remediation': true,
          'mold_air_samples_taken': true,
        },
      );

      final bytes = await engine.generate(
        input: input,
        formType: FormType.moldAssessment,
        retryStep: retryStep,
      );

      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x25);
    });
  });

  // ---------------------------------------------------------------------------
  // General Inspection E2E
  // ---------------------------------------------------------------------------

  group('generalInspection E2E', () {
    test('generates multi-page PDF with all 9 systems rated', () async {
      final formData = GeneralInspectionFormData(
        scopeAndPurpose:
            'Full home inspection per Florida Rule 61-30.801 F.A.C. covering '
            'all 9 mandatory systems.',
        generalComments:
            'Property is in overall satisfactory condition with minor findings '
            'in exterior and electrical systems.',
        structural: SystemInspectionData.structural().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Foundation slab — no cracks. Wood frame intact.',
          subsystems: [
            const SubsystemData(
              id: 'foundation',
              name: 'Foundation',
              rating: ConditionRating.satisfactory,
              findings: 'Slab foundation — no settlement cracks observed.',
            ),
            const SubsystemData(
              id: 'framing',
              name: 'Framing',
              rating: ConditionRating.satisfactory,
              findings: 'Wood frame intact, no visible damage.',
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
          rating: ConditionRating.marginal,
          findings: 'Minor stucco cracking on east wall.',
          subsystems: [
            const SubsystemData(
              id: 'siding',
              name: 'Siding',
              rating: ConditionRating.marginal,
              findings: 'Hairline stucco cracks — monitor for expansion.',
            ),
            const SubsystemData(
              id: 'trim',
              name: 'Trim',
              rating: ConditionRating.satisfactory,
              findings: 'Fascia and soffit intact.',
            ),
            const SubsystemData(
              id: 'porches',
              name: 'Porches',
              rating: ConditionRating.satisfactory,
              findings: 'Screened porch functional.',
            ),
            const SubsystemData(
              id: 'driveways',
              name: 'Driveways',
              rating: ConditionRating.satisfactory,
              findings: 'Concrete driveway — minor surface wear.',
            ),
          ],
        ),
        roofing: SystemInspectionData.roofing().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'Shingle roof — 10 years old, good condition.',
          subsystems: [
            const SubsystemData(
              id: 'covering',
              name: 'Covering',
              rating: ConditionRating.satisfactory,
              findings: 'Architectural shingles — no missing tabs.',
            ),
            const SubsystemData(
              id: 'flashing',
              name: 'Flashing',
              rating: ConditionRating.satisfactory,
              findings: 'Flashing sealed at all penetrations.',
            ),
            const SubsystemData(
              id: 'drainage',
              name: 'Drainage',
              rating: ConditionRating.satisfactory,
              findings: 'Gutters clear and properly sloped.',
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
              findings: 'CPVC supply lines — adequate pressure.',
            ),
            const SubsystemData(
              id: 'drain_waste',
              name: 'Drain/Waste',
              rating: ConditionRating.satisfactory,
              findings: 'PVC drain lines — flowing properly.',
            ),
            const SubsystemData(
              id: 'water_heater',
              name: 'Water Heater',
              rating: ConditionRating.satisfactory,
              findings: '50-gallon electric — TPR valve functional.',
            ),
          ],
        ),
        electrical: SystemInspectionData.electrical().copyWith(
          rating: ConditionRating.marginal,
          findings: 'Open junction box in garage — needs cover.',
          subsystems: [
            const SubsystemData(
              id: 'service',
              name: 'Service',
              rating: ConditionRating.satisfactory,
              findings: '200A service — adequate for dwelling.',
            ),
            const SubsystemData(
              id: 'panels',
              name: 'Panels',
              rating: ConditionRating.satisfactory,
              findings: 'Panel properly labeled, no double-taps.',
            ),
            const SubsystemData(
              id: 'branch_circuits',
              name: 'Branch Circuits',
              rating: ConditionRating.marginal,
              findings: 'Open junction box requires cover plate.',
            ),
            const SubsystemData(
              id: 'gfci',
              name: 'GFCI',
              rating: ConditionRating.satisfactory,
              findings: 'GFCI outlets tested — all tripping properly.',
            ),
          ],
        ),
        hvac: SystemInspectionData.hvac().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'HVAC system operational — 5 years old.',
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
              findings: '3-ton central AC — adequate cooling.',
            ),
            const SubsystemData(
              id: 'distribution',
              name: 'Distribution',
              rating: ConditionRating.satisfactory,
              findings: 'Flex duct in good condition.',
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
              findings: 'R-30 blown-in insulation present.',
            ),
            const SubsystemData(
              id: 'wall',
              name: 'Wall',
              rating: ConditionRating.satisfactory,
              findings: 'Wall insulation present per thermal scan.',
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
              findings: 'Smoke detectors in all bedrooms and hallway.',
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

      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-gen-full',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'General Inspection Client',
        propertyAddress: '200 General Ave, Orlando, FL 32801',
        enabledForms: {FormType.generalInspection},
        capturedCategories: const {},
        narrativeFormData: {
          FormType.generalInspection: formData.toFormDataMap(),
        },
        fieldValues: const <String, String>{
          'inspector_name': 'Jane Inspector, HI-1234',
          'inspector_license': 'HI-1234',
          'inspector_company': 'Florida Home Inspectors LLC',
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
      expect(bytes[2], 0x44);
      expect(bytes[3], 0x46);
      // Multi-page report with 9 systems should be substantial
      expect(bytes.length, greaterThan(2000));
    });

    test('generates PDF with all 9 systems deficient', () async {
      final formData = GeneralInspectionFormData(
        scopeAndPurpose: 'Full home inspection.',
        generalComments: 'Major deficiencies identified across all systems.',
        structural: SystemInspectionData.structural().copyWith(
          rating: ConditionRating.deficient,
          findings: 'Settlement cracks in slab foundation.',
        ),
        exterior: SystemInspectionData.exterior().copyWith(
          rating: ConditionRating.deficient,
          findings: 'Significant stucco damage — water intrusion.',
        ),
        roofing: SystemInspectionData.roofing().copyWith(
          rating: ConditionRating.deficient,
          findings: 'Multiple missing shingles, active leak.',
        ),
        plumbing: SystemInspectionData.plumbing().copyWith(
          rating: ConditionRating.deficient,
          findings: 'Polybutylene supply lines — recommend replacement.',
        ),
        electrical: SystemInspectionData.electrical().copyWith(
          rating: ConditionRating.deficient,
          findings: 'Federal Pacific panel — safety hazard.',
        ),
        hvac: SystemInspectionData.hvac().copyWith(
          rating: ConditionRating.deficient,
          findings: 'System not cooling — 20 years old.',
        ),
        insulationVentilation:
            SystemInspectionData.insulationVentilation().copyWith(
          rating: ConditionRating.deficient,
          findings: 'No attic insulation present.',
        ),
        appliances: SystemInspectionData.appliances().copyWith(
          rating: ConditionRating.deficient,
          findings: 'Dishwasher leaking at supply connection.',
        ),
        lifeSafety: SystemInspectionData.lifeSafety().copyWith(
          rating: ConditionRating.deficient,
          findings: 'No smoke detectors present.',
        ),
        safetyHazard: true,
        structuralConcern: true,
      );

      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-gen-deficient',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Deficient Client',
        propertyAddress: '300 Deficient Rd',
        enabledForms: {FormType.generalInspection},
        capturedCategories: const {},
        narrativeFormData: {
          FormType.generalInspection: formData.toFormDataMap(),
        },
        branchContext: const <String, dynamic>{
          'general_safety_hazard': true,
          'general_structural_concern': true,
        },
      );

      final bytes = await engine.generate(
        input: input,
        formType: FormType.generalInspection,
        retryStep: retryStep,
      );

      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x25);
    });

    test('generates PDF with empty form data (graceful degradation)', () async {
      final formData = GeneralInspectionFormData.empty();

      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-gen-empty',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Empty Client',
        propertyAddress: '1 Empty St',
        enabledForms: {FormType.generalInspection},
        capturedCategories: const {},
        narrativeFormData: {
          FormType.generalInspection: formData.toFormDataMap(),
        },
      );

      final bytes = await engine.generate(
        input: input,
        formType: FormType.generalInspection,
        retryStep: retryStep,
      );

      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x25);
      // Even empty data produces valid PDF with boilerplate sections
      expect(bytes.length, greaterThan(500));
    });

    test('generates PDF with moisture/mold and pest branch flags', () async {
      final formData = GeneralInspectionFormData(
        scopeAndPurpose: 'Inspection with moisture and pest concerns.',
        generalComments: 'Moisture and pest evidence noted.',
        structural: SystemInspectionData.structural().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'OK.',
        ),
        exterior: SystemInspectionData.exterior().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'OK.',
        ),
        roofing: SystemInspectionData.roofing().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'OK.',
        ),
        plumbing: SystemInspectionData.plumbing().copyWith(
          rating: ConditionRating.marginal,
          findings: 'Slow drain under master bath sink.',
        ),
        electrical: SystemInspectionData.electrical().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'OK.',
        ),
        hvac: SystemInspectionData.hvac().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'OK.',
        ),
        insulationVentilation:
            SystemInspectionData.insulationVentilation().copyWith(
          rating: ConditionRating.marginal,
          findings: 'Elevated moisture in attic insulation.',
        ),
        appliances: SystemInspectionData.appliances().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'OK.',
        ),
        lifeSafety: SystemInspectionData.lifeSafety().copyWith(
          rating: ConditionRating.satisfactory,
          findings: 'OK.',
        ),
        moistureMoldEvidence: true,
        pestEvidence: true,
      );

      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-gen-branch',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Branch Flag Client',
        propertyAddress: '400 Branch Dr',
        enabledForms: {FormType.generalInspection},
        capturedCategories: const {},
        narrativeFormData: {
          FormType.generalInspection: formData.toFormDataMap(),
        },
        branchContext: const <String, dynamic>{
          'general_moisture_mold_evidence': true,
          'general_pest_evidence': true,
        },
      );

      final bytes = await engine.generate(
        input: input,
        formType: FormType.generalInspection,
        retryStep: retryStep,
      );

      expect(bytes, isNotEmpty);
      expect(bytes[0], 0x25);
    });
  });

  // ---------------------------------------------------------------------------
  // Cross-narrative: both narrative forms in sequence
  // ---------------------------------------------------------------------------

  group('multi-narrative generation', () {
    test('generates both mold and general inspection PDFs independently',
        () async {
      final moldData = MoldFormData(
        scopeOfAssessment: 'Visual mold assessment.',
        visualObservations: 'Mold on bathroom ceiling.',
      );

      final genData = GeneralInspectionFormData(
        scopeAndPurpose: 'General inspection.',
        generalComments: 'Satisfactory.',
        structural: SystemInspectionData.structural(),
        exterior: SystemInspectionData.exterior(),
        roofing: SystemInspectionData.roofing(),
        plumbing: SystemInspectionData.plumbing(),
        electrical: SystemInspectionData.electrical(),
        hvac: SystemInspectionData.hvac(),
        insulationVentilation: SystemInspectionData.insulationVentilation(),
        appliances: SystemInspectionData.appliances(),
        lifeSafety: SystemInspectionData.lifeSafety(),
      );

      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-both-narrative',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Dual Narrative Client',
        propertyAddress: '500 Dual Narrative Blvd',
        enabledForms: {FormType.moldAssessment, FormType.generalInspection},
        capturedCategories: const {},
        narrativeFormData: {
          FormType.moldAssessment: moldData.toFormDataMap(),
          FormType.generalInspection: genData.toFormDataMap(),
        },
      );

      // Generate each independently (as PdfOrchestrator would)
      final moldBytes = await engine.generate(
        input: input,
        formType: FormType.moldAssessment,
        retryStep: retryStep,
      );
      final genBytes = await engine.generate(
        input: input,
        formType: FormType.generalInspection,
        retryStep: retryStep,
      );

      expect(moldBytes, isNotEmpty);
      expect(moldBytes[0], 0x25);

      expect(genBytes, isNotEmpty);
      expect(genBytes[0], 0x25);

      // Both should be valid but different PDFs
      expect(moldBytes.length, isNot(equals(genBytes.length)));
    });
  });
}
