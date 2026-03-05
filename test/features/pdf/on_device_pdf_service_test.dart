import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/pdf/data/pdf_media_resolver.dart';
import 'package:inspectobot/features/pdf/data/pdf_size_budget_config_store.dart';
import 'package:inspectobot/features/pdf/data/pdf_template_asset_loader.dart';
import 'package:inspectobot/features/pdf/domain/pdf_size_budget.dart';
import 'package:inspectobot/features/pdf/models/pdf_field_map.dart';
import 'package:inspectobot/features/pdf/models/pdf_template_manifest.dart';
import 'package:inspectobot/features/pdf/on_device_pdf_service.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/pdf/services/pdf_renderer.dart';

void main() {
  group('OnDevicePdfService', () {
    test('generates mapped official-form output for every selected form', () async {
      final renderer = _RecordingRenderer(
        bytesByAttempt: <List<int>>[
          List<int>.generate(1024, (index) => index % 255),
        ],
      );
      final service = OnDevicePdfService(
        templateAssetLoader: _FakeTemplateLoader(),
        mediaResolver: const PdfMediaResolver(),
        sizeBudgetStore: PdfSizeBudgetConfigStore(
          readConfig: () => <String, dynamic>{
            'max_bytes': 5 * 1024 * 1024,
            'retry_steps': <Map<String, dynamic>>[
              <String, dynamic>{'jpeg_quality': 75, 'max_width': 1280},
            ],
          },
        ),
        renderer: renderer,
        outputDirectoryProvider: () async => Directory.systemTemp,
      );

      final photoFile = await _writeTempJpeg(<int>[1, 2, 3, 4, 5]);
      final input = PdfGenerationInput(
        inspectionId: 'insp-1',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Jane Doe',
        propertyAddress: '123 Palm Ave',
        enabledForms: {FormType.fourPoint, FormType.roofCondition},
        capturedCategories: {
          RequiredPhotoCategory.exteriorFront,
          RequiredPhotoCategory.roofSlopeMain,
        },
        wizardCompletion: const <String, bool>{
          'photo:exterior_front': true,
          'photo:roof_condition_main_slope': true,
        },
        fieldValues: const <String, String>{'inspection_id': 'insp-1'},
        evidenceMediaPaths: <String, List<String>>{
          'photo:exterior_front': <String>[photoFile.path],
          'photo:roof_condition_main_slope': <String>[photoFile.path],
        },
        signatureBytes: Uint8List.fromList(<int>[9, 9, 9, 9]),
      );

      final file = await service.generate(input);
      expect(await file.exists(), isTrue);

      final renderCall = renderer.calls.single;
      expect(renderCall.forms, hasLength(2));
      expect(
        renderCall.forms.map((form) => form.manifestEntry.formType).toSet(),
        <FormType>{FormType.fourPoint, FormType.roofCondition},
      );
      expect(
        renderCall.forms.expand((form) => form.resolved.imageByFieldKey.keys),
        contains('image.photo_exterior_front'),
      );
      expect(
        renderCall.forms.expand((form) => form.resolved.signatureByFieldKey.keys),
        contains('signature.inspector'),
      );
      for (final form in renderCall.forms) {
        expect(form.templateBytes, isNotEmpty);
      }
    });

    test('retries rendering with deterministic budget policy before succeeding', () async {
      final renderer = _RecordingRenderer(
        bytesByAttempt: <List<int>>[
          List<int>.filled(2048, 7),
          List<int>.filled(512, 8),
        ],
      );
      final service = OnDevicePdfService(
        templateAssetLoader: _FakeTemplateLoader(),
        mediaResolver: const PdfMediaResolver(),
        sizeBudgetStore: PdfSizeBudgetConfigStore(
          readConfig: () => <String, dynamic>{
            'max_bytes': 1024,
            'retry_steps': <Map<String, dynamic>>[
              <String, dynamic>{'jpeg_quality': 75, 'max_width': 1280},
              <String, dynamic>{'jpeg_quality': 60, 'max_width': 1024},
            ],
          },
        ),
        renderer: renderer,
        outputDirectoryProvider: () async => Directory.systemTemp,
      );

      final file = await service.generate(_buildInput());
      expect(await file.length(), 512);
      expect(renderer.calls, hasLength(2));
      expect(renderer.calls.first.retryStep.jpegQuality, 75);
      expect(renderer.calls.last.retryStep.jpegQuality, 60);
    });

    test('fails with explicit over-budget error when all retries exceed budget', () async {
      final renderer = _RecordingRenderer(
        bytesByAttempt: <List<int>>[
          List<int>.filled(4096, 1),
          List<int>.filled(3072, 2),
        ],
      );
      final service = OnDevicePdfService(
        templateAssetLoader: _FakeTemplateLoader(),
        mediaResolver: const PdfMediaResolver(),
        sizeBudgetStore: PdfSizeBudgetConfigStore(
          readConfig: () => <String, dynamic>{
            'max_bytes': 1024,
            'retry_steps': <Map<String, dynamic>>[
              <String, dynamic>{'jpeg_quality': 75, 'max_width': 1280},
              <String, dynamic>{'jpeg_quality': 60, 'max_width': 1024},
            ],
          },
        ),
        renderer: renderer,
        outputDirectoryProvider: () async => Directory.systemTemp,
      );

      expect(
        () => service.generate(_buildInput()),
        throwsA(
          isA<PdfGenerationSizeBudgetExceeded>().having(
            (e) => e.message,
            'message',
            contains('exceeded configured size budget'),
          ),
        ),
      );
    });

    test('fails closed when template asset bytes are missing', () async {
      final service = OnDevicePdfService(
        templateAssetLoader: _EmptyTemplateLoader(),
        mediaResolver: const PdfMediaResolver(),
        sizeBudgetStore: PdfSizeBudgetConfigStore(
          readConfig: () => <String, dynamic>{
            'max_bytes': 1024,
            'retry_steps': <Map<String, dynamic>>[
              <String, dynamic>{'jpeg_quality': 75, 'max_width': 1280},
            ],
          },
        ),
        renderer: _RecordingRenderer(
          bytesByAttempt: <List<int>>[
            List<int>.filled(128, 3),
          ],
        ),
        outputDirectoryProvider: () async => Directory.systemTemp,
      );

      expect(
        () => service.generate(_buildInput()),
        throwsA(
          isA<PdfTemplateAssetLoaderError>().having(
            (e) => e.message,
            'message',
            contains('Template asset is empty'),
          ),
        ),
      );
    });

    test('resolves remote-only evidence references for required mapped fields', () async {
      final renderer = _RecordingRenderer(
        bytesByAttempt: <List<int>>[
          List<int>.filled(256, 5),
        ],
      );
      final service = OnDevicePdfService(
        templateAssetLoader: _FakeTemplateLoader(),
        mediaResolver: PdfMediaResolver(
          remoteReadBytes: (storagePath) async {
            if (storagePath == 'org/org-1/users/user-1/inspections/insp-1/media/remote-key.jpg') {
              return Uint8List.fromList(<int>[4, 5, 6]);
            }
            return null;
          },
        ),
        sizeBudgetStore: PdfSizeBudgetConfigStore(
          readConfig: () => <String, dynamic>{
            'max_bytes': 5 * 1024 * 1024,
            'retry_steps': <Map<String, dynamic>>[
              <String, dynamic>{'jpeg_quality': 75, 'max_width': 1280},
            ],
          },
        ),
        renderer: renderer,
        outputDirectoryProvider: () async => Directory.systemTemp,
      );

      final input = PdfGenerationInput(
        inspectionId: 'insp-remote-1',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Remote User',
        propertyAddress: '1 Remote Key Ln',
        enabledForms: {FormType.fourPoint},
        capturedCategories: {RequiredPhotoCategory.exteriorFront},
        wizardCompletion: const <String, bool>{'photo:exterior_front': true},
        evidenceMediaPaths: const <String, List<String>>{
          'photo:exterior_front': <String>[
            'org/org-1/users/user-1/inspections/insp-1/media/remote-key.jpg',
          ],
        },
      );

      final file = await service.generate(input);
      expect(await file.exists(), isTrue);
      expect(
        renderer.calls.single.forms.single.resolved.imageByFieldKey,
        contains('image.photo_exterior_front'),
      );
    });

    test('fails closed when required mapped evidence cannot be resolved', () async {
      final service = OnDevicePdfService(
        templateAssetLoader: _FakeTemplateLoader(),
        mediaResolver: const PdfMediaResolver(),
        sizeBudgetStore: PdfSizeBudgetConfigStore(
          readConfig: () => <String, dynamic>{
            'max_bytes': 5 * 1024 * 1024,
            'retry_steps': <Map<String, dynamic>>[
              <String, dynamic>{'jpeg_quality': 75, 'max_width': 1280},
            ],
          },
        ),
        renderer: _RecordingRenderer(
          bytesByAttempt: <List<int>>[
            List<int>.filled(256, 5),
          ],
        ),
        outputDirectoryProvider: () async => Directory.systemTemp,
      );

      final input = PdfGenerationInput(
        inspectionId: 'insp-unresolved-1',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Unresolved User',
        propertyAddress: '2 Missing Ln',
        enabledForms: {FormType.fourPoint},
        capturedCategories: {RequiredPhotoCategory.exteriorFront},
        wizardCompletion: const <String, bool>{'photo:exterior_front': true},
        evidenceMediaPaths: const <String, List<String>>{
          'photo:exterior_front': <String>['org/org-1/users/user-1/missing.jpg'],
        },
      );

      expect(
        () => service.generate(input),
        throwsA(
          isA<PdfGenerationException>()
              .having(
                (error) => error.unresolvedRequiredEvidence.keys,
                'unresolvedRequiredEvidence.keys',
                contains('image.photo_exterior_front'),
              )
              .having(
                (error) => error.message,
                'message',
                contains('Required evidence media could not be resolved'),
              ),
        ),
      );
    });

    test('accepts mixed local and remote evidence references deterministically', () async {
      final renderer = _RecordingRenderer(
        bytesByAttempt: <List<int>>[
          List<int>.filled(512, 6),
        ],
      );
      final localFile = await _writeTempJpeg(<int>[1, 2, 3, 4]);
      final service = OnDevicePdfService(
        templateAssetLoader: _FakeTemplateLoader(),
        mediaResolver: PdfMediaResolver(
          remoteReadBytes: (storagePath) async {
            if (storagePath == 'org/org-1/users/user-1/inspections/insp-1/media/remote-secondary.jpg') {
              return Uint8List.fromList(<int>[8, 8, 8]);
            }
            return null;
          },
        ),
        sizeBudgetStore: PdfSizeBudgetConfigStore(
          readConfig: () => <String, dynamic>{
            'max_bytes': 5 * 1024 * 1024,
            'retry_steps': <Map<String, dynamic>>[
              <String, dynamic>{'jpeg_quality': 75, 'max_width': 1280},
            ],
          },
        ),
        renderer: renderer,
        outputDirectoryProvider: () async => Directory.systemTemp,
      );

      final input = PdfGenerationInput(
        inspectionId: 'insp-mixed-1',
        organizationId: 'org-1',
        userId: 'user-1',
        clientName: 'Mixed User',
        propertyAddress: '3 Mixed Ln',
        enabledForms: {FormType.fourPoint},
        capturedCategories: {RequiredPhotoCategory.exteriorFront},
        wizardCompletion: const <String, bool>{'photo:exterior_front': true},
        evidenceMediaPaths: <String, List<String>>{
          'photo:exterior_front': <String>[
            localFile.path,
            'org/org-1/users/user-1/inspections/insp-1/media/remote-secondary.jpg',
          ],
        },
      );

      final file = await service.generate(input);
      expect(await file.exists(), isTrue);
      expect(
        renderer.calls.single.forms.single.resolved.imageByFieldKey,
        contains('image.photo_exterior_front'),
      );
    });
  });
}

PdfGenerationInput _buildInput() {
  return PdfGenerationInput(
    inspectionId: 'insp-2',
    organizationId: 'org-1',
    userId: 'user-1',
    clientName: 'Inspector User',
    propertyAddress: '100 Main St',
    enabledForms: {FormType.fourPoint},
    capturedCategories: {RequiredPhotoCategory.exteriorFront},
    wizardCompletion: const <String, bool>{},
  );
}

Future<File> _writeTempJpeg(List<int> bytes) async {
  final output = File(
    '${Directory.systemTemp.path}/pdf-test-${DateTime.now().microsecondsSinceEpoch}.jpg',
  );
  await output.writeAsBytes(bytes, flush: true);
  return output;
}

class _FakeTemplateLoader extends PdfTemplateAssetLoader {
  _FakeTemplateLoader()
    : super(
        manifest: PdfTemplateManifest.standard(),
        readMapAsset: (assetPath) async {
          if (assetPath.contains('rcf1')) {
            return _roofMap;
          }
          return _fourPointMap;
        },
        readTemplateAsset: (assetPath) async {
          return ByteData.view(Uint8List.fromList(_pdfStubBytes).buffer);
        },
      );
}

class _EmptyTemplateLoader extends PdfTemplateAssetLoader {
  _EmptyTemplateLoader()
    : super(
        manifest: PdfTemplateManifest.standard(),
        readMapAsset: (assetPath) async {
          if (assetPath.contains('rcf1')) {
            return _roofMap;
          }
          return _fourPointMap;
        },
        readTemplateAsset: (assetPath) async => ByteData(0),
      );
}

class _RecordingRenderer extends PdfRenderer {
  _RecordingRenderer({required this.bytesByAttempt});

  final List<List<int>> bytesByAttempt;
  final List<PdfRenderRequest> calls = <PdfRenderRequest>[];

  @override
  Future<Uint8List> render(PdfRenderRequest request) async {
    calls.add(request);
    final index = calls.length - 1;
    return Uint8List.fromList(bytesByAttempt[index]);
  }
}

const String _fourPointMap = '''
{
  "form_code": "four_point",
  "map_version": "v1",
  "fields": [
    {"key": "text.client_name", "source_key": "client_name", "type": "text", "page": 1, "x": 40, "y": 700, "width": 180, "height": 14},
    {"key": "image.photo_exterior_front", "source_key": "photo:exterior_front", "type": "image", "page": 1, "x": 40, "y": 520, "width": 120, "height": 90},
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
    {"key": "signature.inspector", "source_key": "inspector_signature", "type": "signature", "page": 1, "x": 360, "y": 86, "width": 170, "height": 36}
  ]
}
''';

const List<int> _pdfStubBytes = <int>[
  0x25,
  0x50,
  0x44,
  0x46,
  0x2D,
  0x31,
  0x2E,
  0x34,
  0x0A,
];
