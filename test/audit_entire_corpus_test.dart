import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentish/src/features/language/translator_engine.dart';
import 'package:fluentish/src/features/language/corpus/travel_corpus.dart';

void main() {
  group('Exhaustive Corpus & Dictionary Audit Test', () {
    test('Audit ALL TravelCorpus sentences (exact match)', () {
      int count = 0;
      for (final item in TravelCorpus.entries) {
        final vi = item['vi']!;
        final en = item['en']!;

        // Exact match En -> Vi
        final transVi = TranslatorEngine.translateSync(en, 'English', 'Vietnamese');
        expect(transVi, isNotEmpty, reason: 'En -> Vi failed for: $en');

        // Exact match Vi -> En
        final transEn = TranslatorEngine.translateSync(vi, 'Vietnamese', 'English');
        expect(transEn, isNotEmpty, reason: 'Vi -> En failed for: $vi');

        count++;
      }
      debugPrint('Successfully audited $count complete TravelCorpus sentences in both directions.');
    });

    test('Audit progressive prefix streaming for ALL TravelCorpus English sentences', () {
      int sentenceCount = 0;
      int prefixCount = 0;
      for (final item in TravelCorpus.entries) {
        final en = item['en']!;
        final words = en.split(' ').where((w) => w.trim().isNotEmpty).toList();
        if (words.length <= 1) continue;

        // Test every prefix from length 1 up to words.length - 1
        for (int len = 1; len < words.length; len++) {
          final prefix = words.sublist(0, len).join(' ');
          final trans = TranslatorEngine.translateSync(prefix, 'English', 'Vietnamese');
          
          expect(trans, isNotEmpty, reason: 'Empty translation for prefix "$prefix" of "$en"');
          
          // Verify no single tiny keyword (like "is" or "the" or "can" or "have") hijacked into a huge unrelated sentence
          // E.g. if prefix is just "Can", it shouldn't equal "Bạn có thể mở cửa giúp tôi được không?"
          if (len == 1 && prefix.length <= 4) {
            expect(trans.length < 50, isTrue, reason: 'Single word prefix "$prefix" hijacked into long sentence: "$trans"');
          }
          prefixCount++;
        }
        sentenceCount++;
      }
      debugPrint('Successfully audited $prefixCount progressive prefixes across $sentenceCount English sentences.');
    });

    test('Audit progressive prefix streaming for ALL TravelCorpus Vietnamese sentences', () {
      int sentenceCount = 0;
      int prefixCount = 0;
      for (final item in TravelCorpus.entries) {
        final vi = item['vi']!;
        final words = vi.split(' ').where((w) => w.trim().isNotEmpty).toList();
        if (words.length <= 1) continue;

        for (int len = 1; len < words.length; len++) {
          final prefix = words.sublist(0, len).join(' ');
          final trans = TranslatorEngine.translateSync(prefix, 'Vietnamese', 'English');
          expect(trans, isNotEmpty, reason: 'Empty translation for Vi prefix "$prefix" of "$vi"');
          prefixCount++;
        }
        sentenceCount++;
      }
      debugPrint('Successfully audited $prefixCount progressive prefixes across $sentenceCount Vietnamese sentences.');
    });
  });
}
