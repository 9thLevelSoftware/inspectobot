import 'form_type.dart';
import 'required_photo_category.dart';

class FormRequirements {
  static const Map<FormType, List<RequiredPhotoCategory>> requiredPhotos = {
    FormType.fourPoint: [
      RequiredPhotoCategory.exteriorFront,
      RequiredPhotoCategory.exteriorRear,
      RequiredPhotoCategory.exteriorLeft,
      RequiredPhotoCategory.exteriorRight,
      RequiredPhotoCategory.roofSlopeMain,
      RequiredPhotoCategory.waterHeaterTprValve,
      RequiredPhotoCategory.plumbingUnderSink,
      RequiredPhotoCategory.electricalPanelLabel,
      RequiredPhotoCategory.electricalPanelOpen,
      RequiredPhotoCategory.hvacDataPlate,
    ],
    FormType.roofCondition: [
      RequiredPhotoCategory.roofSlopeMain,
      RequiredPhotoCategory.roofDefect,
    ],
    FormType.windMitigation: [
      RequiredPhotoCategory.roofSlopeMain,
      RequiredPhotoCategory.windRoofDeck,
      RequiredPhotoCategory.windRoofToWall,
      RequiredPhotoCategory.windOpeningProtection,
    ],
  };

  static List<RequiredPhotoCategory> forForms(Set<FormType> forms) {
    final merged = <RequiredPhotoCategory>{};
    for (final form in forms) {
      merged.addAll(requiredPhotos[form] ?? const []);
    }
    return merged.toList(growable: false);
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
}

