import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geohash_plus/geohash_plus.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationDataSource {
  Stream<bool> watchSharing(String uid);
  Future<void> setSharing(String uid, bool enabled);
  Future<Position> currentPosition();
  Future<LocationSharingSession> startForegroundSharing(String uid);
}

class LocationRepository implements LocationDataSource {
  LocationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<bool> watchSharing(String uid) {
    return _firestore.collection('locationSharing').doc(uid).snapshots().map(
          (document) => document.data()?['enabled'] as bool? ?? false,
        );
  }

  @override
  Future<void> setSharing(String uid, bool enabled) {
    return _firestore.collection('locationSharing').doc(uid).set({
      'enabled': enabled,
      'audience': 'friends',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Location services are disabled.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('Location permission is required.');
    }
  }

  @override
  Future<Position> currentPosition() async {
    await _ensurePermission();
    return Geolocator.getCurrentPosition();
  }

  Future<void> _writePosition(String uid, Position position) {
    final now = DateTime.now().toUtc();
    return _firestore.collection('locations').doc(uid).set({
      'ownerId': uid,
      'geo': {
        'geopoint': GeoPoint(position.latitude, position.longitude),
        'geohash': GeoHash.encode(
          position.latitude,
          position.longitude,
          precision: 9,
        ).hash,
      },
      'accuracyM': position.accuracy,
      'updatedAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(minutes: 10))),
    }, SetOptions(merge: true));
  }

  @override
  Future<LocationSharingSession> startForegroundSharing(String uid) async {
    await _ensurePermission();
    final initial = await Geolocator.getCurrentPosition();
    await _writePosition(uid, initial);
    final subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
      ),
    ).listen((position) async {
      try {
        await _writePosition(uid, position);
      } catch (_) {}
    });
    final timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        await _writePosition(uid, await Geolocator.getCurrentPosition());
      } catch (_) {}
    });
    return LocationSharingSession(subscription: subscription, timer: timer);
  }
}

class LocationSharingSession {
  LocationSharingSession({required this.subscription, required this.timer});

  final StreamSubscription<Position> subscription;
  final Timer timer;

  Future<void> dispose() async {
    timer.cancel();
    await subscription.cancel();
  }
}
