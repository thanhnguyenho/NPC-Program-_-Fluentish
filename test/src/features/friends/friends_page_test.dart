import 'package:fluentish/src/features/friends/friends_page.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    FakeFriendDataSource? repository,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: FriendsPage(
          auth: FakeAuthGateway(),
          friendRepository: repository ?? FakeFriendDataSource(),
          locationRepository: FakeLocationDataSource(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows accepted Firestore friends and no legacy mocks', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('Test Friend'), findsOneWidget);
    expect(find.text('@testfriend · Offline'), findsOneWidget);
    expect(find.text('Thanh Nguyen (Chloe)'), findsNothing);
    expect(find.text('Coffee after class?'), findsNothing);
  });

  testWidgets('shows incoming requests with accept and decline actions', (
    tester,
  ) async {
    final request = FriendRequestRecord(
      id: 'sender-user_current-user',
      senderId: 'sender-user',
      receiverId: 'current-user',
      status: 'pending',
      createdAt: DateTime.now(),
    );
    await pumpPage(
      tester,
      repository: FakeFriendDataSource(requests: [request]),
    );

    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();

    expect(find.text('Request Sender'), findsOneWidget);
    expect(find.byTooltip('Accept'), findsOneWidget);
    expect(find.byTooltip('Decline'), findsOneWidget);
  });

  testWidgets('nearby tab only shows current shared locations', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Nearby'));
    await tester.pumpAndSettle();

    expect(find.text('Test Friend'), findsOneWidget);
    expect(find.text('Route'), findsOneWidget);
  });
}
