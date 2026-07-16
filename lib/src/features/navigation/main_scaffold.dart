import 'package:flutter/material.dart';

import 'package:fluentish/src/features/friend_location/friend_location_page.dart';
import 'package:fluentish/src/features/guides_review/guides_review_page.dart';
import 'package:fluentish/src/features/home/home_page.dart';
import 'package:fluentish/src/features/language/language_page.dart';
import 'package:fluentish/src/features/profile/profile_page.dart';
import 'package:fluentish/src/features/soundboard/soundboard_page.dart';
import 'package:fluentish/src/shared/shared.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Widget _pageForIndex(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          onNavigateToGuides: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const GuidesPage(),
              ),
            );
          },
        );
      case 1:
        return const LanguagePage();
      case 2:
        return const SoundboardPage();
      case 3:
        return const FriendLocationPage(showBottomNavigation: false);
      case 4:
        return const ProfilePage();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageForIndex(_currentIndex),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
