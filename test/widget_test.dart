import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluentish/main.dart';
import 'package:fluentish/src/features/welcome/welcome_page.dart';
import 'package:fluentish/src/shared/theme/app_colors.dart';

import 'helpers/fakes.dart';

void main() {
  testWidgets('Fluentish app starts with theme and auth gate', (tester) async {
    await tester.pumpWidget(MyApp(auth: FakeAuthGateway(uid: null)));
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'Fluentish');
    expect(materialApp.theme?.colorScheme.primary, AppColors.pine);
    expect(find.byType(WelcomePage), findsOneWidget);
  });
}
