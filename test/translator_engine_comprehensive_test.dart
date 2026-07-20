import 'package:flutter_test/flutter_test.dart';
import 'package:fluentish/src/features/language/translator_engine.dart';

void main() {
  group('TranslatorEngine Comprehensive & Progressive Typing Tests', () {
    test('Progressive typing: what should we eat today', () {
      expect(TranslatorEngine.translateSync('what', 'English', 'Vietnamese'), 'Cái gì / Gì / Món gì');
      expect(TranslatorEngine.translateSync('what can', 'English', 'Vietnamese'), 'Có thể làm gì / Cái gì có thể...');
      expect(TranslatorEngine.translateSync('what can we', 'English', 'Vietnamese'), 'Chúng ta có thể làm gì / Chúng ta có thể...');
      expect(TranslatorEngine.translateSync('what can we eat', 'English', 'Vietnamese'), 'Chúng ta có thể ăn gì?');
      expect(TranslatorEngine.translateSync('what can we eat today', 'English', 'Vietnamese'), 'Hôm nay chúng ta có thể ăn gì?');
      expect(TranslatorEngine.translateSync('what should', 'English', 'Vietnamese'), 'Nên làm gì / Cái gì nên...');
      expect(TranslatorEngine.translateSync('what should we', 'English', 'Vietnamese'), 'Chúng ta nên làm gì / Chúng ta nên...');
      expect(TranslatorEngine.translateSync('what should we eat', 'English', 'Vietnamese'), 'Chúng ta nên ăn gì?');
      expect(TranslatorEngine.translateSync('what should we eat today', 'English', 'Vietnamese'), 'Hôm nay chúng ta nên ăn gì?');
    });

    test('Typo handling during live streaming: what should we e today / what shoul we eat today', () {
      expect(TranslatorEngine.translateSync('what should we e today', 'English', 'Vietnamese'), 'Hôm nay chúng ta nên ăn gì?');
      expect(TranslatorEngine.translateSync('what shoul we eat today', 'English', 'Vietnamese'), 'Hôm nay chúng ta nên ăn gì?');
      expect(TranslatorEngine.translateSync('what can we e today', 'English', 'Vietnamese'), 'Hôm nay chúng ta có thể ăn gì?');
    });

    test('Progressive typing: where should we go for dinner', () {
      expect(TranslatorEngine.translateSync('where', 'English', 'Vietnamese'), 'Ở đâu?');
      expect(TranslatorEngine.translateSync('where should', 'English', 'Vietnamese'), 'Ở đâu nên...');
      expect(TranslatorEngine.translateSync('where should we', 'English', 'Vietnamese'), 'Chúng ta nên đi đâu / Chúng ta nên...');
      expect(TranslatorEngine.translateSync('where should we go', 'English', 'Vietnamese'), 'Chúng ta nên đi đâu?');
      expect(TranslatorEngine.translateSync('where should we go for', 'English', 'Vietnamese'), 'Chúng ta nên đi đâu để...');
      expect(TranslatorEngine.translateSync('where should we go for dinner', 'English', 'Vietnamese'), 'Chúng ta nên đi đâu ăn tối?');
    });

    test('Vietnamese to English progressive checks', () {
      expect(TranslatorEngine.translateSync('chúng ta nên', 'Vietnamese', 'English'), 'We should...');
      expect(TranslatorEngine.translateSync('chúng ta nên đi đâu', 'Vietnamese', 'English'), 'Where should we go?');
      expect(TranslatorEngine.translateSync('hôm nay chúng ta ăn gì', 'Vietnamese', 'English'), 'What should we eat today?');
      expect(TranslatorEngine.translateSync('chúng ta có thể ăn gì', 'Vietnamese', 'English'), 'What can we eat?');
    });

    test('Live Typo & Spelling Suggestion (findSpellingCorrection)', () {
      expect(TranslatorEngine.findSpellingCorrection('what shoul we eat today', 'English'), 'what should we eat today');
      expect(TranslatorEngine.findSpellingCorrection('whre should we go', 'English'), 'where should we go');
      expect(TranslatorEngine.findSpellingCorrection('xin tinh tien', 'Vietnamese'), 'xin tính tiền');
      expect(TranslatorEngine.findSpellingCorrection('what should we eat today', 'English'), null); // exact match -> null
    });

    test('New Translation Engine Fixes Verification', () {
      // 1. Verify that "could you explain it again" does NOT suggest any spelling corrections.
      expect(TranslatorEngine.findSpellingCorrection('could you explain it again', 'English'), null);

      // 2. Verify that progressive translations and subclause translations do NOT repeat prefix phrases (e.g. "Bạn có thể bạn có thể...").
      expect(TranslatorEngine.translateSync('can you can you help me', 'English', 'Vietnamese'), 'Bạn có thể giúp tôi không?');
      expect(TranslatorEngine.translateSync('bạn có thể bạn có thể giúp tôi', 'Vietnamese', 'English'), 'Can you please help me?');

      // 3. Verify that "can you tell me about the plan" translates smoothly without uppercase words in the middle
      expect(TranslatorEngine.translateSync('can you tell me about the plan', 'English', 'Vietnamese'), 'Bạn có thể cho tôi biết về kế hoạch được không?');

      // 4. Verify that "can you tell" translates without slash options inside.
      expect(TranslatorEngine.translateSync('can you tell', 'English', 'Vietnamese'), 'Bạn có thể bảo được không?');

      // 5. Verify that "where is the toilet?" and "where is the restroom?" translate cleanly
      expect(TranslatorEngine.translateSync('where is the toilet?', 'English', 'Vietnamese'), 'Nhà vệ sinh ở đâu?');
      expect(TranslatorEngine.translateSync('where is the restroom?', 'English', 'Vietnamese'), 'Nhà vệ sinh ở đâu?');

      // 6. Slashes inside terms like "24/24" are not split, but choice synonyms are.
      expect(TranslatorEngine.translateSync('cửa hàng tiện lợi 24/24', 'Vietnamese', 'English'), contains('24/24'));
      expect(TranslatorEngine.translateSync('discount', 'English', 'Vietnamese'), 'Giảm giá');

      // 7. Greedy substring matching is fixed: 'where is the parking lot near the hotel' translates fully.
      expect(TranslatorEngine.translateSync('where is the parking lot near the hotel', 'English', 'Vietnamese'), contains('khách sạn'));

      // 8. 'what will we' and other progressive intermediate states are handled cleanly.
      expect(TranslatorEngine.translateSync('what will we', 'English', 'Vietnamese'), 'Chúng ta làm gì...');

      // 9. Typo corrections return the correct spelling suggestions.
      expect(TranslatorEngine.findSpellingCorrection('bao nhieu tien', 'Vietnamese'), 'bao nhiêu tiền');
      expect(TranslatorEngine.findSpellingCorrection('xin tinh tien giup toi', 'Vietnamese'), 'xin tính tiền giúp tôi');
    });
  });
}

