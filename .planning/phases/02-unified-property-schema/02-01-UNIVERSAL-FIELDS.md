# 02-01: UniversalPropertyFields Class Design

> **Plan**: 02-01 Core Shared Models
> **Task**: 1 of 3
> **Date**: 2026-03-07
> **Source**: FIELD_INVENTORY Section 2.1 + Spec Section 3.1

---

## 1. Complete Dart Class Specification

```dart
/// Strongly-typed fields present on all or nearly all 7 form types.
///
/// These 8 fields represent the core identity of every property inspection
/// and are shared across 5+ of the 7 Florida inspection form types.
///
/// Source: FIELD_INVENTORY Section 2.1 (Universal Fields)
/// File: lib/features/inspection/domain/universal_property_fields.dart
class UniversalPropertyFields {
  const UniversalPropertyFields({
    required this.propertyAddress,
    required this.inspectionDate,
    required this.inspectorName,
    required this.inspectorCompany,
    required this.inspectorLicenseNumber,
    required this.clientName,
    this.inspectorSignaturePath,
    this.comments,
  });

  /// Full street address of the property inspected.
  ///
  /// Present on: All 7 forms.
  /// Name variations:
  ///   - "Address Inspected" (4-Point)
  ///   - "Address of Property Inspected" (WDO 1.9, Sinkhole 0.2)
  ///   - "Property Address" (Mold, General)
  /// Validation: Non-empty after trimming.
  /// Backward compat: Maps to InspectionDraft.propertyAddress (direct 1:1).
  final String propertyAddress;

  /// Date the inspection was performed.
  ///
  /// Present on: All 7 forms.
  /// Name variations:
  ///   - "Date Inspected" (4-Point, RCF-1)
  ///   - "Date of Inspection" (WDO 1.6, Wind Mit, Sinkhole 0.4)
  ///   - "Assessment Date(s)" (Mold)
  ///   - "Inspection Date" (General)
  /// Validation: Not in the future by more than 365 days; not before 1900-01-01.
  /// Semantic note: Mold Assessment allows multi-day inspections. This field
  /// stores the first day; an optional end date is stored in
  /// formData['mold.header.assessmentEndDate'].
  /// Backward compat: Maps to InspectionDraft.inspectionDate (direct 1:1).
  final DateTime inspectionDate;

  /// Full name of the inspector performing the inspection.
  ///
  /// Present on: All 7 forms.
  /// Name variations:
  ///   - "Inspector Signature block" (4-Point, RCF-1, Wind Mit)
  ///   - "Inspector's Name (Print)" (WDO 1.7)
  ///   - "Inspector Name" (Sinkhole 0.5, General)
  ///   - "Assessor Name" (Mold)
  /// Validation: Non-empty after trimming.
  /// Semantic note: WDO specifically requires a printed name (not just
  /// signature). All forms accept a printed name string.
  /// Populated from: InspectorProfile via identity module.
  /// Backward compat: New field (not in InspectionDraft/InspectionSetup).
  final String inspectorName;

  /// Name of the inspection company.
  ///
  /// Present on: All 7 forms.
  /// Name variations:
  ///   - "Company Name" (4-Point, RCF-1, Wind Mit, Mold)
  ///   - "Inspection Company Name" (WDO 1.1)
  ///   - "Inspector Company" (Sinkhole 0.7, General)
  /// Validation: Non-empty after trimming.
  /// Populated from: InspectorProfile via identity module.
  /// Backward compat: New field (not in InspectionDraft/InspectionSetup).
  final String inspectorCompany;

  /// Inspector's license or ID card number.
  ///
  /// Present on: 6 of 7 forms (absent from some General Inspection variants).
  /// Name variations:
  ///   - "License Number" (4-Point, RCF-1, Wind Mit)
  ///   - "Inspector's ID Card Number" (WDO 1.8)
  ///   - "Inspector License Number" (Sinkhole 0.6)
  ///   - "MRSA License Number" (Mold)
  /// Validation: Non-empty after trimming.
  /// Semantic note: The license TYPE varies by form:
  ///   - Home inspector license (4-Point, RCF-1, Wind Mit, General)
  ///   - FDACS pest control ID card (WDO)
  ///   - MRSA license (Mold)
  ///   The license type is stored per-form in formData (e.g.,
  ///   'fourPoint.inspector.licenseType', 'wdo.header.licenseType').
  /// Populated from: InspectorProfile via identity module.
  /// Backward compat: New field (not in InspectionDraft/InspectionSetup).
  final String inspectorLicenseNumber;

  /// Name of the client / insured / applicant / customer.
  ///
  /// Present on: All 7 forms (possibly 6 if HUD uses case-based ID, but
  /// HUD is not a distinct form type in scope).
  /// Name variations:
  ///   - "Insured/Applicant Name" (4-Point, Sinkhole 0.1)
  ///   - "Policyholder Name" (Wind Mit)
  ///   - "Insured Name" (RCF-1)
  ///   - "Inspection requested by" (WDO 1.11)
  ///   - "Client Name" (Mold)
  ///   - "Customer Name(s)" (General)
  /// Validation: Non-empty after trimming.
  /// Backward compat: Maps to InspectionDraft.clientName (direct 1:1).
  final String clientName;

  /// Local file path to the inspector's signature image.
  ///
  /// Present on: All 7 forms.
  /// Name variations:
  ///   - "Inspector Signature" (4-Point, RCF-1, Wind Mit)
  ///   - "Signature of Licensee or Agent" (WDO 5.3)
  ///   - Implied (Sinkhole, Mold, General)
  /// Validation: If non-null, file must exist at the given path.
  /// Nullable: Null until signature is captured during the wizard flow.
  /// Semantic note: Already mapped in 3 existing forms as
  /// `signature.inspector`. WDO has a separate licensee signature.
  /// Backward compat: New field (captured during wizard, not in setup).
  final String? inspectorSignaturePath;

  /// General comments / additional observations.
  ///
  /// Present on: All 7 forms.
  /// Name variations:
  ///   - "Additional Comments/Observations" (4-Point, RCF-1)
  ///   - "Comments" (WDO 5.1, Wind Mit)
  ///   - "Other relevant information" (Sinkhole 5.4)
  ///   - Narrative sections (Mold, General)
  /// Validation: None (free text). Trimmed on save.
  /// Nullable: Null if no comments provided.
  /// Backward compat: New field (not in InspectionDraft/InspectionSetup).
  final String? comments;

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Serializes to JSON.
  ///
  /// JSON keys use snake_case to match InspectionSetup convention:
  /// ```json
  /// {
  ///   "property_address": "123 Main St, Tampa, FL 33601",
  ///   "inspection_date": "2026-03-07",
  ///   "inspector_name": "John Smith",
  ///   "inspector_company": "ABC Inspections",
  ///   "inspector_license_number": "HI-12345",
  ///   "client_name": "Jane Doe",
  ///   "inspector_signature_path": "/data/.../signature.png",
  ///   "comments": "No major issues found."
  /// }
  /// ```
  Map<String, dynamic> toJson() => {
    'property_address': propertyAddress,
    'inspection_date': inspectionDate.toIso8601String().split('T').first,
    'inspector_name': inspectorName,
    'inspector_company': inspectorCompany,
    'inspector_license_number': inspectorLicenseNumber,
    'client_name': clientName,
    if (inspectorSignaturePath != null)
      'inspector_signature_path': inspectorSignaturePath,
    if (comments != null) 'comments': comments,
  };

  /// Deserializes from JSON.
  ///
  /// Required keys: property_address, inspection_date, inspector_name,
  /// inspector_company, inspector_license_number, client_name.
  /// Optional keys: inspector_signature_path, comments.
  factory UniversalPropertyFields.fromJson(Map<String, dynamic> json) {
    return UniversalPropertyFields(
      propertyAddress: json['property_address'] as String,
      inspectionDate: DateTime.parse(json['inspection_date'] as String).toUtc(),
      inspectorName: json['inspector_name'] as String,
      inspectorCompany: json['inspector_company'] as String,
      inspectorLicenseNumber: json['inspector_license_number'] as String,
      clientName: json['client_name'] as String,
      inspectorSignaturePath: json['inspector_signature_path'] as String?,
      comments: json['comments'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Copy
  // ---------------------------------------------------------------------------

  /// Returns a new instance with specified fields replaced.
  UniversalPropertyFields copyWith({
    String? propertyAddress,
    DateTime? inspectionDate,
    String? inspectorName,
    String? inspectorCompany,
    String? inspectorLicenseNumber,
    String? clientName,
    String? Function()? inspectorSignaturePath,
    String? Function()? comments,
  }) {
    return UniversalPropertyFields(
      propertyAddress: propertyAddress ?? this.propertyAddress,
      inspectionDate: inspectionDate ?? this.inspectionDate,
      inspectorName: inspectorName ?? this.inspectorName,
      inspectorCompany: inspectorCompany ?? this.inspectorCompany,
      inspectorLicenseNumber:
          inspectorLicenseNumber ?? this.inspectorLicenseNumber,
      clientName: clientName ?? this.clientName,
      inspectorSignaturePath: inspectorSignaturePath != null
          ? inspectorSignaturePath()
          : this.inspectorSignaturePath,
      comments: comments != null ? comments() : this.comments,
    );
  }
}
```

**Design decision -- nullable optionals in copyWith**: For nullable fields (`inspectorSignaturePath`, `comments`), `copyWith` accepts `String? Function()?` so callers can explicitly set them to `null` by passing `() => null`. This follows the Dart copyWith convention for nullable fields without using sentinel values.

---

## 2. Field Cross-Check Against FIELD_INVENTORY Section 2.1

| # | FIELD_INVENTORY Normalized Name | Type in Inventory | Dart Field | Dart Type | Accounted |
|---|-------------------------------|-------------------|------------|-----------|-----------|
| 1 | `property_address` | text | `propertyAddress` | `String` | YES |
| 2 | `inspection_date` | date | `inspectionDate` | `DateTime` | YES |
| 3 | `inspector_name` | text | `inspectorName` | `String` | YES |
| 4 | `inspector_company` | text | `inspectorCompany` | `String` | YES |
| 5 | `inspector_signature` | signature | `inspectorSignaturePath` | `String?` | YES |
| 6 | `inspector_license_number` | text | `inspectorLicenseNumber` | `String` | YES |
| 7 | `client_name` | text | `clientName` | `String` | YES |
| 8 | `comments` | text (multi-line) | `comments` | `String?` | YES |

**Result**: All 8 universal fields accounted for. Zero missing.

---

## 3. Field Type Verification

| Field | FIELD_INVENTORY Type | Dart Type | Match | Notes |
|-------|---------------------|-----------|-------|-------|
| `property_address` | text | `String` | YES | |
| `inspection_date` | date | `DateTime` | YES | |
| `inspector_name` | text | `String` | YES | |
| `inspector_company` | text | `String` | YES | |
| `inspector_signature` | signature | `String?` | YES | Stored as file path; the actual signature is a PNG image on disk |
| `inspector_license_number` | text | `String` | YES | |
| `client_name` | text | `String` | YES | |
| `comments` | text (multi-line) | `String?` | YES | Multi-line handled by widget, not type |

---

## 4. Validation Rules Summary

| Field | Rule | Error Message Pattern |
|-------|------|-----------------------|
| `propertyAddress` | `value.trim().isNotEmpty` | "Property address is required" |
| `inspectionDate` | Not after `now + 365 days`; not before `1900-01-01` | "Inspection date is out of valid range" |
| `inspectorName` | `value.trim().isNotEmpty` | "Inspector name is required" |
| `inspectorCompany` | `value.trim().isNotEmpty` | "Company name is required" |
| `inspectorLicenseNumber` | `value.trim().isNotEmpty` | "License number is required" |
| `clientName` | `value.trim().isNotEmpty` | "Client name is required" |
| `inspectorSignaturePath` | If non-null, file exists at path | "Signature file not found" |
| `comments` | None (optional free text) | -- |

---

## 5. Backward Compatibility Mapping Table

| UniversalPropertyFields | InspectionDraft Field | InspectionSetup Field | Direction | Notes |
|------------------------|----------------------|----------------------|-----------|-------|
| `propertyAddress` | `propertyAddress` (String, required) | `propertyAddress` (String, required) | Bidirectional 1:1 | Identical type and semantics |
| `inspectionDate` | `inspectionDate` (DateTime, required) | `inspectionDate` (DateTime, required) | Bidirectional 1:1 | Identical type and semantics |
| `inspectorName` | -- | -- | New field | Populated from InspectorProfile |
| `inspectorCompany` | -- | -- | New field | Populated from InspectorProfile |
| `inspectorLicenseNumber` | -- | -- | New field | Populated from InspectorProfile |
| `clientName` | `clientName` (String, required) | `clientName` (String, required) | Bidirectional 1:1 | Identical type and semantics |
| `inspectorSignaturePath` | -- | -- | New field | Captured during wizard |
| `comments` | -- | -- | New field | General comments |

**Fields on InspectionDraft/InspectionSetup NOT mapped to UniversalPropertyFields** (retained elsewhere):

| Field | Location | Reason |
|-------|----------|--------|
| `clientEmail` | PropertyData (app-only) | Not on any paper form |
| `clientPhone` | PropertyData (app-only) | Not on any paper form |
| `yearBuilt` | SharedBuildingSystemFields | Only on 5 of 7 forms |
| `inspectionId` | InspectionDraft (workflow) | Not property data |
| `organizationId` | InspectionDraft (workflow) | Not property data |
| `userId` | InspectionDraft (workflow) | Not property data |
| `enabledForms` | InspectionDraft (workflow) | Not property data |
| `wizardSnapshot` | InspectionDraft (workflow) | Not property data |
| `initialStepIndex` | InspectionDraft (workflow) | Not property data |

---

## 6. Semantic Differences Across Forms

| Field | Semantic Variation | Resolution |
|-------|-------------------|------------|
| `inspectionDate` | Mold Assessment allows multi-day inspections ("Assessment Date(s)") | Store first day in `inspectionDate`; store end date in `formData['mold.header.assessmentEndDate']` |
| `inspectorLicenseNumber` | License TYPE varies: home inspector (4-Pt, RCF-1, Wind Mit, General), FDACS pest control ID (WDO), MRSA license (Mold) | Store the license number here; store the license type per-form in formData |
| `clientName` | Terminology varies: "Insured" (insurance), "Client" (assessment), "Customer" (general), "Requested by" (WDO) | Semantically identical -- the person who ordered/benefits from the inspection |
| `comments` | Prompt text varies: "Additional Comments/Observations" vs "Other relevant information" vs narrative sections | All serve the same purpose: free-text observations. Form-specific comment sections stored in formData |
| `inspectorSignaturePath` | WDO uses "Signature of Licensee or Agent" (different legal framing) | Same physical action; WDO legal distinction handled by form-specific fields if needed |
