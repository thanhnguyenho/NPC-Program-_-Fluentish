import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluentish/src/features/friends/friends_page.dart';
import 'package:fluentish/src/features/profile/profile_page.dart';
import 'package:fluentish/src/shared/theme/app_theme.dart';

import '../../../helpers/fakes.dart';

void main() {
  testWidgets('shows authenticated profile and opens real friends page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = FakeAuthGateway();
    final friends = FakeFriendDataSource();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ProfilePage(
          auth: auth,
          friendRepository: friends,
          guideRepository: FakeGuideDataSource(savedIds: const ['guide']),
          locationRepository: FakeLocationDataSource(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Demo User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('Chloe'), findsNothing);

    await tester.tap(find.text('MY FRIENDS'));
    await tester.pumpAndSettle();
    expect(find.byType(FriendsPage), findsOneWidget);
    expect(find.text('Test Friend'), findsOneWidget);
  });
}
