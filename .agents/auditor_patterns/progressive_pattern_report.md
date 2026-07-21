# Progressive Pattern Audit Report

**Date**: 2026-07-16
**Agent**: Live Streaming & Pattern Specialist (Agent 2)
**Scope**: Prefix pattern translation methods and progressive prefix typing behavior in `lib/src/features/language/translator_engine.dart`.

---

## Executive Summary
An audit of `lib/src/features/language/translator_engine.dart` was conducted to evaluate prefix pattern translations (`_translateToVietnamesePatterns` and `_translateToEnglishPatterns`) and the smooth transition of progressive prefix typing.
Seven critical logic flaws and unstable states were identified, ranging from trim-induced syntax mismatches and untranslated string leaks to aggressive short-query overrides and greedy substring collisions that drop key query semantics.

---

## Detailed Findings

### Finding 1: Trim-Induced Mismatch for Trailing Spaces in Vietnamese -> English Prefixes
* **Location**: `lib/src/features/language/translator_engine.dart` (Line 2031, 2015, etc.)
* **Code Snippet**:
  ```dart
  if (clean.startsWith('bạn có thể ')) {
  ```
* **Observation & Bug**: The input is trimmed (`final clean = text.trim().toLowerCase();`) before entering the pattern methods. As a result, typing exactly `"bạn có thể"` or even with trailing spaces `"bạn có thể "` results in a `clean` string of `"bạn có thể"`. Because of the trailing space in the pattern `'bạn có thể '`, this check fails. It falls back to word-by-word translation, resulting in `"You yes thể"` (or similar garbage depending on dictionary mappings).
* **Impact**: Jarring transition during live typing:
  1. `"bạn có thể"` -> `"You yes thể"` (Broken state)
  2. `"bạn có thể g"` -> `"Can you g?"` (Suddenly correct state)

---

### Finding 2: Missing Exact Prefix Matches in English -> Vietnamese Question Structures
* **Location**: `_translateToVietnamesePatterns` (Lines 1637–1642, 1780, etc.)
* **Observation & Bug**: Several English question prefix structures only match if they have a trailing space, e.g., `clean.startsWith('what will we ')`, `clean.startsWith('where can we find ')`, `clean.startsWith('when should we ')`. When typing progressively, intermediate inputs like `"what will we"`, `"where can we find"`, or `"when should we"` fail these pattern checks and fall back to word-by-word translations.
* **Impact**: Jarring jumps in word order during typing:
  * `"what will we"` -> `"Cái gì sẽ chúng ta"` (Word salad)
  * `"what will we eat"` -> `"Chúng ta sẽ ăn gì?"` (Correct)
  * `"when should we"` -> `"Khi nào nên chúng ta"` (Word salad)
  * `"when should we go"` -> `"Khi nào chúng ta nên đi?"` (Correct)

---

### Finding 3: Untranslated Remainder Interpolation Leak in Vietnamese -> English
* **Location**: `_translateToEnglishPatterns` (Lines 2001–2007)
* **Code Snippet**:
  ```dart
  if (clean.startsWith('chúng ta nên đi đâu')) {
    final remainder = clean.replaceAll('chúng ta nên đi đâu', '').replaceAll('?', '').trim();
    if (remainder.isNotEmpty) {
      return 'Where should we go $remainder?';
    }
    return 'Where should we go?';
  }
  ```
* **Observation & Bug**: Unlike other patterns in the class, `$remainder` is directly interpolated into the English sentence template *without* being translated using `translateSync` or `_lookupTerm`.
* **Impact**: Vietnamese terms are leaked raw into the English output.
  * `"chúng ta nên đi đâu ngày mai"` -> `"Where should we go ngày mai?"`
  * `"chúng ta nên đi đâu ăn tối"` -> `"Where should we go ăn tối?"`

---

### Finding 4: Raw Substring Truncation Fallback in "Xin" Pattern
* **Location**: `_translateToEnglishPatterns` (Lines 2041–2052)
* **Code Snippet**:
  ```dart
  if (clean.startsWith('xin ')) {
    // ... subclause checks ...
    return 'Please ${original.substring(4)}';
  }
  ```
* **Observation & Bug**: When input starts with `"xin "` and doesn't match any specific sub-pattern (like `"mở cửa"`, `"tính tiền"`), it directly appends `original.substring(4)` (the raw Vietnamese string following `"xin "`) to `"Please "`.
* **Impact**: Generates bilingual word salads.
  * `"xin chào bạn"` -> `"Please chào bạn"` (instead of `"Hello friend"`)
  * `"xin cốc nước"` -> `"Please cốc nước"` (instead of `"May I have a cup of water, please?"`)

---

### Finding 5: Short-Query Overrides Destroying Query Semantics
* **Location**: `_translateToVietnamesePatterns` (Lines 1939–1942), `_translateToEnglishPatterns` (Lines 2079–2084)
* **Code Snippet**:
  ```dart
  if (words.length <= 4 && (clean.contains('coffee') || clean.contains('caffeine') || clean.contains('latte'))) {
    if (clean.contains('milk') || clean.contains('iced')) return 'Cho tôi xin một ly cà phê sữa đá';
    return 'Cho tôi xin một ly cà phê';
  }
  ```
* **Observation & Bug**: Short inputs (<= 4 words) containing key vocabulary are aggressively intercepted and replaced with hardcoded sentences, regardless of the user's actual intention.
* **Impact**: Serious translation failures and logical contradictions:
  * `"caffeine is bad"` (3 words) -> `"Cho tôi xin một ly cà phê"` (Translates to "Please give me a cup of coffee" – the opposite of the user's intent).
  * `"avoid caffeine"` -> `"Cho tôi xin một ly cà phê"`.
  * `"không ăn gì"` (not eating anything) -> `"What should we eat today?"`.
  * `"không đi đâu"` (not going anywhere) -> `"Where should we go?"`.

---

### Finding 6: Question Word / Phrase Duplication
* **Location**: `_translateToVietnamesePatterns` (Lines 1737–1744)
* **Observation & Bug**: If a user types a question word that is already part of the hardcoded pattern template, it gets duplicated in the final output.
* **Impact**: Duplicate question words.
  * `"where should we go where"` -> `remainder` is `"where"` -> `translateSync("where")` is `"ở đâu"`. The result is `"Chúng ta nên đi đâu ở đâu?"`.
  * `"what should we buy what"` -> `remainder` is `"buy what"` -> translates to `"mua cái gì"`. The result is `"Chúng ta nên mua cái gì gì?"`.

---

### Finding 7: Greedy Substring Collision in `_lookupTerm`
* **Location**: `_lookupTerm` (Lines 1172–1182)
* **Code Snippet**:
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
* **Observation & Bug**: When a term is not found exactly, `_lookupTerm` loops through all dictionary keys. If any dictionary key of length >= 4 matches as a word-boundary substring inside the input `cleanTerm`, it breaks the loop and uses that key's translation as the translation for the *entire* input.
* **Impact**: Dropped semantics and complete translation hijack. Since `'hotel'` is defined before other words:
  * `"where is the parking lot near the hotel"` -> `cleanTerm` = `"parking lot near the hotel"`.
  * The loop finds `'hotel'` (length 5 >= 4), matches, and immediately returns `"Khách sạn"`.
  * Result: `"Khách sạn nằm ở đâu?"` (translating to "Where is the hotel?", completely dropping "parking lot").
  * `"what is the wifi password of the hotel"` -> `cleanTerm` = `"wifi password of the hotel"`.
  * Matches `'hotel'`, returns `"Khách sạn"`.
  * Result: `"Khách sạn là gì?"` (translating to "What is the hotel?", dropping the wifi password query).

---

## Recommended Corrective Actions
1. **Sanitize trailing spaces in patterns**: Replace checks like `.startsWith('bạn có thể ')` with `.startsWith('bạn có thể')` and verify word boundaries or check exact matches.
2. **Add exact match handlers**: Add exact matches for intermediate states (e.g., `clean == 'what should we'`) to provide placeholders (e.g., `'Chúng ta nên...'`) instead of falling back to word salad.
3. **Translate remainders properly**: In `chúng ta nên đi đâu`, wrap `$remainder` in `translateSync(remainder, 'Vietnamese', 'English', isSubclause: true)`.
4. **Remove lazy substring fallback in "Xin"**: Replace `original.substring(4)` with proper dictionary translation or syntax parsing.
5. **Contextualize short-query checks**: Ensure short-query checks check for negation (like "avoid", "no", "không") and don't aggressively replace queries with opposite intents.
6. **Refactor `_lookupTerm` dictionary matching**: Avoid greedy substring matches that discard the rest of the string. Either translate words individually or match the longest common substring first.
