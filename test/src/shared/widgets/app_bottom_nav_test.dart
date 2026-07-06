import 'package:fluentish/src/shared/theme/app_theme.dart';
import 'package:fluentish/src/shared/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppBottomNav exposes Fluentish navigation items', (
    WidgetTester tester,
  ) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            currentIndex: selectedIndex,
            onItemSelected: (index) => selectedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Soundboard'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Language'));
    await tester.pump();

    expect(selectedIndex, 1);
  });
}
