import 'evidence_requirement.dart';
import 'form_type.dart';
import 'required_photo_category.dart';

class FormRequirements {
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
        when: _boolFlag('hazard_present'),
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
        when: _boolFlag('roof_defect_present'),
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
        when: _boolFlag('wind_roof_deck_document_required'),
      ),
      _document(
        key: 'document:wind_opening_protection',
        label: 'Wind Opening Protection Document',
        form: FormType.windMitigation,
        category: RequiredPhotoCategory.windOpeningProtection,
        when: _boolFlag('wind_opening_document_required'),
      ),
      _document(
        key: 'document:wind_permit_year',
        label: 'Wind Permit/Age Document',
        form: FormType.windMitigation,
        category: RequiredPhotoCategory.windPermitYear,
        when: _boolFlag('wind_permit_document_required'),
      ),
    ],
  };

  static final Map<FormType, List<RequiredPhotoCategory>> requiredPhotos = {
    for (final entry in _requirementsByForm.entries)
      entry.key: entry.value
          .where((requirement) => requirement.applies(const <String, dynamic>{}))
          .where((requirement) => requirement.mediaType == EvidenceMediaType.photo)
          .map((requirement) => requirement.category)
          .whereType<RequiredPhotoCategory>()
          .toList(growable: false),
  };

  static List<EvidenceRequirement> forFormRequirements(
    FormType form, {
    Map<String, dynamic> branchContext = const <String, dynamic>{},
  }) {
    final requirements = _requirementsByForm[form] ?? const <EvidenceRequirement>[];
    final filtered = requirements
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
    final sortedForms = forms.toList()..sort((a, b) => a.index.compareTo(b.index));
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
    return List<RequiredPhotoCategory>.unmodifiable(requiredPhotos[form] ?? const []);
  }

  static String requirementKeyForPhoto(RequiredPhotoCategory category) {
    return 'photo:${category.name}';
  }

  static List<String> requirementKeysForForm(FormType form) {
    return forForm(form)
        .map(requirementKeyForPhoto)
        .toList(growable: false);
  }

  static void _assertUniqueKeys(List<EvidenceRequirement> requirements) {
    final keys = <String>{};
    for (final requirement in requirements) {
      if (!keys.add(requirement.key)) {
        throw StateError('Duplicate evidence requirement key: ${requirement.key}');
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

  static bool _always(Map<String, dynamic> _) => true;
}

