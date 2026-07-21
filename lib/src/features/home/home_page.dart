import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../services/settings_controller.dart';
import '../../shared/shared.dart';
import '../community/community_page.dart';
import '../friend_location/friend_location_page.dart';
import '../friend_location/maps_launcher.dart';
import '../friends/friends_page.dart';
import '../language/language_page.dart';
import '../profile/profile_page.dart';
import '../soundboard/soundboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  FavouritePhraseRecord? _selectedFavouritePhrase;

  Widget _pageForIndex(int index) {
    return switch (index) {
      0 => HomeScreen(
          onNavigateToMap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const FriendLocationPage(showBottomNavigation: false),
            ),
          ),
          onNavigateToLanguage: _openLanguage,
          onNavigateToSoundboard: () {
            setState(() {
              _currentIndex = 2;
            });
          },
          onOpenFavouritePhrase: _openFavouritePhrase,
        ),
      1 => LanguagePage(
          key: ValueKey(_selectedFavouritePhrase?.id),
          initialSourceText: _selectedFavouritePhrase?.sourceText,
          initialTargetText: _selectedFavouritePhrase?.translatedText,
          initialSourceLang: _selectedFavouritePhrase?.sourceLanguage,
          initialTargetLang: _selectedFavouritePhrase?.targetLanguage,
        ),
      2 => const SoundboardPage(),
      3 => const CommunityPage(),
      4 => const ProfilePage(),
      _ => const SizedBox.shrink(),
    };
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

  void _selectTab(int index) {
    setState(() {
      if (index == 1) _selectedFavouritePhrase = null;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageForIndex(_currentIndex),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onItemSelected: _selectTab,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onNavigateToMap,
    this.onNavigateToLanguage,
    this.onNavigateToSoundboard,
    this.onOpenFavouritePhrase,
    this.auth,
    this.friendRepository,
    this.favouriteRepository,
    this.locationRepository,
    this.guideRepository,
    this.launchDirections,
    this.phrasePlayback,
    this.soundboardPlayback,
  });

  final VoidCallback onNavigateToMap;
  final VoidCallback? onNavigateToLanguage;
  final VoidCallback? onNavigateToSoundboard;
  final ValueChanged<FavouritePhraseRecord>? onOpenFavouritePhrase;
  final AuthGateway? auth;
  final FriendDataSource? friendRepository;
  final FavouriteDataSource? favouriteRepository;
  final LocationDataSource? locationRepository;
  final GuideDataSource? guideRepository;
  final Future<bool> Function(ll.LatLng)? launchDirections;
  final Future<void> Function(FavouritePhraseRecord)? phrasePlayback;
  final Future<void> Function(FavouriteSoundboardRecord)? soundboardPlayback;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthGateway _auth;
  late final FriendDataSource _friends;
  late final FavouriteDataSource _favourites;
  late final LocationDataSource _locations;
  late final GuideDataSource _guides;
  Future<Position>? _positionFuture;
  AudioPlayer? _audioPlayer;
  FlutterTts? _flutterTts;
  String? _playingFavouriteId;
  final Set<String> _removingFavouriteIds = {};

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? Auth.instance;
    _friends = widget.friendRepository ?? FriendRepository();
    _favourites = widget.favouriteRepository ?? FavouriteRepository();
    _locations = widget.locationRepository ?? LocationRepository();
    _guides = widget.guideRepository ?? GuideRepository();
    if (SettingsController.instance.nearbyRecommendation) {
      _positionFuture = _locations.currentPosition();
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _flutterTts?.stop();
    super.dispose();
  }

  void _retryPosition() {
    setState(() {
      _positionFuture = _locations.currentPosition();
    });
  }

  Future<void> _openDirections(ll.LatLng destination) async {
    try {
      final launch = widget.launchDirections ?? launchGoogleMapsDirections;
      final launched = await launch(destination);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps.')),
        );
      }
    }
  }

  AudioPlayer _soundPlayer() {
    final existing = _audioPlayer;
    if (existing != null) return existing;
    final player = AudioPlayer();
    player.onPlayerComplete.listen((_) => _clearPlayingFavourite());
    _audioPlayer = player;
    return player;
  }

  FlutterTts _phraseTts() {
    final existing = _flutterTts;
    if (existing != null) return existing;
    final tts = FlutterTts();
    tts.setCompletionHandler(_clearPlayingFavourite);
    tts.setCancelHandler(_clearPlayingFavourite);
    tts.setErrorHandler((_) => _clearPlayingFavourite());
    _flutterTts = tts;
    return tts;
  }

  void _clearPlayingFavourite() {
    if (mounted && _playingFavouriteId != null) {
      setState(() => _playingFavouriteId = null);
    }
  }

  Future<void> _playPhrase(FavouritePhraseRecord phrase) async {
    final override = widget.phrasePlayback;
    final playingId = 'phrase:${phrase.id}';
    if (override != null) {
      setState(() => _playingFavouriteId = playingId);
      try {
        await override(phrase);
      } catch (_) {
        _showPlaybackError();
      } finally {
        _clearPlayingFavourite();
      }
      return;
    }
    await _speakText(
      playingId: playingId,
      text: phrase.playbackText,
      language: phrase.playbackLanguage,
    );
  }

  Future<void> _playSoundboard(FavouriteSoundboardRecord bite) async {
    final override = widget.soundboardPlayback;
    final playingId = 'soundboard:${bite.id}';
    if (override != null) {
      setState(() => _playingFavouriteId = playingId);
      try {
        await override(bite);
      } catch (_) {
        _showPlaybackError();
      } finally {
        _clearPlayingFavourite();
      }
      return;
    }

    final audioPath = bite.playbackAudio;
    if (audioPath.isEmpty) {
      await _speakText(
        playingId: playingId,
        text: bite.prefersEnglish ? bite.english : bite.vietnamese,
        language: bite.preferredLanguage,
      );
      return;
    }

    try {
      await _flutterTts?.stop();
      final player = _soundPlayer();
      await player.stop();
      if (mounted) setState(() => _playingFavouriteId = playingId);
      await player.play(AssetSource(audioPath));
    } catch (_) {
      _clearPlayingFavourite();
      _showPlaybackError();
    }
  }

  Future<void> _removePhrase(FavouritePhraseRecord phrase) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    final operationId = 'phrase:${phrase.id}';
    if (_removingFavouriteIds.contains(operationId)) return;
    setState(() => _removingFavouriteIds.add(operationId));
    try {
      await _favourites.removeFavouritePhrase(uid, phrase.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phrase removed from favourites.')),
        );
      }
    } catch (_) {
      _showRemoveError();
    } finally {
      if (mounted) {
        setState(() => _removingFavouriteIds.remove(operationId));
      }
    }
  }

  Future<void> _removeSoundboardBite(
    FavouriteSoundboardRecord bite,
  ) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    final operationId = 'soundboard:${bite.id}';
    if (_removingFavouriteIds.contains(operationId)) return;
    setState(() => _removingFavouriteIds.add(operationId));
    try {
      await _favourites.removeFavouriteSoundboardBite(uid, bite.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Soundboard bite removed from favourites.'),
          ),
        );
      }
    } catch (_) {
      _showRemoveError();
    } finally {
      if (mounted) {
        setState(() => _removingFavouriteIds.remove(operationId));
      }
    }
  }

  Future<void> _speakText({
    required String playingId,
    required String text,
    required String language,
  }) async {
    if (text.trim().isEmpty) return;
    try {
      await _audioPlayer?.stop();
      final tts = _phraseTts();
      await tts.stop();
      await tts.setLanguage(_ttsLocale(language));
      await tts.setSpeechRate(0.45);
      await tts.setVolume(1);
      await tts.awaitSpeakCompletion(true);
      if (mounted) setState(() => _playingFavouriteId = playingId);
      final result = await tts.speak(text);
      if (result != 1) {
        _clearPlayingFavourite();
        _showPlaybackError();
      }
    } catch (_) {
      _clearPlayingFavourite();
      _showPlaybackError();
    }
  }

  String _ttsLocale(String language) {
    final normalized = language.toLowerCase();
    if (normalized.startsWith('vi') || normalized.contains('vietnam')) {
      return 'vi-VN';
    }
    return 'en-AU';
  }

  void _showPlaybackError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not play this favourite.')),
    );
  }

  void _showRemoveError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not remove this favourite.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUserId;
    final colors = context.fluentishColors;
    final showNearby = SettingsController.instance.nearbyRecommendation;
    if (showNearby) {
      _positionFuture ??= _locations.currentPosition();
    }
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.bottomNavHeight + AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<PublicProfile?>(
              stream: _auth.watchCurrentProfile(),
              builder: (context, snapshot) => Text(
                'Welcome Back, ${snapshot.data?.displayName ?? 'Fluentish user'}!',
                style: AppTextStyles.title.copyWith(
                  color: colors.textPrimary,
                  fontSize: 34,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Discover local places and meet friends nearby.',
              style: AppTextStyles.body.copyWith(color: AppColors.pineMuted),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (showNearby) ...[
              _SectionHeader(
                title: 'Nearby Recommendations',
                action: 'See all',
                onTap: widget.onNavigateToMap,
              ),
              const SizedBox(height: AppSpacing.md),
              _NearbyRecommendations(
                positionFuture: _positionFuture!,
                locations: _locations,
                guides: _guides,
                onRetryPosition: _retryPosition,
                onOpenDirections: _openDirections,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            _FavouritePhrasesSection(
              uid: uid,
              favourites: _favourites,
              playingId: _playingFavouriteId,
              removingIds: _removingFavouriteIds,
              onOpen: widget.onOpenFavouritePhrase ??
                  (_) => widget.onNavigateToLanguage?.call(),
              onPlay: _playPhrase,
              onRemove: _removePhrase,
              onBrowse: widget.onNavigateToLanguage,
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionHeader(
              title: 'Favourite Soundboard Bites',
              action: 'Browse',
              onTap: widget.onNavigateToSoundboard ?? () {},
            ),
            const SizedBox(height: AppSpacing.md),
            _FavouriteSoundboardSection(
              uid: uid,
              favourites: _favourites,
              playingId: _playingFavouriteId,
              removingIds: _removingFavouriteIds,
              onPlay: _playSoundboard,
              onRemove: _removeSoundboardBite,
              onBrowse: widget.onNavigateToSoundboard,
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionHeader(
              title: 'Active Friends',
              action: 'Manage',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FriendsPage(
                    auth: widget.auth,
                    friendRepository: widget.friendRepository,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (uid == null)
              const _EmptyCard('Sign in to see your friends.')
            else
              StreamBuilder<List<PublicProfile>>(
                stream: _friends.watchFriends(uid),
                builder: (context, snapshot) {
                  final active = (snapshot.data ?? const <PublicProfile>[])
                      .where((friend) => friend.isOnline)
                      .toList();
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      active.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (active.isEmpty) {
                    return const _EmptyCard(
                      'No active friends. Add friends from your profile.',
                    );
                  }
                  return AppCard(
                    width: double.infinity,
                    child: Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        for (final friend in active)
                          SizedBox(
                            width: 72,
                            child: Column(
                              children: [
                                _HomeAvatar(profile: friend),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  friend.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      AppTextStyles.body.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _FavouritePhrasesSection extends StatelessWidget {
  const _FavouritePhrasesSection({
    required this.uid,
    required this.favourites,
    required this.playingId,
    required this.removingIds,
    required this.onOpen,
    required this.onPlay,
    required this.onRemove,
    required this.onBrowse,
  });

  final String? uid;
  final FavouriteDataSource favourites;
  final String? playingId;
  final Set<String> removingIds;
  final ValueChanged<FavouritePhraseRecord> onOpen;
  final ValueChanged<FavouritePhraseRecord> onPlay;
  final ValueChanged<FavouritePhraseRecord> onRemove;
  final VoidCallback? onBrowse;

  void _showAllPhrasesSheet(
      BuildContext context, List<FavouritePhraseRecord> phrases) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF8EDED),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = phrases
                .where((p) =>
                    p.sourceText
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    p.translatedText
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    p.id.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '⭐ All Favourite Phrases (${phrases.length})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E4E31),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText:
                          'Search your ${phrases.length} saved phrases...',
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF3E4E31)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    onChanged: (val) => setModalState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'No matching phrases found.',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final phrase = filtered[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _FavouritePhraseCard(
                                  phrase: phrase,
                                  isPlaying: playingId == 'phrase:${phrase.id}',
                                  isRemoving: removingIds
                                      .contains('phrase:${phrase.id}'),
                                  onOpen: () {
                                    Navigator.pop(context);
                                    onOpen(phrase);
                                  },
                                  onPlay: () => onPlay(phrase),
                                  onRemove: () => onRemove(phrase),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = uid;
    if (userId == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Favourite Phrases'),
          SizedBox(height: AppSpacing.md),
          _EmptyCard('Sign in to see your favourite phrases.'),
        ],
      );
    }
    return StreamBuilder<List<FavouritePhraseRecord>>(
      stream: favourites.watchFavouritePhrases(userId),
      builder: (context, snapshot) {
        final phrases = snapshot.data ?? const <FavouritePhraseRecord>[];
        if (snapshot.connectionState == ConnectionState.waiting &&
            phrases.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: 'Favourite Phrases'),
              SizedBox(height: AppSpacing.md),
              Center(child: CircularProgressIndicator()),
            ],
          );
        }
        if (snapshot.hasError) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: 'Favourite Phrases'),
              SizedBox(height: AppSpacing.md),
              _EmptyCard('Favourite phrases could not be loaded.'),
            ],
          );
        }
        if (phrases.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(title: 'Favourite Phrases'),
              const SizedBox(height: AppSpacing.md),
              _FavouriteEmptyCard(
                icon: Icons.translate,
                message: 'No favourite phrases yet. Add phrases from the '
                    'Language screen to see them here.',
                action: 'Browse phrases',
                onTap: onBrowse,
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Favourite Phrases',
              action: 'See All (${phrases.length})',
              onTap: () => _showAllPhrasesSheet(context, phrases),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final phrase in phrases.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _FavouritePhraseCard(
                  phrase: phrase,
                  isPlaying: playingId == 'phrase:${phrase.id}',
                  isRemoving: removingIds.contains('phrase:${phrase.id}'),
                  onOpen: () => onOpen(phrase),
                  onPlay: () => onPlay(phrase),
                  onRemove: () => onRemove(phrase),
                ),
              ),
            if (phrases.length > 5)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  width: double.infinity,
                  onTap: () => _showAllPhrasesSheet(context, phrases),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.blush,
                        foregroundColor: AppColors.pine,
                        child: Icon(Icons.add,
                            size: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'View ${phrases.length - 5} older favourite phrases...',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.pine,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FavouriteSoundboardSection extends StatelessWidget {
  const _FavouriteSoundboardSection({
    required this.uid,
    required this.favourites,
    required this.playingId,
    required this.removingIds,
    required this.onPlay,
    required this.onRemove,
    required this.onBrowse,
  });

  final String? uid;
  final FavouriteDataSource favourites;
  final String? playingId;
  final Set<String> removingIds;
  final ValueChanged<FavouriteSoundboardRecord> onPlay;
  final ValueChanged<FavouriteSoundboardRecord> onRemove;
  final VoidCallback? onBrowse;

  @override
  Widget build(BuildContext context) {
    final userId = uid;
    if (userId == null) {
      return const _EmptyCard(
        'Sign in to see your favourite soundboard bites.',
      );
    }
    return StreamBuilder<List<FavouriteSoundboardRecord>>(
      stream: favourites.watchFavouriteSoundboardBites(userId),
      builder: (context, snapshot) {
        final bites = snapshot.data ?? const <FavouriteSoundboardRecord>[];
        if (snapshot.connectionState == ConnectionState.waiting &&
            bites.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const _EmptyCard(
            'Favourite soundboard bites could not be loaded.',
          );
        }
        if (bites.isEmpty) {
          return _FavouriteEmptyCard(
            icon: Icons.volume_up_outlined,
            message: 'No favourite soundboard bites yet. Add sounds from '
                'the Soundboard screen to see them here.',
            action: 'Open soundboard',
            onTap: onBrowse,
          );
        }
        return Column(
          children: [
            for (final bite in bites.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _FavouriteSoundboardCard(
                  bite: bite,
                  isPlaying: playingId == 'soundboard:${bite.id}',
                  isRemoving: removingIds.contains('soundboard:${bite.id}'),
                  onPlay: () => onPlay(bite),
                  onRemove: () => onRemove(bite),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FavouritePhraseCard extends StatelessWidget {
  const _FavouritePhraseCard({
    required this.phrase,
    required this.isPlaying,
    required this.isRemoving,
    required this.onOpen,
    required this.onPlay,
    required this.onRemove,
  });

  final FavouritePhraseRecord phrase;
  final bool isPlaying;
  final bool isRemoving;
  final VoidCallback onOpen;
  final VoidCallback onPlay;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      onTap: onOpen,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.blush,
            foregroundColor: AppColors.pine,
            child: Icon(Icons.translate),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phrase.sourceText,
                  style: AppTextStyles.title.copyWith(fontSize: 19),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(phrase.translatedText, style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${phrase.sourceLanguage} → ${phrase.targetLanguage}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.pineMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: ValueKey('play-phrase-${phrase.id}'),
            tooltip: 'Play phrase',
            onPressed: onPlay,
            icon: Icon(isPlaying ? Icons.graphic_eq : Icons.volume_up),
          ),
          IconButton(
            key: ValueKey('remove-phrase-${phrase.id}'),
            tooltip: 'Remove from favourites',
            onPressed: isRemoving ? null : onRemove,
            icon: isRemoving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.star, color: Colors.amber),
          ),
        ],
      ),
    );
  }
}

class _FavouriteSoundboardCard extends StatelessWidget {
  const _FavouriteSoundboardCard({
    required this.bite,
    required this.isPlaying,
    required this.isRemoving,
    required this.onPlay,
    required this.onRemove,
  });

  final FavouriteSoundboardRecord bite;
  final bool isPlaying;
  final bool isRemoving;
  final VoidCallback onPlay;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final primaryText = bite.prefersEnglish ? bite.english : bite.vietnamese;

    final secondaryText = bite.prefersEnglish ? bite.vietnamese : bite.english;

    final primaryLanguage = bite.prefersEnglish ? 'English' : 'Vietnamese';

    return AppCard(
      width: double.infinity,
      onTap: onPlay,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.blush,
            foregroundColor: AppColors.pine,
            child: Icon(Icons.volume_up_outlined),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primaryText,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  secondaryText,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${bite.category} · $primaryLanguage',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.pineMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: ValueKey('play-soundboard-${bite.id}'),
            tooltip: 'Play $primaryLanguage sound',
            onPressed: onPlay,
            icon: Icon(
              isPlaying ? Icons.graphic_eq : Icons.volume_up,
            ),
          ),
          IconButton(
            key: ValueKey('remove-soundboard-${bite.id}'),
            tooltip: 'Remove from favourites',
            onPressed: isRemoving ? null : onRemove,
            icon: isRemoving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
          ),
        ],
      ),
    );
  }
}

class _FavouriteEmptyCard extends StatelessWidget {
  const _FavouriteEmptyCard({
    required this.icon,
    required this.message,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String message;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      child: Row(
        children: [
          Icon(icon, color: AppColors.pine),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(message, style: AppTextStyles.body)),
          if (onTap != null) TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }
}

class _NearbyRecommendations extends StatelessWidget {
  const _NearbyRecommendations({
    required this.positionFuture,
    required this.locations,
    required this.guides,
    required this.onRetryPosition,
    required this.onOpenDirections,
  });

  final Future<Position> positionFuture;
  final LocationDataSource locations;
  final GuideDataSource guides;
  final VoidCallback onRetryPosition;
  final ValueChanged<ll.LatLng> onOpenDirections;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: positionFuture,
      builder: (context, positionSnapshot) {
        if (positionSnapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final position = positionSnapshot.data;
        if (positionSnapshot.hasError || position == null) {
          return _RecommendationErrorCard(
            message: 'Location access is needed to find nearby places.',
            onRetry: onRetryPosition,
          );
        }
        return StreamBuilder<List<MapLocationRecord>>(
          stream: locations.watchMapLocations(),
          builder: (context, locationSnapshot) {
            final mapLocations =
                locationSnapshot.data ?? const <MapLocationRecord>[];
            return StreamBuilder<List<PlaceRecord>>(
              stream: guides.watchPublishedPlaces(),
              builder: (context, placeSnapshot) {
                final places = placeSnapshot.data ?? const <PlaceRecord>[];
                final waiting = locationSnapshot.connectionState ==
                        ConnectionState.waiting ||
                    placeSnapshot.connectionState == ConnectionState.waiting;
                if (waiting && mapLocations.isEmpty && places.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final recommendations = _nearestByGroup(
                  mapLocations,
                  places,
                  position.latitude,
                  position.longitude,
                );
                if (recommendations.isEmpty &&
                    locationSnapshot.hasError &&
                    placeSnapshot.hasError) {
                  return const _EmptyCard(
                    'Nearby places could not be loaded. Please try again.',
                  );
                }
                if (recommendations.isEmpty) {
                  return const _EmptyCard(
                    'No nearby places are available yet.',
                  );
                }
                return Column(
                  children: [
                    for (final recommendation in recommendations)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _RecommendationCard(
                          recommendation: recommendation,
                          onTap: () => onOpenDirections(recommendation.point),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _NearbyRecommendation {
  const _NearbyRecommendation({
    required this.name,
    required this.categoryLabel,
    required this.description,
    required this.group,
    required this.iconKey,
    required this.point,
    required this.distanceMeters,
  });

  final String name;
  final String categoryLabel;
  final String description;
  final String group;
  final String iconKey;
  final ll.LatLng point;
  final double distanceMeters;
}

List<_NearbyRecommendation> _nearestByGroup(
  List<MapLocationRecord> locations,
  List<PlaceRecord> places,
  double latitude,
  double longitude,
) {
  const groups = ['food_drink', 'entertainment', 'culture'];
  final candidates = <_NearbyRecommendation>[];
  for (final location in locations) {
    if (!location.isActive || !location.hasValidPoint) continue;
    final distance = Geolocator.distanceBetween(
      latitude,
      longitude,
      location.point.latitude,
      location.point.longitude,
    );
    candidates.add(
      _NearbyRecommendation(
        name: location.name,
        categoryLabel: location.categoryLabel,
        description: _recommendationDescription(location),
        group: location.group,
        iconKey: location.iconKey,
        point: ll.LatLng(
          location.point.latitude,
          location.point.longitude,
        ),
        distanceMeters: distance,
      ),
    );
  }
  for (final place in places) {
    if (place.point.latitude == 0 && place.point.longitude == 0) continue;
    final group = switch (place.category) {
      'food' || 'cafe' => 'food_drink',
      'entertainment' => 'entertainment',
      _ => 'culture',
    };
    final distance = Geolocator.distanceBetween(
      latitude,
      longitude,
      place.point.latitude,
      place.point.longitude,
    );
    candidates.add(
      _NearbyRecommendation(
        name: place.name,
        categoryLabel: switch (place.category) {
          'food' => 'Food guide',
          'cafe' => 'Cafe guide',
          'route' => 'Walking route',
          _ => 'Local guide',
        },
        description: place.address.isEmpty
            ? '${place.guideCount} published guide(s).'
            : place.address,
        group: group,
        iconKey: place.category,
        point: ll.LatLng(place.point.latitude, place.point.longitude),
        distanceMeters: distance,
      ),
    );
  }
  final recommendations = <_NearbyRecommendation>[];
  for (final group in groups) {
    _NearbyRecommendation? nearest;
    for (final candidate in candidates) {
      if (candidate.group != group) continue;
      if (nearest == null ||
          candidate.distanceMeters < nearest.distanceMeters) {
        nearest = candidate;
      }
    }
    if (nearest != null) recommendations.add(nearest);
  }
  return recommendations;
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.recommendation,
    required this.onTap,
  });

  final _NearbyRecommendation recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: mapLocationColor(recommendation.group),
            foregroundColor: Colors.white,
            child: Icon(mapLocationIcon(recommendation.iconKey), size: 25),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.name,
                  style: AppTextStyles.title.copyWith(fontSize: 20),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${_distanceLabel(recommendation.distanceMeters)} · '
                  '${recommendation.categoryLabel}',
                  style: AppTextStyles.body.copyWith(
                    color: mapLocationColor(recommendation.group),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  recommendation.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.directions, color: AppColors.pine),
        ],
      ),
    );
  }
}

class _RecommendationErrorCard extends StatelessWidget {
  const _RecommendationErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(child: Text(message, style: AppTextStyles.body)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

String _distanceLabel(double meters) {
  if (meters < 1000) return '${meters.round()} m away';
  return '${(meters / 1000).toStringAsFixed(1)} km away';
}

String _recommendationDescription(MapLocationRecord location) {
  if (location.shortDescription.trim().isNotEmpty) {
    return location.shortDescription.trim();
  }
  final type = location.sourceCategory.isNotEmpty
      ? location.sourceCategory
      : location.categoryLabel;
  final area =
      location.neighborhood.isNotEmpty ? location.neighborhood : location.city;
  final locationSentence = area.isEmpty ? '$type.' : '$type in $area.';
  final rating = location.rating;
  if (rating == null) return locationSentence;
  final reviewText = location.reviewCount == 1
      ? '1 review'
      : '${location.reviewCount} reviews';
  return '$locationSentence Rated ${rating.toStringAsFixed(1)} from '
      '$reviewText.';
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.action,
    this.onTap,
  });

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.title.copyWith(
              color: colors.textPrimary,
              fontSize: 24,
            ),
          ),
        ),
        if (action != null && onTap != null)
          TextButton(onPressed: onTap, child: Text(action!)),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return AppCard(
      width: double.infinity,
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(color: colors.textSecondary),
      ),
    );
  }
}

class _HomeAvatar extends StatelessWidget {
  const _HomeAvatar({required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return AvatarImage(
      radius: 28,
      base64Data: profile.avatarBase64,
      url: profile.avatarUrl,
      backgroundColor: colors.surfaceStrong,
      fallbackText: profile.displayName,
    );
  }
}
