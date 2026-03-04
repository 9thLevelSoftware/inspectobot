import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/report_readiness.dart';

void main() {
  group('ReportReadiness.evaluate', () {
    test('returns blocked with missing labels when required keys are incomplete', () {
      final readiness = ReportReadiness.evaluate(
        enabledForms: {FormType.fourPoint},
        completion: const <String, bool>{
          'photo:exterior_front': true,
          'photo:exterior_rear': false,
        },
        branchContext: const <String, dynamic>{},
      );

      expect(readiness.status, ReportReadinessStatus.blocked);
      expect(readiness.missingItems, contains('Exterior Rear'));
      expect(readiness.missingItems, contains('Exterior Left'));
      expect(readiness.missingItems, isNot(contains('Exterior Front')));
    });

    test('returns ready only when every required key is complete', () {
      final readiness = ReportReadiness.evaluate(
        enabledForms: {FormType.fourPoint},
        completion: const <String, bool>{
          'photo:electrical_panel_label': true,
          'photo:electrical_panel_open': true,
          'photo:exterior_front': true,
          'photo:exterior_left': true,
          'photo:exterior_rear': true,
          'photo:exterior_right': true,
          'photo:hvac_data_plate': true,
          'photo:plumbing_under_sink': true,
          'photo:roof_slope_main': true,
          'photo:roof_slope_secondary': true,
          'photo:water_heater_tpr_valve': true,
        },
        branchContext: const <String, dynamic>{},
      );

      expect(readiness.status, ReportReadinessStatus.ready);
      expect(readiness.missingItems, isEmpty);
    });

    test('preserves deterministic sorted missing item snapshots', () {
      final readiness = ReportReadiness.evaluate(
        enabledForms: {FormType.windMitigation},
        completion: const <String, bool>{
          'photo:wind_roof_shape': true,
          'photo:wind_opening_type': true,
        },
        branchContext: const <String, dynamic>{
          'wind_opening_document_required': true,
          'wind_permit_document_required': true,
        },
      );

      expect(readiness.status, ReportReadinessStatus.blocked);
      expect(readiness.missingItems, orderedEquals(List<String>.from(readiness.missingItems)..sort()));
    });
  });
}
