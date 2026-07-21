# Chief Quality Judge Final Audit & Execution Plan

**Date**: 2026-07-16  
**Author**: Chief Quality Judge (Agent 4)  
**Target Project**: Fluentish (Translation Engine, Travel Corpus, and Test Suites)  

---

## 1. Synthesis of Findings & Comprehensive Judgment

Having reviewed the reports from all three auditor agents:
- **Agent 1 (Corpus Auditor)**: Identified 34 duplicate dictionary keys, 12 phrasing/grammatical issues in the travel corpus (including medical hallucinations and awkward phrasing), and slash usage.
- **Agent 2 (Live Streaming & Pattern Specialist)**: Identified 7 critical prefix pattern and progressive typing issues, including trailing space mismatch, untranslated remainder leaks, greedy substring matching in `_lookupTerm`, and aggressive override blocks.
- **Agent 3 (Spellcheck QA)**: Identified 4 spelling correction failures in Vietnamese where words like `tien` remained uncorrected due to strict pattern matching.

This plan synthesizes these findings into a unified, step-by-step execution plan for the implementer agent.

---

## 2. Step-by-Step Clean-Up Instructions

### Phase 1: Travel Corpus Cleanup
**Target File**: `lib/src/features/language/corpus/travel_corpus.dart`

Apply the following modifications to resolve slash violations and phrasing issues:

1. **Split Ticket Entry (Index 81, Line 411)**:
   * **Old**: 
     ```dart
     {
       'vi': 'Tôi muốn mua một vé một chiều/khứ hồi.',
       'en': 'I would like to buy a one-way/round-trip ticket.',
       'category': 'transportation'
     }
     ```
   * **New (Split into two separate entries)**:
     ```dart
     {
       'vi': 'Tôi muốn mua một vé một chiều.',
       'en': 'I would like to buy a one-way ticket.',
       'category': 'transportation'
     },
     {
       'vi': 'Tôi muốn mua một vé khứ hồi.',
       'en': 'I would like to buy a round-trip ticket.',
       'category': 'transportation'
     }
     ```

2. **Fix Travel Corpus Phrasing and Contextual Issues (12 Items)**:
   * **Item 1 (Line 783)**: Change `'vi'` to `'Tôi bị đau bụng và sốt nhẹ từ chiều hôm qua.'` (Removes medical hallucination "đau bụng khan").
   * **Item 2 (Line 1207)**: Change `'vi'` to `'Tôi bị đau bụng dữ dội từ tối qua, có lẽ tôi đã ăn phải đồ không hợp vệ sinh.'` (Removes awkward phrasing "đau bụng gay gắt").
   * **Item 3 (Line 1028)**: Change `'vi'` to `'Tôi muốn thuê một chiếc xe số trong ba ngày, thủ tục cần những gì?'` (Removes literal translation "xe máy số tay").
   * **Item 4 (Line 1283)**: Change `'vi'` to `'Tôi để quên chiếc ô ở sảnh chờ lúc nãy, không biết có ai nhặt được không?'` (Removes passive "bị để quên").
   * **Item 5 (Line 589)**: Change `'vi'` to `'Vui lòng không cho bột ngọt hay đậu phộng vào món ăn của tôi.'` (Removes redundant "Xin làm ơn").
   * **Item 6 (Line 931)**: Change `'vi'` to `'Vòi nước nóng trong phòng tắm hình như bị trục trặc.'` (Simplifies technical term "Hệ thống nước nóng").
   * **Item 7 (Line 604)**: Change `'en'` to `'Please give me some extra ice and wet wipes.'` (Changes "wet tissues" to natural "wet wipes").
   * **Item 8 (Line 473)**: Change `'en'` to `'How many minutes does it take to walk from here to there?'` (Corrects awkward English "How many minutes walk is it").
   * **Item 9 (Line 159)**: Change `'vi'` to `'Tôi đã đặt phòng tên là Nguyễn.'` (Removes literal translation "dưới tên").
   * **Item 10 (Line 1227)**: Change `'en'` to `'This is the phone number of my emergency contact in case of emergency.'` (Replaces literal "in case of necessity").
   * **Item 11 (Line 1232)**: Change `'en'` to `'I have seasonal allergies with itchy rashes on my arms, do you have any good topical cream?'` (Corrects "weather allergy" and singular "arm").
   * **Item 12 (Line 947)**: Change `'en'` to `'I am vegan, does the restaurant have any dishes with no meat or animal products?'` (Replaces literal "strict vegetarian").

---

### Phase 2: Translation Engine Optimization & Typo Correction
**Target File**: `lib/src/features/language/translator_engine.dart`

Apply the following modifications to resolve duplicates, progressive typing issues, and spellcheck gaps:

1. **Resolve Dictionary Overrides & Context Collisions**:
   * Consolidate and remove the 34 duplicate keys in `_dictionary` (lines 8–980) as detailed in `gap_report.md`.
   * For the key `'discount'`, ensure the incorrect mapping `'Có giảm giá không?'` is removed, and keep only `'Giảm giá'`.
   * Fix homophone/context collisions:
     * Change `'cửa': 'Door / Window'` to `'cửa': 'Door'`.
     * Change `'đường': 'Street / Road / Sugar'` to `'đường': 'Street / Road'`.
     * Change `'năm': 'Year / Five'` to `'năm': 'Year'`.
     * Change `'fresh': 'Tươi sống / Trong lành'` to `'fresh': 'Fresh'`. (Add separate keys `'fresh air': 'Trong lành'` and `'fresh food': 'Tươi sống'`).

2. **Deduplicate Slash Splitting via Regex**:
   * To prevent splitting valid terms containing slashes (like `24/24` or `24/7`) while still splitting choices, change all slash splitting calls:
     * Change `text.split('/').first` and `val.split('/').first` to `text.split(RegExp(r'(?<!\d)/(?!\d)')).first`.

3. **Prefix Trailing Space Mismatch (Vietnamese -> English)**:
   * In `_translateToEnglishPatterns`, update startsWith checks to match either with or without a trailing space (e.g. `clean == 'bạn có thể' || clean.startsWith('bạn có thể ')`).

4. **Missing Prefix Matches (English -> Vietnamese Questions)**:
   * In `_translateToVietnamesePatterns`, update question pattern checks to handle prefixes without trailing spaces (e.g. `clean == 'what will we' || clean.startsWith('what will we ')`, etc.).

5. **Untranslated Remainder Interpolation Leak**:
   * In `_translateToEnglishPatterns` for `chúng ta nên đi đâu`, pass the remainder through `translateSync` before interpolating:
     ```dart
     final transRemainder = translateSync(remainder, 'Vietnamese', 'English', isSubclause: true);
     return 'Where should we go $transRemainder?';
     ```

6. **Raw Substring Truncation Fallback in "Xin"**:
   * Replace `original.substring(4)` with a subclause translation:
     ```dart
     final remainder = clean.substring(4).trim();
     final transRemainder = translateSync(remainder, 'Vietnamese', 'English', isSubclause: true);
     return 'Please $transRemainder';
     ```

7. **Remove Aggressive Short-Query Overrides**:
   * Delete or restrict the broad short-query overrides in `_translateToVietnamesePatterns` (lines 1939–1942) and `_translateToEnglishPatterns` (lines 2079–2084) to prevent incorrect hardcoded sentence replacements.

8. **Greedy Substring Collision in `_lookupTerm`**:
   * Remove the regex fallback block in `_lookupTerm` (lines 1177–1180) that allows single matching words to hijack the entire phrase translation.

9. **Expand Vietnamese Spelling Correction**:
   * In `findSpellingCorrection`, allow `tien` to be corrected to `tiền` when preceded by `nhiêu` or `nhieu`.
   * Add corrections for common missing words:
     * `muon` -> `muốn`
     * `giup` -> `giúp`
     * `toi` -> `tôi`

---

### Phase 3: Comprehensive Test Suite Expansion
**Target Files**: 
- `test/translator_engine_comprehensive_test.dart`
- `test/typo_qa_custom_test.dart`

1. **Update Typo QA Expected Results**:
   * In `test/typo_qa_custom_test.dart`, update the expected values for the 4 corrected Vietnamese typo scenarios to reflect the proper spelling suggestion (e.g. `'bao nhiêu tiền'`, `'cái này bao nhiêu tiền'`, `'bao nhiêu tiền cái này'`, `'tôi muốn xin tính tiền'`, and `'xin tính tiền giúp tôi'`).

2. **Add New Verification Tests**:
   * In `test/translator_engine_comprehensive_test.dart`, add assertions verifying:
     * Slash-containing terms (like `24/24` or `24/7`) do not get truncated inside sentences.
     * Greedy substring matching is fixed: `translateSync('where is the parking lot near the hotel', 'English', 'Vietnamese')` translates fully instead of returning `"Khách sạn nằm ở đâu?"`.
     * `translateSync('what will we', 'English', 'Vietnamese')` and other progressive intermediate states are handled cleanly.
     * Typo corrections for `bao nhieu tien`, `xin tinh tien giup toi`, etc., return the correct spelling suggestions.

---

## 3. Verification Method

To verify the correct execution of these changes:
1. Run all tests to ensure zero regressions:
   ```bash
   flutter test
   ```
2. Verify that the custom typo test harness runs and passes:
   ```bash
   flutter test test/typo_qa_custom_test.dart
   ```
3. Check the generated `typo_qa_report.md` to ensure all 51 scenarios pass with the correct, fully-accented Vietnamese words.
