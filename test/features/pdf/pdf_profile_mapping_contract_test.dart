import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/pdf/data/pdf_template_asset_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pinned map source keys stay within loader allowlist', () async {
    final loader = PdfTemplateAssetLoader();
    final allowlist = loader.allowedSourceKeys;
    final sourceKeys = await _loadPinnedMapSourceKeys();

    final unknownKeys = sourceKeys.difference(allowlist);
    expect(
      unknownKeys,
      isEmpty,
      reason:
          'Pinned maps introduced source keys not allowed by loader: $unknownKeys. '
          'Update PdfTemplateAssetLoader.allowlist and mapping contracts together.',
    );
  });

  test('inspector license source keys are explicitly documented by map audit', () async {
    final sourceKeys = await _loadPinnedMapSourceKeys();
    const licenseKeys = PdfTemplateAssetLoader.inspectorLicenseSourceKeys;
    final requiredLicenseKeys = sourceKeys.intersection(licenseKeys);

    expect(
      requiredLicenseKeys,
      isEmpty,
      reason:
          'Pinned maps now require inspector license keys: $requiredLicenseKeys. '
          'Intentional policy change required: update loader policy + runtime '
          'text mapping in lib/features/pdf/data/pdf_media_resolver.dart and '
          'keep map/contract changes in the same PR.',
    );
  });

  test('loader allowlist keeps license keys non-required by default policy', () {
    final allowlist = PdfTemplateAssetLoader().allowedSourceKeys;
    const licenseKeys = PdfTemplateAssetLoader.inspectorLicenseSourceKeys;

    expect(
      allowlist.intersection(licenseKeys),
      isEmpty,
      reason:
          'Default loader policy drifted: license keys moved into allowlist. '
          'If this is intentional, update explicit policy and runtime mapping '
          'contracts in the same PR.',
    );
  });
}

Future<Set<String>> _loadPinnedMapSourceKeys() async {
  const mapPaths = <String>[
    'assets/pdf/maps/insp4pt_03_25.v1.json',
    'assets/pdf/maps/rcf1_03_25.v1.json',
    'assets/pdf/maps/oir_b1_1802_rev_04_26.v1.json',
  ];

  final sourceKeys = <String>{};
  for (final path in mapPaths) {
    final raw = await rootBundle.loadString(path);
    final dynamic decoded = jsonDecode(raw);
    final fields = (decoded as Map<String, dynamic>)['fields'] as List<dynamic>;
    for (final field in fields) {
      sourceKeys.add((field as Map<String, dynamic>)['source_key'] as String);
    }
  }
  return sourceKeys;
}
