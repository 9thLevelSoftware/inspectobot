import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/app_text_field.dart';
import 'package:inspectobot/theme/app_theme.dart';

void main() {
  Widget buildApp({required Widget child}) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: Form(child: child),
      ),
    );
  }

  group('AppTextField', () {
    testWidgets('text input works and updates controller', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        buildApp(child: AppTextField(controller: controller, label: 'Name')),
      );

      await tester.enterText(find.byType(TextFormField), 'Hello');
      expect(controller.text, 'Hello');
    });

    testWidgets('label is displayed', (tester) async {
      await tester.pumpWidget(
        buildApp(child: const AppTextField(label: 'Email')),
      );

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('validator is called on form validation', (tester) async {
      bool validatorCalled = false;
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AppTextField(
                label: 'Required',
                validator: (value) {
                  validatorCalled = true;
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(validatorCalled, isTrue);
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('obscureText hides input', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const AppTextField(label: 'Password', obscureText: true),
        ),
      );

      final editableText =
          tester.widget<EditableText>(find.byType(EditableText));
      expect(editableText.obscureText, isTrue);
    });
  });
}
