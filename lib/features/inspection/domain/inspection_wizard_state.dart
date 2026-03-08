import 'evidence_requirement.dart';
import 'form_requirements.dart';
import 'form_type.dart';
import 'required_photo_category.dart';

enum WizardProgressStatus { inProgress, complete }

class WizardProgressSnapshot {
  const WizardProgressSnapshot({
    required this.lastStepIndex,
    required this.completion,
    required this.branchContext,
    required this.status,
  });

  final int lastStepIndex;
  final Map<String, bool> completion;
  final Map<String, dynamic> branchContext;
  final WizardProgressStatus status;

  static const empty = WizardProgressSnapshot(
    lastStepIndex: 0,
    completion: <String, bool>{},
    branchContext: <String, dynamic>{},
    status: WizardProgressStatus.inProgress,
  );

  WizardProgressSnapshot copyWith({
    int? lastStepIndex,
    Map<String, bool>? completion,
    Map<String, dynamic>? branchContext,
    WizardProgressStatus? status,
  }) {
    return WizardProgressSnapshot(
      lastStepIndex: lastStepIndex ?? this.lastStepIndex,
      completion: completion ?? this.completion,
      branchContext: branchContext ?? this.branchContext,
      status: status ?? this.status,
    );
  }
}

class WizardStepDefinition {
  const WizardStepDefinition({
    required this.id,
    required this.title,
    required this.requirements,
    this.form,
  });

  final String id;
  final String title;
  final List<EvidenceRequirement> requirements;
  final FormType? form;

  List<String> get requiredRequirementKeys {
    return requirements.map((requirement) => requirement.key).toList(growable: false);
  }

  List<RequiredPhotoCategory> get requiredCategories {
    return requirements
        .where((requirement) => requirement.mediaType == EvidenceMediaType.photo)
        .map((requirement) => requirement.category)
        .whereType<RequiredPhotoCategory>()
        .toList(growable: false);
  }

  bool isComplete(Map<String, bool> completion) {
    for (final requirement in requirements) {
      if (_countCompletions(completion, requirement.key) < requirement.minimumCount) {
        return false;
      }
    }
    return true;
  }

  static int _countCompletions(Map<String, bool> completion, String requirementKey) {
    var count = 0;
    for (final entry in completion.entries) {
      if (entry.value != true) {
        continue;
      }
      if (entry.key == requirementKey || entry.key.startsWith('$requirementKey#')) {
        count += 1;
      }
    }
    return count;
  }
}

class FormProgressSummary {
  const FormProgressSummary({
    required this.form,
    required this.missingRequirements,
    required this.totalRequirements,
  });

  final FormType form;
  final List<EvidenceRequirement> missingRequirements;
  final int totalRequirements;

  /// Percentage of requirements completed (0–100).
  int get percentComplete {
    if (totalRequirements == 0) return 100;
    return ((totalRequirements - missingRequirements.length) /
            totalRequirements *
            100)
        .round();
  }

  /// Short abbreviation label for the form type.
  /// Delegates to [FormType.abbreviation] to keep abbreviations in one place.
  String get abbreviation => form.abbreviation;

  List<RequiredPhotoCategory> get missingCategories {
    return missingRequirements
        .where((requirement) => requirement.mediaType == EvidenceMediaType.photo)
        .map((requirement) => requirement.category)
        .whereType<RequiredPhotoCategory>()
        .toList(growable: false);
  }

  bool get isComplete => missingRequirements.isEmpty;
}

class InspectionWizardState {
  InspectionWizardState({
    required Set<FormType> enabledForms,
    required WizardProgressSnapshot snapshot,
  })  : _enabledForms = enabledForms,
        _snapshot = snapshot,
        _canonicalBranchContext = _canonicalizeBranchContext(snapshot.branchContext),
        steps = _buildSteps(
          enabledForms.toList()..sort((a, b) => a.index.compareTo(b.index)),
          _canonicalizeBranchContext(snapshot.branchContext),
        );

  final Set<FormType> _enabledForms;
  final WizardProgressSnapshot _snapshot;
  final Map<String, dynamic> _canonicalBranchContext;
  final List<WizardStepDefinition> steps;

  int get safeLastStepIndex {
    if (steps.isEmpty) {
      return 0;
    }
    return _snapshot.lastStepIndex.clamp(0, steps.length - 1);
  }

  bool canAdvanceFrom(int stepIndex) {
    if (stepIndex < 0 || stepIndex >= steps.length) {
      return false;
    }
    return steps[stepIndex].isComplete(_snapshot.completion);
  }

  bool canVisitStep(int targetIndex) {
    if (targetIndex < 0 || targetIndex >= steps.length) {
      return false;
    }
    for (var index = 0; index < targetIndex; index += 1) {
      if (!steps[index].isComplete(_snapshot.completion)) {
        return false;
      }
    }
    return true;
  }

  int resolveNextIncompleteStep() {
    for (var index = 0; index < steps.length; index += 1) {
      if (!steps[index].isComplete(_snapshot.completion)) {
        return index;
      }
    }
    return steps.isEmpty ? 0 : steps.length - 1;
  }

  bool get isComplete {
    if (_enabledForms.isEmpty) {
      return true;
    }
    final summaries = buildFormSummaries();
    return summaries.every((summary) => summary.isComplete);
  }

  List<FormProgressSummary> buildFormSummaries() {
    final sortedForms = _enabledForms.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return sortedForms.map((form) {
      final requirements = FormRequirements.forFormRequirements(
        form,
        branchContext: _canonicalBranchContext,
      );
      final missing = requirements
          .where(
            (requirement) =>
                WizardStepDefinition._countCompletions(_snapshot.completion, requirement.key) <
                requirement.minimumCount,
          )
          .toList(growable: false);
      return FormProgressSummary(
        form: form,
        missingRequirements: missing,
        totalRequirements: requirements.length,
      );
    }).toList(growable: false);
  }

  static List<WizardStepDefinition> _buildSteps(
    List<FormType> forms,
    Map<String, dynamic> branchContext,
  ) {
    final steps = <WizardStepDefinition>[
      const WizardStepDefinition(
        id: 'inspection_overview',
        title: 'Inspection Overview',
        requirements: <EvidenceRequirement>[],
      ),
    ];

    for (final form in forms) {
      final requirements = FormRequirements.forFormRequirements(
        form,
        branchContext: branchContext,
      );
      steps.add(
        WizardStepDefinition(
          id: 'form_${form.code}',
          title: form.label,
          requirements: requirements,
          form: form,
        ),
      );
    }

    return steps;
  }

  static Map<String, dynamic> _canonicalizeBranchContext(
    Map<String, dynamic> branchContext,
  ) {
    final canonical = <String, dynamic>{};
    for (final key in FormRequirements.canonicalBranchFlags) {
      final value = branchContext[key];
      if (value is bool) {
        canonical[key] = value;
      }
    }
    return canonical;
  }
}
