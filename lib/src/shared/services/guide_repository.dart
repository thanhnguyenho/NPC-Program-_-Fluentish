import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/firestore_models.dart';

abstract class GuideDataSource {
  Stream<List<GuideRecord>> watchPublishedGuides();
  Stream<List<PlaceRecord>> watchPublishedPlaces();
  Stream<List<String>> watchSavedGuideIds(String uid);
  Future<List<GuideRecord>> guidesForPlace(String placeId);
  Future<List<GuideStop>> loadStops(String guideId);
  Future<void> setSaved({
    required String uid,
    required String guideId,
    required bool saved,
  });
}

class GuideRepository implements GuideDataSource {
  GuideRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<GuideRecord>> watchPublishedGuides() {
    return _firestore
        .collection('guides')
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final guides = snapshot.docs.map(GuideRecord.fromDocument).toList()
        ..sort((a, b) => a.title.compareTo(b.title));
      return guides;
    });
  }

  @override
  Stream<List<PlaceRecord>> watchPublishedPlaces() {
    return _firestore
        .collection('places')
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(PlaceRecord.fromDocument).toList());
  }

  @override
  Stream<List<String>> watchSavedGuideIds(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('savedGuides')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((document) => document.id).toList());
  }

  @override
  Future<List<GuideRecord>> guidesForPlace(String placeId) async {
    final snapshot = await _firestore
        .collection('guides')
        .where('placeId', isEqualTo: placeId)
        .where('isPublished', isEqualTo: true)
        .get();
    return snapshot.docs.map(GuideRecord.fromDocument).toList();
  }

  @override
  Future<List<GuideStop>> loadStops(String guideId) async {
    final snapshot = await _firestore
        .collection('guides')
        .doc(guideId)
        .collection('stops')
        .orderBy('order')
        .get();
    return snapshot.docs.map(GuideStop.fromDocument).toList();
  }

  @override
  Future<void> setSaved({
    required String uid,
    required String guideId,
    required bool saved,
  }) async {
    final reference = _firestore
        .collection('users')
        .doc(uid)
        .collection('savedGuides')
        .doc(guideId);
    if (saved) {
      await reference.set({
        'guideId': guideId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await reference.delete();
    }
  }
}
