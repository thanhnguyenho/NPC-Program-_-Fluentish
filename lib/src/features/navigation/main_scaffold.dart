import 'package:flutter/material.dart';

import 'package:fluentish/src/features/friend_location/friend_location_page.dart';
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
    this.favouriteRepository,
    this.guideRepository,
    this.locationRepository,
  });

  final int initialIndex;
  final AuthGateway? auth;
  final FriendDataSource? friendRepository;
  final FavouriteDataSource? favouriteRepository;
  final GuideDataSource? guideRepository;
  final LocationDataSource? locationRepository;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;
  FavouritePhraseRecord? _selectedFavouritePhrase;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Widget _pageForIndex(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          onNavigateToMap: _openMap,
          onNavigateToLanguage: _openLanguage,
          onNavigateToSoundboard: _openSoundboard,
          onOpenFavouritePhrase: _openFavouritePhrase,
          auth: widget.auth,
          friendRepository: widget.friendRepository,
          favouriteRepository: widget.favouriteRepository,
          guideRepository: widget.guideRepository,
          locationRepository: widget.locationRepository,
        );
      case 1:
        return LanguagePage(
          key: ValueKey(_selectedFavouritePhrase?.id),
          initialSourceText: _selectedFavouritePhrase?.sourceText,
          initialTargetText: _selectedFavouritePhrase?.translatedText,
          initialSourceLang: _selectedFavouritePhrase?.sourceLanguage,
          initialTargetLang: _selectedFavouritePhrase?.targetLanguage,
        );
      case 2:
        return const SoundboardPage();
      case 3:
        return FriendLocationPage(
          showBottomNavigation: false,
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

  void _openLanguage() {
    setState(() {
      _selectedFavouritePhrase = null;
      _currentIndex = 1;
    });
  }

  void _openFavouritePhrase(FavouritePhraseRecord phrase) {
    setState(() {
      _selectedFavouritePhrase = phrase;
      _currentIndex = 1;
    });
  }

  void _openSoundboard() {
    setState(() {
      _currentIndex = 2;
    });
  }

  void _openMap() {
    setState(() {
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
          setState(() {
            if (index == 1) _selectedFavouritePhrase = null;
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
