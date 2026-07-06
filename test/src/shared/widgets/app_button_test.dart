import 'package:fluentish/src/shared/theme/app_theme.dart';
import 'package:fluentish/src/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppButton renders label and handles taps', (
    WidgetTester tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppButton(
            label: 'LOGIN',
            onPressed: () => taps++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('LOGIN'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('AppButton supports the outlined Figma variant', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AppButton.outlined(
            label: 'CREATE ACCOUNT',
            onPressed: null,
          ),
        ),
      ),
    );

    expect(find.text('CREATE ACCOUNT'), findsOneWidget);
  });
}
