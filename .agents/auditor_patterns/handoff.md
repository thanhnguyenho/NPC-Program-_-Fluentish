# Handoff Report — Progressive Pattern Audit

## 1. Observation
I directly observed the following implementations in `lib/src/features/language/translator_engine.dart`:

* **O1: Trim-induced space mismatch** (Line 2031):
  ```dart
  if (clean.startsWith('bạn có thể ')) {
  ```
* **O2: Trailing space checking in English questions** (Line 1637):
  ```dart
  if (clean.startsWith('what should we ') || clean.startsWith('what can we ') || clean.startsWith('what will we ')) {
  ```
* **O3: Missing translation of remainder** (Line 2004):
  ```dart
  return 'Where should we go $remainder?';
  ```
* **O4: Direct substring inclusion of original** (Line 2051):
  ```dart
  return 'Please ${original.substring(4)}';
  ```
* **O5: Short query overrides** (Lines 1939–1942):
  ```dart
  if (words.length <= 4 && (clean.contains('coffee') || clean.contains('caffeine') || clean.contains('latte'))) {
    if (clean.contains('milk') || clean.contains('iced')) return 'Cho tôi xin một ly cà phê sữa đá';
    return 'Cho tôi xin một ly cà phê';
  }
  ```
* **O6: Question word repetition** (Line 1742):
  ```dart
  if (remainder.isNotEmpty) return 'Chúng ta nên đi đâu ${translateSync(remainder, 'English', 'Vietnamese', isSubclause: true)}?';
  ```
* **O7: Greedy substring collision in `_lookupTerm`** (Lines 1172–1181):
  ```dart
  for (final entry in _dictionary.entries) {
    if (cleanTerm == entry.key) {
      val = entry.value;
      break;
    }
    if (entry.key.length >= 4 && RegExp(r'\b' + RegExp.escape(entry.key) + r'\b').hasMatch(cleanTerm)) {
      val = entry.value;
      break;
    }
  }
  ```

---

## 2. Logic Chain
1. **LC1 (From O1)**: The `clean` variable is trimmed using `text.trim().toLowerCase()` prior to matching. When a user has typed exactly `"bạn có thể"`, `clean` is `"bạn có thể"`. Because `"bạn có thể"` does not start with `"bạn có thể "` (note the trailing space), it fails the match and falls back to word-by-word, generating `"You yes thể"`. Only when a trailing word starts (e.g. `"bạn có thể g"`) does it match `"bạn có thể "` and transition to `"Can you g?"`.
2. **LC2 (From O2)**: Intermediate progressive typing values like `"what will we"`, `"where can we find"`, or `"when should we"` fail to match prefix patterns because they require trailing spaces or specific suffix patterns. They fall back to word-by-word reordering, leading to grammatically broken translations like `"Cái gì sẽ chúng ta"` and `"Khi nào nên chúng ta"`.
3. **LC3 (From O3)**: In `_translateToEnglishPatterns`, the remainder string is interpolated directly into `Where should we go $remainder?`. Because it is not wrapped in `translateSync` or `_lookupTerm`, the untranslated Vietnamese remainder is printed directly inside the English sentence (e.g. `"Where should we go ngày mai?"`).
4. **LC4 (From O4)**: In the polite request check, the raw Vietnamese substring is appended after `"Please "` (e.g. `"xin chào bạn"` becomes `"Please chào bạn"`). This creates hybrid word salad sentences.
5. **LC5 (From O5)**: Short queries containing `"caffeine"` are forcefully rewritten into requests for coffee. Therefore, `"caffeine is bad"` or `"avoid caffeine"` results in `"Cho tôi xin một ly cà phê"` (the exact opposite of the user's intent).
6. **LC6 (From O6)**: When translating `"where should we go where"`, the remainder `"where"` is translated as `"ở đâu"`, resulting in `"Chúng ta nên đi đâu ở đâu?"` – repeating the query phrase.
7. **LC7 (From O7)**: In `_lookupTerm`, the loop matches the first dictionary key (>= 4 chars) that occurs anywhere inside the query `cleanTerm`. If a long query has a reference word (like `"hotel"` in `"parking lot near the hotel"`), it matches `'hotel'` early, breaks the loop, and outputs `"Khách sạn nằm ở đâu?"`, losing the primary subject `"parking lot"`.

---

## 3. Caveats
* I operated under a read-only investigation constraint, meaning no files outside of `.agents/auditor_patterns` were modified.
* Flutter tests could not be run locally because the `flutter` and `dart` binaries are not present in the CLI environment PATH.
* The analysis assumes that the target runtime dictionary and regex patterns behave standardly as written in the Dart code.

---

## 4. Conclusion
The progressive prefix typing logic suffers from several severe translation errors, layout breakage, and word drops. Refactoring is required to handle trimmed strings, check exact intermediate matches, sanitize/translate remainders, remove greedy substring lookups, and properly map short queries without losing semantic intent.

---

## 5. Verification Method
To verify these issues:
1. Inspect the source file: `lib/src/features/language/translator_engine.dart` at the specified lines.
2. Run the existing tests using `flutter test` when a Flutter environment is available.
3. Add the following unit tests to `test/translator_engine_comprehensive_test.dart` to verify the findings:
   ```dart
   test('Greedy lookup collision', () {
     expect(TranslatorEngine.translateSync('where is the parking lot near the hotel', 'English', 'Vietnamese'), isNot('Khách sạn nằm ở đâu?'));
   });
   test('Remainder translation leak', () {
     expect(TranslatorEngine.translateSync('chúng ta nên đi đâu ngày mai', 'Vietnamese', 'English'), 'Where should we go tomorrow?');
   });
   test('Caffeine short override logic', () {
     expect(TranslatorEngine.translateSync('caffeine is bad', 'English', 'Vietnamese'), isNot('Cho tôi xin một ly cà phê'));
   });
   test('Trim-induced mismatch', () {
     expect(TranslatorEngine.translateSync('bạn có thể', 'Vietnamese', 'English'), 'Can you...');
   });
   ```
