import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/pdf/data/pdf_template_asset_loader.dart';
import 'package:inspectobot/features/pdf/models/pdf_field_map.dart';
import 'package:inspectobot/features/pdf/models/pdf_template_manifest.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfTemplateManifest', () {
    test('pins every supported form to explicit revision and map version', () {
      final manifest = PdfTemplateManifest.standard();

      expect(manifest.entriesByForm.keys.toSet(), {
        FormType.fourPoint,
        FormType.roofCondition,
        FormType.windMitigation,
      });

      final fourPoint = manifest.requireForForm(FormType.fourPoint);
      expect(fourPoint.revisionLabel, 'Insp4pt 03-25');
      expect(fourPoint.templateAssetId, isNotEmpty);
      expect(fourPoint.mapVersion, 'v1');

      final roof = manifest.requireForForm(FormType.roofCondition);
      expect(roof.revisionLabel, 'RCF-1 03-25');
      expect(roof.templateAssetId, isNotEmpty);
      expect(roof.mapVersion, 'v1');

      final wind = manifest.requireForForm(FormType.windMitigation);
      expect(wind.revisionLabel, 'OIR-B1-1802 Rev 04/26');
      expect(wind.templateAssetId, isNotEmpty);
      expect(wind.mapVersion, 'v1');
    });

    test('throws deterministic error for unknown form code or revision', () {
      final manifest = PdfTemplateManifest.standard();

      expect(
        () => manifest.requireByCodeAndRevision(
          formCode: 'unknown_form',
          revisionLabel: 'Insp4pt 03-25',
        ),
        throwsA(
          isA<PdfTemplateManifestError>().having(
            (e) => e.message,
            'message',
            contains('Unsupported form code'),
          ),
        ),
      );

      expect(
        () => manifest.requireByCodeAndRevision(
          formCode: FormType.fourPoint.code,
          revisionLabel: 'Insp4pt 11-99',
        ),
        throwsA(
          isA<PdfTemplateManifestError>().having(
            (e) => e.message,
            'message',
            contains('Unsupported revision'),
          ),
        ),
      );
    });
  });

  group('PdfTemplateAssetLoader', () {
    test('loads pinned template bytes for each manifest form', () async {
      final loader = PdfTemplateAssetLoader();

      final manifest = PdfTemplateManifest.standard();
      for (final form in manifest.entriesByForm.keys) {
        final bundle = await loader.load(form);
        expect(bundle.templateBytes, isNotEmpty);
        expect(bundle.manifestEntry.templateAssetId, startsWith('assets/pdf/templates/'));
      }
    });

    test('parses typed field map entries for every supported kind', () async {
      final loader = PdfTemplateAssetLoader(
        manifest: PdfTemplateManifest.standard(),
        readMapAsset: (assetPath) async {
          return '''
{
  "form_code": "four_point",
  "map_version": "v1",
  "fields": [
    {"key": "text.client_name", "source_key": "client_name", "type": "text", "page": 1, "x": 40, "y": 700, "width": 220, "height": 14},
    {"key": "checkbox.photo_exterior_front", "source_key": "photo:exterior_front", "type": "checkbox", "page": 1, "x": 40, "y": 664, "width": 12, "height": 12},
    {"key": "image.photo_exterior_front", "source_key": "photo:exterior_front", "type": "image", "page": 1, "x": 40, "y": 520, "width": 140, "height": 100},
    {"key": "signature.inspector", "source_key": "inspector_signature", "type": "signature", "page": 1, "x": 360, "y": 86, "width": 170, "height": 36}
  ]
}
''';
        },
        readTemplateAsset: (_) async => ByteData.view(
          Uint8List.fromList(_pdfStubBytes).buffer,
        ),
      );

      final bundle = await loader.load(FormType.fourPoint);
      expect(bundle.manifestEntry.mapVersion, 'v1');
      expect(bundle.fieldMap.formType, FormType.fourPoint);

      expect(
        bundle.fieldMap.fields.map((f) => f.type).toSet(),
        containsAll(
          <PdfFieldType>{
            PdfFieldType.text,
            PdfFieldType.checkbox,
            PdfFieldType.image,
            PdfFieldType.signature,
          },
        ),
      );
    });

    test('fails fast when map version does not match manifest', () async {
      final loader = PdfTemplateAssetLoader(
        manifest: PdfTemplateManifest.standard(),
        readMapAsset: (_) async => '''
{
  "form_code": "four_point",
  "map_version": "legacy-v0",
  "fields": []
}
''',
        readTemplateAsset: (_) async => ByteData.view(
          Uint8List.fromList(_pdfStubBytes).buffer,
        ),
      );

      expect(
        () => loader.load(FormType.fourPoint),
        throwsA(
          isA<PdfTemplateAssetLoaderError>().having(
            (e) => e.message,
            'message',
            contains('map version mismatch'),
          ),
        ),
      );
    });

    test('rejects map fields with unknown source_key values', () async {
      final loader = PdfTemplateAssetLoader(
        manifest: PdfTemplateManifest.standard(),
        readMapAsset: (_) async => '''
{
  "form_code": "four_point",
  "map_version": "v1",
  "fields": [
    {"key": "image.bad", "source_key": "photo:roof_overview", "type": "image", "page": 1, "x": 10, "y": 10, "width": 20, "height": 20}
  ]
}
''',
        readTemplateAsset: (_) async => ByteData.view(
          Uint8List.fromList(_pdfStubBytes).buffer,
        ),
      );

      expect(
        () => loader.load(FormType.fourPoint),
        throwsA(
          isA<PdfTemplateAssetLoaderError>().having(
            (e) => e.message,
            'message',
            contains('Unknown source_key'),
          ),
        ),
      );
    });

    test('exposes allowlist surface that stays compatible with pinned maps', () async {
      final loader = PdfTemplateAssetLoader();
      final allowlist = loader.allowedSourceKeys;
      final mapPaths = <String>[
        'assets/pdf/maps/insp4pt_03_25.v1.json',
        'assets/pdf/maps/rcf1_03_25.v1.json',
        'assets/pdf/maps/oir_b1_1802_rev_04_26.v1.json',
      ];

      final sourceKeys = <String>{};
      for (final path in mapPaths) {
        sourceKeys.addAll(await _loadSourceKeys(path));
      }

      expect(sourceKeys.difference(allowlist), isEmpty);
      expect(allowlist, contains('inspector_signature'));
      expect(
        allowlist.intersection(PdfTemplateAssetLoader.inspectorLicenseSourceKeys),
        isEmpty,
      );
    });
  });
}

Future<Set<String>> _loadSourceKeys(String assetPath) async {
  final raw = await rootBundle.loadString(assetPath);
  final dynamic decoded = jsonDecode(raw);
  final fields = (decoded as Map<String, dynamic>)['fields'] as List<dynamic>;
  return fields
      .map((field) => (field as Map<String, dynamic>)['source_key'] as String)
      .toSet();
}

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
