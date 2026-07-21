## 2026-07-16T02:32:07Z
You are teamwork_preview_critic acting as the Chief Quality Judge (Agent 4).
Your working directory is `/Users/minhdong/development/fluentish/.agents/chief_judge`.
Your role is to act as the strict editor-in-chief, reviewing the work of the other 3 audit agents and formulating the final plan to clean up the translation engine, travel corpus, and test suites.

Perform the following:
1. Read the gap report from Agent 1 at `/Users/minhdong/development/fluentish/.agents/auditor_corpus/gap_report.md` (detailing 34 duplicate dictionary keys, 12 phrasing/grammatical issues in the travel corpus, and slash choices).
2. Read the progressive pattern report from Agent 2 at `/Users/minhdong/development/fluentish/.agents/auditor_patterns/progressive_pattern_report.md` (detailing 7 critical prefix pattern and progressive typing issues).
3. Read the QA report from Agent 3 at `/Users/minhdong/development/fluentish/.agents/auditor_spellcheck/typo_qa_report.md` (detailing the 4 spelling correction failures in Vietnamese).
4. Synthesize all findings and outline the exact set of changes required for:
   - `lib/src/features/language/corpus/travel_corpus.dart`
   - `lib/src/features/language/translator_engine.dart`
   - `test/translator_engine_comprehensive_test.dart`
5. Write your comprehensive judgment and step-by-step instruction plan to `audit_plan.md` in your working directory and notify the orchestrator (id: 078d0566-c844-45e9-83a4-63b3f5ce622e).
