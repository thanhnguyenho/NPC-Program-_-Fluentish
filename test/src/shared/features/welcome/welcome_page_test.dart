import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluentish/src/features/login/login_page.dart';
import 'package:fluentish/src/features/registration/registration_page.dart';
import 'package:fluentish/src/features/welcome/welcome_page.dart';
import 'package:fluentish/src/shared/theme/app_theme.dart';
import '../../../../helpers/fakes.dart';

void main() {
  late FakeAuthGateway fakeAuth;

  setUp(() {
    fakeAuth = FakeAuthGateway(uid: null);
  });

  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.light,
      home: WelcomePage(auth: fakeAuth),
    );
  }

  testWidgets('WelcomePage shows the logo and both auth actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('CREATE ACCOUNT'), findsOneWidget);
  });

  testWidgets('Tapping LOGIN navigates to LoginPage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Tapping CREATE ACCOUNT navigates to RegistrationPage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('CREATE ACCOUNT'));
    await tester.pumpAndSettle();

    expect(find.byType(RegistrationPage), findsOneWidget);
  });
}
