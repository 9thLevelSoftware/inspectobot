import 'form_type.dart';
import 'required_photo_category.dart';

/// Static lookup table mapping [RequiredPhotoCategory] to the [FormType]s
/// that accept it, accounting for both native sharing (same enum value used
/// by multiple forms) and semantic equivalence (different enum values
/// representing the same physical subject across forms).
class EvidenceSharingMatrix {
  EvidenceSharingMatrix._();

  // ---------------------------------------------------------------------------
  // Semantic equivalents: different enum values for the same physical subject
  // ---------------------------------------------------------------------------

  static const Map<RequiredPhotoCategory, Set<RequiredPhotoCategory>>
      _semanticEquivalents = {
    // Front of house
    RequiredPhotoCategory.exteriorFront: {
      RequiredPhotoCategory.generalFrontElevation,
    },
    RequiredPhotoCategory.generalFrontElevation: {
      RequiredPhotoCategory.exteriorFront,
    },
    // Electrical panel
    RequiredPhotoCategory.electricalPanelLabel: {
      RequiredPhotoCategory.generalElectricalPanel,
    },
    RequiredPhotoCategory.generalElectricalPanel: {
      RequiredPhotoCategory.electricalPanelLabel,
    },
    // HVAC / water heater data plate
    RequiredPhotoCategory.hvacDataPlate: {
      RequiredPhotoCategory.generalDataPlate,
    },
    RequiredPhotoCategory.generalDataPlate: {
      RequiredPhotoCategory.hvacDataPlate,
    },
  };

  // ---------------------------------------------------------------------------
  // Category → Forms mapping (native + semantic sharing combined)
  // ---------------------------------------------------------------------------

  static final Map<RequiredPhotoCategory, Set<FormType>> _categoryToForms = {
    // Native sharing: same enum value used by fourPoint + roofCondition
    RequiredPhotoCategory.roofSlopeMain: {
      FormType.fourPoint,
      FormType.roofCondition,
    },
    RequiredPhotoCategory.roofSlopeSecondary: {
      FormType.fourPoint,
      FormType.roofCondition,
    },

    // Semantic sharing: exteriorFront (4PT) ↔ generalFrontElevation (GEN)
    RequiredPhotoCategory.exteriorFront: {
      FormType.fourPoint,
      FormType.generalInspection,
    },
    RequiredPhotoCategory.generalFrontElevation: {
      FormType.fourPoint,
      FormType.generalInspection,
    },

    // Semantic sharing: electricalPanelLabel (4PT) ↔ generalElectricalPanel (GEN)
    RequiredPhotoCategory.electricalPanelLabel: {
      FormType.fourPoint,
      FormType.generalInspection,
    },
    RequiredPhotoCategory.generalElectricalPanel: {
      FormType.fourPoint,
      FormType.generalInspection,
    },

    // Semantic sharing: hvacDataPlate (4PT) ↔ generalDataPlate (GEN)
    RequiredPhotoCategory.hvacDataPlate: {
      FormType.fourPoint,
      FormType.generalInspection,
    },
    RequiredPhotoCategory.generalDataPlate: {
      FormType.fourPoint,
      FormType.generalInspection,
    },

    // --- Form-specific categories (single form only) ---

    // 4-Point only
    RequiredPhotoCategory.exteriorRear: {FormType.fourPoint},
    RequiredPhotoCategory.exteriorLeft: {FormType.fourPoint},
    RequiredPhotoCategory.exteriorRight: {FormType.fourPoint},
    RequiredPhotoCategory.waterHeaterTprValve: {FormType.fourPoint},
    RequiredPhotoCategory.plumbingUnderSink: {FormType.fourPoint},
    RequiredPhotoCategory.electricalPanelOpen: {FormType.fourPoint},
    RequiredPhotoCategory.hazardPhoto: {FormType.fourPoint},

    // Roof Condition only
    RequiredPhotoCategory.roofDefect: {FormType.roofCondition},

    // Wind Mitigation only
    RequiredPhotoCategory.windRoofDeck: {FormType.windMitigation},
    RequiredPhotoCategory.windRoofToWall: {FormType.windMitigation},
    RequiredPhotoCategory.windOpeningProtection: {FormType.windMitigation},
    RequiredPhotoCategory.windRoofShape: {FormType.windMitigation},
    RequiredPhotoCategory.windSecondaryWaterResistance: {
      FormType.windMitigation,
    },
    RequiredPhotoCategory.windOpeningType: {FormType.windMitigation},
    RequiredPhotoCategory.windPermitYear: {FormType.windMitigation},

    // WDO only
    RequiredPhotoCategory.wdoPropertyExterior: {FormType.wdo},
    RequiredPhotoCategory.wdoInfestationEvidence: {FormType.wdo},
    RequiredPhotoCategory.wdoDamageArea: {FormType.wdo},
    RequiredPhotoCategory.wdoInaccessibleArea: {FormType.wdo},
    RequiredPhotoCategory.wdoNoticePosting: {FormType.wdo},

    // Sinkhole only
    RequiredPhotoCategory.sinkholeFrontElevation: {
      FormType.sinkholeInspection,
    },
    RequiredPhotoCategory.sinkholeRearElevation: {
      FormType.sinkholeInspection,
    },
    RequiredPhotoCategory.sinkholeChecklistItem: {
      FormType.sinkholeInspection,
    },
    RequiredPhotoCategory.sinkholeGarageCrack: {FormType.sinkholeInspection},
    RequiredPhotoCategory.sinkholeAdjacentStructure: {
      FormType.sinkholeInspection,
    },

    // Mold only
    RequiredPhotoCategory.moldAffectedArea: {FormType.moldAssessment},
    RequiredPhotoCategory.moldMoistureSource: {FormType.moldAssessment},
    RequiredPhotoCategory.moldMoistureReading: {FormType.moldAssessment},
    RequiredPhotoCategory.moldGrowthEvidence: {FormType.moldAssessment},
    RequiredPhotoCategory.moldLabReport: {FormType.moldAssessment},

    // General Inspection only (non-shared)
    RequiredPhotoCategory.generalDeficiency: {FormType.generalInspection},
    RequiredPhotoCategory.generalPressureTest: {FormType.generalInspection},
    RequiredPhotoCategory.generalRoomPhoto: {FormType.generalInspection},
  };

  /// Returns semantically equivalent categories from other forms.
  ///
  /// For example, [RequiredPhotoCategory.exteriorFront] returns
  /// `{RequiredPhotoCategory.generalFrontElevation}` because they represent
  /// the same physical subject (front of house) in different form contexts.
  ///
  /// Returns an empty set if the category has no semantic equivalents.
  static Set<RequiredPhotoCategory> equivalentCategories(
    RequiredPhotoCategory category,
  ) {
    return _semanticEquivalents[category] ?? const {};
  }

  /// Returns all [FormType]s that accept this category OR its semantic
  /// equivalents.
  ///
  /// For natively shared categories (e.g., [RequiredPhotoCategory.roofSlopeMain]),
  /// returns all forms using that same enum value.
  ///
  /// For semantically equivalent categories (e.g.,
  /// [RequiredPhotoCategory.exteriorFront]), also includes forms that accept
  /// the equivalent category (e.g., generalInspection via generalFrontElevation).
  static Set<FormType> formsAcceptingCategory(
    RequiredPhotoCategory category,
  ) {
    return _categoryToForms[category] ?? const {};
  }

  /// Filtered overload of [formsAcceptingCategory] that only returns forms
  /// present in [enabledForms].
  static Set<FormType> formsAcceptingCategoryFiltered(
    RequiredPhotoCategory category,
    Set<FormType> enabledForms,
  ) {
    final all = formsAcceptingCategory(category);
    return all.intersection(enabledForms);
  }

  /// Returns `true` if this category has semantic equivalents OR is natively
  /// shared across 2+ forms.
  static bool isSharedCategory(RequiredPhotoCategory category) {
    if (_semanticEquivalents.containsKey(category)) {
      return true;
    }
    final forms = _categoryToForms[category];
    return forms != null && forms.length >= 2;
  }
}
