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

  test('AUTH-04 POLICY: pinned maps must not reference license keys (non-consumer policy)', () async {
    final sourceKeys = await _loadPinnedMapSourceKeys();
    const licenseKeys = PdfTemplateAssetLoader.inspectorLicenseSourceKeys;
    final requiredLicenseKeys = sourceKeys.intersection(licenseKeys);

    expect(
      requiredLicenseKeys,
      isEmpty,
      reason:
          'AUTH-04 non-consumer policy violated: pinned maps now require '
          'inspector license keys: $requiredLicenseKeys. '
          'Florida inspection forms have no designated license fields. '
          'If this is an intentional policy change, update loader policy + '
          'runtime text mapping in PdfMediaResolver and keep map/contract '
          'changes in the same PR.',
    );
  });

  test('AUTH-04 POLICY: loader allowlist excludes license keys by design', () {
    final allowlist = PdfTemplateAssetLoader().allowedSourceKeys;
    const licenseKeys = PdfTemplateAssetLoader.inspectorLicenseSourceKeys;

    expect(
      allowlist.intersection(licenseKeys),
      isEmpty,
      reason:
          'AUTH-04 non-consumer policy violated: license keys moved into '
          'allowlist. To intentionally reverse this policy: '
          '1) Remove keys from inspectorLicenseSourceKeys, '
          '2) Add resolver cases in PdfMediaResolver._resolveTextValue(), '
          '3) Add field entries to JSON map files, '
          '4) Update these tests to assert consumer status, '
          '5) Load InspectorProfile during PDF input assembly.',
    );
  });

  test('AUTH-04 POLICY: license data is persisted but intentionally not consumed by PDF pipeline', () {
    // This test documents the AUTH-04 resolution as a "policy-bound non-consumer."
    // InspectorProfile stores licenseType and licenseNumber for profile continuity.
    // Florida inspection forms do not have license number fields.
    //
    // To reverse this policy, follow the steps documented in
    // PdfTemplateAssetLoader.inspectorLicenseSourceKeys.

    const licenseKeys = PdfTemplateAssetLoader.inspectorLicenseSourceKeys;
    expect(licenseKeys, containsAll(['license_type', 'license_number']));

    final allowlist = PdfTemplateAssetLoader().allowedSourceKeys;
    expect(
      allowlist.intersection(licenseKeys),
      isEmpty,
      reason: 'AUTH-04 non-consumer policy: license keys must not appear in '
          'loader allowlist. If forms change to require license fields, '
          'follow the reversal steps in PdfTemplateAssetLoader source doc.',
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
