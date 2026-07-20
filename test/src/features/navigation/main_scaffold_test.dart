import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentish/src/shared/services/favourite_repository.dart';
import 'package:fluentish/src/features/friend_location/friend_location_page.dart';
import 'package:fluentish/src/features/home/home_page.dart';
//import 'package:fluentish/src/features/language/language_page.dart';
import 'package:fluentish/src/features/navigation/main_scaffold.dart';
import 'package:fluentish/src/features/profile/profile_page.dart';
import 'package:fluentish/src/features/soundboard/soundboard_page.dart';
import 'package:fluentish/src/shared/theme/app_theme.dart';
import 'package:fluentish/src/shared/widgets/app_bottom_nav.dart';

import '../../../helpers/fakes.dart';

void main() {
  Future<void> pumpMainScaffold(
    WidgetTester tester, {
    FavouriteDataSource? favouriteRepository,
  }) async {
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
          favouriteRepository: favouriteRepository ?? FakeFavouriteDataSource(),
          guideRepository: FakeGuideDataSource(),
          locationRepository: FakeLocationDataSource(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('starts on the real Home screen', (tester) async {
    await pumpMainScaffold(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Sample Cafe'), findsOneWidget);
    expect(find.text('Sample Cinema'), findsOneWidget);
    expect(find.text('Sample Museum'), findsOneWidget);
  });

  testWidgets('Community tab opens OpenStreetMap without nested nav', (
    tester,
  ) async {
    await pumpMainScaffold(tester);

    await tester.tap(find.text('Community'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(FriendLocationPage), findsOneWidget);
    expect(find.text('Friends & Places'), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);
  });

  testWidgets('See all opens the Community map tab', (tester) async {
    await pumpMainScaffold(tester);

    await tester.tap(find.text('See all'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(FriendLocationPage), findsOneWidget);
    expect(find.text('Friends & Places'), findsOneWidget);
  });

  // testWidgets('favourite phrase opens Language with both boxes prefilled', (
  //   tester,
  // ) async {
  //   await pumpMainScaffold(
  //     tester,
  //     favouriteRepository: FakeFavouriteDataSource(
  //       phrases: const [sampleFavouritePhrase],
  //     ),
  //   );

  //   final phraseText = find.text('How are you?');
  //   await tester.ensureVisible(phraseText);
  //   await tester.tap(phraseText);
  //   await tester.pumpAndSettle();

  //   expect(find.byType(LanguagePage), findsOneWidget);
  //   final sourceInput = tester.widget<TextField>(
  //     find.byKey(const ValueKey('language-source-input')),
  //   );
  //   expect(sourceInput.controller?.text, 'How are you?');
  //   final targetText = tester.widget<Text>(
  //     find.byKey(const ValueKey('language-target-text')),
  //   );
  //   expect(targetText.data, 'Bạn khỏe không?');
  // });

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
