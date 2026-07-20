# Handoff Report — Corpus & Dictionary Auditor

## 1. Observation
* **Files inspected**:
  * `lib/src/features/language/corpus/travel_corpus.dart` (lines 1 to 1294)
  * `lib/src/features/language/translator_engine.dart` (lines 1 to 2176, specifically `_dictionary` from line 8 to 973)
* **Tool commands and results**:
  * Executed custom python script `audit.py` to count entries and detect rule violations:
    * Found 253 entries in `travel_corpus.dart`.
    * Found 925 entries in `_dictionary`.
    * Multiple choices with slashes in `travel_corpus.dart`: 2 entries.
      * Line 411: `'vi': 'Tôi muốn mua một vé một chiều/khứ hồi.'` | `'en': 'I would like to buy a one-way/round-trip ticket.'`
      * Line 498: `'vi': 'Cửa hàng tiện lợi gần nhất có mở cửa 24/24 không?'` | `'en': 'Is the nearest convenience store open 24/7?'`
    * Multiple choices with slashes in `_dictionary`: 207 entries.
    * Duplicate keys in `_dictionary`: 34 keys (e.g., `'phở bò'`, `'cà phê sữa đá'`, `'air conditioner'`).
  * Inspected sentences in both files manually for grammatical and contextual correctness. Key findings:
    * Line 783: `Tôi bị đau bụng khan và sốt nhẹ từ chiều hôm qua.` ("đau bụng khan" is not a valid medical term).
    * Line 1207: `Tôi bị đau bụng gay gắt từ tối qua...` ("đau bụng gay gắt" is unnatural; should be "đau bụng dữ dội").
    * Line 1028: `...xe máy số tay...` ("xe máy số tay" is unnatural; should be "xe số" or "xe côn tay").
    * Line 1283: `Tôi bị để quên chiếc ô...` (awkward passive voice "bị để quên").
    * Line 533: `'đường': 'Street / Road / Sugar'` (severe homophone/context collision).
    * Line 752: `'năm': 'Year / Five'` (homophone conflict).
    * Line 957: `'fresh': 'Tươi sống / Trong lành'` (context collision).
  * Executed the project test suite with local Flutter:
    ```bash
    /Users/minhdong/development/flutter/bin/flutter test test/audit_entire_corpus_test.dart test/translator_engine_comprehensive_test.dart
    ```
    * The first test "Audit ALL TravelCorpus sentences (exact match)" passed, successfully auditing 253 complete sentences in both directions.

## 2. Logic Chain
1. **Observation**: Executing the python script mapped 34 duplicate keys in `_dictionary` (e.g. `'phở bò'` defined twice, `'air conditioner'` defined twice).
   * **Inference**: Dart Maps override previous keys if initialized with duplicate keys, meaning 34 values are silently overridden or ignored. This represents redundant code.
2. **Observation**: `travel_corpus.dart` contains `'Tôi muốn mua một vé một chiều/khứ hồi.'` at line 411.
   * **Inference**: A bilingual user learning a phrase cannot speak a slashed combination. Since this is an end-user corpus sentence, it violates clean translation guidelines and must be split.
3. **Observation**: `_dictionary` has keys mapping to translations with slashes (e.g., `'đường': 'Street / Road / Sugar'`).
   * **Inference**: When single-word lookup happens, if the engine doesn't strip slashes, the user receives all choices separated by slashes. More seriously, contextually different meanings (sugar vs. street) are grouped under the same key, which breaks contextual translation accuracy.
4. **Observation**: Sentence at line 783 contains "đau bụng khan" (dry stomach ache).
   * **Inference**: This is a medical hallucination (combining "ho khan" and "đau bụng"). It is grammatically incorrect and contextually invalid in Vietnamese.

## 3. Caveats
* We assumed that the VSM Vector Corpus (`_vectorCorpus` from line 976 to 1064 in `translator_engine.dart`) did not require deduplication against `_dictionary` keys as VSM uses it for semantic matching and is separate from the exact match dictionary.
* Environmental path lacks standard `flutter` and `dart` globals, requiring execution via `/Users/minhdong/development/flutter/bin/flutter`.

## 4. Conclusion
The travel corpus and dictionary have excellent basic coverage (successfully translating 253 sentences bidirectionally in tests), but contain critical style and quality issues:
* **Redundancy**: 34 duplicate keys override map entries.
* **Corpus Issues**: Slashes in index 81 and unnatural phrases ("đau bụng khan", "đau bụng gay gắt", "xe máy số tay", "Tôi bị để quên") need clean rewriting.
* **Dictionary Conflicts**: Homophones like "đường" and "năm" require contextual handling rather than grouped slash translations.

## 5. Verification Method
* Run the tests to confirm baseline correctness:
  ```bash
  /Users/minhdong/development/flutter/bin/flutter test test/audit_entire_corpus_test.dart test/translator_engine_comprehensive_test.dart
  ```
* Review the full list of findings and duplicate keys in `/Users/minhdong/development/fluentish/.agents/auditor_corpus/gap_report.md`.
