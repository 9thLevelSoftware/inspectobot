import 'evidence_requirement.dart';
import 'form_type.dart';
import 'required_photo_category.dart';

class FormRequirements {
  static const String hazardPresentBranchFlag = 'hazard_present';
  static const String roofDefectPresentBranchFlag = 'roof_defect_present';
  static const String windRoofDeckDocumentRequiredBranchFlag =
      'wind_roof_deck_document_required';
  static const String windOpeningDocumentRequiredBranchFlag =
      'wind_opening_document_required';
  static const String windPermitDocumentRequiredBranchFlag =
      'wind_permit_document_required';

  // WDO branch flags
  static const String wdoVisibleEvidenceBranchFlag = 'wdo_visible_evidence';
  static const String wdoLiveWdoBranchFlag = 'wdo_live_wdo';
  static const String wdoEvidenceOfWdoBranchFlag = 'wdo_evidence_of_wdo';
  static const String wdoDamageByWdoBranchFlag = 'wdo_damage_by_wdo';
  static const String wdoPreviousTreatmentBranchFlag = 'wdo_previous_treatment';
  static const String wdoTreatedAtInspectionBranchFlag =
      'wdo_treated_at_inspection';
  static const String wdoAtticInaccessibleBranchFlag =
      'wdo_attic_inaccessible';
  static const String wdoInteriorInaccessibleBranchFlag =
      'wdo_interior_inaccessible';
  static const String wdoExteriorInaccessibleBranchFlag =
      'wdo_exterior_inaccessible';
  static const String wdoCrawlspaceInaccessibleBranchFlag =
      'wdo_crawlspace_inaccessible';
  static const String wdoOtherInaccessibleBranchFlag =
      'wdo_other_inaccessible';
  static const String wdoSpotTreatmentBranchFlag = 'wdo_spot_treatment';

  // Sinkhole branch flags
  static const String sinkholeAnyExteriorYesBranchFlag =
      'sinkhole_any_exterior_yes';
  static const String sinkholeAnyInteriorYesBranchFlag =
      'sinkhole_any_interior_yes';
  static const String sinkholeAnyGarageYesBranchFlag =
      'sinkhole_any_garage_yes';
  static const String sinkholeAnyAppurtenantYesBranchFlag =
      'sinkhole_any_appurtenant_yes';
  static const String sinkholeAnyYesBranchFlag = 'sinkhole_any_yes';
  static const String sinkholeTownhouseBranchFlag = 'sinkhole_townhouse';
  static const String sinkholeUnableToScheduleBranchFlag =
      'sinkhole_unable_to_schedule';
  static const String sinkholeCrackSignificantBranchFlag =
      'sinkhole_crack_significant';

  // Mold branch flags
  static const String moldVisibleFoundBranchFlag = 'mold_visible_found';
  static const String moldMoistureSourceFoundBranchFlag =
      'mold_moisture_source_found';
  static const String moldSamplesTakenBranchFlag = 'mold_samples_taken';
  static const String moldAirSamplesTakenBranchFlag = 'mold_air_samples_taken';
  static const String moldSurfaceSamplesTakenBranchFlag =
      'mold_surface_samples_taken';
  static const String moldBulkSamplesTakenBranchFlag =
      'mold_bulk_samples_taken';
  static const String moldRemediationRecommendedBranchFlag =
      'mold_remediation_recommended';
  static const String moldPostRemediationBranchFlag = 'mold_post_remediation';

  // General branch flags
  static const String generalSafetyHazardBranchFlag = 'general_safety_hazard';
  static const String generalMoistureMoldEvidenceBranchFlag =
      'general_moisture_mold_evidence';
  static const String generalPestEvidenceBranchFlag = 'general_pest_evidence';
  static const String generalStructuralConcernBranchFlag =
      'general_structural_concern';

  static const Set<String> canonicalBranchFlags = <String>{
    hazardPresentBranchFlag,
    roofDefectPresentBranchFlag,
    windRoofDeckDocumentRequiredBranchFlag,
    windOpeningDocumentRequiredBranchFlag,
    windPermitDocumentRequiredBranchFlag,
    // WDO
    wdoVisibleEvidenceBranchFlag,
    wdoLiveWdoBranchFlag,
    wdoEvidenceOfWdoBranchFlag,
    wdoDamageByWdoBranchFlag,
    wdoPreviousTreatmentBranchFlag,
    wdoTreatedAtInspectionBranchFlag,
    wdoAtticInaccessibleBranchFlag,
    wdoInteriorInaccessibleBranchFlag,
    wdoExteriorInaccessibleBranchFlag,
    wdoCrawlspaceInaccessibleBranchFlag,
    wdoOtherInaccessibleBranchFlag,
    wdoSpotTreatmentBranchFlag,
    // Sinkhole
    sinkholeAnyExteriorYesBranchFlag,
    sinkholeAnyInteriorYesBranchFlag,
    sinkholeAnyGarageYesBranchFlag,
    sinkholeAnyAppurtenantYesBranchFlag,
    sinkholeAnyYesBranchFlag,
    sinkholeTownhouseBranchFlag,
    sinkholeUnableToScheduleBranchFlag,
    sinkholeCrackSignificantBranchFlag,
    // Mold
    moldVisibleFoundBranchFlag,
    moldMoistureSourceFoundBranchFlag,
    moldSamplesTakenBranchFlag,
    moldAirSamplesTakenBranchFlag,
    moldSurfaceSamplesTakenBranchFlag,
    moldBulkSamplesTakenBranchFlag,
    moldRemediationRecommendedBranchFlag,
    moldPostRemediationBranchFlag,
    // General
    generalSafetyHazardBranchFlag,
    generalMoistureMoldEvidenceBranchFlag,
    generalPestEvidenceBranchFlag,
    generalStructuralConcernBranchFlag,
  };

  static final Map<FormType, List<EvidenceRequirement>> _requirementsByForm = {
    FormType.fourPoint: <EvidenceRequirement>[
      _photo(
        key: 'photo:exterior_front',
        label: 'Exterior Front',
        form: FormType.fourPoint,
        category: RequiredPhotoCategory.exteriorFront,
      ),
      _photo(
        key: 'photo:exterior_rear',
        label: 'Exterior Rear',
        form: FormType.fourPoint,
        category: RequiredPhotoCategory.exteriorRear,
      ),
      _photo(
        key: 'photo:exterior_left',
        label: 'Exterior Left',
        form: FormType.fourPoint,
        category: RequiredPhotoCategory.exteriorLeft,
      ),
      _photo(
        key: 'photo:exterior_right',
        label: 'Exterior Right',
        form: FormType.fourPoint,
        category: RequiredPhotoCategory.exteriorRight,
      ),
      _photo(
        key: 'photo:roof_slope_main',
        label: 'Roof Slope Main',
        form: FormType.fourPoint,
        category: RequiredPhotoCategory.roofSlopeMain,
        group: 'roof-slopes',
      ),
      _photo(
        key: 'photo:roof_slope_secondary',
        label: 'Roof Slope Secondary',
        form: FormType.fourPoint,
        category: RequiredPhotoCategory.roofSlopeSecondary,
        group: 'roof-slopes',
      ),
      _photo(
        key: 'photo:water_heater_tpr_valve',
        label: 'Water Heater TPR Valve',
        form: FormType.fourPoint,
        category: RequiredPhotoCategory.waterHeaterTprValve,
      ),
      _photo(
        key: 'photo:plumbing_under_sink',
        label: 'Plumbing Under Sink',
        form: FormType.fourPoint,
        category: RequiredPhotoCategory.plumbingUnderSink,
      ),
      _photo(
        key: 'photo:electrical_panel_label',
        label: 'Electrical Panel Label',
        form: FormType.fourPoint,
        category: RequiredPhotoCategory.electricalPanelLabel,
      ),
      _photo(
        key: 'photo:electrical_panel_open',
        label: 'Electrical Panel Open',
        form: FormType.fourPoint,
        category: RequiredPhotoCategory.electricalPanelOpen,
      ),
      _photo(
        key: 'photo:hvac_data_plate',
        label: 'HVAC Data Plate',
        form: FormType.fourPoint,
        category: RequiredPhotoCategory.hvacDataPlate,
      ),
      _photo(
        key: 'photo:hazard_photo',
        label: 'Hazard Photo',
        form: FormType.fourPoint,
        category: RequiredPhotoCategory.hazardPhoto,
        when: _boolFlag(hazardPresentBranchFlag),
      ),
    ],
    FormType.roofCondition: <EvidenceRequirement>[
      _photo(
        key: 'photo:roof_condition_main_slope',
        label: 'Roof Condition Main Slope',
        form: FormType.roofCondition,
        category: RequiredPhotoCategory.roofSlopeMain,
        group: 'roof-condition',
      ),
      _photo(
        key: 'photo:roof_condition_secondary_slope',
        label: 'Roof Condition Secondary Slope',
        form: FormType.roofCondition,
        category: RequiredPhotoCategory.roofSlopeSecondary,
        group: 'roof-condition',
      ),
      _photo(
        key: 'photo:roof_defect',
        label: 'Roof Defect',
        form: FormType.roofCondition,
        category: RequiredPhotoCategory.roofDefect,
        when: _boolFlag(roofDefectPresentBranchFlag),
      ),
    ],
    FormType.windMitigation: <EvidenceRequirement>[
      _photo(
        key: 'photo:wind_roof_deck',
        label: 'Wind: Roof Deck Attachment',
        form: FormType.windMitigation,
        category: RequiredPhotoCategory.windRoofDeck,
      ),
      _photo(
        key: 'photo:wind_roof_to_wall',
        label: 'Wind: Roof To Wall Attachment',
        form: FormType.windMitigation,
        category: RequiredPhotoCategory.windRoofToWall,
      ),
      _photo(
        key: 'photo:wind_roof_shape',
        label: 'Wind: Roof Geometry',
        form: FormType.windMitigation,
        category: RequiredPhotoCategory.windRoofShape,
      ),
      _photo(
        key: 'photo:wind_secondary_water_resistance',
        label: 'Wind: Secondary Water Resistance',
        form: FormType.windMitigation,
        category: RequiredPhotoCategory.windSecondaryWaterResistance,
      ),
      _photo(
        key: 'photo:wind_opening_protection',
        label: 'Wind: Opening Protection',
        form: FormType.windMitigation,
        category: RequiredPhotoCategory.windOpeningProtection,
      ),
      _photo(
        key: 'photo:wind_opening_type',
        label: 'Wind: Opening Type',
        form: FormType.windMitigation,
        category: RequiredPhotoCategory.windOpeningType,
      ),
      _photo(
        key: 'photo:wind_permit_year',
        label: 'Wind: Permit Year',
        form: FormType.windMitigation,
        category: RequiredPhotoCategory.windPermitYear,
      ),
      _document(
        key: 'document:wind_roof_deck',
        label: 'Wind Roof Deck Supporting Document',
        form: FormType.windMitigation,
        category: RequiredPhotoCategory.windRoofDeck,
        when: _boolFlag(windRoofDeckDocumentRequiredBranchFlag),
      ),
      _document(
        key: 'document:wind_opening_protection',
        label: 'Wind Opening Protection Document',
        form: FormType.windMitigation,
        category: RequiredPhotoCategory.windOpeningProtection,
        when: _boolFlag(windOpeningDocumentRequiredBranchFlag),
      ),
      _document(
        key: 'document:wind_permit_year',
        label: 'Wind Permit/Age Document',
        form: FormType.windMitigation,
        category: RequiredPhotoCategory.windPermitYear,
        when: _boolFlag(windPermitDocumentRequiredBranchFlag),
      ),
    ],
    FormType.wdo: <EvidenceRequirement>[
      _photo(
        key: 'photo:wdo_property_exterior',
        label: 'WDO Property Exterior',
        form: FormType.wdo,
        category: RequiredPhotoCategory.wdoPropertyExterior,
      ),
      _photo(
        key: 'photo:wdo_notice_posting',
        label: 'WDO Notice of Inspection Posting',
        form: FormType.wdo,
        category: RequiredPhotoCategory.wdoNoticePosting,
      ),
      _photo(
        key: 'photo:wdo_infestation_evidence',
        label: 'WDO Infestation Evidence',
        form: FormType.wdo,
        category: RequiredPhotoCategory.wdoInfestationEvidence,
        when: _boolFlag(wdoVisibleEvidenceBranchFlag),
      ),
      _photo(
        key: 'photo:wdo_damage_area',
        label: 'WDO Damage Area',
        form: FormType.wdo,
        category: RequiredPhotoCategory.wdoDamageArea,
        when: _boolFlag(wdoDamageByWdoBranchFlag),
      ),
      _photo(
        key: 'photo:wdo_inaccessible_area',
        label: 'WDO Inaccessible Area Documentation',
        form: FormType.wdo,
        category: RequiredPhotoCategory.wdoInaccessibleArea,
        when: _anyWdoInaccessible,
      ),
    ],
    FormType.sinkholeInspection: <EvidenceRequirement>[
      _photo(
        key: 'photo:sinkhole_front_elevation',
        label: 'Sinkhole Front Elevation',
        form: FormType.sinkholeInspection,
        category: RequiredPhotoCategory.sinkholeFrontElevation,
      ),
      _photo(
        key: 'photo:sinkhole_rear_elevation',
        label: 'Sinkhole Rear Elevation',
        form: FormType.sinkholeInspection,
        category: RequiredPhotoCategory.sinkholeRearElevation,
      ),
      _photo(
        key: 'photo:sinkhole_checklist_item',
        label: 'Sinkhole Checklist Item',
        form: FormType.sinkholeInspection,
        category: RequiredPhotoCategory.sinkholeChecklistItem,
        minimumCount: 2,
        when: anySinkholeYes,
      ),
      _photo(
        key: 'photo:sinkhole_garage_crack',
        label: 'Sinkhole Garage Crack Pattern',
        form: FormType.sinkholeInspection,
        category: RequiredPhotoCategory.sinkholeGarageCrack,
        when: _boolFlag(sinkholeAnyGarageYesBranchFlag),
      ),
      _photo(
        key: 'photo:sinkhole_adjacent_structure',
        label: 'Sinkhole Adjacent Structure',
        form: FormType.sinkholeInspection,
        category: RequiredPhotoCategory.sinkholeAdjacentStructure,
        when: _boolFlag(sinkholeTownhouseBranchFlag),
      ),
    ],
    FormType.moldAssessment: <EvidenceRequirement>[
      _photo(
        key: 'photo:mold_moisture_reading',
        label: 'Mold Moisture Meter Reading',
        form: FormType.moldAssessment,
        category: RequiredPhotoCategory.moldMoistureReading,
      ),
      _photo(
        key: 'photo:mold_growth_evidence',
        label: 'Mold Growth Evidence Photo',
        form: FormType.moldAssessment,
        category: RequiredPhotoCategory.moldGrowthEvidence,
      ),
      _photo(
        key: 'photo:mold_affected_area',
        label: 'Mold Affected Area Photo',
        form: FormType.moldAssessment,
        category: RequiredPhotoCategory.moldAffectedArea,
      ),
      _photo(
        key: 'photo:mold_moisture_source',
        label: 'Mold Moisture Source Photo',
        form: FormType.moldAssessment,
        category: RequiredPhotoCategory.moldMoistureSource,
        when: _boolFlag(moldMoistureSourceFoundBranchFlag),
      ),
      _document(
        key: 'document:mold_lab_report',
        label: 'Mold Lab Report',
        form: FormType.moldAssessment,
        category: RequiredPhotoCategory.moldLabReport,
        when: _boolFlag(moldSamplesTakenBranchFlag),
      ),
    ],
    FormType.generalInspection: <EvidenceRequirement>[
      _photo(
        key: 'photo:general_front_elevation',
        label: 'General Front Elevation',
        form: FormType.generalInspection,
        category: RequiredPhotoCategory.generalFrontElevation,
      ),
      _photo(
        key: 'photo:general_electrical_panel',
        label: 'General Electrical Panel',
        form: FormType.generalInspection,
        category: RequiredPhotoCategory.generalElectricalPanel,
      ),
      _photo(
        key: 'photo:general_data_plate',
        label: 'General Water Heater/HVAC Data Plate',
        form: FormType.generalInspection,
        category: RequiredPhotoCategory.generalDataPlate,
        minimumCount: 2,
      ),
      _photo(
        key: 'photo:general_pressure_test',
        label: 'General Pressure Test Reading',
        form: FormType.generalInspection,
        category: RequiredPhotoCategory.generalPressureTest,
      ),
      _photo(
        key: 'photo:general_deficiency',
        label: 'General Deficiency Photo',
        form: FormType.generalInspection,
        category: RequiredPhotoCategory.generalDeficiency,
        when: _boolFlag(generalSafetyHazardBranchFlag),
      ),
      _photo(
        key: 'photo:general_room_photo',
        label: 'General Room Photo',
        form: FormType.generalInspection,
        category: RequiredPhotoCategory.generalRoomPhoto,
      ),
    ],
  };

  static final Map<FormType, List<RequiredPhotoCategory>> requiredPhotos = {
    for (final entry in _requirementsByForm.entries)
      entry.key: entry.value
          .where(
            (requirement) => requirement.applies(const <String, dynamic>{}),
          )
          .where(
            (requirement) => requirement.mediaType == EvidenceMediaType.photo,
          )
          .map((requirement) => requirement.category)
          .whereType<RequiredPhotoCategory>()
          .toList(growable: false),
  };

  static final Map<RequiredPhotoCategory, String> _canonicalPhotoKeyByCategory =
      {
        for (final form in FormType.values)
          for (final requirement
              in _requirementsByForm[form] ?? const <EvidenceRequirement>[])
            if (requirement.mediaType == EvidenceMediaType.photo &&
                requirement.category != null)
              requirement.category!: requirement.key,
      };

  // ---------------------------------------------------------------------------
  // Branch flag maps (authoritative source for UI and controller)
  // ---------------------------------------------------------------------------

  static const Map<FormType, List<String>> branchFlagsByForm = {
    FormType.fourPoint: [hazardPresentBranchFlag],
    FormType.roofCondition: [roofDefectPresentBranchFlag],
    FormType.windMitigation: [
      windRoofDeckDocumentRequiredBranchFlag,
      windOpeningDocumentRequiredBranchFlag,
      windPermitDocumentRequiredBranchFlag,
    ],
    FormType.wdo: [
      wdoVisibleEvidenceBranchFlag,
      wdoLiveWdoBranchFlag,
      wdoEvidenceOfWdoBranchFlag,
      wdoDamageByWdoBranchFlag,
      wdoPreviousTreatmentBranchFlag,
      wdoTreatedAtInspectionBranchFlag,
      wdoAtticInaccessibleBranchFlag,
      wdoInteriorInaccessibleBranchFlag,
      wdoExteriorInaccessibleBranchFlag,
      wdoCrawlspaceInaccessibleBranchFlag,
      wdoOtherInaccessibleBranchFlag,
      wdoSpotTreatmentBranchFlag,
    ],
    FormType.sinkholeInspection: [
      sinkholeAnyExteriorYesBranchFlag,
      sinkholeAnyInteriorYesBranchFlag,
      sinkholeAnyGarageYesBranchFlag,
      sinkholeAnyAppurtenantYesBranchFlag,
      sinkholeAnyYesBranchFlag,
      sinkholeTownhouseBranchFlag,
      sinkholeUnableToScheduleBranchFlag,
      sinkholeCrackSignificantBranchFlag,
    ],
    FormType.moldAssessment: [
      moldVisibleFoundBranchFlag,
      moldMoistureSourceFoundBranchFlag,
      moldSamplesTakenBranchFlag,
      moldAirSamplesTakenBranchFlag,
      moldSurfaceSamplesTakenBranchFlag,
      moldBulkSamplesTakenBranchFlag,
      moldRemediationRecommendedBranchFlag,
      moldPostRemediationBranchFlag,
    ],
    FormType.generalInspection: [
      generalSafetyHazardBranchFlag,
      generalMoistureMoldEvidenceBranchFlag,
      generalPestEvidenceBranchFlag,
      generalStructuralConcernBranchFlag,
    ],
  };

  static const Map<String, String> branchFlagLabels = {
    hazardPresentBranchFlag: 'Hazard present?',
    roofDefectPresentBranchFlag: 'Roof defect present?',
    windRoofDeckDocumentRequiredBranchFlag:
        'Roof deck supporting document required?',
    windOpeningDocumentRequiredBranchFlag:
        'Opening protection document required?',
    windPermitDocumentRequiredBranchFlag:
        'Permit/age document required?',
    // WDO
    wdoVisibleEvidenceBranchFlag: 'WDO visible evidence found?',
    wdoLiveWdoBranchFlag: 'Live WDOs observed?',
    wdoEvidenceOfWdoBranchFlag: 'Evidence of WDOs found?',
    wdoDamageByWdoBranchFlag: 'Damage caused by WDOs?',
    wdoPreviousTreatmentBranchFlag: 'Previous treatment evidence?',
    wdoTreatedAtInspectionBranchFlag: 'Treatment performed at inspection?',
    wdoAtticInaccessibleBranchFlag: 'Attic areas inaccessible?',
    wdoInteriorInaccessibleBranchFlag: 'Interior areas inaccessible?',
    wdoExteriorInaccessibleBranchFlag: 'Exterior areas inaccessible?',
    wdoCrawlspaceInaccessibleBranchFlag: 'Crawlspace inaccessible?',
    wdoOtherInaccessibleBranchFlag: 'Other areas inaccessible?',
    wdoSpotTreatmentBranchFlag: 'Spot treatment performed?',
    // Sinkhole
    sinkholeAnyExteriorYesBranchFlag: 'Exterior indicators found?',
    sinkholeAnyInteriorYesBranchFlag: 'Interior indicators found?',
    sinkholeAnyGarageYesBranchFlag: 'Garage indicators found?',
    sinkholeAnyAppurtenantYesBranchFlag:
        'Appurtenant structure indicators found?',
    sinkholeAnyYesBranchFlag: 'Any sinkhole indicators found?',
    sinkholeTownhouseBranchFlag: 'Property is townhouse/row house?',
    sinkholeUnableToScheduleBranchFlag: 'Unable to schedule inspection?',
    sinkholeCrackSignificantBranchFlag:
        'Significant cracks (>= 1/8 inch) found?',
    // Mold
    moldVisibleFoundBranchFlag: 'Visible mold growth found?',
    moldMoistureSourceFoundBranchFlag: 'Moisture source identified?',
    moldSamplesTakenBranchFlag: 'Samples collected?',
    moldAirSamplesTakenBranchFlag: 'Air samples collected?',
    moldSurfaceSamplesTakenBranchFlag: 'Surface samples collected?',
    moldBulkSamplesTakenBranchFlag: 'Bulk samples collected?',
    moldRemediationRecommendedBranchFlag: 'Remediation recommended?',
    moldPostRemediationBranchFlag: 'Post-remediation assessment?',
    // General
    generalSafetyHazardBranchFlag: 'Safety hazard identified?',
    generalMoistureMoldEvidenceBranchFlag:
        'Moisture/mold evidence observed?',
    generalPestEvidenceBranchFlag: 'Pest/WDO evidence observed?',
    generalStructuralConcernBranchFlag: 'Structural concern identified?',
  };

  static final Map<String, RequiredPhotoCategory> _categoryByRequirementKey = {
    for (final requirements in _requirementsByForm.values)
      for (final requirement in requirements)
        if (requirement.category != null)
          requirement.key: requirement.category!,
  };

  static List<EvidenceRequirement> forFormRequirements(
    FormType form, {
    Map<String, dynamic> branchContext = const <String, dynamic>{},
  }) {
    final requirements =
        _requirementsByForm[form] ?? const <EvidenceRequirement>[];
    final filtered =
        requirements
            .where((requirement) => requirement.applies(branchContext))
            .toList(growable: false)
          ..sort((a, b) => a.key.compareTo(b.key));
    _assertUniqueKeys(filtered);
    return filtered;
  }

  static List<EvidenceRequirement> evaluate(
    Set<FormType> forms, {
    Map<String, dynamic> branchContext = const <String, dynamic>{},
  }) {
    final merged = <EvidenceRequirement>[];
    final sortedForms = forms.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    for (final form in sortedForms) {
      merged.addAll(forFormRequirements(form, branchContext: branchContext));
    }
    merged.sort((a, b) => a.key.compareTo(b.key));
    _assertUniqueKeys(merged);
    return merged;
  }

  static List<RequiredPhotoCategory> forForms(Set<FormType> forms) {
    final merged = <RequiredPhotoCategory>{};
    for (final form in forms) {
      merged.addAll(requiredPhotos[form] ?? const []);
    }
    final categories = merged.toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }

  static List<RequiredPhotoCategory> forForm(FormType form) {
    return List<RequiredPhotoCategory>.unmodifiable(
      requiredPhotos[form] ?? const [],
    );
  }

  static String requirementKeyForPhoto(RequiredPhotoCategory category) {
    return _canonicalPhotoKeyByCategory[category] ?? 'photo:${category.name}';
  }

  static List<String> requirementKeysForForm(FormType form) {
    return forFormRequirements(form)
        .where(
          (requirement) => requirement.mediaType == EvidenceMediaType.photo,
        )
        .map((requirement) => requirement.key)
        .toList(growable: false);
  }

  static RequiredPhotoCategory? categoryForRequirementKey(String key) {
    return _categoryByRequirementKey[key];
  }

  /// Returns all canonical evidence source keys declared for [form],
  /// regardless of branch conditions or media type.
  static Set<String> canonicalSourceKeysForForm(FormType form) {
    return (_requirementsByForm[form] ?? const <EvidenceRequirement>[])
        .map((r) => r.key)
        .toSet();
  }

  static Set<String> canonicalSourceKeys() {
    final keys = <String>{};
    for (final requirements in _requirementsByForm.values) {
      for (final requirement in requirements) {
        keys.add(requirement.key);
      }
    }
    return keys;
  }

  static void _assertUniqueKeys(List<EvidenceRequirement> requirements) {
    final keys = <String>{};
    for (final requirement in requirements) {
      if (!keys.add(requirement.key)) {
        throw StateError(
          'Duplicate evidence requirement key: ${requirement.key}',
        );
      }
    }
  }

  static EvidenceRequirement _photo({
    required String key,
    required String label,
    required FormType form,
    required RequiredPhotoCategory category,
    String? group,
    int minimumCount = 1,
    EvidencePredicate? when,
  }) {
    return EvidenceRequirement(
      key: key,
      label: label,
      form: form,
      mediaType: EvidenceMediaType.photo,
      minimumCount: minimumCount,
      category: category,
      group: group,
      isRequired: when ?? _always,
    );
  }

  static EvidenceRequirement _document({
    required String key,
    required String label,
    required FormType form,
    required RequiredPhotoCategory category,
    int minimumCount = 1,
    EvidencePredicate? when,
  }) {
    return EvidenceRequirement(
      key: key,
      label: label,
      form: form,
      mediaType: EvidenceMediaType.document,
      minimumCount: minimumCount,
      category: category,
      isRequired: when ?? _always,
    );
  }

  static EvidencePredicate _boolFlag(String key) {
    return (Map<String, dynamic> branchContext) => branchContext[key] == true;
  }

  static bool _anyWdoInaccessible(Map<String, dynamic> ctx) {
    return ctx['wdo_attic_inaccessible'] == true ||
        ctx['wdo_interior_inaccessible'] == true ||
        ctx['wdo_exterior_inaccessible'] == true ||
        ctx['wdo_crawlspace_inaccessible'] == true ||
        ctx['wdo_other_inaccessible'] == true;
  }

  /// Returns true if any of the 4 sinkhole section flags are true.
  static bool anySinkholeYes(Map<String, dynamic> ctx) {
    return ctx[sinkholeAnyExteriorYesBranchFlag] == true ||
        ctx[sinkholeAnyInteriorYesBranchFlag] == true ||
        ctx[sinkholeAnyGarageYesBranchFlag] == true ||
        ctx[sinkholeAnyAppurtenantYesBranchFlag] == true;
  }

  static bool _always(Map<String, dynamic> _) => true;
}
