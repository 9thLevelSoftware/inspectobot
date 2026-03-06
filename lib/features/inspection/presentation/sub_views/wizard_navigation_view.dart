import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/theme/theme.dart';

import '../../domain/evidence_requirement.dart';
import '../../domain/form_requirements.dart';
import '../../domain/inspection_wizard_state.dart';
import '../shared_widgets/branch_flag_toggle_tile.dart';
import '../shared_widgets/evidence_requirement_card.dart';

/// Renders the current wizard step: step header, branch flag toggles,
/// evidence requirement cards, and the Continue/Finish button.
///
/// Pure [StatelessWidget] -- receives all data and callbacks from the parent.
class WizardNavigationView extends StatelessWidget {
  const WizardNavigationView({
    super.key,
    required this.wizardState,
    required this.currentStepIndex,
    required this.snapshot,
    required this.isSavingProgress,
    required this.onCapture,
    required this.onContinue,
    required this.onSetBranchFlag,
  });

  final InspectionWizardState wizardState;
  final int currentStepIndex;
  final WizardProgressSnapshot snapshot;
  final bool isSavingProgress;
  final void Function(EvidenceRequirement) onCapture;
  final VoidCallback onContinue;
  final void Function(String key, bool value) onSetBranchFlag;

  @override
  Widget build(BuildContext context) {
    final step = wizardState.steps[currentStepIndex];
    final canContinue = wizardState.canAdvanceFrom(currentStepIndex);
    final isFinalStep = currentStepIndex >= wizardState.steps.length - 1;

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
      stickyBottom: AppButton(
        label: isFinalStep ? 'Finish Wizard' : 'Continue to Next Step',
        onPressed: canContinue && !isSavingProgress ? onContinue : null,
        isLoading: isSavingProgress,
        loadingLabel: 'Saving...',
        isThumbZone: true,
      ),
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
