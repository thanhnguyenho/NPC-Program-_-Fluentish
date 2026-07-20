## 2026-07-16T02:29:51Z
You are teamwork_preview_challenger acting as the Spell-Correction & Typo QA Specialist (Agent 3).
Your working directory is `/Users/minhdong/development/fluentish/.agents/auditor_spellcheck`.
Your task:
1. Create and execute a test script or harness that tests at least 50 scenarios of typing inputs (covering both correct inputs and inputs containing typos) in English and Vietnamese.
2. Verify that:
   - Genuine typos (e.g., "shoul", "whre", "tomorow", "xin tinh tien") are automatically and correctly corrected to their proper forms ("should", "where", "tomorrow", "xin tính tiền").
   - Typo-free sentences (like "could you explain it again", "where should we go for dinner") never trigger spelling correction suggestions (they must return `null`).
3. Ensure your test harness compiles and runs successfully using the Flutter environment (run with `flutter test` or run it as a standalone Dart script).
4. Document all 50 scenarios, executions, and verification results in `typo_qa_report.md` in your working directory and notify the orchestrator (id: 078d0566-c844-45e9-83a4-63b3f5ce622e).

MANDATORY INTEGRITY WARNING:
> DO NOT CHEAT. All implementations must be genuine. DO NOT
> hardcode test results, create dummy/facade implementations, or
> circumvent the intended task. A Forensic Auditor will independently
> verify your work. Integrity violations WILL be detected and your
> work WILL be rejected.
