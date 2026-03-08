import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Map from FormType to its pinned asset path
  const mapAssets = <FormType, String>{
    FormType.fourPoint: 'assets/pdf/maps/insp4pt_03_25.v1.json',
    FormType.roofCondition: 'assets/pdf/maps/rcf1_03_25.v1.json',
    FormType.windMitigation: 'assets/pdf/maps/oir_b1_1802_rev_04_26.v1.json',
    FormType.wdo: 'assets/pdf/maps/fdacs_13645_rev_10_22.v1.json',
  };

  for (final entry in mapAssets.entries) {
    test('${entry.key.code} map covers every canonical evidence source key',
        () async {
      final canonical =
          FormRequirements.canonicalSourceKeysForForm(entry.key);
      final raw = await rootBundle.loadString(entry.value);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final fields = decoded['fields'] as List<dynamic>;
      final mappedSourceKeys = fields
          .map((f) => (f as Map<String, dynamic>)['source_key'] as String)
          .toSet();

      final missing = canonical.difference(mappedSourceKeys);
      expect(
        missing,
        isEmpty,
        reason:
            'Pinned map for ${entry.key.code} is missing field entries for '
            'canonical evidence keys: $missing. Add field entries to '
            '${entry.value} for each missing key.',
      );
    });
  }
}
