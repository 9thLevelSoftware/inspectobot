import '../../inspection/domain/form_type.dart';

class PdfTemplateManifest {
  const PdfTemplateManifest(this.entriesByForm);

  factory PdfTemplateManifest.standard() {
    return PdfTemplateManifest(<FormType, PdfTemplateManifestEntry>{
      FormType.fourPoint: const PdfTemplateManifestEntry(
        formType: FormType.fourPoint,
        revisionLabel: 'Insp4pt 03-25',
        templateAssetId: 'assets/pdf/templates/insp4pt_03_25.pdf',
        mapAssetPath: 'assets/pdf/maps/insp4pt_03_25.v1.json',
        mapVersion: 'v1',
      ),
      FormType.roofCondition: const PdfTemplateManifestEntry(
        formType: FormType.roofCondition,
        revisionLabel: 'RCF-1 03-25',
        templateAssetId: 'assets/pdf/templates/rcf1_03_25.pdf',
        mapAssetPath: 'assets/pdf/maps/rcf1_03_25.v1.json',
        mapVersion: 'v1',
      ),
      FormType.windMitigation: const PdfTemplateManifestEntry(
        formType: FormType.windMitigation,
        revisionLabel: 'OIR-B1-1802 Rev 04/26',
        templateAssetId: 'assets/pdf/templates/oir_b1_1802_rev_04_26.pdf',
        mapAssetPath: 'assets/pdf/maps/oir_b1_1802_rev_04_26.v1.json',
        mapVersion: 'v1',
      ),
      FormType.wdo: const PdfTemplateManifestEntry(
        formType: FormType.wdo,
        revisionLabel: 'FDACS-13645 Rev. 10/22',
        templateAssetId: 'assets/pdf/templates/fdacs_13645_rev_10_22.pdf',
        mapAssetPath: 'assets/pdf/maps/fdacs_13645_rev_10_22.v1.json',
        mapVersion: 'v1',
      ),
      FormType.sinkholeInspection: const PdfTemplateManifestEntry(
        formType: FormType.sinkholeInspection,
        revisionLabel: 'Citizens Sinkhole v2 Ed. 6/2012',
        templateAssetId: 'assets/pdf/templates/sinkhole_inspection.pdf',
        mapAssetPath: 'assets/pdf/maps/sinkhole_inspection.v1.json',
        mapVersion: 'v1',
      ),
    });
  }

  final Map<FormType, PdfTemplateManifestEntry> entriesByForm;

  PdfTemplateManifestEntry requireForForm(FormType formType) {
    final entry = entriesByForm[formType];
    if (entry == null) {
      throw PdfTemplateManifestError(
        'No pinned template manifest entry for form: ${formType.code}',
      );
    }
    return entry;
  }

  PdfTemplateManifestEntry requireByCodeAndRevision({
    required String formCode,
    required String revisionLabel,
  }) {
    final formType = FormType.values.where((form) => form.code == formCode);
    if (formType.isEmpty) {
      throw PdfTemplateManifestError('Unsupported form code: $formCode');
    }
    final manifestEntry = requireForForm(formType.first);
    if (manifestEntry.revisionLabel != revisionLabel) {
      throw PdfTemplateManifestError(
        'Unsupported revision "$revisionLabel" for form "$formCode". '
        'Expected: ${manifestEntry.revisionLabel}',
      );
    }
    return manifestEntry;
  }
}

class PdfTemplateManifestEntry {
  const PdfTemplateManifestEntry({
    required this.formType,
    required this.revisionLabel,
    required this.templateAssetId,
    required this.mapAssetPath,
    required this.mapVersion,
  });

  final FormType formType;
  final String revisionLabel;
  final String templateAssetId;
  final String mapAssetPath;
  final String mapVersion;
}

class PdfTemplateManifestError implements Exception {
  const PdfTemplateManifestError(this.message);

  final String message;

  @override
  String toString() => message;
}
