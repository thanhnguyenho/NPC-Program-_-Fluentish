import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guide types map to stable Firestore values', () {
    expect(guideTypeFromString('place'), GuideType.place);
    expect(guideTypeFromString('route'), GuideType.route);
    expect(guideTypeFromString('collection'), GuideType.collection);
  });

  test('nested geo fields return GeoPoint and geohash', () {
    const point = GeoPoint(10.7, 106.7);
    final data = {
      'geopoint': point,
      'geohash': 'w3gv',
    };
    expect(firestoreGeoPoint(data), point);
    expect(firestoreGeohash(data), 'w3gv');
  });

  test('friendship ids are deterministic', () {
    expect(
      FriendRepository.friendshipId('user-b', 'user-a'),
      'user-a_user-b',
    );
  });

  test('Firestore models parse and serialize the shared contract', () {
    final now = DateTime.utc(2026, 7, 16, 12);
    const point = GeoPoint(10.7725301, 106.6980365);
    final profile = PublicProfile.fromMap('user-1', {
      'uid': 'user-1',
      'displayName': 'Lan',
      'username': 'lan',
      'usernameLower': 'lan',
      'avatarUrl': 'https://example.com/lan.jpg',
      'lastSeenAt': Timestamp.fromDate(now),
    });
    final request = FriendRequestRecord.fromMap('request-1', {
      'senderId': 'user-1',
      'receiverId': 'user-2',
      'status': 'accepted',
      'createdAt': Timestamp.fromDate(now),
      'respondedAt': Timestamp.fromDate(now),
    });
    final location = SharedLocation.fromMap('user-1', {
      'ownerId': 'user-1',
      'geo': firestoreGeo(point, 'w3gv'),
      'accuracyM': 5,
      'updatedAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(minutes: 10))),
    });
    final place = PlaceRecord.fromMap('ben-thanh-market', {
      'name': 'Chợ Bến Thành',
      'address': 'Quận 1',
      'category': 'food',
      'geo': firestoreGeo(point, 'w3gv'),
      'osmType': 'way',
      'osmId': '123',
      'guideCount': 1,
      'primaryGuideId': 'street-food-basics',
      'isPublished': true,
    });
    final guide = GuideRecord.fromMap('street-food-basics', {
      'type': 'place',
      'placeId': place.id,
      'title': 'Street Food Basics',
      'category': 'food',
      'summary': 'Summary',
      'content': 'Content',
      'authorId': 'fluentish-team',
      'ratingAverage': 4.5,
      'reviewCount': 2,
      'isPublished': true,
      'isMapVisible': true,
      'stopCount': 0,
    });
    final stop = GuideStop.fromMap('stop-1', {
      'order': 1,
      'name': 'Start',
      'address': 'Address',
      'geo': firestoreGeo(point, 'w3gv'),
      'osmType': 'node',
      'osmId': '456',
      'instruction': 'Begin here.',
    });

    expect(profile.toFirestore()['displayName'], 'Lan');
    expect(request.toFirestore()['respondedAt'], Timestamp.fromDate(now));
    expect(location.toFirestore()['geo'], firestoreGeo(point, 'w3gv'));
    expect(place.toFirestore()['osmId'], '123');
    expect(guide.toFirestore()['type'], 'place');
    expect(stop.toFirestore()['osmType'], 'node');
  });

  test('distance and expiry calculations are deterministic', () {
    const first = GeoPoint(10.7725301, 106.6980365);
    const second = GeoPoint(10.7737196, 106.7040457);
    final now = DateTime.utc(2026, 7, 16, 12);
    final location = SharedLocation(
      ownerId: 'friend',
      point: first,
      geohash: 'w3gv',
      accuracyM: 5,
      updatedAt: now,
      expiresAt: now.add(const Duration(minutes: 10)),
    );

    expect(geoDistanceMeters(first, second), closeTo(670, 40));
    expect(location.isExpiredAt(now.add(const Duration(minutes: 9))), isFalse);
    expect(location.isExpiredAt(now.add(const Duration(minutes: 10))), isTrue);
  });
}
