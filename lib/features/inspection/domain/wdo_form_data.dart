import 'form_requirements.dart';
import 'shared_building_system_fields.dart';
import 'universal_property_fields.dart';

/// Typed data class for the WDO (Wood-Destroying Organism) inspection form.
///
/// Contains ~37 text fields across 5 sections. Branch flag booleans (12 flags)
/// are stored in [WizardProgressSnapshot.branchContext], not here.
class WdoFormData {
  const WdoFormData({
    // Section 1: General Info (12 fields)
    this.companyName,
    this.businessLicenseNumber,
    this.companyAddress,
    this.phoneNumber,
    this.companyCityStateZip,
    this.inspectionDate,
    this.inspectorName,
    this.inspectorIdCardNumber,
    this.propertyAddress,
    this.structuresInspected,
    this.requestedBy,
    this.reportSentTo,
    // Section 2: Findings (4 fields)
    this.liveWdoDescription,
    this.evidenceDescription,
    this.damageDescription,
    this.findingsNotes,
    // Section 3: Inaccessible Areas (10 fields: 5 areas x 2)
    this.atticSpecificAreas,
    this.atticReason,
    this.interiorSpecificAreas,
    this.interiorReason,
    this.exteriorSpecificAreas,
    this.exteriorReason,
    this.crawlspaceSpecificAreas,
    this.crawlspaceReason,
    this.otherSpecificAreas,
    this.otherReason,
    // Section 4: Treatment Info (7 fields)
    this.previousTreatmentDescription,
    this.noticeLocation,
    this.organismTreated,
    this.pesticideUsed,
    this.treatmentTerms,
    this.spotTreatmentDescription,
    this.treatmentNoticeLocation,
    // Section 5: Comments (4 fields)
    this.comments,
    this.signatureDate,
    this.propertyAddressRepeat,
    this.inspectionDateRepeat,
  });

  // Section 1: General Info
  final String? companyName;
  final String? businessLicenseNumber;
  final String? companyAddress;
  final String? phoneNumber;
  final String? companyCityStateZip;
  final String? inspectionDate;
  final String? inspectorName;
  final String? inspectorIdCardNumber;
  final String? propertyAddress;
  final String? structuresInspected;
  final String? requestedBy;
  final String? reportSentTo;

  // Section 2: Findings
  final String? liveWdoDescription;
  final String? evidenceDescription;
  final String? damageDescription;
  final String? findingsNotes;

  // Section 3: Inaccessible Areas
  final String? atticSpecificAreas;
  final String? atticReason;
  final String? interiorSpecificAreas;
  final String? interiorReason;
  final String? exteriorSpecificAreas;
  final String? exteriorReason;
  final String? crawlspaceSpecificAreas;
  final String? crawlspaceReason;
  final String? otherSpecificAreas;
  final String? otherReason;

  // Section 4: Treatment Info
  final String? previousTreatmentDescription;
  final String? noticeLocation;
  final String? organismTreated;
  final String? pesticideUsed;
  final String? treatmentTerms;
  final String? spotTreatmentDescription;
  final String? treatmentNoticeLocation;

  // Section 5: Comments
  final String? comments;
  final String? signatureDate;
  final String? propertyAddressRepeat;
  final String? inspectionDateRepeat;

  // ---------------------------------------------------------------------------
  // All field keys (used for serialization)
  // ---------------------------------------------------------------------------

  static const List<String> fieldKeys = <String>[
    'companyName',
    'businessLicenseNumber',
    'companyAddress',
    'phoneNumber',
    'companyCityStateZip',
    'inspectionDate',
    'inspectorName',
    'inspectorIdCardNumber',
    'propertyAddress',
    'structuresInspected',
    'requestedBy',
    'reportSentTo',
    'liveWdoDescription',
    'evidenceDescription',
    'damageDescription',
    'findingsNotes',
    'atticSpecificAreas',
    'atticReason',
    'interiorSpecificAreas',
    'interiorReason',
    'exteriorSpecificAreas',
    'exteriorReason',
    'crawlspaceSpecificAreas',
    'crawlspaceReason',
    'otherSpecificAreas',
    'otherReason',
    'previousTreatmentDescription',
    'noticeLocation',
    'organismTreated',
    'pesticideUsed',
    'treatmentTerms',
    'spotTreatmentDescription',
    'treatmentNoticeLocation',
    'comments',
    'signatureDate',
    'propertyAddressRepeat',
    'inspectionDateRepeat',
  ];

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'companyName': companyName,
      'businessLicenseNumber': businessLicenseNumber,
      'companyAddress': companyAddress,
      'phoneNumber': phoneNumber,
      'companyCityStateZip': companyCityStateZip,
      'inspectionDate': inspectionDate,
      'inspectorName': inspectorName,
      'inspectorIdCardNumber': inspectorIdCardNumber,
      'propertyAddress': propertyAddress,
      'structuresInspected': structuresInspected,
      'requestedBy': requestedBy,
      'reportSentTo': reportSentTo,
      'liveWdoDescription': liveWdoDescription,
      'evidenceDescription': evidenceDescription,
      'damageDescription': damageDescription,
      'findingsNotes': findingsNotes,
      'atticSpecificAreas': atticSpecificAreas,
      'atticReason': atticReason,
      'interiorSpecificAreas': interiorSpecificAreas,
      'interiorReason': interiorReason,
      'exteriorSpecificAreas': exteriorSpecificAreas,
      'exteriorReason': exteriorReason,
      'crawlspaceSpecificAreas': crawlspaceSpecificAreas,
      'crawlspaceReason': crawlspaceReason,
      'otherSpecificAreas': otherSpecificAreas,
      'otherReason': otherReason,
      'previousTreatmentDescription': previousTreatmentDescription,
      'noticeLocation': noticeLocation,
      'organismTreated': organismTreated,
      'pesticideUsed': pesticideUsed,
      'treatmentTerms': treatmentTerms,
      'spotTreatmentDescription': spotTreatmentDescription,
      'treatmentNoticeLocation': treatmentNoticeLocation,
      'comments': comments,
      'signatureDate': signatureDate,
      'propertyAddressRepeat': propertyAddressRepeat,
      'inspectionDateRepeat': inspectionDateRepeat,
    };
  }

  factory WdoFormData.fromJson(Map<String, dynamic> json) {
    return WdoFormData(
      companyName: json['companyName'] as String?,
      businessLicenseNumber: json['businessLicenseNumber'] as String?,
      companyAddress: json['companyAddress'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      companyCityStateZip: json['companyCityStateZip'] as String?,
      inspectionDate: json['inspectionDate'] as String?,
      inspectorName: json['inspectorName'] as String?,
      inspectorIdCardNumber: json['inspectorIdCardNumber'] as String?,
      propertyAddress: json['propertyAddress'] as String?,
      structuresInspected: json['structuresInspected'] as String?,
      requestedBy: json['requestedBy'] as String?,
      reportSentTo: json['reportSentTo'] as String?,
      liveWdoDescription: json['liveWdoDescription'] as String?,
      evidenceDescription: json['evidenceDescription'] as String?,
      damageDescription: json['damageDescription'] as String?,
      findingsNotes: json['findingsNotes'] as String?,
      atticSpecificAreas: json['atticSpecificAreas'] as String?,
      atticReason: json['atticReason'] as String?,
      interiorSpecificAreas: json['interiorSpecificAreas'] as String?,
      interiorReason: json['interiorReason'] as String?,
      exteriorSpecificAreas: json['exteriorSpecificAreas'] as String?,
      exteriorReason: json['exteriorReason'] as String?,
      crawlspaceSpecificAreas: json['crawlspaceSpecificAreas'] as String?,
      crawlspaceReason: json['crawlspaceReason'] as String?,
      otherSpecificAreas: json['otherSpecificAreas'] as String?,
      otherReason: json['otherReason'] as String?,
      previousTreatmentDescription:
          json['previousTreatmentDescription'] as String?,
      noticeLocation: json['noticeLocation'] as String?,
      organismTreated: json['organismTreated'] as String?,
      pesticideUsed: json['pesticideUsed'] as String?,
      treatmentTerms: json['treatmentTerms'] as String?,
      spotTreatmentDescription: json['spotTreatmentDescription'] as String?,
      treatmentNoticeLocation: json['treatmentNoticeLocation'] as String?,
      comments: json['comments'] as String?,
      signatureDate: json['signatureDate'] as String?,
      propertyAddressRepeat: json['propertyAddressRepeat'] as String?,
      inspectionDateRepeat: json['inspectionDateRepeat'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // toPdfMaps
  // ---------------------------------------------------------------------------

  /// Separates text fields into [fieldValues] and merges [branchContext]
  /// booleans into [checkboxValues] for PDF generation.
  ({Map<String, String> fieldValues, Map<String, bool> checkboxValues})
      toPdfMaps({Map<String, dynamic>? branchContext}) {
    final fieldValues = <String, String>{};
    final json = toJson();
    for (final entry in json.entries) {
      if (entry.value != null && entry.value is String) {
        fieldValues[entry.key] = entry.value as String;
      }
    }

    final checkboxValues = <String, bool>{};
    if (branchContext != null) {
      for (final flag in _wdoBranchFlagKeys) {
        final value = branchContext[flag];
        if (value is bool) {
          checkboxValues[flag] = value;
        }
      }
    }

    return (fieldValues: fieldValues, checkboxValues: checkboxValues);
  }

  static const _wdoBranchFlagKeys = <String>[
    FormRequirements.wdoVisibleEvidenceBranchFlag,
    FormRequirements.wdoLiveWdoBranchFlag,
    FormRequirements.wdoEvidenceOfWdoBranchFlag,
    FormRequirements.wdoDamageByWdoBranchFlag,
    FormRequirements.wdoPreviousTreatmentBranchFlag,
    FormRequirements.wdoTreatedAtInspectionBranchFlag,
    FormRequirements.wdoAtticInaccessibleBranchFlag,
    FormRequirements.wdoInteriorInaccessibleBranchFlag,
    FormRequirements.wdoExteriorInaccessibleBranchFlag,
    FormRequirements.wdoCrawlspaceInaccessibleBranchFlag,
    FormRequirements.wdoOtherInaccessibleBranchFlag,
    FormRequirements.wdoSpotTreatmentBranchFlag,
  ];

  // ---------------------------------------------------------------------------
  // toFormDataMap
  // ---------------------------------------------------------------------------

  /// Returns this data in the format expected by
  /// `PropertyData.formData[FormType.wdo]`.
  Map<String, dynamic> toFormDataMap() => toJson();

  // ---------------------------------------------------------------------------
  // withDefaults factory
  // ---------------------------------------------------------------------------

  /// Creates a [WdoFormData] pre-filled from [universal] and [shared] fields.
  factory WdoFormData.withDefaults({
    UniversalPropertyFields? universal,
    SharedBuildingSystemFields? shared,
  }) {
    return WdoFormData(
      inspectorName: universal?.inspectorName,
      propertyAddress: universal?.propertyAddress,
      inspectionDate: universal?.inspectionDate.toIso8601String().split('T').first,
      companyName: universal?.inspectorCompany,
      propertyAddressRepeat: universal?.propertyAddress,
      inspectionDateRepeat:
          universal?.inspectionDate.toIso8601String().split('T').first,
      comments: universal?.comments,
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith (closure-based for nullable String? fields)
  // ---------------------------------------------------------------------------

  WdoFormData copyWith({
    String? Function()? companyName,
    String? Function()? businessLicenseNumber,
    String? Function()? companyAddress,
    String? Function()? phoneNumber,
    String? Function()? companyCityStateZip,
    String? Function()? inspectionDate,
    String? Function()? inspectorName,
    String? Function()? inspectorIdCardNumber,
    String? Function()? propertyAddress,
    String? Function()? structuresInspected,
    String? Function()? requestedBy,
    String? Function()? reportSentTo,
    String? Function()? liveWdoDescription,
    String? Function()? evidenceDescription,
    String? Function()? damageDescription,
    String? Function()? findingsNotes,
    String? Function()? atticSpecificAreas,
    String? Function()? atticReason,
    String? Function()? interiorSpecificAreas,
    String? Function()? interiorReason,
    String? Function()? exteriorSpecificAreas,
    String? Function()? exteriorReason,
    String? Function()? crawlspaceSpecificAreas,
    String? Function()? crawlspaceReason,
    String? Function()? otherSpecificAreas,
    String? Function()? otherReason,
    String? Function()? previousTreatmentDescription,
    String? Function()? noticeLocation,
    String? Function()? organismTreated,
    String? Function()? pesticideUsed,
    String? Function()? treatmentTerms,
    String? Function()? spotTreatmentDescription,
    String? Function()? treatmentNoticeLocation,
    String? Function()? comments,
    String? Function()? signatureDate,
    String? Function()? propertyAddressRepeat,
    String? Function()? inspectionDateRepeat,
  }) {
    return WdoFormData(
      companyName:
          companyName != null ? companyName() : this.companyName,
      businessLicenseNumber: businessLicenseNumber != null
          ? businessLicenseNumber()
          : this.businessLicenseNumber,
      companyAddress:
          companyAddress != null ? companyAddress() : this.companyAddress,
      phoneNumber:
          phoneNumber != null ? phoneNumber() : this.phoneNumber,
      companyCityStateZip: companyCityStateZip != null
          ? companyCityStateZip()
          : this.companyCityStateZip,
      inspectionDate:
          inspectionDate != null ? inspectionDate() : this.inspectionDate,
      inspectorName:
          inspectorName != null ? inspectorName() : this.inspectorName,
      inspectorIdCardNumber: inspectorIdCardNumber != null
          ? inspectorIdCardNumber()
          : this.inspectorIdCardNumber,
      propertyAddress:
          propertyAddress != null ? propertyAddress() : this.propertyAddress,
      structuresInspected: structuresInspected != null
          ? structuresInspected()
          : this.structuresInspected,
      requestedBy:
          requestedBy != null ? requestedBy() : this.requestedBy,
      reportSentTo:
          reportSentTo != null ? reportSentTo() : this.reportSentTo,
      liveWdoDescription: liveWdoDescription != null
          ? liveWdoDescription()
          : this.liveWdoDescription,
      evidenceDescription: evidenceDescription != null
          ? evidenceDescription()
          : this.evidenceDescription,
      damageDescription: damageDescription != null
          ? damageDescription()
          : this.damageDescription,
      findingsNotes:
          findingsNotes != null ? findingsNotes() : this.findingsNotes,
      atticSpecificAreas: atticSpecificAreas != null
          ? atticSpecificAreas()
          : this.atticSpecificAreas,
      atticReason:
          atticReason != null ? atticReason() : this.atticReason,
      interiorSpecificAreas: interiorSpecificAreas != null
          ? interiorSpecificAreas()
          : this.interiorSpecificAreas,
      interiorReason:
          interiorReason != null ? interiorReason() : this.interiorReason,
      exteriorSpecificAreas: exteriorSpecificAreas != null
          ? exteriorSpecificAreas()
          : this.exteriorSpecificAreas,
      exteriorReason:
          exteriorReason != null ? exteriorReason() : this.exteriorReason,
      crawlspaceSpecificAreas: crawlspaceSpecificAreas != null
          ? crawlspaceSpecificAreas()
          : this.crawlspaceSpecificAreas,
      crawlspaceReason:
          crawlspaceReason != null ? crawlspaceReason() : this.crawlspaceReason,
      otherSpecificAreas: otherSpecificAreas != null
          ? otherSpecificAreas()
          : this.otherSpecificAreas,
      otherReason:
          otherReason != null ? otherReason() : this.otherReason,
      previousTreatmentDescription: previousTreatmentDescription != null
          ? previousTreatmentDescription()
          : this.previousTreatmentDescription,
      noticeLocation:
          noticeLocation != null ? noticeLocation() : this.noticeLocation,
      organismTreated:
          organismTreated != null ? organismTreated() : this.organismTreated,
      pesticideUsed:
          pesticideUsed != null ? pesticideUsed() : this.pesticideUsed,
      treatmentTerms:
          treatmentTerms != null ? treatmentTerms() : this.treatmentTerms,
      spotTreatmentDescription: spotTreatmentDescription != null
          ? spotTreatmentDescription()
          : this.spotTreatmentDescription,
      treatmentNoticeLocation: treatmentNoticeLocation != null
          ? treatmentNoticeLocation()
          : this.treatmentNoticeLocation,
      comments: comments != null ? comments() : this.comments,
      signatureDate:
          signatureDate != null ? signatureDate() : this.signatureDate,
      propertyAddressRepeat: propertyAddressRepeat != null
          ? propertyAddressRepeat()
          : this.propertyAddressRepeat,
      inspectionDateRepeat: inspectionDateRepeat != null
          ? inspectionDateRepeat()
          : this.inspectionDateRepeat,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WdoFormData &&
          runtimeType == other.runtimeType &&
          companyName == other.companyName &&
          businessLicenseNumber == other.businessLicenseNumber &&
          companyAddress == other.companyAddress &&
          phoneNumber == other.phoneNumber &&
          companyCityStateZip == other.companyCityStateZip &&
          inspectionDate == other.inspectionDate &&
          inspectorName == other.inspectorName &&
          inspectorIdCardNumber == other.inspectorIdCardNumber &&
          propertyAddress == other.propertyAddress &&
          structuresInspected == other.structuresInspected &&
          requestedBy == other.requestedBy &&
          reportSentTo == other.reportSentTo &&
          liveWdoDescription == other.liveWdoDescription &&
          evidenceDescription == other.evidenceDescription &&
          damageDescription == other.damageDescription &&
          findingsNotes == other.findingsNotes &&
          atticSpecificAreas == other.atticSpecificAreas &&
          atticReason == other.atticReason &&
          interiorSpecificAreas == other.interiorSpecificAreas &&
          interiorReason == other.interiorReason &&
          exteriorSpecificAreas == other.exteriorSpecificAreas &&
          exteriorReason == other.exteriorReason &&
          crawlspaceSpecificAreas == other.crawlspaceSpecificAreas &&
          crawlspaceReason == other.crawlspaceReason &&
          otherSpecificAreas == other.otherSpecificAreas &&
          otherReason == other.otherReason &&
          previousTreatmentDescription == other.previousTreatmentDescription &&
          noticeLocation == other.noticeLocation &&
          organismTreated == other.organismTreated &&
          pesticideUsed == other.pesticideUsed &&
          treatmentTerms == other.treatmentTerms &&
          spotTreatmentDescription == other.spotTreatmentDescription &&
          treatmentNoticeLocation == other.treatmentNoticeLocation &&
          comments == other.comments &&
          signatureDate == other.signatureDate &&
          propertyAddressRepeat == other.propertyAddressRepeat &&
          inspectionDateRepeat == other.inspectionDateRepeat;

  @override
  int get hashCode => Object.hashAll(<Object?>[
        companyName,
        businessLicenseNumber,
        companyAddress,
        phoneNumber,
        companyCityStateZip,
        inspectionDate,
        inspectorName,
        inspectorIdCardNumber,
        propertyAddress,
        structuresInspected,
        requestedBy,
        reportSentTo,
        liveWdoDescription,
        evidenceDescription,
        damageDescription,
        findingsNotes,
        atticSpecificAreas,
        atticReason,
        interiorSpecificAreas,
        interiorReason,
        exteriorSpecificAreas,
        exteriorReason,
        crawlspaceSpecificAreas,
        crawlspaceReason,
        otherSpecificAreas,
        otherReason,
        previousTreatmentDescription,
        noticeLocation,
        organismTreated,
        pesticideUsed,
        treatmentTerms,
        spotTreatmentDescription,
        treatmentNoticeLocation,
        comments,
        signatureDate,
        propertyAddressRepeat,
        inspectionDateRepeat,
      ]);
}
