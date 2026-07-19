import 'package:fluentish/src/features/home/home_page.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../../helpers/fakes.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    Future<bool> Function(ll.LatLng)? launchDirections,
    VoidCallback? onNavigateToMap,
  }) async {
    tester.view.physicalSize = const Size(393, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: HomeScreen(
            onNavigateToMap: onNavigateToMap ?? () {},
            auth: FakeAuthGateway(),
            friendRepository: FakeFriendDataSource(),
            locationRepository: FakeLocationDataSource(),
            launchDirections: launchDirections,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('shows the nearest place from each recommendation group', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('Sample Cafe'), findsOneWidget);
    expect(find.text('Sample Cinema'), findsOneWidget);
    expect(find.text('Sample Museum'), findsOneWidget);
    expect(find.text('Far Restaurant'), findsNothing);
    expect(find.textContaining('Cafe'), findsWidgets);
    expect(find.textContaining('Movie Theatre'), findsOneWidget);
    expect(find.textContaining('Museum'), findsWidgets);
    expect(
      find.text('A relaxed cafe for coffee and conversation.'),
      findsOneWidget,
    );
    expect(find.textContaining('Cinema in District 1.'), findsOneWidget);
    expect(find.byIcon(Icons.local_cafe), findsOneWidget);
    expect(find.byIcon(Icons.movie), findsOneWidget);
    expect(find.byIcon(Icons.museum), findsOneWidget);
  });

  testWidgets('tapping a recommendation launches directions', (tester) async {
    ll.LatLng? destination;
    await pumpHome(
      tester,
      launchDirections: (value) async {
        destination = value;
        return true;
      },
    );

    await tester.tap(find.text('Sample Cafe'));
    await tester.pump();

    expect(destination?.latitude, 10.775);
    expect(destination?.longitude, 106.701);
  });

  testWidgets('See all opens the map callback', (tester) async {
    var openedMap = false;
    await pumpHome(
      tester,
      onNavigateToMap: () => openedMap = true,
    );

    await tester.tap(find.text('See all'));
    await tester.pump();

    expect(openedMap, isTrue);
  });
}
