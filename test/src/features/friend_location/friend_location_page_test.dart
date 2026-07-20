import 'package:fluentish/src/features/friend_location/friend_location_page.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) async {
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
          guideRepository: FakeGuideDataSource(),
          locationRepository: FakeLocationDataSource(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('shows real friends and guides layers without old notes', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('Friends & Guides'), findsOneWidget);
    expect(find.text('1 friends · 2 guides'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Guides'), findsOneWidget);
    expect(find.text('Test Friend'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant), findsOneWidget);
    expect(find.text('OMW in 8 min.'), findsNothing);
    expect(find.text('Chat'), findsNothing);
    expect(find.text('React'), findsNothing);
    expect(find.text('Poke'), findsNothing);
  });

  testWidgets('filter hides friend markers in Guides mode', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Guides'));
    await tester.pump();

    expect(find.text('Test Friend'), findsNothing);
    expect(find.byIcon(Icons.restaurant), findsOneWidget);
  });

  testWidgets('route guide draws stops only after View Route', (tester) async {
    await pumpPage(tester);

    expect(find.text('2 stops'), findsNothing);
    await tester.tap(find.byIcon(Icons.route));
    await tester.pumpAndSettle();
    expect(find.text('District 1 Walk'), findsWidgets);
    expect(find.text('View Route'), findsOneWidget);

    await tester.ensureVisible(find.text('View Route'));
    await tester.tap(find.text('View Route'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('District 1 Walk'), findsWidgets);
    expect(find.text('2 stops'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
