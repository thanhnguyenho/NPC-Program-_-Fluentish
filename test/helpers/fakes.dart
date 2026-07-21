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

const sampleMapLocation = MapLocationRecord(
  id: 'sample-cafe',
  placeId: 'sample-cafe',
  name: 'Sample Cafe',
  point: GeoPoint(10.775, 106.701),
  geohash: 'w3gv',
  group: 'food_drink',
  category: 'cafe',
  categoryLabel: 'Cafe',
  iconKey: 'cafe',
  sourceCategory: 'Coffee shop',
  shortDescription: 'A relaxed cafe for coffee and conversation.',
  sourceCategories: ['Coffee shop', 'Cafe'],
  address: '1 Sample Street, Ho Chi Minh City',
  neighborhood: 'District 1',
  region: 'Ho Chi Minh City',
  city: 'Ho Chi Minh City',
  countryCode: 'VN',
  phone: '+84123456789',
  website: 'https://example.com',
  rating: 4.5,
  reviewCount: 12,
  price: '₫50–100K',
  openingHours: {'monday': '8 AM to 10 PM'},
  status: 'open',
  isActive: true,
  googleMapsUrl: null,
  scrapedAt: null,
);

const sampleEntertainmentLocation = MapLocationRecord(
  id: 'sample-cinema',
  placeId: 'sample-cinema',
  name: 'Sample Cinema',
  point: GeoPoint(10.778, 106.702),
  geohash: 'w3gv',
  group: 'entertainment',
  category: 'movie_theatre',
  categoryLabel: 'Movie Theatre',
  iconKey: 'movie_theatre',
  sourceCategory: 'Cinema',
  sourceCategories: ['Cinema'],
  address: '2 Sample Street, Ho Chi Minh City',
  neighborhood: 'District 1',
  region: 'Ho Chi Minh City',
  city: 'Ho Chi Minh City',
  countryCode: 'VN',
  phone: null,
  website: null,
  rating: 4.3,
  reviewCount: 80,
  price: null,
  openingHours: {},
  status: 'open',
  isActive: true,
  googleMapsUrl: null,
  scrapedAt: null,
);

const sampleCultureLocation = MapLocationRecord(
  id: 'sample-museum',
  placeId: 'sample-museum',
  name: 'Sample Museum',
  point: GeoPoint(10.779, 106.699),
  geohash: 'w3gv',
  group: 'culture',
  category: 'museum',
  categoryLabel: 'Museum',
  iconKey: 'museum',
  sourceCategory: 'History museum',
  sourceCategories: ['History museum', 'Museum'],
  address: '3 Sample Street, Ho Chi Minh City',
  neighborhood: 'District 1',
  region: 'Ho Chi Minh City',
  city: 'Ho Chi Minh City',
  countryCode: 'VN',
  phone: null,
  website: null,
  rating: 4.7,
  reviewCount: 120,
  price: null,
  openingHours: {},
  status: 'open',
  isActive: true,
  googleMapsUrl: null,
  scrapedAt: null,
);

const sampleFarFoodLocation = MapLocationRecord(
  id: 'far-restaurant',
  placeId: 'far-restaurant',
  name: 'Far Restaurant',
  point: GeoPoint(10.785, 106.706),
  geohash: 'w3gv',
  group: 'food_drink',
  category: 'restaurant',
  categoryLabel: 'Restaurant',
  iconKey: 'restaurant',
  sourceCategory: 'Restaurant',
  sourceCategories: ['Restaurant'],
  address: 'Far Away, Ho Chi Minh City',
  neighborhood: '',
  region: 'Ho Chi Minh City',
  city: 'Ho Chi Minh City',
  countryCode: 'VN',
  phone: null,
  website: null,
  rating: 4,
  reviewCount: 10,
  price: null,
  openingHours: {},
  status: 'open',
  isActive: true,
  googleMapsUrl: null,
  scrapedAt: null,
);

const sampleMapLocations = [
  sampleFarFoodLocation,
  sampleMapLocation,
  sampleEntertainmentLocation,
  sampleCultureLocation,
];

const sampleFavouritePhrase = FavouritePhraseRecord(
  id: 'phrase-how-are-you',
  sourceText: 'How are you?',
  translatedText: 'Bạn khỏe không?',
  sourceLanguage: 'English',
  targetLanguage: 'Vietnamese',
  createdAt: null,
);

const sampleFavouriteSoundboard = FavouriteSoundboardRecord(
  id: 'soundboard-hello',
  english: 'Hello',
  vietnamese: 'Xin chào',
  category: 'Greetings',
  englishAudio: 'audio/Hello - English.mp3',
  vietnameseAudio: 'audio/Hello - Vietnamese.mp3',
  preferredLanguage: 'Vietnamese',
  createdAt: null,
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
  int presenceUpdates = 0;

  @override
  String? get currentUserId => uid;

  @override
  String? get currentEmail => email;

  @override
  Stream<String?> get userIdChanges => Stream.value(uid);

  @override
  Stream<PublicProfile?> watchCurrentProfile() => Stream.value(profile);

  @override
  Future<void> updatePresence() async {
    presenceUpdates++;
  }

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
  final List<String> acceptedRequestIds = [];
  final List<String> declinedRequestIds = [];

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
  Future<void> acceptRequest(FriendRequestRecord request) async {
    acceptedRequestIds.add(request.id);
  }

  @override
  Future<void> declineRequest(FriendRequestRecord request) async {
    declinedRequestIds.add(request.id);
  }
}

class FakeGuideDataSource implements GuideDataSource {
  FakeGuideDataSource({
    this.guides = const [sampleFoodGuide, sampleRouteGuide],
    this.places = const [sampleFoodPlace, sampleRoutePlace],
    this.savedIds = const [],
    this.placesError,
  });

  final List<GuideRecord> guides;
  final List<PlaceRecord> places;
  final List<String> savedIds;
  final Object? placesError;

  @override
  Stream<List<GuideRecord>> watchPublishedGuides() => Stream.value(guides);

  @override
  Stream<List<PlaceRecord>> watchPublishedPlaces() =>
      placesError == null ? Stream.value(places) : Stream.error(placesError!);

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

class FakeFavouriteDataSource implements FavouriteDataSource {
  FakeFavouriteDataSource({
    List<FavouritePhraseRecord> phrases = const [],
    List<FavouriteSoundboardRecord> soundboardBites = const [],
  })  : phrases = List.of(phrases),
        soundboardBites = List.of(soundboardBites);

  final List<FavouritePhraseRecord> phrases;
  final List<FavouriteSoundboardRecord> soundboardBites;
  final List<String> removedPhraseIds = [];
  final List<FavouritePhraseRecord> savedPhrases = [];
  final List<String> removedSoundboardIds = [];
  final StreamController<List<FavouritePhraseRecord>> _phraseChanges =
      StreamController.broadcast();
  final StreamController<List<FavouriteSoundboardRecord>> _soundboardChanges =
      StreamController.broadcast();

  @override
  Stream<List<FavouritePhraseRecord>> watchFavouritePhrases(String uid) async* {
    yield List.unmodifiable(phrases);
    yield* _phraseChanges.stream;
  }

  @override
  Stream<List<FavouriteSoundboardRecord>> watchFavouriteSoundboardBites(
    String uid,
  ) async* {
    yield List.unmodifiable(soundboardBites);
    yield* _soundboardChanges.stream;
  }

  @override
  Future<void> removeFavouritePhrase(String uid, String favouriteId) async {
    removedPhraseIds.add(favouriteId);
    phrases.removeWhere((phrase) => phrase.id == favouriteId);
    _phraseChanges.add(List.unmodifiable(phrases));
  }

  @override
  Future<void> removeFavouriteSoundboardBite(
    String uid,
    String favouriteId,
  ) async {
    removedSoundboardIds.add(favouriteId);
    soundboardBites.removeWhere((bite) => bite.id == favouriteId);
    _soundboardChanges.add(List.unmodifiable(soundboardBites));
  }

  @override
  Future<String> saveFavouritePhrase(
    String uid, {
    required String sourceText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final id = 'phrase_${phrases.length + 1}';
    final record = FavouritePhraseRecord(
      id: id,
      sourceText: sourceText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      createdAt: DateTime.now(),
    );
    phrases.add(record);
    savedPhrases.add(record);
    _phraseChanges.add(List.unmodifiable(phrases));
    return id;
  }

  @override
  Future<void> saveFavouriteSoundboardBite(
    String uid, {
    required String english,
    required String vietnamese,
    required String category,
    required String englishAudio,
    required String vietnameseAudio,
    required String preferredLanguage,
  }) async {
    final id = 'bite_${soundboardBites.length + 1}';
    final record = FavouriteSoundboardRecord(
      id: id,
      english: english,
      vietnamese: vietnamese,
      category: category,
      englishAudio: englishAudio,
      vietnameseAudio: vietnameseAudio,
      preferredLanguage: preferredLanguage,
      createdAt: DateTime.now(),
    );
    soundboardBites.add(record);
    _soundboardChanges.add(List.unmodifiable(soundboardBites));
  }
}

class FakeLocationDataSource implements LocationDataSource {
  FakeLocationDataSource({
    this.sharing = false,
    this.mapLocations = sampleMapLocations,
    this.currentPositionError,
    this.startSharingError,
    this.mapLocationsError,
  });

  bool sharing;
  final List<MapLocationRecord> mapLocations;
  final Object? currentPositionError;
  final Object? startSharingError;
  final Object? mapLocationsError;
  final StreamController<bool> _sharingChanges = StreamController.broadcast();
  int currentPositionCalls = 0;

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
  Stream<bool> watchSharing(String uid) async* {
    yield sharing;
    yield* _sharingChanges.stream;
  }

  @override
  Stream<List<MapLocationRecord>> watchMapLocations() =>
      mapLocationsError == null
          ? Stream.value(mapLocations)
          : Stream.error(mapLocationsError!);

  @override
  Future<void> setSharing(String uid, bool enabled) async {
    sharing = enabled;
    _sharingChanges.add(enabled);
  }

  @override
  Future<Position> currentPosition() async {
    currentPositionCalls++;
    if (currentPositionError case final error?) throw error;
    return position;
  }

  @override
  Future<LocationSharingSession> startForegroundSharing(String uid) async {
    if (startSharingError case final error?) throw error;
    return LocationSharingSession(
      subscription: const Stream<Position>.empty().listen((_) {}),
      timer: Timer(const Duration(days: 1), () {}),
    );
  }

  Future<void> dispose() => _sharingChanges.close();
}
