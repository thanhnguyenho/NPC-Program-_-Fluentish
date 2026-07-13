import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluentish/main.dart';
import 'package:fluentish/src/shared/theme/app_colors.dart';

void main() {
  testWidgets('Fluentish app starts with the shared theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(materialApp.title, 'Fluentish');
    expect(materialApp.theme?.colorScheme.primary, AppColors.pine);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
