## 2026-07-16T02:34:02Z
You are teamwork_preview_worker. Your working directory is `/Users/minhdong/development/fluentish/.agents/worker_m3_1`.
Your role is to execute the final audit and cleanup plan formulated by the Chief Quality Judge (Agent 4) in `/Users/minhdong/development/fluentish/.agents/chief_judge/audit_plan.md`.

Please read that plan carefully. Your tasks are:
1. Clean up `lib/src/features/language/corpus/travel_corpus.dart` by resolving the 12 phrasing/grammatical issues (such as removing "đau bụng khan" and "đau bụng gay gắt") and splitting the ticket booking entry (Index 81) into two separate entries to avoid inline slashes.
2. Clean up `lib/src/features/language/translator_engine.dart`:
   - Consolidate and remove the 34 duplicate keys in `_dictionary` (keep the most accurate translation).
   - Fix homophone/context collisions (like "cửa", "đường", "năm", "fresh").
   - Fix regex split of slashes using `text.split(RegExp(r'(?<!\d)/(?!\d)'))` so that terms like "24/24" are not split but choice synonyms are.
   - Adjust startsWith prefix patterns (e.g. `bạn có thể`, `what will we`, `where can we find`, etc.) to match both with or without a trailing space so progressive typing is stable.
   - Pass the remainder through `translateSync` inside patterns to prevent untranslated text leak.
   - Replace raw substring offsets in the "Xin" pattern with a translated subclause.
   - Delete or restrict the broad short-query override blocks that replace queries with opposite intents.
   - Remove the greedy word-boundary substring loop in `_lookupTerm` that hijacks sentences.
   - Refactor `findSpellingCorrection` to run manual typo normalizations (like "nay" -> "này", "tien" -> "tiền") BEFORE performing the `allWordsValid` check. This ensures context typos are corrected. Extend spelling corrections for "muon" -> "muốn", "giup" -> "giúp", "toi" -> "tôi", and "tien" -> "tiền" (allowing "tiền" in broad travel contexts like "bao nhiêu tiền", "tiền mặt", etc.).
3. Update and extend test suites:
   - In `test/typo_qa_custom_test.dart`, update the expected values for the 4 corrected Vietnamese typo scenarios to reflect the proper spelling suggestions (e.g. "bao nhiêu tiền", "xin tính tiền giúp tôi", etc.).
   - In `test/translator_engine_comprehensive_test.dart`, add assertions verifying:
     - Slashes inside terms like "24/24" do not get truncated inside sentences.
     - Greedy substring matching is fixed: `translateSync('where is the parking lot near the hotel', 'English', 'Vietnamese')` translates fully.
     - `translateSync('what will we', 'English', 'Vietnamese')` and other progressive intermediate states are handled cleanly.
     - Typo corrections for `bao nhieu tien`, `xin tinh tien giup toi`, etc., return the correct spelling suggestions.
4. Run all tests with local Flutter:
   - `flutter test`
   - `flutter test test/typo_qa_custom_test.dart`
5. Verify that all 51 scenarios in the generated `typo_qa_report.md` now pass with 100% success.
6. Document all changes in your working directory and notify the orchestrator (id: 078d0566-c844-45e9-83a4-63b3f5ce622e).
