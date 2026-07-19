import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_models.dart';

class FavouritePhraseRecord {
  const FavouritePhraseRecord({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.createdAt,
  });

  factory FavouritePhraseRecord.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) =>
      FavouritePhraseRecord.fromMap(document.id, document.data());

  factory FavouritePhraseRecord.fromMap(
    String id,
    Map<String, dynamic>? value,
  ) {
    final data = value ?? const <String, dynamic>{};
    return FavouritePhraseRecord(
      id: id,
      sourceText:
          data['sourceText'] as String? ?? data['source'] as String? ?? '',
      translatedText: data['translatedText'] as String? ??
          data['targetText'] as String? ??
          data['target'] as String? ??
          '',
      sourceLanguage: data['sourceLanguage'] as String? ?? 'English',
      targetLanguage: data['targetLanguage'] as String? ?? 'Vietnamese',
      createdAt: firestoreDateTime(data['createdAt']),
    );
  }

  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime? createdAt;

  bool get isValid => sourceText.isNotEmpty || translatedText.isNotEmpty;

  String get playbackText =>
      translatedText.isNotEmpty ? translatedText : sourceText;

  String get playbackLanguage =>
      translatedText.isNotEmpty ? targetLanguage : sourceLanguage;
}

class FavouriteSoundboardRecord {
  const FavouriteSoundboardRecord({
    required this.id,
    required this.english,
    required this.vietnamese,
    required this.category,
    required this.englishAudio,
    required this.vietnameseAudio,
    required this.preferredLanguage,
    required this.createdAt,
  });

  factory FavouriteSoundboardRecord.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) =>
      FavouriteSoundboardRecord.fromMap(document.id, document.data());

  factory FavouriteSoundboardRecord.fromMap(
    String id,
    Map<String, dynamic>? value,
  ) {
    final data = value ?? const <String, dynamic>{};
    return FavouriteSoundboardRecord(
      id: id,
      english: data['english'] as String? ?? '',
      vietnamese: data['vietnamese'] as String? ?? '',
      category: data['category'] as String? ?? 'Soundboard',
      englishAudio: data['englishAudio'] as String? ?? '',
      vietnameseAudio: data['vietnameseAudio'] as String? ?? '',
      preferredLanguage: data['preferredLanguage'] as String? ?? 'Vietnamese',
      createdAt: firestoreDateTime(data['createdAt']),
    );
  }

  final String id;
  final String english;
  final String vietnamese;
  final String category;
  final String englishAudio;
  final String vietnameseAudio;
  final String preferredLanguage;
  final DateTime? createdAt;

  bool get isValid => english.isNotEmpty || vietnamese.isNotEmpty;

  bool get prefersEnglish =>
      preferredLanguage.toLowerCase().startsWith('en') ||
      preferredLanguage.toLowerCase().startsWith('english');

  String get playbackAudio => prefersEnglish ? englishAudio : vietnameseAudio;
}
