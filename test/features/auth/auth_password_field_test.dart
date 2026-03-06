import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/app_text_field.dart';
import 'package:inspectobot/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:inspectobot/theme/app_theme.dart';

void main() {
  Widget buildSubject({String? label, bool useCustomLabel = false}) {
    final formKey = GlobalKey<FormState>();
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: Form(
          key: formKey,
          child: Column(
            children: [
              if (useCustomLabel)
                AuthPasswordField(label: label)
              else
                const AuthPasswordField(),
              ElevatedButton(
                onPressed: () => formKey.currentState!.validate(),
                child: const Text('Validate'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('renders with default Password label', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('renders with custom label when provided', (tester) async {
    await tester.pumpWidget(
      buildSubject(label: 'New Password', useCustomLabel: true),
    );

    expect(find.text('New Password'), findsOneWidget);
  });

  testWidgets('validates short password shows error', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.enterText(find.byType(TextFormField), 'short');
    await tester.tap(find.text('Validate'));
    await tester.pump();

    expect(
      find.text('Password must be at least 8 characters.'),
      findsOneWidget,
    );
  });

  testWidgets('accepts 8+ character password without error', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.enterText(find.byType(TextFormField), 'longpassword');
    await tester.tap(find.text('Validate'));
    await tester.pump();

    expect(
      find.text('Password must be at least 8 characters.'),
      findsNothing,
    );
  });

  testWidgets('obscures text input', (tester) async {
    await tester.pumpWidget(buildSubject());

    final appTextField = tester.widget<AppTextField>(
      find.byType(AppTextField),
    );
    expect(appTextField.obscureText, isTrue);
  });
}
