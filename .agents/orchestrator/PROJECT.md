# Project: Fluentish Translation Engine Correctness and Corpus Audit

## Architecture
- **TranslatorEngine**: Core component in `lib/src/features/language/translator_engine.dart` which translates input text between English and Vietnamese.
- **Corpus**: `lib/src/features/language/corpus/travel_corpus.dart` containing 253 sentences.
- **Data Flow**: Input text -> lowercase/punctuation cleaning -> dictionary matching -> exact corpus matching -> pattern matching -> VSM similarity search -> word-by-word progressive streaming fallback.
- **Spell Check**: `findSpellingCorrection` uses typo normalizations and VSM similarity to suggest corrections.

## Code Layout
- `lib/src/features/language/translator_engine.dart` — Core engine and dictionary.
- `lib/src/features/language/corpus/travel_corpus.dart` — Travel corpus entries.
- `test/translator_engine_comprehensive_test.dart` — Progressive typing and spellcheck tests.
- `test/audit_entire_corpus_test.dart` — Corpus coverage and prefix streaming tests.

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | Audit & Analysis | Run exploratory tests, map out the 5 bugs, and draft fixes | None | DONE |
| 2 | Code Implementation | Implement fixes for the 5 bugs, add test cases to comprehensive test | M1 | DONE |
| 3 | Corpus & Pattern Audit | Multi-agent audit of travel_corpus and dictionary phrases for natural translations | M2 | DONE |
| 4 | Verification & Hardening | Run all test suites, challenger checks, and forensic auditing | M3 | IN_PROGRESS (IDs: challenger_m4_1, auditor_m4_1) |

## Interface Contracts
### TranslatorEngine ↔ UI / Client
- `static String translateSync(String text, String sourceLang, String targetLang, {bool isSubclause = false})`
- `static String? findSpellingCorrection(String text, String sourceLang)`
