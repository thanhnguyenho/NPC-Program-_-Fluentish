import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluentish/src/features/friends/friends_page.dart';
import 'package:fluentish/src/features/profile/profile_page.dart';
import 'package:fluentish/src/shared/theme/app_theme.dart';

void main() {
  testWidgets('MY FRIENDS opens the friends page', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ProfilePage(),
      ),
    );

    await tester.tap(find.text('MY FRIENDS'));
    await tester.pumpAndSettle();

    expect(find.byType(FriendsPage), findsOneWidget);
  });
}
