import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/pdf/data/pdf_media_resolver.dart';
import 'package:inspectobot/features/pdf/data/pdf_size_budget_config_store.dart';
import 'package:inspectobot/features/pdf/data/pdf_template_asset_loader.dart';
import 'package:inspectobot/features/pdf/models/pdf_template_manifest.dart';
import 'package:inspectobot/features/pdf/on_device_pdf_service.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
/// End-to-end integration tests for fillable PDF generation across all 5
/// overlay form types: fourPoint, roofCondition, windMitigation, wdo,
/// sinkholeInspection.
///
/// These tests exercise OnDevicePdfService with a real PdfRenderer (using the
/// `pdf` package) but fake template assets to avoid Flutter asset bundle
/// dependencies.
/// Valid PNG bytes for use as signature images in PDF rendering tests.
late Uint8List _validSignaturePng;

void main() {
  late _FakeTemplateLoader templateLoader;
  late PdfSizeBudgetConfigStore sizeBudgetStore;
  late OnDevicePdfService service;

  setUpAll(() {
    final sigImage = img.Image(width: 4, height: 4);
    img.fill(sigImage, color: img.ColorRgb8(0, 0, 0));
    _validSignaturePng = Uint8List.fromList(img.encodePng(sigImage));
  });

  setUp(() {
    templateLoader = _FakeTemplateLoader();
    sizeBudgetStore = PdfSizeBudgetConfigStore(
      readConfig: () => <String, dynamic>{
        'max_bytes': 10 * 1024 * 1024,
        'retry_steps': <Map<String, dynamic>>[
          <String, dynamic>{'jpeg_quality': 75, 'max_width': 1280},
        ],
      },
    );
    service = OnDevicePdfService(
      templateAssetLoader: templateLoader,
      mediaResolver: const PdfMediaResolver(),
      sizeBudgetStore: sizeBudgetStore,
      outputDirectoryProvider: () async => Directory.systemTemp,
    );
  });

  // ---------------------------------------------------------------------------
  // Per-form-type: full-data PDF generation
  // ---------------------------------------------------------------------------

  group('fourPoint E2E', () {
    test('generates PDF with all fields populated', () async {
      final photoFile = await _writeTempPng();
      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-4pt',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Jane Doe',
        propertyAddress: '123 Palm Ave, Tampa, FL 33601',
        enabledForms: {FormType.fourPoint},
        capturedCategories: {
          RequiredPhotoCategory.exteriorFront,
          RequiredPhotoCategory.exteriorRear,
          RequiredPhotoCategory.exteriorLeft,
          RequiredPhotoCategory.exteriorRight,
          RequiredPhotoCategory.roofSlopeMain,
          RequiredPhotoCategory.roofSlopeSecondary,
          RequiredPhotoCategory.waterHeaterTprValve,
          RequiredPhotoCategory.plumbingUnderSink,
          RequiredPhotoCategory.electricalPanelLabel,
          RequiredPhotoCategory.electricalPanelOpen,
          RequiredPhotoCategory.hvacDataPlate,
          RequiredPhotoCategory.hazardPhoto,
        },
        wizardCompletion: const <String, bool>{
          'photo:exterior_front': true,
          'photo:exterior_rear': true,
          'photo:exterior_left': true,
          'photo:exterior_right': true,
          'photo:roof_slope_main': true,
          'photo:roof_slope_secondary': true,
          'photo:water_heater_tpr_valve': true,
          'photo:plumbing_under_sink': true,
          'photo:electrical_panel_label': true,
          'photo:electrical_panel_open': true,
          'photo:hvac_data_plate': true,
          'photo:hazard_photo': true,
        },
        branchContext: const <String, dynamic>{
          'hazard_present': true,
        },
        fieldValues: const <String, String>{
          'client_name': 'Jane Doe',
          'inspection_id': 'insp-e2e-4pt',
        },
        evidenceMediaPaths: <String, List<String>>{
          'photo:exterior_front': [photoFile.path],
          'photo:exterior_rear': [photoFile.path],
          'photo:exterior_left': [photoFile.path],
          'photo:exterior_right': [photoFile.path],
          'photo:roof_slope_main': [photoFile.path],
          'photo:roof_slope_secondary': [photoFile.path],
          'photo:water_heater_tpr_valve': [photoFile.path],
          'photo:plumbing_under_sink': [photoFile.path],
          'photo:electrical_panel_label': [photoFile.path],
          'photo:electrical_panel_open': [photoFile.path],
          'photo:hvac_data_plate': [photoFile.path],
          'photo:hazard_photo': [photoFile.path],
        },
        signatureBytes: _validSignaturePng,
      );

      final file = await service.generate(input);
      expect(await file.exists(), isTrue);
      final length = await file.length();
      expect(length, greaterThan(0));
      // PDF magic bytes
      final bytes = await file.readAsBytes();
      expect(bytes[0], 0x25); // %
      expect(bytes[1], 0x50); // P
      expect(bytes[2], 0x44); // D
      expect(bytes[3], 0x46); // F
    });

    test('generates PDF with minimal data (no optional hazard photo)', () async {
      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-4pt-min',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Min User',
        propertyAddress: '1 Min St',
        enabledForms: {FormType.fourPoint},
        capturedCategories: const {},
        wizardCompletion: const <String, bool>{},
        fieldValues: const <String, String>{'client_name': 'Min User'},
      );

      final file = await service.generate(input);
      expect(await file.exists(), isTrue);
      expect(await file.length(), greaterThan(0));
    });
  });

  group('roofCondition E2E', () {
    test('generates PDF with all fields populated including defect', () async {
      final photoFile = await _writeTempPng();
      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-roof',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Roof Client',
        propertyAddress: '200 Roof Blvd',
        enabledForms: {FormType.roofCondition},
        capturedCategories: {
          RequiredPhotoCategory.roofSlopeMain,
          RequiredPhotoCategory.roofSlopeSecondary,
          RequiredPhotoCategory.roofDefect,
        },
        wizardCompletion: const <String, bool>{
          'photo:roof_condition_main_slope': true,
          'photo:roof_condition_secondary_slope': true,
          'photo:roof_defect': true,
        },
        branchContext: const <String, dynamic>{
          'roof_defect_present': true,
        },
        fieldValues: const <String, String>{'client_name': 'Roof Client'},
        evidenceMediaPaths: <String, List<String>>{
          'photo:roof_condition_main_slope': [photoFile.path],
          'photo:roof_condition_secondary_slope': [photoFile.path],
          'photo:roof_defect': [photoFile.path],
        },
        signatureBytes: _validSignaturePng,
      );

      final file = await service.generate(input);
      expect(await file.exists(), isTrue);
      final bytes = await file.readAsBytes();
      expect(bytes[0], 0x25);
      expect(bytes[1], 0x50);
    });

    test('generates PDF with minimal data (no defect)', () async {
      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-roof-min',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Min Roof',
        propertyAddress: '1 Min Roof St',
        enabledForms: {FormType.roofCondition},
        capturedCategories: const {},
      );

      final file = await service.generate(input);
      expect(await file.exists(), isTrue);
      expect(await file.length(), greaterThan(0));
    });
  });

  group('windMitigation E2E', () {
    test('generates PDF with all fields and document requirements', () async {
      final photoFile = await _writeTempPng();
      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-wind',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Wind Client',
        propertyAddress: '300 Wind Way',
        enabledForms: {FormType.windMitigation},
        capturedCategories: {
          RequiredPhotoCategory.windRoofDeck,
          RequiredPhotoCategory.windRoofToWall,
          RequiredPhotoCategory.windRoofShape,
          RequiredPhotoCategory.windSecondaryWaterResistance,
          RequiredPhotoCategory.windOpeningProtection,
          RequiredPhotoCategory.windOpeningType,
          RequiredPhotoCategory.windPermitYear,
        },
        wizardCompletion: const <String, bool>{
          'photo:wind_roof_deck': true,
          'photo:wind_roof_to_wall': true,
          'photo:wind_roof_shape': true,
          'photo:wind_secondary_water_resistance': true,
          'photo:wind_opening_protection': true,
          'photo:wind_opening_type': true,
          'photo:wind_permit_year': true,
          'document:wind_roof_deck': true,
          'document:wind_opening_protection': true,
          'document:wind_permit_year': true,
        },
        branchContext: const <String, dynamic>{
          'wind_roof_deck_document_required': true,
          'wind_opening_document_required': true,
          'wind_permit_document_required': true,
        },
        fieldValues: const <String, String>{'client_name': 'Wind Client'},
        evidenceMediaPaths: <String, List<String>>{
          'photo:wind_roof_deck': [photoFile.path],
          'photo:wind_roof_to_wall': [photoFile.path],
          'photo:wind_roof_shape': [photoFile.path],
          'photo:wind_secondary_water_resistance': [photoFile.path],
          'photo:wind_opening_protection': [photoFile.path],
          'photo:wind_opening_type': [photoFile.path],
          'photo:wind_permit_year': [photoFile.path],
          'document:wind_roof_deck': [photoFile.path],
          'document:wind_opening_protection': [photoFile.path],
          'document:wind_permit_year': [photoFile.path],
        },
        signatureBytes: _validSignaturePng,
      );

      final file = await service.generate(input);
      expect(await file.exists(), isTrue);
      final bytes = await file.readAsBytes();
      expect(bytes[0], 0x25);
      expect(bytes[1], 0x50);
    });

    test('generates PDF with minimal data (no document branches)', () async {
      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-wind-min',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Min Wind',
        propertyAddress: '1 Min Wind',
        enabledForms: {FormType.windMitigation},
        capturedCategories: const {},
      );

      final file = await service.generate(input);
      expect(await file.exists(), isTrue);
    });
  });

  group('wdo E2E', () {
    test('generates PDF with all WDO fields and branch flags', () async {
      final photoFile = await _writeTempPng();
      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-wdo',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'WDO Client',
        propertyAddress: '400 WDO Ln',
        enabledForms: {FormType.wdo},
        capturedCategories: {
          RequiredPhotoCategory.wdoPropertyExterior,
          RequiredPhotoCategory.wdoNoticePosting,
          RequiredPhotoCategory.wdoInfestationEvidence,
          RequiredPhotoCategory.wdoDamageArea,
          RequiredPhotoCategory.wdoInaccessibleArea,
        },
        wizardCompletion: const <String, bool>{
          'photo:wdo_property_exterior': true,
          'photo:wdo_notice_posting': true,
          'photo:wdo_infestation_evidence': true,
          'photo:wdo_damage_area': true,
          'photo:wdo_inaccessible_area': true,
        },
        branchContext: const <String, dynamic>{
          'wdo_visible_evidence': true,
          'wdo_live_wdo': true,
          'wdo_evidence_of_wdo': true,
          'wdo_damage_by_wdo': true,
          'wdo_previous_treatment': true,
          'wdo_treated_at_inspection': true,
          'wdo_attic_inaccessible': true,
        },
        fieldValues: const <String, String>{
          'client_name': 'WDO Client',
          'gen_company_name': 'Test Pest Co',
          'gen_inspector_name': 'John Inspector',
          'find_live_description': 'Subterranean termites in garage framing',
          'find_evidence_description': 'Mud tubes on foundation wall',
          'find_damage_description': 'Damaged sill plate — south wall',
        },
        evidenceMediaPaths: <String, List<String>>{
          'photo:wdo_property_exterior': [photoFile.path],
          'photo:wdo_notice_posting': [photoFile.path],
          'photo:wdo_infestation_evidence': [photoFile.path],
          'photo:wdo_damage_area': [photoFile.path],
          'photo:wdo_inaccessible_area': [photoFile.path],
        },
        signatureBytes: _validSignaturePng,
      );

      final file = await service.generate(input);
      expect(await file.exists(), isTrue);
      final bytes = await file.readAsBytes();
      expect(bytes[0], 0x25);
      expect(bytes[1], 0x50);
    });

    test('generates PDF with minimal WDO data', () async {
      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-wdo-min',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Min WDO',
        propertyAddress: '1 Min WDO',
        enabledForms: {FormType.wdo},
        capturedCategories: const {},
      );

      final file = await service.generate(input);
      expect(await file.exists(), isTrue);
    });
  });

  group('sinkholeInspection E2E', () {
    test('generates PDF with all sinkhole fields and checkboxes', () async {
      final photoFile = await _writeTempPng();
      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-sink',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Sinkhole Client',
        propertyAddress: '500 Sinkhole Dr',
        enabledForms: {FormType.sinkholeInspection},
        capturedCategories: {
          RequiredPhotoCategory.sinkholeFrontElevation,
          RequiredPhotoCategory.sinkholeRearElevation,
          RequiredPhotoCategory.sinkholeChecklistItem,
          RequiredPhotoCategory.sinkholeGarageCrack,
          RequiredPhotoCategory.sinkholeAdjacentStructure,
        },
        wizardCompletion: const <String, bool>{
          'photo:sinkhole_front_elevation': true,
          'photo:sinkhole_rear_elevation': true,
          'photo:sinkhole_checklist_item': true,
          'photo:sinkhole_checklist_item#2': true,
          'photo:sinkhole_garage_crack': true,
          'photo:sinkhole_adjacent_structure': true,
        },
        branchContext: const <String, dynamic>{
          'sinkhole_any_exterior_yes': true,
          'sinkhole_any_interior_yes': true,
          'sinkhole_any_garage_yes': true,
          'sinkhole_any_appurtenant_yes': true,
          'sinkhole_any_yes': true,
          'sinkhole_townhouse': true,
          'sinkhole_crack_significant': true,
        },
        fieldValues: const <String, String>{
          'client_name': 'Sinkhole Client',
          'insuredName': 'Sinkhole Client',
          'propertyAddress': '500 Sinkhole Dr',
          'generalConditionOverview': 'Multiple sinkhole indicators observed.',
        },
        checkboxValues: const <String, bool>{
          'ext1Depression__yes': true,
          'ext4FoundationCracks__yes': true,
          'int3CompressionCracks__yes': true,
          'gar1WallToSlabCracks__yes': true,
          'sinkhole_any_exterior_yes': true,
          'sinkhole_any_interior_yes': true,
          'sinkhole_any_garage_yes': true,
          'sinkhole_any_appurtenant_yes': true,
          'sinkhole_any_yes': true,
          'sinkhole_townhouse': true,
          'sinkhole_crack_significant': true,
        },
        evidenceMediaPaths: <String, List<String>>{
          'photo:sinkhole_front_elevation': [photoFile.path],
          'photo:sinkhole_rear_elevation': [photoFile.path],
          'photo:sinkhole_checklist_item': [photoFile.path],
          'photo:sinkhole_garage_crack': [photoFile.path],
          'photo:sinkhole_adjacent_structure': [photoFile.path],
        },
        signatureBytes: _validSignaturePng,
      );

      final file = await service.generate(input);
      expect(await file.exists(), isTrue);
      final bytes = await file.readAsBytes();
      expect(bytes[0], 0x25);
      expect(bytes[1], 0x50);
    });

    test('generates PDF with minimal sinkhole data', () async {
      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-sink-min',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Min Sink',
        propertyAddress: '1 Min Sink',
        enabledForms: {FormType.sinkholeInspection},
        capturedCategories: const {},
      );

      final file = await service.generate(input);
      expect(await file.exists(), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Cross-form: multi-form generation in a single pass
  // ---------------------------------------------------------------------------

  group('multi-form overlay generation', () {
    test('generates PDF for all 5 fillable forms simultaneously', () async {
      final input = PdfGenerationInput(
        inspectionId: 'insp-e2e-all-overlay',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'All Forms Client',
        propertyAddress: '999 All Forms Blvd',
        enabledForms: {
          FormType.fourPoint,
          FormType.roofCondition,
          FormType.windMitigation,
          FormType.wdo,
          FormType.sinkholeInspection,
        },
        capturedCategories: const {},
        fieldValues: const <String, String>{
          'client_name': 'All Forms Client',
        },
      );

      final file = await service.generate(input);
      expect(await file.exists(), isTrue);
      final bytes = await file.readAsBytes();
      expect(bytes[0], 0x25); // %PDF
      // With 5 forms, should have multiple pages
      expect(bytes.length, greaterThan(500));
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<File> _writeTempPng() async {
  // Generate a real 4x4 white PNG using the image package (same library
  // that the pdf package uses to decode images).
  final image = img.Image(width: 4, height: 4);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));
  final pngBytes = Uint8List.fromList(img.encodePng(image));
  final output = File(
    '${Directory.systemTemp.path}/pdf-e2e-${DateTime.now().microsecondsSinceEpoch}.png',
  );
  await output.writeAsBytes(pngBytes, flush: true);
  return output;
}

/// Fake template loader that returns in-memory field maps for all 5 fillable
/// form types. Uses the same map structure as the real JSON assets but with
/// zero-dimension fields (rendering still succeeds since PdfRenderer just
/// positions widgets).
class _FakeTemplateLoader extends PdfTemplateAssetLoader {
  _FakeTemplateLoader()
      : super(
          manifest: PdfTemplateManifest.standard(),
          readMapAsset: (assetPath) async {
            if (assetPath.contains('fdacs_13645')) {
              return _wdoMap;
            }
            if (assetPath.contains('sinkhole')) {
              return _sinkholeMap;
            }
            if (assetPath.contains('rcf1')) {
              return _roofMap;
            }
            if (assetPath.contains('oir_b1')) {
              return _windMap;
            }
            return _fourPointMap;
          },
          readTemplateAsset: (assetPath) async {
            return ByteData.view(Uint8List.fromList(_pdfStubBytes).buffer);
          },
        );
}

const List<int> _pdfStubBytes = <int>[
  0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x34, 0x0A,
];

const String _fourPointMap = '''
{
  "form_code": "four_point",
  "map_version": "v1",
  "fields": [
    {"key": "text.client_name", "source_key": "client_name", "type": "text", "page": 1, "x": 40, "y": 700, "width": 180, "height": 14},
    {"key": "image.photo_exterior_front", "source_key": "photo:exterior_front", "type": "image", "page": 1, "x": 40, "y": 520, "width": 120, "height": 90},
    {"key": "image.photo_exterior_rear", "source_key": "photo:exterior_rear", "type": "image", "page": 2, "x": 40, "y": 520, "width": 120, "height": 90},
    {"key": "image.photo_exterior_left", "source_key": "photo:exterior_left", "type": "image", "page": 2, "x": 200, "y": 520, "width": 120, "height": 90},
    {"key": "image.photo_exterior_right", "source_key": "photo:exterior_right", "type": "image", "page": 2, "x": 360, "y": 520, "width": 120, "height": 90},
    {"key": "image.photo_roof_slope_main", "source_key": "photo:roof_slope_main", "type": "image", "page": 2, "x": 40, "y": 400, "width": 120, "height": 90},
    {"key": "image.photo_roof_slope_secondary", "source_key": "photo:roof_slope_secondary", "type": "image", "page": 2, "x": 200, "y": 400, "width": 120, "height": 90},
    {"key": "image.photo_water_heater_tpr_valve", "source_key": "photo:water_heater_tpr_valve", "type": "image", "page": 3, "x": 40, "y": 520, "width": 120, "height": 90},
    {"key": "image.photo_plumbing_under_sink", "source_key": "photo:plumbing_under_sink", "type": "image", "page": 3, "x": 200, "y": 520, "width": 120, "height": 90},
    {"key": "image.photo_electrical_panel_label", "source_key": "photo:electrical_panel_label", "type": "image", "page": 3, "x": 360, "y": 520, "width": 120, "height": 90},
    {"key": "image.photo_electrical_panel_open", "source_key": "photo:electrical_panel_open", "type": "image", "page": 3, "x": 40, "y": 400, "width": 120, "height": 90},
    {"key": "image.photo_hvac_data_plate", "source_key": "photo:hvac_data_plate", "type": "image", "page": 3, "x": 200, "y": 400, "width": 120, "height": 90},
    {"key": "image.photo_hazard_photo", "source_key": "photo:hazard_photo", "type": "image", "page": 3, "x": 360, "y": 400, "width": 120, "height": 90},
    {"key": "signature.inspector", "source_key": "inspector_signature", "type": "signature", "page": 1, "x": 360, "y": 86, "width": 170, "height": 36}
  ]
}
''';

const String _roofMap = '''
{
  "form_code": "roof_condition",
  "map_version": "v1",
  "fields": [
    {"key": "text.client_name", "source_key": "client_name", "type": "text", "page": 1, "x": 40, "y": 700, "width": 180, "height": 14},
    {"key": "image.photo_roof_condition_main_slope", "source_key": "photo:roof_condition_main_slope", "type": "image", "page": 1, "x": 40, "y": 520, "width": 120, "height": 90},
    {"key": "image.photo_roof_condition_secondary_slope", "source_key": "photo:roof_condition_secondary_slope", "type": "image", "page": 1, "x": 200, "y": 520, "width": 120, "height": 90},
    {"key": "image.photo_roof_defect", "source_key": "photo:roof_defect", "type": "image", "page": 1, "x": 360, "y": 520, "width": 120, "height": 90},
    {"key": "signature.inspector", "source_key": "inspector_signature", "type": "signature", "page": 1, "x": 360, "y": 86, "width": 170, "height": 36}
  ]
}
''';

const String _windMap = '''
{
  "form_code": "wind_mitigation",
  "map_version": "v1",
  "fields": [
    {"key": "text.client_name", "source_key": "client_name", "type": "text", "page": 1, "x": 40, "y": 700, "width": 180, "height": 14},
    {"key": "image.photo_wind_roof_deck", "source_key": "photo:wind_roof_deck", "type": "image", "page": 1, "x": 40, "y": 520, "width": 120, "height": 90},
    {"key": "image.photo_wind_roof_to_wall", "source_key": "photo:wind_roof_to_wall", "type": "image", "page": 2, "x": 40, "y": 520, "width": 120, "height": 90},
    {"key": "image.photo_wind_roof_shape", "source_key": "photo:wind_roof_shape", "type": "image", "page": 2, "x": 200, "y": 520, "width": 120, "height": 90},
    {"key": "image.photo_wind_secondary_water_resistance", "source_key": "photo:wind_secondary_water_resistance", "type": "image", "page": 2, "x": 360, "y": 520, "width": 120, "height": 90},
    {"key": "image.photo_wind_opening_protection", "source_key": "photo:wind_opening_protection", "type": "image", "page": 2, "x": 40, "y": 400, "width": 120, "height": 90},
    {"key": "image.photo_wind_opening_type", "source_key": "photo:wind_opening_type", "type": "image", "page": 2, "x": 200, "y": 400, "width": 120, "height": 90},
    {"key": "image.photo_wind_permit_year", "source_key": "photo:wind_permit_year", "type": "image", "page": 2, "x": 360, "y": 400, "width": 120, "height": 90},
    {"key": "image.document_wind_roof_deck", "source_key": "document:wind_roof_deck", "type": "image", "page": 3, "x": 40, "y": 520, "width": 120, "height": 90},
    {"key": "image.document_wind_opening_protection", "source_key": "document:wind_opening_protection", "type": "image", "page": 3, "x": 200, "y": 520, "width": 120, "height": 90},
    {"key": "image.document_wind_permit_year", "source_key": "document:wind_permit_year", "type": "image", "page": 3, "x": 360, "y": 520, "width": 120, "height": 90},
    {"key": "signature.inspector", "source_key": "inspector_signature", "type": "signature", "page": 1, "x": 360, "y": 86, "width": 170, "height": 36}
  ]
}
''';

const String _wdoMap = '''
{
  "form_code": "wdo",
  "map_version": "v1",
  "fields": [
    {"key": "text.gen_company_name", "source_key": "gen_company_name", "type": "text", "page": 1, "x": 40, "y": 700, "width": 180, "height": 14},
    {"key": "text.gen_inspector_name", "source_key": "gen_inspector_name", "type": "text", "page": 1, "x": 40, "y": 680, "width": 180, "height": 14},
    {"key": "text.find_live_description", "source_key": "find_live_description", "type": "text", "page": 1, "x": 40, "y": 600, "width": 400, "height": 14},
    {"key": "text.find_evidence_description", "source_key": "find_evidence_description", "type": "text", "page": 1, "x": 40, "y": 580, "width": 400, "height": 14},
    {"key": "text.find_damage_description", "source_key": "find_damage_description", "type": "text", "page": 1, "x": 40, "y": 560, "width": 400, "height": 14},
    {"key": "image.wdo_property_exterior", "source_key": "photo:wdo_property_exterior", "type": "image", "page": 2, "x": 40, "y": 520, "width": 120, "height": 90},
    {"key": "image.wdo_notice_posting", "source_key": "photo:wdo_notice_posting", "type": "image", "page": 2, "x": 200, "y": 520, "width": 120, "height": 90},
    {"key": "image.wdo_infestation_evidence", "source_key": "photo:wdo_infestation_evidence", "type": "image", "page": 2, "x": 360, "y": 520, "width": 120, "height": 90},
    {"key": "image.wdo_damage_area", "source_key": "photo:wdo_damage_area", "type": "image", "page": 2, "x": 40, "y": 400, "width": 120, "height": 90},
    {"key": "image.wdo_inaccessible_area", "source_key": "photo:wdo_inaccessible_area", "type": "image", "page": 2, "x": 200, "y": 400, "width": 120, "height": 90},
    {"key": "signature.inspector", "source_key": "inspector_signature", "type": "signature", "page": 2, "x": 360, "y": 86, "width": 170, "height": 36}
  ]
}
''';

const String _sinkholeMap = '''
{
  "form_code": "sinkhole_inspection",
  "map_version": "v1",
  "fields": [
    {"key": "text.insuredName", "source_key": "insuredName", "type": "text", "page": 1, "x": 40, "y": 700, "width": 180, "height": 14},
    {"key": "text.propertyAddress", "source_key": "propertyAddress", "type": "text", "page": 1, "x": 40, "y": 680, "width": 300, "height": 14},
    {"key": "text.generalConditionOverview", "source_key": "generalConditionOverview", "type": "text", "page": 2, "x": 40, "y": 600, "width": 400, "height": 60},
    {"key": "checkbox.ext1Depression__yes", "source_key": "ext1Depression__yes", "type": "checkbox", "page": 1, "x": 400, "y": 600, "width": 14, "height": 14},
    {"key": "checkbox.ext4FoundationCracks__yes", "source_key": "ext4FoundationCracks__yes", "type": "checkbox", "page": 1, "x": 400, "y": 580, "width": 14, "height": 14},
    {"key": "checkbox.int3CompressionCracks__yes", "source_key": "int3CompressionCracks__yes", "type": "checkbox", "page": 1, "x": 400, "y": 560, "width": 14, "height": 14},
    {"key": "checkbox.gar1WallToSlabCracks__yes", "source_key": "gar1WallToSlabCracks__yes", "type": "checkbox", "page": 1, "x": 400, "y": 540, "width": 14, "height": 14},
    {"key": "checkbox.sinkhole_any_exterior_yes", "source_key": "sinkhole_any_exterior_yes", "type": "checkbox", "page": 1, "x": 400, "y": 520, "width": 14, "height": 14},
    {"key": "checkbox.sinkhole_any_yes", "source_key": "sinkhole_any_yes", "type": "checkbox", "page": 1, "x": 400, "y": 500, "width": 14, "height": 14},
    {"key": "checkbox.sinkhole_crack_significant", "source_key": "sinkhole_crack_significant", "type": "checkbox", "page": 2, "x": 400, "y": 700, "width": 14, "height": 14},
    {"key": "image.sinkhole_front_elevation", "source_key": "photo:sinkhole_front_elevation", "type": "image", "page": 2, "x": 40, "y": 520, "width": 120, "height": 90},
    {"key": "image.sinkhole_rear_elevation", "source_key": "photo:sinkhole_rear_elevation", "type": "image", "page": 2, "x": 200, "y": 520, "width": 120, "height": 90},
    {"key": "image.sinkhole_checklist_item", "source_key": "photo:sinkhole_checklist_item", "type": "image", "page": 2, "x": 360, "y": 520, "width": 120, "height": 90},
    {"key": "image.sinkhole_garage_crack", "source_key": "photo:sinkhole_garage_crack", "type": "image", "page": 2, "x": 40, "y": 400, "width": 120, "height": 90},
    {"key": "image.sinkhole_adjacent_structure", "source_key": "photo:sinkhole_adjacent_structure", "type": "image", "page": 2, "x": 200, "y": 400, "width": 120, "height": 90},
    {"key": "signature.inspector", "source_key": "inspector_signature", "type": "signature", "page": 2, "x": 360, "y": 86, "width": 170, "height": 36}
  ]
}
''';
