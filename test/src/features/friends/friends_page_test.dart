import 'package:fluentish/src/features/friends/friends_page.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    FakeFriendDataSource? repository,
    FakeLocationDataSource? locationRepository,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: FriendsPage(
          auth: FakeAuthGateway(),
          friendRepository: repository ?? FakeFriendDataSource(),
          locationRepository: locationRepository ?? FakeLocationDataSource(),
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
    final repository = FakeFriendDataSource(requests: [request]);
    await pumpPage(
      tester,
      repository: repository,
    );

    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();

    expect(find.text('Request Sender'), findsOneWidget);
    expect(find.byTooltip('Accept'), findsOneWidget);
    expect(find.byTooltip('Decline'), findsOneWidget);

    await tester.tap(find.byTooltip('Accept'));
    await tester.pump();
    expect(repository.acceptedRequestIds, [request.id]);
  });

  testWidgets('nearby tab only shows current shared locations', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Nearby'));
    await tester.pumpAndSettle();

    expect(find.text('Test Friend'), findsOneWidget);
    expect(find.text('Route'), findsOneWidget);
  });

  testWidgets('requests GPS only after opening Nearby', (tester) async {
    final locations = FakeLocationDataSource();
    addTearDown(locations.dispose);

    await pumpPage(tester, locationRepository: locations);

    expect(locations.currentPositionCalls, 0);

    await tester.tap(find.text('Nearby'));
    await tester.pumpAndSettle();

    expect(locations.currentPositionCalls, 1);
  });

  testWidgets('sorts nearby friends by real distance', (tester) async {
    const fartherProfile = PublicProfile(
      uid: 'farther-user',
      displayName: 'Farther Friend',
      username: 'farther',
      usernameLower: 'farther',
    );
    const nearerProfile = PublicProfile(
      uid: 'nearer-user',
      displayName: 'Nearer Friend',
      username: 'nearer',
      usernameLower: 'nearer',
    );
    final now = DateTime.now();
    final repository = FakeFriendDataSource(
      locations: [
        FriendMapEntry(
          profile: fartherProfile,
          location: SharedLocation(
            ownerId: fartherProfile.uid,
            point: const GeoPoint(10.79, 106.72),
            geohash: 'far',
            accuracyM: 5,
            updatedAt: now,
            expiresAt: now.add(const Duration(minutes: 5)),
          ),
        ),
        FriendMapEntry(
          profile: nearerProfile,
          location: SharedLocation(
            ownerId: nearerProfile.uid,
            point: const GeoPoint(10.777, 106.701),
            geohash: 'near',
            accuracyM: 5,
            updatedAt: now,
            expiresAt: now.add(const Duration(minutes: 5)),
          ),
        ),
      ],
    );
    final locations = FakeLocationDataSource();
    addTearDown(locations.dispose);
    await pumpPage(
      tester,
      repository: repository,
      locationRepository: locations,
    );

    await tester.tap(find.text('Nearby'));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Nearer Friend')).dy,
      lessThan(tester.getTopLeft(find.text('Farther Friend')).dy),
    );
  });
}
