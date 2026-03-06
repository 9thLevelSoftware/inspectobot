import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/auth/presentation/widgets/auth_form_scaffold.dart';
import 'package:inspectobot/theme/app_theme.dart';

void main() {
  Widget buildSubject({
    String title = 'Test Title',
    List<Widget> fields = const [],
    Widget submitButton = const FilledButton(
      onPressed: null,
      child: Text('Submit'),
    ),
    List<Widget> actions = const [],
    Widget? feedbackBanner,
  }) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: AuthFormScaffold(
        title: title,
        formKey: GlobalKey<FormState>(),
        fields: fields,
        submitButton: submitButton,
        actions: actions,
        feedbackBanner: feedbackBanner,
      ),
    );
  }

  testWidgets('renders title in AppBar', (tester) async {
    await tester.pumpWidget(buildSubject(title: 'Sign In'));

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('renders provided field widgets', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        fields: [
          const TextField(key: ValueKey('field1')),
          const TextField(key: ValueKey('field2')),
        ],
      ),
    );

    expect(find.byKey(const ValueKey('field1')), findsOneWidget);
    expect(find.byKey(const ValueKey('field2')), findsOneWidget);
  });

  testWidgets('renders submit button', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('renders action widgets when provided', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Action Link'),
          ),
        ],
      ),
    );

    expect(find.text('Action Link'), findsOneWidget);
  });

  testWidgets('renders feedbackBanner when provided', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        feedbackBanner: const Text('Error occurred'),
      ),
    );

    expect(find.text('Error occurred'), findsOneWidget);
  });

  testWidgets('does not render feedbackBanner slot when null', (tester) async {
    await tester.pumpWidget(buildSubject(feedbackBanner: null));

    // The scaffold should render without any feedback banner widget.
    // We verify by checking that no extra Text widget (beyond title/submit)
    // is rendered, and also that the Form still exists.
    expect(find.byType(Form), findsOneWidget);
    // No error text visible
    expect(find.text('Error occurred'), findsNothing);
  });
}
