import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluentish/src/features/login/widgets/login_form.dart';
import 'package:fluentish/src/features/navigation/main_scaffold.dart';
import 'package:fluentish/src/shared/theme/app_theme.dart';

void main() {
  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: SingleChildScrollView(
          child: LoginForm(),
        ),
      ),
    );
  }

  testWidgets('demo admin credentials open the main app', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'admin');
    await tester.enterText(fields.at(1), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pumpAndSettle();

    expect(find.byType(MainScaffold), findsOneWidget);
  });

  testWidgets('invalid demo credentials show an error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'wrong');
    await tester.enterText(fields.at(1), 'password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pump();

    expect(find.text('Invalid demo username or password'), findsOneWidget);
  });
}
