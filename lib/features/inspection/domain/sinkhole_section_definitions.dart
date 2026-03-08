import 'field_definition.dart';
import 'field_group.dart';
import 'field_type.dart';
import 'form_requirements.dart';
import 'form_section_definition.dart';
import 'repeating_field_group.dart';

/// Citizens Sinkhole Form (ver. 2, Ed. 6/2012) section definitions.
///
/// Seven sections covering Property ID, Exterior, Interior, Garage,
/// Appurtenant Structures, Additional Info, and Scheduling Attempts.
class SinkholeSectionDefinitions {
  SinkholeSectionDefinitions._();

  // ---------------------------------------------------------------------------
  // Section 0: Property ID
  // ---------------------------------------------------------------------------

  static final propertyId = FormSectionDefinition(
    id: 'sinkhole_property_id',
    title: 'Property ID',
    branchFlagKeys: const <String>[],
    fieldDefinitions: const <FieldDefinition>[
      FieldDefinition(
        key: 'insuredName',
        label: 'Insured Name',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'propertyAddress',
        label: 'Property Address',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'policyNumber',
        label: 'Policy Number',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'inspectionDate',
        label: 'Inspection Date',
        type: FieldType.date,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'inspectorName',
        label: 'Inspector Name',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'inspectorLicenseNumber',
        label: 'Inspector License Number',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'inspectorCompany',
        label: 'Inspector Company',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'inspectorPhone',
        label: 'Inspector Phone',
        type: FieldType.text,
        isRequired: true,
        keyboardType: 'phone',
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Section 1: Exterior
  // ---------------------------------------------------------------------------

  static final exterior = FormSectionDefinition(
    id: 'sinkhole_exterior',
    title: 'Exterior',
    branchFlagKeys: const <String>[
      FormRequirements.sinkholeAnyExteriorYesBranchFlag,
    ],
    evidenceRequirementKeys: const <String>[
      'photo:sinkhole_front_elevation',
    ],
    fieldGroups: <FieldGroup>[
      const FieldGroup(
        groupKey: 'ext1',
        triggerField: FieldDefinition(
          key: 'ext1Depression',
          label: 'Depression, sinkhole, or settlement',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'ext1Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'ext2',
        triggerField: FieldDefinition(
          key: 'ext2AdjacentSinkholes',
          label: 'Adjacent sinkholes or depressions',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'ext2Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'ext3',
        triggerField: FieldDefinition(
          key: 'ext3SoilErosion',
          label: 'Soil erosion or ground cracking',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'ext3Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'ext4',
        triggerField: FieldDefinition(
          key: 'ext4FoundationCracks',
          label: 'Foundation cracks or displacement',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'ext4Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'ext5',
        triggerField: FieldDefinition(
          key: 'ext5ExteriorWallCracks',
          label: 'Exterior wall cracks',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'ext5Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
    ],
    fieldDefinitions: const <FieldDefinition>[],
  );

  // ---------------------------------------------------------------------------
  // Section 2: Interior
  // ---------------------------------------------------------------------------

  static final interior = FormSectionDefinition(
    id: 'sinkhole_interior',
    title: 'Interior',
    branchFlagKeys: const <String>[
      FormRequirements.sinkholeAnyInteriorYesBranchFlag,
    ],
    evidenceRequirementKeys: const <String>[
      'photo:sinkhole_checklist_item',
    ],
    fieldGroups: <FieldGroup>[
      const FieldGroup(
        groupKey: 'int1',
        triggerField: FieldDefinition(
          key: 'int1DoorsOutOfPlumb',
          label: 'Doors out of plumb',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'int1Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'int2',
        triggerField: FieldDefinition(
          key: 'int2DoorsWindowsOutOfSquare',
          label: 'Doors/windows out of square',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'int2Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'int3',
        triggerField: FieldDefinition(
          key: 'int3CompressionCracks',
          label: 'Compression cracks',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'int3Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'int4',
        triggerField: FieldDefinition(
          key: 'int4FloorsOutOfLevel',
          label: 'Floors out of level',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'int4Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'int5',
        triggerField: FieldDefinition(
          key: 'int5CabinetsPulledFromWall',
          label: 'Cabinets pulled from wall',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'int5Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'int6',
        triggerField: FieldDefinition(
          key: 'int6InteriorWallCracks',
          label: 'Interior wall cracks',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'int6Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'int7',
        triggerField: FieldDefinition(
          key: 'int7CeilingCracks',
          label: 'Ceiling cracks',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'int7Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'int8',
        triggerField: FieldDefinition(
          key: 'int8FlooringCracks',
          label: 'Flooring cracks or buckling',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'int8Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
    ],
    fieldDefinitions: const <FieldDefinition>[],
  );

  // ---------------------------------------------------------------------------
  // Section 3: Garage
  // ---------------------------------------------------------------------------

  static final garage = FormSectionDefinition(
    id: 'sinkhole_garage',
    title: 'Garage',
    branchFlagKeys: const <String>[
      FormRequirements.sinkholeAnyGarageYesBranchFlag,
    ],
    evidenceRequirementKeys: const <String>[
      'photo:sinkhole_garage_crack',
    ],
    fieldGroups: <FieldGroup>[
      const FieldGroup(
        groupKey: 'gar1',
        triggerField: FieldDefinition(
          key: 'gar1WallToSlabCracks',
          label: 'Wall-to-slab joint cracks',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'gar1Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'gar2',
        triggerField: FieldDefinition(
          key: 'gar2FloorCracksRadiate',
          label: 'Floor cracks radiating from walls',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'gar2Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
    ],
    fieldDefinitions: const <FieldDefinition>[],
  );

  // ---------------------------------------------------------------------------
  // Section 4: Appurtenant Structures
  // ---------------------------------------------------------------------------

  static final appurtenant = FormSectionDefinition(
    id: 'sinkhole_appurtenant',
    title: 'Appurtenant',
    branchFlagKeys: const <String>[
      FormRequirements.sinkholeAnyAppurtenantYesBranchFlag,
    ],
    evidenceRequirementKeys: const <String>[
      'photo:sinkhole_adjacent_structure',
    ],
    fieldGroups: <FieldGroup>[
      const FieldGroup(
        groupKey: 'app1',
        triggerField: FieldDefinition(
          key: 'app1CracksNoted',
          label: 'Cracks noted in appurtenant structures',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'app1Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'app2',
        triggerField: FieldDefinition(
          key: 'app2UpliftNoted',
          label: 'Uplift or heaving noted',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'app2Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'app3',
        triggerField: FieldDefinition(
          key: 'app3PoolCracksDamage',
          label: 'Pool cracks or damage',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'app3Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
      const FieldGroup(
        groupKey: 'app4',
        triggerField: FieldDefinition(
          key: 'app4PoolDeckCracks',
          label: 'Pool deck cracks or settlement',
          type: FieldType.triState,
          isRequired: true,
        ),
        dependentFields: <FieldDefinition>[
          FieldDefinition(
            key: 'app4Detail',
            label: 'Details',
            type: FieldType.textarea,
            isRequired: true,
            maxLines: 3,
          ),
        ],
      ),
    ],
    fieldDefinitions: const <FieldDefinition>[],
  );

  // ---------------------------------------------------------------------------
  // Section 5: Additional Info
  // ---------------------------------------------------------------------------

  static final additionalInfo = FormSectionDefinition(
    id: 'sinkhole_additional',
    title: 'Additional',
    branchFlagKeys: const <String>[
      FormRequirements.sinkholeTownhouseBranchFlag,
      FormRequirements.sinkholeUnableToScheduleBranchFlag,
      FormRequirements.sinkholeCrackSignificantBranchFlag,
    ],
    fieldDefinitions: const <FieldDefinition>[
      FieldDefinition(
        key: 'generalConditionOverview',
        label: 'General Condition Overview',
        type: FieldType.textarea,
        isRequired: true,
        maxLines: 4,
      ),
      FieldDefinition(
        key: 'adjacentBuildingDescription',
        label: 'Adjacent Building Description',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.sinkholeTownhouseBranchFlag,
        maxLines: 4,
      ),
      FieldDefinition(
        key: 'distanceToNearestSinkhole',
        label: 'Distance to Nearest Sinkhole',
        type: FieldType.text,
        isRequired: true,
      ),
      FieldDefinition(
        key: 'otherRelevantFindings',
        label: 'Other Relevant Findings',
        type: FieldType.textarea,
        isRequired: false,
        maxLines: 4,
      ),
      FieldDefinition(
        key: 'unableToScheduleExplanation',
        label: 'Unable to Schedule Explanation',
        type: FieldType.textarea,
        isRequired: true,
        conditionalOn: FormRequirements.sinkholeUnableToScheduleBranchFlag,
        maxLines: 4,
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Section 6: Scheduling Attempts
  // ---------------------------------------------------------------------------

  static final scheduling = FormSectionDefinition(
    id: 'sinkhole_scheduling',
    title: 'Scheduling',
    branchFlagKeys: const <String>[
      FormRequirements.sinkholeUnableToScheduleBranchFlag,
    ],
    fieldDefinitions: const <FieldDefinition>[],
    repeatingFieldGroups: <RepeatingFieldGroup>[
      RepeatingFieldGroup(
        groupKey: 'attempt',
        label: 'Scheduling Attempts',
        repetitions: 4,
        fieldTemplate: const <FieldDefinition>[
          FieldDefinition(
            key: 'Date',
            label: 'Date',
            type: FieldType.date,
          ),
          FieldDefinition(
            key: 'Time',
            label: 'Time',
            type: FieldType.text,
          ),
          FieldDefinition(
            key: 'NumberCalled',
            label: 'Number Called',
            type: FieldType.text,
          ),
          FieldDefinition(
            key: 'Result',
            label: 'Result',
            type: FieldType.text,
          ),
        ],
        repetitionLabel: _schedulingAttemptLabel,
      ),
    ],
  );

  static String _schedulingAttemptLabel(int index) => 'Attempt $index';

  // ---------------------------------------------------------------------------
  // Aggregate
  // ---------------------------------------------------------------------------

  static List<FormSectionDefinition> get all => [
        propertyId,
        exterior,
        interior,
        garage,
        appurtenant,
        additionalInfo,
        scheduling,
      ];

  /// Returns the total field count across all sections, counting
  /// RepeatingFieldGroup concrete fields (repetitions x template length)
  /// rather than just template fields.
  static int get totalFieldCount {
    int count = 0;
    for (final section in all) {
      count += section.fieldDefinitions.length;
      for (final group in section.fieldGroups) {
        count += group.allFields.length;
      }
      for (final rg in section.repeatingFieldGroups) {
        count += rg.totalFieldCount;
      }
    }
    return count;
  }
}
