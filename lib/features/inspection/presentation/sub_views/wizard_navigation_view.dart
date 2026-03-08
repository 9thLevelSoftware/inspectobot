import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/theme/theme.dart';

import '../../domain/evidence_requirement.dart';
import '../../domain/form_requirements.dart';
import '../../domain/form_type.dart';
import '../../domain/inspection_wizard_state.dart';
import '../../domain/general_inspection_form_data.dart';
import '../../domain/mold_form_data.dart';
import '../shared_widgets/branch_flag_toggle_tile.dart';
import '../shared_widgets/evidence_requirement_card.dart';
import 'general_inspection_form_step.dart';
import 'mold_form_step.dart';
import 'sinkhole_form_step.dart';
import 'wdo_form_step.dart';

/// Renders the current wizard step: step header, branch flag toggles,
/// evidence requirement cards, and the Continue/Finish button.
///
/// Pure [StatelessWidget] -- receives all data and callbacks from the parent.
class WizardNavigationView extends StatelessWidget {
  // Narrative forms (mold, general) use typed data objects instead of generic
  // Map<String,dynamic> because they require explicit toFormDataMap() translation
  // for the narrative PDF engine. See MoldFormData.toFormDataMap() for the key
  // contract. Checklist forms (WDO, Sinkhole) pass raw maps directly.
  const WizardNavigationView({
    super.key,
    required this.wizardState,
    required this.currentStepIndex,
    required this.snapshot,
    required this.isSavingProgress,
    required this.onCapture,
    required this.onContinue,
    required this.onSetBranchFlag,
    this.formData,
    this.onFieldChanged,
    this.moldFormData,
    this.onMoldChanged,
    this.generalFormData,
    this.onGeneralChanged,
  });

  final InspectionWizardState wizardState;
  final int currentStepIndex;
  final WizardProgressSnapshot snapshot;
  final bool isSavingProgress;
  final void Function(EvidenceRequirement) onCapture;
  final VoidCallback onContinue;
  final void Function(String key, bool value) onSetBranchFlag;
  final Map<FormType, Map<String, dynamic>>? formData;
  final void Function(FormType form, String key, dynamic value)? onFieldChanged;
  final MoldFormData? moldFormData;
  final ValueChanged<MoldFormData>? onMoldChanged;
  final GeneralInspectionFormData? generalFormData;
  final ValueChanged<GeneralInspectionFormData>? onGeneralChanged;

  Widget? _buildFormStepWidget(WizardStepDefinition step) {
    if (step.form == FormType.wdo) {
      return WdoFormStep(
        formData: formData?[FormType.wdo] ?? const {},
        branchContext: snapshot.branchContext,
        onFieldChanged: (key, value) {
          onFieldChanged?.call(FormType.wdo, key, value);
        },
        onBranchFlagChanged: onSetBranchFlag,
      );
    }
    if (step.form == FormType.sinkholeInspection) {
      return SinkholeFormStep(
        formData: formData?[FormType.sinkholeInspection] ?? const {},
        branchContext: snapshot.branchContext,
        onFieldChanged: (key, value) {
          onFieldChanged?.call(FormType.sinkholeInspection, key, value);
        },
        onBranchFlagChanged: onSetBranchFlag,
      );
    }
    if (step.form == FormType.moldAssessment) {
      return MoldFormStep(
        formData: moldFormData ?? MoldFormData.empty(),
        onChanged: (data) => onMoldChanged?.call(data),
      );
    }
    if (step.form == FormType.generalInspection) {
      return GeneralInspectionFormStep(
        formData: generalFormData ?? GeneralInspectionFormData.empty(),
        onChanged: (data) => onGeneralChanged?.call(data),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final step = wizardState.steps[currentStepIndex];
    final canContinue = wizardState.canAdvanceFrom(currentStepIndex);
    final isFinalStep = currentStepIndex >= wizardState.steps.length - 1;

    final stickyBottom = AppButton(
      label: isFinalStep ? 'Finish Wizard' : 'Continue to Next Step',
      onPressed: canContinue && !isSavingProgress ? onContinue : null,
      isLoading: isSavingProgress,
      loadingLabel: 'Saving...',
      isThumbZone: true,
    );

    final formWidget = _buildFormStepWidget(step);
    if (formWidget != null) {
      // Form step manages its own scrolling (TabBarView).
      // Do NOT wrap in SingleChildScrollView — it needs bounded height.
      //
      // Evidence capture is handled via separate wizard steps, not inline in
      // form sections. FormSectionUI.evidenceRequirementKeys are metadata for
      // cross-referencing, not UI triggers here.
      //
      // Branch flag toggles are rendered per-section inside FormSectionUI,
      // so we skip _buildBranchInputControls when a form step widget is active.
      return ReachZoneScaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: AppEdgeInsets.pagePadding,
              child: _buildStepHeader(context, step),
            ),
            const SizedBox(height: AppSpacing.spacingSm),
            Expanded(child: formWidget),
          ],
        ),
        stickyBottom: stickyBottom,
      );
    }

    return ReachZoneScaffold(
      body: SingleChildScrollView(
        padding: AppEdgeInsets.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepHeader(context, step),
            const SizedBox(height: AppSpacing.spacingSm),
            _buildStepContent(step),
          ],
        ),
      ),
      stickyBottom: stickyBottom,
    );
  }

  Widget _buildStepHeader(BuildContext context, WizardStepDefinition step) {
    return Text(
      'Step ${currentStepIndex + 1} of ${wizardState.steps.length}: ${step.title}',
      style: AppTypography.subsectionTitle,
    );
  }

  Widget _buildStepContent(WizardStepDefinition step) {
    if (step.requirements.isEmpty && step.form == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacingSm),
        child: const Text(
          'Review the inspection details and continue through each required form step.',
        ),
      );
    }

    final branchControls = _buildBranchInputControls(step);
    final evidenceCards = step.requirements.map((requirement) {
      final captured = snapshot.completion[requirement.key] == true;
      return EvidenceRequirementCard(
        requirement: requirement,
        isCaptured: captured,
        onCapture: requirement.category == null
            ? null
            : () => onCapture(requirement),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (branchControls.isNotEmpty)
          SectionGroup(
            title: 'Conditional Options',
            showDividers: false,
            children: branchControls,
          ),
        if (branchControls.isNotEmpty && evidenceCards.isNotEmpty)
          const SizedBox(height: AppSpacing.spacingLg),
        if (evidenceCards.isNotEmpty)
          SectionGroup(
            title: 'Evidence Requirements',
            children: evidenceCards,
          ),
      ],
    );
  }

  List<Widget> _buildBranchInputControls(WizardStepDefinition step) {
    final form = step.form;
    if (form == null) {
      return const <Widget>[];
    }
    final flags = FormRequirements.branchFlagsByForm[form];
    if (flags == null || flags.isEmpty) {
      return const <Widget>[];
    }
    return flags.map((flag) {
      final label =
          FormRequirements.branchFlagLabels[flag] ?? flag;
      final currentValue = snapshot.branchContext[flag] == true;
      return BranchFlagToggleTile(
        flagKey: flag,
        label: label,
        value: currentValue,
        onChanged: (value) => onSetBranchFlag(flag, value),
      );
    }).toList(growable: false);
  }
}
