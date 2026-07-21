import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/favourite_models.dart';

abstract class FavouriteDataSource {
  Stream<List<FavouritePhraseRecord>> watchFavouritePhrases(String uid);

  Future<void> saveFavouritePhrase(
    String uid, {
    required String sourceText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
  });

  Stream<List<FavouriteSoundboardRecord>> watchFavouriteSoundboardBites(
    String uid,
  );

  Future<void> removeFavouritePhrase(String uid, String favouriteId);

  Future<void> removeFavouriteSoundboardBite(String uid, String favouriteId);

  Future<void> saveFavouritePhrase(
    String uid, {
    required String sourceText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
  });

  Future<void> saveFavouriteSoundboardBite(
    String uid, {
    required String english,
    required String vietnamese,
    required String category,
    required String englishAudio,
    required String vietnameseAudio,
    required String preferredLanguage,
  });
}

class FavouriteRepository implements FavouriteDataSource {
  FavouriteRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> saveFavouritePhrase(
    String uid, {
    required String sourceText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    final id = _phraseDocumentId(
      '$sourceText|$translatedText|$sourceLanguage|$targetLanguage',
    );
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favouritePhrases')
        .doc(id)
        .set({
      'sourceText': sourceText.trim(),
      'translatedText': translatedText.trim(),
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

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

  @override
  Future<void> saveFavouritePhrase(
    String uid, {
    required String sourceText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('favouritePhrases')
        .doc();
    await docRef.set({
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('favouriteSoundboardBites')
        .doc();
    await docRef.set({
      'english': english,
      'vietnamese': vietnamese,
      'category': category,
      'englishAudio': englishAudio,
      'vietnameseAudio': vietnameseAudio,
      'preferredLanguage': preferredLanguage,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

String _phraseDocumentId(String value) {
  var hash = 0x811c9dc5;
  for (final codeUnit in value.trim().toLowerCase().codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash.toRadixString(16);
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
