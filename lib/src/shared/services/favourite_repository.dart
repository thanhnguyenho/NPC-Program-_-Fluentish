import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/favourite_models.dart';

abstract class FavouriteDataSource {
  Stream<List<FavouritePhraseRecord>> watchFavouritePhrases(String uid);

  Stream<List<FavouriteSoundboardRecord>> watchFavouriteSoundboardBites(
    String uid,
  );

  Future<void> removeFavouritePhrase(String uid, String favouriteId);

  Future<void> removeFavouriteSoundboardBite(String uid, String favouriteId);
}

class FavouriteRepository implements FavouriteDataSource {
  FavouriteRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<FavouritePhraseRecord>> watchFavouritePhrases(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favouritePhrases')
        .snapshots()
        .map((snapshot) {
      final favourites = snapshot.docs
          .map(FavouritePhraseRecord.fromDocument)
          .where((favourite) => favourite.isValid)
          .toList();
      _sortNewestFirst(favourites, (favourite) => favourite.createdAt);
      return favourites;
    });
  }

  @override
  Stream<List<FavouriteSoundboardRecord>> watchFavouriteSoundboardBites(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favouriteSoundboardBites')
        .snapshots()
        .map((snapshot) {
      final favourites = snapshot.docs
          .map(FavouriteSoundboardRecord.fromDocument)
          .where((favourite) => favourite.isValid)
          .toList();
      _sortNewestFirst(favourites, (favourite) => favourite.createdAt);
      return favourites;
    });
  }

  @override
  Future<void> removeFavouritePhrase(String uid, String favouriteId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favouritePhrases')
        .doc(favouriteId)
        .delete();
  }

  @override
  Future<void> removeFavouriteSoundboardBite(
    String uid,
    String favouriteId,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favouriteSoundboardBites')
        .doc(favouriteId)
        .delete();
  }
}

void _sortNewestFirst<T>(
  List<T> values,
  DateTime? Function(T value) dateFor,
) {
  values.sort((first, second) {
    final firstDate = dateFor(first) ?? DateTime.fromMillisecondsSinceEpoch(0);
    final secondDate =
        dateFor(second) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return secondDate.compareTo(firstDate);
  });
}
