# Contributing Guide

This guide helps the team work on the Flutter project with the same workflow, avoid overwriting each other's work, and make pull requests easier to review.

## 1. Current Roles

Each person should work inside their assigned feature folder first. If a change needs to touch files outside your area, mention it in the group chat or explain it clearly in the pull request.

| Feature | Owner | Folder |
| --- | --- | --- |
| Welcome page | Chloe | `lib/src/features/welcome/` |
| Login page | Chloe | `lib/src/features/login/` |
| Registration page | Chloe | `lib/src/features/registration/` |
| Language page | Minh | `lib/src/features/language/` |
| Soundboard page | Mary | `lib/src/features/soundboard/` |
| Profile | Chloe | `lib/src/features/profile/` |
| Home page | Chris | `lib/src/features/home/` |
| Community | Chris | `lib/src/features/community/` |
| Friend Location | Phong | `lib/src/features/friend_location/` |
| Guides/Review | Chris | `lib/src/features/guides_review/` |
| Additional Profile menu screen options | Chloe | `lib/src/features/profile_menu/` |
| Friends | Phong | `lib/src/features/friends/` |

Shared code:

| Area | Folder | Rule |
| --- | --- | --- |
| Shared assets/constants | `lib/src/shared/` | Only change this when code is truly shared. Explain the change in the PR. |
| App entry | `lib/main.dart` | Avoid editing directly. Discuss first if shared navigation changes are needed. |
| Flutter config | `pubspec.yaml` | Only add packages/assets when needed. Always run `flutter pub get`. |

## 2. Daily Workflow

Do not code directly on `main`.

1. Update your local `main` branch:

```sh
git checkout main
git pull origin main
```

2. Create a new branch from `main`:

```sh
git checkout -b feature/<name>-<feature>
```

Examples:

```sh
git checkout -b feature/chris-community
git checkout -b feature/phong-friends
```

3. Code inside your assigned feature folder.

4. Add or update tests for your change.

5. Run checks before committing:

```sh
flutter pub get
flutter analyze
flutter test
```

6. Commit using the rules in section 4.

7. Push your branch:

```sh
git push origin feature/<name>-<feature>
```

8. Open a Pull Request into `main`.

## 3. Branch Naming Rules

Branch names should be short, clear, lowercase, and use `-`.

| Work type | Format | Example |
| --- | --- | --- |
| New feature | `feature/<name>-<feature>` | `feature/chloe-login` |
| Bug fix | `fix/<name>-<bug>` | `fix/minh-language-input` |
| Documentation | `docs/<name>-<topic>` | `docs/chris-readme` |
| Refactor | `refactor/<name>-<area>` | `refactor/phong-friends-page` |
| Chore/config | `chore/<name>-<task>` | `chore/mary-assets` |

One branch should contain one clear change. Do not combine unrelated features in one branch.

## 4. Commit Rules

Use Conventional Commits:

```txt
type: short description
```

Common `type` values:

| Type | When to use it | Example |
| --- | --- | --- |
| `feat` | Add a new feature | `feat: add login page layout` |
| `fix` | Fix a bug | `fix: correct language input spacing` |
| `docs` | Update documentation | `docs: update contributing guide` |
| `style` | Formatting or UI styling, no logic change | `style: adjust soundboard card spacing` |
| `refactor` | Restructure code without changing behavior | `refactor: split profile widgets` |
| `test` | Add or update tests | `test: add login smoke test` |
| `chore` | Config, setup, dependency, generated files | `chore: add flutter asset path` |

Commit messages should:

- Be short.
- Keep each commit focused on one meaningful change.

## 5. Pull Requests

Each PR should include:

- Summary: what changed.
- Scope: which files/folders are affected.
- Screenshots: required for UI changes.
- Checks: which commands were run.
- Notes/Risks: unfinished parts or anything reviewers should notice.

Use this PR description template:

```md
## Summary
- 

## Scope
- 

## Screenshots

## Checks
- [ ] flutter pub get
- [ ] flutter analyze
- [ ] flutter test
- [ ] unit/widget tests added or updated

## Notes
- 
```

Do not merge a PR when:

- `flutter analyze` fails.
- `flutter test` fails.
- The PR changes another owner's folder without notice.
- The PR is too large to review clearly.

## 6. Code Review

Reviewers should check:

- The code is inside the correct feature folder.
- The UI matches the Figma design.
- File/class/function names are clear.
- There is no unnecessary repeated hardcoding.
- No unrelated files were changed by mistake.
- The app can still run.

The PR author should:

- Review their own diff before requesting review (most important).
- Reply clearly to review comments.
- Push follow-up commits to the same branch when changes are requested.

## 7. Handling Conflicts

Conflicts usually happen when multiple people edit the same file.

Recommended flow:

```sh
git checkout main
git pull origin main
git checkout <your-branch>
git merge main
```

If Git reports conflicts:

1. Open the conflicted files.
2. Choose the correct code.
3. Remove conflict markers:

```txt
<<<<<<< HEAD
=======
>>>>>>> main
```

4. Run checks again:

```sh
flutter analyze
flutter test
```

5. Commit the conflict resolution:

```sh
git add .
git commit -m "fix: resolve merge conflict"
git push
```

If the conflict is in someone else's folder, ask the owner before choosing the final code.

## 8. Flutter Project Rules

- Put feature code in `lib/src/features/<feature>/`.
- Put unit/widget tests in `test/`.
- Put shared constants/assets in `lib/src/shared/`.
- Put new assets in `assets/`, then declare them in `pubspec.yaml`.
- Do not add a new package unless it is actually needed.
- After editing `pubspec.yaml`, always run:

```sh
flutter pub get
```

## 9. GitHub Rules

Team policy: `main` must be protected on GitHub. All feature work must go through Pull Requests.

Required merge rules for `main`:

- A PR must have at least 3 approvals.
- The `flutter-ci` GitHub Actions check must pass.
- The branch must be up to date with `main`.
- Stale approvals are dismissed when new commits are pushed.
- All the directly changes to main are illegal (Github police can arrest you if you bypass it).

The CI workflow lives here:

```txt
.github/workflows/flutter_ci.yml
```

It runs (so you dont need to run locally):

```sh
flutter pub get
flutter analyze
flutter test
```

## 10. Starter Issues

Create one issue per feature so each owner has a clear scope.


```txt
1 issue -> 1 branch -> 1 pull request
```

In the pull request description, link the issue with a closing keyword:

```md
Closes #1
```

When the PR is merged into `main`, GitHub automatically closes the linked issue.

When creating an issue, add labels from the right sidebar.

Recommended issue labels:

| Issue type | Labels |
| --- | --- |
| Feature screen | `feature`, `ui`, `flutter` |
| Bug fix | `bug`, `flutter` |
| Documentation | `docs` |
| Project setup | `setup`, `flutter` |
| Blocked task | `blocked` |

Issue template:

```md
## Goal

## Owner

## Scope

## Acceptance Criteria
- UI matches Figma.
- Unit/widget tests are added or updated.
- `flutter analyze` passes.
- `flutter test` passes.
- PR includes screenshot if UI changed.
```
