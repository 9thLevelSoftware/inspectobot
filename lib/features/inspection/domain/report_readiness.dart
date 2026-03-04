import 'form_requirements.dart';
import 'form_type.dart';

enum ReportReadinessStatus { ready, blocked }

class ReportReadiness {
  const ReportReadiness({
    required this.inspectionId,
    required this.organizationId,
    required this.userId,
    required this.status,
    required this.missingItems,
    required this.computedAt,
  });

  final String inspectionId;
  final String organizationId;
  final String userId;
  final ReportReadinessStatus status;
  final List<String> missingItems;
  final DateTime computedAt;

  bool get isReady => status == ReportReadinessStatus.ready;

  factory ReportReadiness.fromJson(Map<String, dynamic> json) {
    final statusRaw = json['status'] as String?;
    final itemsRaw = json['missing_items'];
    final items = <String>[];
    if (itemsRaw is List) {
      for (final item in itemsRaw) {
        if (item is String) {
          items.add(item);
        }
      }
    }

    return ReportReadiness(
      inspectionId: json['inspection_id'] as String,
      organizationId: json['organization_id'] as String,
      userId: json['user_id'] as String,
      status: statusRaw == 'ready'
          ? ReportReadinessStatus.ready
          : ReportReadinessStatus.blocked,
      missingItems: List<String>.unmodifiable(items),
      computedAt: DateTime.parse(json['computed_at'] as String).toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'status': status.name,
      'missing_items': missingItems,
      'computed_at': computedAt.toIso8601String(),
    };
  }

  static ReportReadiness evaluate({
    required Set<FormType> enabledForms,
    required Map<String, bool> completion,
    required Map<String, dynamic> branchContext,
    String inspectionId = '',
    String organizationId = '',
    String userId = '',
    DateTime? computedAt,
  }) {
    final missing = <String>[];
    final requirements = FormRequirements.evaluate(
      enabledForms,
      branchContext: branchContext,
    );
    for (final requirement in requirements) {
      var count = 0;
      for (final entry in completion.entries) {
        if (entry.value != true) {
          continue;
        }
        if (entry.key == requirement.key || entry.key.startsWith('${requirement.key}#')) {
          count += 1;
        }
      }
      if (count < requirement.minimumCount) {
        missing.add(requirement.label);
      }
    }

    missing.sort();
    return ReportReadiness(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      status: missing.isEmpty ? ReportReadinessStatus.ready : ReportReadinessStatus.blocked,
      missingItems: List<String>.unmodifiable(missing),
      computedAt: (computedAt ?? DateTime.now()).toUtc(),
    );
  }
}
