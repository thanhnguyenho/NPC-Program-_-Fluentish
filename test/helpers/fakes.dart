import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'package:geolocator/geolocator.dart';

const sampleProfile = PublicProfile(
  uid: 'current-user',
  displayName: 'Demo User',
  username: 'demo',
  usernameLower: 'demo',
  lastSeenAt: null,
);

const sampleFriend = PublicProfile(
  uid: 'friend-user',
  displayName: 'Test Friend',
  username: 'testfriend',
  usernameLower: 'testfriend',
  lastSeenAt: null,
);

const sampleSender = PublicProfile(
  uid: 'sender-user',
  displayName: 'Request Sender',
  username: 'sender',
  usernameLower: 'sender',
  lastSeenAt: null,
);

final sampleLocation = SharedLocation(
  ownerId: sampleFriend.uid,
  point: const GeoPoint(10.778, 106.7),
  geohash: 'w3gv',
  accuracyM: 5,
  updatedAt: DateTime.now(),
  expiresAt: DateTime.now().add(const Duration(minutes: 10)),
);

const sampleFoodPlace = PlaceRecord(
  id: 'ben-thanh-market',
  name: 'Chợ Bến Thành',
  address: 'Quận 1',
  category: 'food',
  point: GeoPoint(10.7725301, 106.6980365),
  geohash: 'w3gv',
  guideCount: 1,
  primaryGuideId: 'street-food-basics',
  isPublished: true,
);

const sampleRoutePlace = PlaceRecord(
  id: 'independence-palace',
  name: 'Dinh Độc Lập',
  address: 'Quận 1',
  category: 'route',
  point: GeoPoint(10.7770348, 106.695488),
  geohash: 'w3gv',
  guideCount: 1,
  primaryGuideId: 'district-1-walk',
  isPublished: true,
);

const sampleFoodGuide = GuideRecord(
  id: 'street-food-basics',
  type: GuideType.place,
  placeId: 'ben-thanh-market',
  title: 'Street Food Basics',
  category: 'food',
  summary: 'Order food with confidence.',
  content: 'Useful phrases for local food vendors.',
  authorId: 'fluentish-team',
  ratingAverage: 4,
  reviewCount: 0,
  isPublished: true,
  isMapVisible: true,
);

const sampleRouteGuide = GuideRecord(
  id: 'district-1-walk',
  type: GuideType.route,
  placeId: 'independence-palace',
  title: 'District 1 Walk',
  category: 'route',
  summary: 'A route through District 1.',
  content: 'Walk through five authored stops.',
  authorId: 'fluentish-team',
  ratingAverage: null,
  reviewCount: 0,
  isPublished: true,
  isMapVisible: true,
  stopCount: 2,
);

const sampleStops = [
  GuideStop(
    id: 'stop-1',
    order: 1,
    name: 'First Stop',
    address: 'Address 1',
    point: GeoPoint(10.777, 106.695),
    geohash: 'w3gv',
    instruction: 'Start here.',
  ),
  GuideStop(
    id: 'stop-2',
    order: 2,
    name: 'Second Stop',
    address: 'Address 2',
    point: GeoPoint(10.779, 106.7),
    geohash: 'w3gv',
    instruction: 'Finish here.',
  ),
];

class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({
    this.uid = 'current-user',
    this.email = 'test@example.com',
    this.profile = sampleProfile,
    this.signInError,
  });

  String? uid;
  String? email;
  PublicProfile? profile;
  Object? signInError;
  String? signedInEmail;
  String? signedInPassword;
  bool signedInWithGoogle = false;
  bool signedOut = false;

  @override
  String? get currentUserId => uid;

  @override
  String? get currentEmail => email;

  @override
  Stream<String?> get userIdChanges => Stream.value(uid);

  @override
  Stream<PublicProfile?> watchCurrentProfile() => Stream.value(profile);

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signedInEmail = email;
    signedInPassword = password;
    if (signInError != null) throw signInError!;
  }

  @override
  Future<void> signInWithGoogle() async {
    signedInWithGoogle = true;
    if (signInError != null) throw signInError!;
  }

  @override
  Future<void> signOut() async {
    signedOut = true;
    uid = null;
  }

  @override
  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String preferredName,
    required String dateOfBirth,
    required String phoneNumber,
  }) async {}
}

class FakeFriendDataSource implements FriendDataSource {
  FakeFriendDataSource({
    this.friends = const [sampleFriend],
    this.requests = const [],
    List<FriendMapEntry>? locations,
    this.searchResults = const [sampleSender],
  }) : locations = locations ??
            [FriendMapEntry(profile: sampleFriend, location: sampleLocation)];

  final List<PublicProfile> friends;
  final List<FriendRequestRecord> requests;
  final List<FriendMapEntry> locations;
  final List<PublicProfile> searchResults;

  @override
  Stream<List<PublicProfile>> watchFriends(String uid) => Stream.value(friends);

  @override
  Stream<List<FriendRequestRecord>> watchIncomingRequests(String uid) =>
      Stream.value(requests);

  @override
  Stream<List<FriendMapEntry>> watchVisibleFriendLocations(String uid) =>
      Stream.value(locations);

  @override
  Future<List<PublicProfile>> searchProfiles(
          String query, String currentUid) async =>
      searchResults;

  @override
  Future<PublicProfile?> getProfile(String uid) async {
    if (uid == sampleSender.uid) return sampleSender;
    if (uid == sampleFriend.uid) return sampleFriend;
    return null;
  }

  @override
  Future<void> sendRequest(String senderId, String receiverId) async {}

  @override
  Future<void> acceptRequest(FriendRequestRecord request) async {}

  @override
  Future<void> declineRequest(FriendRequestRecord request) async {}
}

class FakeGuideDataSource implements GuideDataSource {
  FakeGuideDataSource({
    this.guides = const [sampleFoodGuide, sampleRouteGuide],
    this.places = const [sampleFoodPlace, sampleRoutePlace],
    this.savedIds = const [],
  });

  final List<GuideRecord> guides;
  final List<PlaceRecord> places;
  final List<String> savedIds;

  @override
  Stream<List<GuideRecord>> watchPublishedGuides() => Stream.value(guides);

  @override
  Stream<List<PlaceRecord>> watchPublishedPlaces() => Stream.value(places);

  @override
  Stream<List<String>> watchSavedGuideIds(String uid) => Stream.value(savedIds);

  @override
  Future<List<GuideRecord>> guidesForPlace(String placeId) async =>
      guides.where((guide) => guide.placeId == placeId).toList();

  @override
  Future<List<GuideStop>> loadStops(String guideId) async =>
      guideId == sampleRouteGuide.id ? sampleStops : const [];

  @override
  Future<void> setSaved({
    required String uid,
    required String guideId,
    required bool saved,
  }) async {}
}

class FakeLocationDataSource implements LocationDataSource {
  FakeLocationDataSource({this.sharing = false});

  bool sharing;

  static final position = Position(
    longitude: 106.7009,
    latitude: 10.7769,
    timestamp: DateTime(2026, 7, 16),
    accuracy: 5,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  @override
  Stream<bool> watchSharing(String uid) => Stream.value(sharing);

  @override
  Future<void> setSharing(String uid, bool enabled) async {
    sharing = enabled;
  }

  @override
  Future<Position> currentPosition() async => position;

  @override
  Future<LocationSharingSession> startForegroundSharing(String uid) async {
    return LocationSharingSession(
      subscription: const Stream<Position>.empty().listen((_) {}),
      timer: Timer(const Duration(days: 1), () {}),
    );
  }
}
