import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluentish/src/features/friend_location/friend_location_page.dart';
import 'package:fluentish/src/features/home/home_page.dart';
import 'package:fluentish/src/features/navigation/main_scaffold.dart';
import 'package:fluentish/src/features/profile/profile_page.dart';
import 'package:fluentish/src/features/soundboard/soundboard_page.dart';
import 'package:fluentish/src/shared/theme/app_theme.dart';
import 'package:fluentish/src/shared/widgets/app_bottom_nav.dart';

import '../../../helpers/fakes.dart';

void main() {
  Future<void> pumpMainScaffold(WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MainScaffold(
          auth: FakeAuthGateway(),
          friendRepository: FakeFriendDataSource(),
          guideRepository: FakeGuideDataSource(),
          locationRepository: FakeLocationDataSource(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('starts on the real Home screen', (tester) async {
    await pumpMainScaffold(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Street Food Basics'), findsOneWidget);
  });

  testWidgets('Community tab opens OpenStreetMap without nested nav', (
    tester,
  ) async {
    await pumpMainScaffold(tester);

    await tester.tap(find.text('Community'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(FriendLocationPage), findsOneWidget);
    expect(find.text('Friends & Guides'), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);
  });

  testWidgets('Soundboard tab opens the real soundboard page', (tester) async {
    await pumpMainScaffold(tester);
    await tester.tap(find.text('Soundboard'));
    await tester.pumpAndSettle();
    expect(find.byType(SoundboardPage), findsOneWidget);
  });

  testWidgets('Profile tab opens authenticated profile page', (tester) async {
    await pumpMainScaffold(tester);
    await tester.tap(find.text('Profile'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('Demo User'), findsOneWidget);
  });
}
