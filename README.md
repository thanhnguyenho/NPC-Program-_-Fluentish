<div align="center">

<img src="assets/images/fluentish_logo.png" alt="Fluentish logo" width="180" />

# Fluentish

**An all-in-one Flutter language-learning community app.**

<img src="https://readme-typing-svg.demolab.com?font=Inter&weight=800&size=24&duration=2800&pause=800&color=F7B7C8&center=true&vCenter=true&width=760&lines=Navigate+Vietnam+with+confidence;Find+your+Friends+and+view+Community+Guides;Quickly+translate+everyday+phrases" alt="Fluentish typing intro" />

<p>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/iOS%20%7C%20Android%20%7C%20Web-3E4E31?style=for-the-badge" alt="Platforms" />
</p>

<p>
  <img src="https://img.shields.io/badge/Status-Scaffolded-868F54?style=flat-square" alt="Status" />
  <img src="https://img.shields.io/badge/CI-Flutter%20Analyze%20%2B%20Test-02569B?style=flat-square" alt="CI" />
  <img src="https://img.shields.io/badge/Workflow-GitHub%20Flow-3E4E31?style=flat-square" alt="Workflow" />
</p>

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:3E4E31,55:F7B7C8,100:EEDADA&height=5&section=footer" alt="Fluentish light bar" />

</div>

---

## Overview

The app is planned around a language-learning flow with a strong community layer:

| Area | Planned features |
| --- | --- |
| Onboarding | Welcome, login, registration |
| Learning | Language practice, phrase translation, soundboard phrases |
| Home | Main dashboard and learning entry points |
| Community | Community feed, friends, friend location, guides, review |
| Profile | Profile page and additional profile menu options |

## Quick Start

```sh
flutter pub get
flutter run
```

Run checks:

```sh
flutter analyze
flutter test
```

## Tech Stack

| Area | Tool |
| --- | --- |
| App framework | Flutter |
| Language | Dart |
| Platforms | iOS, Android, Web |
| CI | GitHub Actions |
| Tests | Flutter test |

## Feature Ownership

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
| Profile menu options | Chloe | `lib/src/features/profile_menu/` |
| Friends | Phong | `lib/src/features/friends/` |

## Project Structure

```txt
assets/
  images/
    fluentish_logo.png

lib/
  main.dart
  src/
    features/
      welcome/
        welcome_page.dart
      login/
        login_page.dart
      registration/
        registration_page.dart
      language/
        language_page.dart
      soundboard/
        soundboard_page.dart
      profile/
        profile_page.dart
      home/
        home_page.dart
      community/
        community_page.dart
      friend_location/
        friend_location_page.dart
      guides_review/
        guides_review_page.dart
      profile_menu/
        profile_menu_options_page.dart
      friends/
        friends_page.dart
    shared/
      assets/
        app_assets.dart

test/
  widget_test.dart

.github/
  workflows/
    flutter_ci.yml
```

## Links

- [Contributing Guide](CONTRIBUTING.md)
- [Flutter CI Workflow](.github/workflows/flutter_ci.yml)
