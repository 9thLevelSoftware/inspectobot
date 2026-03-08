import 'package:flutter/material.dart';

import 'package:inspectobot/features/inspection/domain/wdo_section_definitions.dart';
import 'package:inspectobot/features/inspection/presentation/widgets/form_section_ui.dart';
import 'package:inspectobot/theme/theme.dart';

/// Renders the WDO form as a tabbed view with one tab per section.
///
/// Uses [TabBarView] internally, so the parent must provide bounded height
/// (e.g. via [Expanded]).
class WdoFormStep extends StatefulWidget {
  const WdoFormStep({
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
  State<WdoFormStep> createState() => _WdoFormStepState();
}

class _WdoFormStepState extends State<WdoFormStep>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: WdoSectionDefinitions.all.length,
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
          tabs: WdoSectionDefinitions.all
              .map((s) => Tab(text: s.title))
              .toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: WdoSectionDefinitions.all.map((section) {
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
