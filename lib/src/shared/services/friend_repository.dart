import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/firestore_models.dart';

abstract class FriendDataSource {
  Stream<List<PublicProfile>> watchFriends(String uid);
  Stream<List<FriendRequestRecord>> watchIncomingRequests(String uid);
  Stream<List<FriendMapEntry>> watchVisibleFriendLocations(String uid);
  Future<List<PublicProfile>> searchProfiles(String query, String currentUid);
  Future<PublicProfile?> getProfile(String uid);
  Future<void> sendRequest(String senderId, String receiverId);
  Future<void> acceptRequest(FriendRequestRecord request);
  Future<void> declineRequest(FriendRequestRecord request);
}

class FriendRepository implements FriendDataSource {
  FriendRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String friendshipId(String firstUid, String secondUid) {
    final ids = [firstUid, secondUid]..sort();
    return '${ids.first}_${ids.last}';
  }

  @override
  Stream<List<PublicProfile>> watchFriends(String uid) {
    return _firestore
        .collection('friendships')
        .where('userIds', arrayContains: uid)
        .snapshots()
        .asyncMap((snapshot) async {
      final friendIds = snapshot.docs
          .expand((document) => List<String>.from(document.data()['userIds']))
          .where((friendUid) => friendUid != uid)
          .toSet()
          .toList();
      if (friendIds.isEmpty) return const <PublicProfile>[];

      final profiles = await Future.wait(
        friendIds.map(
          (friendUid) =>
              _firestore.collection('publicProfiles').doc(friendUid).get(),
        ),
      );
      final result = profiles
          .where((document) => document.exists)
          .map(PublicProfile.fromDocument)
          .toList()
        ..sort((a, b) => a.displayName.compareTo(b.displayName));
      return result;
    });
  }

  @override
  Stream<List<FriendRequestRecord>> watchIncomingRequests(String uid) {
    return _firestore
        .collection('friendRequests')
        .where('receiverId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(FriendRequestRecord.fromDocument).toList());
  }

  @override
  Stream<List<FriendMapEntry>> watchVisibleFriendLocations(String uid) {
    return _switchLatest(watchFriends(uid), _watchLocationsForProfiles);
  }

  Stream<List<FriendMapEntry>> _watchLocationsForProfiles(
    List<PublicProfile> profiles,
  ) {
    if (profiles.isEmpty) return Stream.value(const <FriendMapEntry>[]);

    late final StreamController<List<FriendMapEntry>> controller;
    final sharingSubscriptions =
        <StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>[];
    final locationSubscriptions =
        <String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>{};
    final locations = <String, SharedLocation>{};
    Timer? expiryTimer;

    void emit() {
      if (controller.isClosed) return;
      final entries = <FriendMapEntry>[
        for (final profile in profiles)
          if (locations[profile.uid] case final location?)
            if (!location.isExpired)
              FriendMapEntry(profile: profile, location: location),
      ]..sort(
          (first, second) =>
              first.profile.displayName.compareTo(second.profile.displayName),
        );
      controller.add(entries);
    }

    Future<void> stopLocation(String friendUid) async {
      locations.remove(friendUid);
      await locationSubscriptions.remove(friendUid)?.cancel();
      emit();
    }

    void startLocation(String friendUid) {
      if (locationSubscriptions.containsKey(friendUid)) return;
      locationSubscriptions[friendUid] =
          _firestore.collection('locations').doc(friendUid).snapshots().listen(
        (document) {
          if (document.exists) {
            locations[friendUid] = SharedLocation.fromDocument(document);
          } else {
            locations.remove(friendUid);
          }
          emit();
        },
        onError: controller.addError,
      );
    }

    controller = StreamController<List<FriendMapEntry>>(
      onListen: () {
        emit();
        for (final profile in profiles) {
          final subscription = _firestore
              .collection('locationSharing')
              .doc(profile.uid)
              .snapshots()
              .listen(
            (document) {
              final data = document.data();
              final enabled =
                  data?['enabled'] == true && data?['audience'] == 'friends';
              if (enabled) {
                startLocation(profile.uid);
              } else {
                unawaited(stopLocation(profile.uid));
              }
            },
            onError: controller.addError,
          );
          sharingSubscriptions.add(subscription);
        }
        expiryTimer = Timer.periodic(const Duration(seconds: 5), (_) => emit());
      },
      onCancel: () async {
        expiryTimer?.cancel();
        await Future.wait([
          for (final subscription in sharingSubscriptions)
            subscription.cancel(),
          for (final subscription in locationSubscriptions.values)
            subscription.cancel(),
        ]);
      },
    );
    return controller.stream;
  }

  @override
  Future<List<PublicProfile>> searchProfiles(
    String query,
    String currentUid,
  ) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];
    final snapshot = await _firestore
        .collection('publicProfiles')
        .orderBy('usernameLower')
        .startAt([normalized])
        .endAt(['$normalized\uf8ff'])
        .limit(20)
        .get();
    return snapshot.docs
        .map(PublicProfile.fromDocument)
        .where((profile) => profile.uid != currentUid)
        .toList();
  }

  @override
  Future<PublicProfile?> getProfile(String uid) async {
    final document =
        await _firestore.collection('publicProfiles').doc(uid).get();
    return document.exists ? PublicProfile.fromDocument(document) : null;
  }

  @override
  Future<void> sendRequest(String senderId, String receiverId) async {
    if (senderId == receiverId) return;
    final directId = '${senderId}_$receiverId';
    final reverseId = '${receiverId}_$senderId';
    final friendship = await _firestore
        .collection('friendships')
        .doc(friendshipId(senderId, receiverId))
        .get();
    if (friendship.exists) return;
    final reverse =
        await _firestore.collection('friendRequests').doc(reverseId).get();
    if (reverse.exists && reverse.data()?['status'] == 'pending') {
      throw StateError('This user already sent you a friend request.');
    }
    await _firestore.collection('friendRequests').doc(directId).set({
      'senderId': senderId,
      'receiverId': receiverId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'respondedAt': null,
    });
  }

  @override
  Future<void> acceptRequest(FriendRequestRecord request) async {
    final requestReference =
        _firestore.collection('friendRequests').doc(request.id);
    final friendshipReference = _firestore
        .collection('friendships')
        .doc(friendshipId(request.senderId, request.receiverId));
    await _firestore.runTransaction((transaction) async {
      final current = await transaction.get(requestReference);
      if (!current.exists || current.data()?['status'] != 'pending') return;
      transaction.update(requestReference, {
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(friendshipReference, {
        'userIds': [request.senderId, request.receiverId],
        'requestId': request.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> declineRequest(FriendRequestRecord request) {
    return _firestore.collection('friendRequests').doc(request.id).update({
      'status': 'declined',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }
}

Stream<R> _switchLatest<T, R>(
  Stream<T> source,
  Stream<R> Function(T value) convert,
) {
  late final StreamController<R> controller;
  StreamSubscription<T>? sourceSubscription;
  StreamSubscription<R>? innerSubscription;
  var generation = 0;

  controller = StreamController<R>(
    onListen: () {
      sourceSubscription = source.listen(
        (value) {
          final currentGeneration = ++generation;
          final previous = innerSubscription;
          innerSubscription = null;
          Future<void>(() async {
            await previous?.cancel();
            if (controller.isClosed || currentGeneration != generation) return;
            innerSubscription = convert(value).listen(
              controller.add,
              onError: controller.addError,
            );
          });
        },
        onError: controller.addError,
      );
    },
    onPause: () {
      sourceSubscription?.pause();
      innerSubscription?.pause();
    },
    onResume: () {
      sourceSubscription?.resume();
      innerSubscription?.resume();
    },
    onCancel: () async {
      generation++;
      await innerSubscription?.cancel();
      await sourceSubscription?.cancel();
    },
  );
  return controller.stream;
}
