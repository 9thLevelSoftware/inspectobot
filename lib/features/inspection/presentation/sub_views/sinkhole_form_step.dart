import 'package:flutter/material.dart';

import 'package:inspectobot/features/inspection/domain/sinkhole_section_definitions.dart';
import 'package:inspectobot/features/inspection/presentation/widgets/form_section_ui.dart';
import 'package:inspectobot/theme/theme.dart';

/// Renders the Sinkhole Inspection form as a tabbed view with one tab per
/// section (7 total).
///
/// Uses [TabBarView] internally, so the parent must provide bounded height
/// (e.g. via [Expanded]).
class SinkholeFormStep extends StatefulWidget {
  const SinkholeFormStep({
    super.key,
    required this.formData,
    required this.branchContext,
    required this.onFieldChanged,
    required this.onBranchFlagChanged,
  });

  final Map<String, dynamic> formData;
  final Map<String, dynamic> branchContext;
  final void Function(String key, dynamic value) onFieldChanged;
  final void Function(String key, bool value) onBranchFlagChanged;

  @override
  State<SinkholeFormStep> createState() => _SinkholeFormStepState();
}

class _SinkholeFormStepState extends State<SinkholeFormStep>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: SinkholeSectionDefinitions.all.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Palette.primary,
          labelColor: Palette.primary,
          unselectedLabelColor: Palette.onSurfaceVariant,
          tabAlignment: TabAlignment.start,
          tabs: SinkholeSectionDefinitions.all
              .map((s) => Tab(text: s.title))
              .toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: SinkholeSectionDefinitions.all.map((section) {
              return FormSectionUI(
                section: section,
                formValues: widget.formData,
                branchContext: widget.branchContext,
                onFieldChanged: widget.onFieldChanged,
                onBranchFlagChanged: widget.onBranchFlagChanged,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
