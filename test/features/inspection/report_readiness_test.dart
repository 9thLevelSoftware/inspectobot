import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/report_readiness.dart';

void main() {
  group('ReportReadiness.evaluate', () {
    test(
      'returns blocked with missing labels when required keys are incomplete',
      () {
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
      },
    );

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
      expect(
        readiness.missingItems,
        orderedEquals(List<String>.from(readiness.missingItems)..sort()),
      );
    });

    test(
      'hazard requirement only blocks readiness when hazard flag is active',
      () {
        final withoutHazard = ReportReadiness.evaluate(
          enabledForms: {FormType.fourPoint},
          completion: {
            for (final key in const <String>[
              'photo:electrical_panel_label',
              'photo:electrical_panel_open',
              'photo:exterior_front',
              'photo:exterior_left',
              'photo:exterior_rear',
              'photo:exterior_right',
              'photo:hvac_data_plate',
              'photo:plumbing_under_sink',
              'photo:roof_slope_main',
              'photo:roof_slope_secondary',
              'photo:water_heater_tpr_valve',
            ])
              key: true,
          },
          branchContext: const <String, dynamic>{},
        );
        final withHazard = ReportReadiness.evaluate(
          enabledForms: {FormType.fourPoint},
          completion: withoutHazard.missingItems.isEmpty
              ? {
                  for (final key in const <String>[
                    'photo:electrical_panel_label',
                    'photo:electrical_panel_open',
                    'photo:exterior_front',
                    'photo:exterior_left',
                    'photo:exterior_rear',
                    'photo:exterior_right',
                    'photo:hvac_data_plate',
                    'photo:plumbing_under_sink',
                    'photo:roof_slope_main',
                    'photo:roof_slope_secondary',
                    'photo:water_heater_tpr_valve',
                  ])
                    key: true,
                }
              : const <String, bool>{},
          branchContext: const <String, dynamic>{'hazard_present': true},
        );

        expect(withoutHazard.status, ReportReadinessStatus.ready);
        expect(withoutHazard.missingItems, isNot(contains('Hazard Photo')));
        expect(withHazard.status, ReportReadinessStatus.blocked);
        expect(withHazard.missingItems, contains('Hazard Photo'));
      },
    );

    test(
      'wind document requirements block readiness only when branch flags require docs',
      () {
        final completion = const <String, bool>{
          'photo:wind_roof_deck': true,
          'photo:wind_roof_to_wall': true,
          'photo:wind_roof_shape': true,
          'photo:wind_secondary_water_resistance': true,
          'photo:wind_opening_protection': true,
          'photo:wind_opening_type': true,
          'photo:wind_permit_year': true,
        };
        final withoutDocs = ReportReadiness.evaluate(
          enabledForms: {FormType.windMitigation},
          completion: completion,
          branchContext: const <String, dynamic>{},
        );
        final withDocsRequired = ReportReadiness.evaluate(
          enabledForms: {FormType.windMitigation},
          completion: completion,
          branchContext: const <String, dynamic>{
            'wind_roof_deck_document_required': true,
            'wind_opening_document_required': true,
          },
        );

        expect(withoutDocs.status, ReportReadinessStatus.ready);
        expect(withDocsRequired.status, ReportReadinessStatus.blocked);
        expect(
          withDocsRequired.missingItems,
          contains('Wind Roof Deck Supporting Document'),
        );
        expect(
          withDocsRequired.missingItems,
          contains('Wind Opening Protection Document'),
        );
      },
    );
  });
}
