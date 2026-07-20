import 'package:flutter/material.dart';

import 'package:fluentish/src/features/friend_location/friend_location_page.dart';
import 'package:fluentish/src/features/guides_review/guides_review_page.dart';
import 'package:fluentish/src/features/home/home_page.dart';
import 'package:fluentish/src/features/language/language_page.dart';
import 'package:fluentish/src/features/profile/profile_page.dart';
import 'package:fluentish/src/features/soundboard/soundboard_page.dart';
import 'package:fluentish/src/shared/shared.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({
    super.key,
    this.initialIndex = 0,
    this.auth,
    this.friendRepository,
    this.guideRepository,
    this.locationRepository,
  });

  final int initialIndex;
  final AuthGateway? auth;
  final FriendDataSource? friendRepository;
  final GuideDataSource? guideRepository;
  final LocationDataSource? locationRepository;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;
  String? _focusedPlaceId;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Widget _pageForIndex(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          onNavigateToGuides: _openGuides,
          auth: widget.auth,
          friendRepository: widget.friendRepository,
          guideRepository: widget.guideRepository,
        );
      case 1:
        return const LanguagePage();
      case 2:
        return const SoundboardPage();
      case 3:
        return FriendLocationPage(
          key: ValueKey(_focusedPlaceId),
          showBottomNavigation: false,
          initialPlaceId: _focusedPlaceId,
          auth: widget.auth,
          friendRepository: widget.friendRepository,
          guideRepository: widget.guideRepository,
          locationRepository: widget.locationRepository,
        );
      case 4:
        return ProfilePage(
          auth: widget.auth,
          friendRepository: widget.friendRepository,
          guideRepository: widget.guideRepository,
          locationRepository: widget.locationRepository,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _openGuides() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GuidesPage(
          onShowPlaceOnMap: _showPlaceOnMap,
          auth: widget.auth,
          repository: widget.guideRepository,
          locationRepository: widget.locationRepository,
        ),
      ),
    );
  }

  void _showPlaceOnMap(String placeId) {
    if (!mounted) return;
    setState(() {
      _focusedPlaceId = placeId;
      _currentIndex = 3;
    });
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
