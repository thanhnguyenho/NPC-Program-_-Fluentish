import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluentish/src/features/login/widgets/login_form.dart';
import 'package:fluentish/src/shared/theme/app_theme.dart';

import '../../../helpers/fakes.dart';

void main() {
  testWidgets('submits Firebase email and password', (tester) async {
    final auth = FakeAuthGateway();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: LoginForm(auth: auth)),
      ),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'demo@example.com');
    await tester.enterText(fields.at(1), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pump();

    expect(auth.signedInEmail, 'demo@example.com');
    expect(auth.signedInPassword, 'secret123');
    expect(find.text('Invalid demo username or password'), findsNothing);
  });

  testWidgets('shows Firebase sign-in errors', (tester) async {
    final auth = FakeAuthGateway(signInError: StateError('Invalid account.'));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: LoginForm(auth: auth)),
      ),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'wrong@example.com');
    await tester.enterText(fields.at(1), 'password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pump();

    expect(find.text('Invalid account.'), findsOneWidget);
  });
}
