import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/app_text_field.dart';
import 'package:inspectobot/features/auth/presentation/widgets/auth_email_field.dart';
import 'package:inspectobot/theme/app_theme.dart';

void main() {
  Widget buildSubject({TextEditingController? controller}) {
    final formKey = GlobalKey<FormState>();
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: Form(
          key: formKey,
          child: Column(
            children: [
              AuthEmailField(controller: controller),
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

  testWidgets('renders with Email label', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('validates empty input shows error', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Validate'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('validates input without @ shows error', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.enterText(find.byType(TextFormField), 'nodomain');
    await tester.tap(find.text('Validate'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('accepts valid email without error', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.enterText(find.byType(TextFormField), 'test@example.com');
    await tester.tap(find.text('Validate'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsNothing);
  });

  testWidgets('uses emailAddress keyboard type', (tester) async {
    await tester.pumpWidget(buildSubject());

    final appTextField = tester.widget<AppTextField>(
      find.byType(AppTextField),
    );
    expect(appTextField.keyboardType, TextInputType.emailAddress);
  });
}
