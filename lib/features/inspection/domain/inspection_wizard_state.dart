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
    required this.requiredRequirementKeys,
    required this.requiredCategories,
    this.form,
  });

  final String id;
  final String title;
  final List<String> requiredRequirementKeys;
  final List<RequiredPhotoCategory> requiredCategories;
  final FormType? form;

  bool isComplete(Map<String, bool> completion) {
    return requiredRequirementKeys.every((key) => completion[key] == true);
  }
}

class FormProgressSummary {
  const FormProgressSummary({
    required this.form,
    required this.missingCategories,
  });

  final FormType form;
  final List<RequiredPhotoCategory> missingCategories;

  bool get isComplete => missingCategories.isEmpty;
}

class InspectionWizardState {
  InspectionWizardState({
    required Set<FormType> enabledForms,
    required WizardProgressSnapshot snapshot,
  })  : _enabledForms = enabledForms,
        _snapshot = snapshot,
        steps = _buildSteps(enabledForms.toList()..sort((a, b) => a.index.compareTo(b.index)));

  final Set<FormType> _enabledForms;
  final WizardProgressSnapshot _snapshot;
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
      final categories = FormRequirements.forForm(form);
      final missing = categories
          .where(
            (category) => _snapshot
                .completion[FormRequirements.requirementKeyForPhoto(category)] !=
            true,
          )
          .toList(growable: false);
      return FormProgressSummary(form: form, missingCategories: missing);
    }).toList(growable: false);
  }

  static List<WizardStepDefinition> _buildSteps(List<FormType> forms) {
    final steps = <WizardStepDefinition>[
      const WizardStepDefinition(
        id: 'inspection_overview',
        title: 'Inspection Overview',
        requiredRequirementKeys: <String>[],
        requiredCategories: <RequiredPhotoCategory>[],
      ),
    ];

    for (final form in forms) {
      final requiredCategories = FormRequirements.forForm(form);
      steps.add(
        WizardStepDefinition(
          id: 'form_${form.code}',
          title: form.label,
          requiredRequirementKeys: FormRequirements.requirementKeysForForm(form),
          requiredCategories: requiredCategories,
          form: form,
        ),
      );
    }

    return steps;
  }
}
