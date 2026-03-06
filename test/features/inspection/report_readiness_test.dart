import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
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

  group('Checklist/readiness parity regressions', () {
    test(
      'EVID-02: roof defect requirement blocks readiness only when roof_defect_present flag is active',
      () {
        // Complete all unconditional roof condition requirements
        final unconditionalComplete = <String, bool>{
          for (final req in FormRequirements.forFormRequirements(
            FormType.roofCondition,
          ))
            req.key: true,
        };

        final withoutDefect = ReportReadiness.evaluate(
          enabledForms: {FormType.roofCondition},
          completion: unconditionalComplete,
          branchContext: const <String, dynamic>{},
        );

        final withDefect = ReportReadiness.evaluate(
          enabledForms: {FormType.roofCondition},
          completion: unconditionalComplete,
          branchContext: const <String, dynamic>{'roof_defect_present': true},
        );

        expect(withoutDefect.status, ReportReadinessStatus.ready);
        expect(withoutDefect.missingItems, isNot(contains('Roof Defect')));
        expect(withDefect.status, ReportReadinessStatus.blocked);
        expect(withDefect.missingItems, contains('Roof Defect'));
      },
    );

    test(
      'EVID-04: wind permit document blocks readiness only when wind_permit_document_required flag is active',
      () {
        // Complete all unconditional wind requirements
        final unconditionalComplete = <String, bool>{
          for (final req in FormRequirements.forFormRequirements(
            FormType.windMitigation,
          ))
            req.key: true,
        };

        final withoutPermit = ReportReadiness.evaluate(
          enabledForms: {FormType.windMitigation},
          completion: unconditionalComplete,
          branchContext: const <String, dynamic>{},
        );

        final withPermit = ReportReadiness.evaluate(
          enabledForms: {FormType.windMitigation},
          completion: unconditionalComplete,
          branchContext: const <String, dynamic>{
            'wind_permit_document_required': true,
          },
        );

        expect(withoutPermit.status, ReportReadinessStatus.ready);
        expect(withoutPermit.missingItems, isEmpty);
        expect(withPermit.status, ReportReadinessStatus.blocked);
        expect(withPermit.missingItems, contains('Wind Permit/Age Document'));
      },
    );

    test(
      'each wind document flag independently adds its conditional requirement',
      () {
        final unconditionalComplete = <String, bool>{
          for (final req in FormRequirements.forFormRequirements(
            FormType.windMitigation,
          ))
            req.key: true,
        };

        // Each flag individually
        final withRoofDeck = ReportReadiness.evaluate(
          enabledForms: {FormType.windMitigation},
          completion: unconditionalComplete,
          branchContext: const <String, dynamic>{
            'wind_roof_deck_document_required': true,
          },
        );
        final withOpening = ReportReadiness.evaluate(
          enabledForms: {FormType.windMitigation},
          completion: unconditionalComplete,
          branchContext: const <String, dynamic>{
            'wind_opening_document_required': true,
          },
        );
        final withPermit = ReportReadiness.evaluate(
          enabledForms: {FormType.windMitigation},
          completion: unconditionalComplete,
          branchContext: const <String, dynamic>{
            'wind_permit_document_required': true,
          },
        );

        // All three together
        final withAllThree = ReportReadiness.evaluate(
          enabledForms: {FormType.windMitigation},
          completion: unconditionalComplete,
          branchContext: const <String, dynamic>{
            'wind_roof_deck_document_required': true,
            'wind_opening_document_required': true,
            'wind_permit_document_required': true,
          },
        );

        expect(withRoofDeck.missingItems, ['Wind Roof Deck Supporting Document']);
        expect(withOpening.missingItems, ['Wind Opening Protection Document']);
        expect(withPermit.missingItems, ['Wind Permit/Age Document']);
        expect(withAllThree.missingItems, hasLength(3));
        expect(
          withAllThree.missingItems,
          containsAll(<String>[
            'Wind Roof Deck Supporting Document',
            'Wind Opening Protection Document',
            'Wind Permit/Age Document',
          ]),
        );
      },
    );

    test(
      'readiness requirement keys match checklist step requirement keys for identical branch context',
      () {
        const branchContext = <String, dynamic>{
          'hazard_present': true,
          'roof_defect_present': true,
          'wind_roof_deck_document_required': true,
          'wind_opening_document_required': true,
          'wind_permit_document_required': true,
        };
        final enabledForms = <FormType>{
          FormType.fourPoint,
          FormType.roofCondition,
          FormType.windMitigation,
        };

        // Readiness path: FormRequirements.evaluate (used by ReportReadiness.evaluate)
        final readinessRequirements = FormRequirements.evaluate(
          enabledForms,
          branchContext: branchContext,
        );
        final readinessKeys = readinessRequirements.map((r) => r.key).toSet();

        // Checklist path: FormRequirements.forFormRequirements per form
        // (used by InspectionWizardState._buildSteps)
        final checklistKeys = <String>{};
        for (final form in enabledForms) {
          final stepRequirements = FormRequirements.forFormRequirements(
            form,
            branchContext: branchContext,
          );
          checklistKeys.addAll(stepRequirements.map((r) => r.key));
        }

        // Parity: same keys, same count, no extras in either direction
        expect(readinessKeys, checklistKeys);
        expect(
          readinessRequirements.length,
          checklistKeys.length,
          reason:
              'Readiness and checklist must evaluate the same number of requirements',
        );
      },
    );

    test(
      'readiness and checklist both exclude conditional requirements when flags are false',
      () {
        const branchContext = <String, dynamic>{
          'hazard_present': false,
          'roof_defect_present': false,
          'wind_roof_deck_document_required': false,
          'wind_opening_document_required': false,
          'wind_permit_document_required': false,
        };
        final enabledForms = <FormType>{
          FormType.fourPoint,
          FormType.roofCondition,
          FormType.windMitigation,
        };

        final readinessReqs = FormRequirements.evaluate(
          enabledForms,
          branchContext: branchContext,
        );
        final readinessLabels = readinessReqs.map((r) => r.label).toSet();

        final checklistLabels = <String>{};
        for (final form in enabledForms) {
          final reqs = FormRequirements.forFormRequirements(
            form,
            branchContext: branchContext,
          );
          checklistLabels.addAll(reqs.map((r) => r.label));
        }

        // Neither path should include conditional requirements
        const conditionalLabels = <String>[
          'Hazard Photo',
          'Roof Defect',
          'Wind Roof Deck Supporting Document',
          'Wind Opening Protection Document',
          'Wind Permit/Age Document',
        ];
        for (final label in conditionalLabels) {
          expect(readinessLabels, isNot(contains(label)));
          expect(checklistLabels, isNot(contains(label)));
        }

        // Both paths have the same set of labels
        expect(readinessLabels, checklistLabels);
      },
    );

    test(
      'multi-form inspection readiness matches sum of per-form checklist requirements',
      () {
        const branchContext = <String, dynamic>{
          'hazard_present': true,
          'wind_roof_deck_document_required': true,
        };
        final enabledForms = <FormType>{
          FormType.fourPoint,
          FormType.windMitigation,
        };

        final readinessReqs = FormRequirements.evaluate(
          enabledForms,
          branchContext: branchContext,
        );

        final checklistReqs = <String>{};
        for (final form in enabledForms) {
          final reqs = FormRequirements.forFormRequirements(
            form,
            branchContext: branchContext,
          );
          checklistReqs.addAll(reqs.map((r) => r.key));
        }

        expect(readinessReqs.map((r) => r.key).toSet(), checklistReqs);

        // Hazard should be present (four_point conditional)
        expect(readinessReqs.any((r) => r.label == 'Hazard Photo'), isTrue);
        // Wind roof deck document should be present (wind conditional)
        expect(
          readinessReqs.any(
            (r) => r.label == 'Wind Roof Deck Supporting Document',
          ),
          isTrue,
        );
        // Roof defect should NOT be present (roof_condition not enabled)
        expect(readinessReqs.any((r) => r.label == 'Roof Defect'), isFalse);
      },
    );
  });
}
