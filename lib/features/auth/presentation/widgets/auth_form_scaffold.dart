import 'package:flutter/material.dart';
import 'package:inspectobot/theme/tokens.dart';

/// Standard scaffold layout for all auth screens.
///
/// Provides a consistent structure: [AppBar] with [title], a scrollable [Form]
/// containing [fields] separated by standard spacing, an optional
/// [feedbackBanner] (e.g. error/info banner), a [submitButton], and optional
/// secondary [actions] below the form.
class AuthFormScaffold extends StatelessWidget {
  const AuthFormScaffold({
    super.key,
    required this.title,
    required this.formKey,
    required this.fields,
    required this.submitButton,
    this.actions = const [],
    this.feedbackBanner,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> fields;
  final Widget submitButton;
  final List<Widget> actions;
  final Widget? feedbackBanner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingLg,
          vertical: AppSpacing.spacingXl,
        ),
        children: [
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < fields.length; i++) ...[
                  if (i > 0)
                    const SizedBox(height: AppSpacing.spacingMd),
                  fields[i],
                ],
                if (feedbackBanner != null) ...[
                  const SizedBox(height: AppSpacing.spacingMd),
                  feedbackBanner!,
                ],
                const SizedBox(height: AppSpacing.spacingLg),
                submitButton,
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spacingMd),
          ...actions,
        ],
      ),
    );
  }
}
