# Translation Bug Analysis Report

## Executive Summary
This report analyzes translation spell-check bugs in Fluentish, specifically focusing on Bug 1: why `could you explain it again` incorrectly triggers a spelling correction suggestion of `can you explain it again`. 

---

## Technical Details

### 1. Root Cause Analysis (Bug 1)
The spelling correction engine in `TranslatorEngine.findSpellingCorrection` uses a Vector Space Model (VSM) with character 3-gram embeddings and word token frequencies to find the closest match in the bilingual corpus.

For the input query `"could you explain it again"`:
1. It is not an exact match in `_dictionary` keys or `TravelCorpus` sentences, so it proceeds to check VSM similarity against all candidate sentences in the corpus.
2. The candidate `"can you explain it again"` exists in `_vectorCorpus`.
3. The query vector and candidate vector have a high similarity score because:
   - Word token matching (`you`, `explain`, `it`, `again` are identical).
   - Word trigram embeddings overlap significantly.
   - The calculated cosine similarity is **`~0.8238`**.
4. The similarity threshold range in `findSpellingCorrection` is:
   ```dart
   if (sim > maxSim && sim >= 0.74 && sim < 0.99 && candidate.toLowerCase() != cleanLower)
   ```
5. Since `0.8238` falls inside `[0.74, 0.99]`, `"can you explain it again"` is incorrectly recommended as a spelling correction.
6. Crucially, the engine does not verify whether the input query actually contains misspelled words before suggesting a correction.

### 2. Proposed Solution
To prevent false-positive corrections for valid input sentences, `findSpellingCorrection` must first check if the input contains any invalid words (spelling typos). If every token in the input matches a known valid word in the dictionary, corpus, or proper nouns list (or is a number), we should skip VSM similarity search entirely and return `null`.

#### Implementation details:
1. Construct a global set of known words `_knownWords` by tokenizing and cleaning all keys/values from the bilingual dictionary, travel corpus, vector corpus, and proper nouns.
2. Tokenize the cleaned input.
3. Verify if every token is a number or belongs to `_knownWords`.
4. If so, return `null`.

---

## Verification
A patch has been written to the agent directory:
- Patch file: `.agents/explorer_m1_1/spell_check_fix.patch`

Test commands:
```bash
/Users/minhdong/development/flutter/bin/flutter test test/translator_engine_comprehensive_test.dart
```
