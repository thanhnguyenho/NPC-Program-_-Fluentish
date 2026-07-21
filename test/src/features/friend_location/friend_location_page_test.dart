import 'package:fluentish/src/features/friend_location/friend_location_page.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    FakeLocationDataSource? locationRepository,
    FakeGuideDataSource? guideRepository,
  }) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: FriendLocationPage(
          auth: FakeAuthGateway(),
          friendRepository: FakeFriendDataSource(),
          guideRepository: guideRepository ?? FakeGuideDataSource(),
          locationRepository: locationRepository ?? FakeLocationDataSource(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('shows friends and imported places', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('Friends & Places'), findsOneWidget);
    expect(find.text('1 friends · 4 places'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Places'), findsOneWidget);
    expect(find.text('Test Friend'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant), findsOneWidget);
    expect(find.byIcon(Icons.local_cafe), findsOneWidget);
    expect(find.byIcon(Icons.movie), findsOneWidget);
    expect(find.byIcon(Icons.museum), findsOneWidget);
    expect(find.text('OMW in 8 min.'), findsNothing);
    expect(find.text('Chat'), findsNothing);
    expect(find.text('React'), findsNothing);
    expect(find.text('Poke'), findsNothing);
  });

  testWidgets('imported place marker opens scraped details', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byTooltip('Sample Cafe'));
    await tester.pumpAndSettle();

    expect(find.text('Sample Cafe'), findsOneWidget);
    expect(find.text('Cafe'), findsOneWidget);
    expect(find.text('1 Sample Street, Ho Chi Minh City'), findsOneWidget);
    expect(find.text('4.5 (12)'), findsOneWidget);
    await tester.tap(find.text('More details'));
    await tester.pumpAndSettle();
    expect(find.text('Opening hours'), findsOneWidget);
    expect(find.text('8 AM to 10 PM'), findsOneWidget);
  });

  testWidgets('clusters large imported place collections', (tester) async {
    await pumpPage(
      tester,
      locationRepository: FakeLocationDataSource(
        mapLocations: List.filled(21, sampleMapLocation),
      ),
    );

    expect(find.byTooltip('21 places'), findsOneWidget);
    expect(find.byTooltip('Sample Cafe'), findsNothing);
  });

  testWidgets('rolls sharing back when GPS cannot start', (tester) async {
    final locations = FakeLocationDataSource(
      startSharingError: StateError('Location permission is required.'),
    );
    addTearDown(locations.dispose);
    await pumpPage(tester, locationRepository: locations);

    await tester.tap(find.byType(Switch));
    await tester.pump(const Duration(milliseconds: 200));

    expect(locations.sharing, isFalse);
    expect(find.text('Location permission is required.'), findsOneWidget);
  });
}
