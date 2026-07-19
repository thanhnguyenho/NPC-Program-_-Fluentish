import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;

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
        ),
      1 => const LanguagePage(),
      2 => const SoundboardPage(),
      3 => const CommunityPage(),
      4 => const ProfilePage(),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageForIndex(_currentIndex),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onItemSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onNavigateToMap,
    this.auth,
    this.friendRepository,
    this.locationRepository,
    this.launchDirections,
  });

  final VoidCallback onNavigateToMap;
  final AuthGateway? auth;
  final FriendDataSource? friendRepository;
  final LocationDataSource? locationRepository;
  final Future<bool> Function(ll.LatLng)? launchDirections;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthGateway _auth;
  late final FriendDataSource _friends;
  late final LocationDataSource _locations;
  late Future<Position> _positionFuture;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? Auth.instance;
    _friends = widget.friendRepository ?? FriendRepository();
    _locations = widget.locationRepository ?? LocationRepository();
    _positionFuture = _locations.currentPosition();
  }

  void _retryPosition() {
    setState(() => _positionFuture = _locations.currentPosition());
  }

  Future<void> _openDirections(MapLocationRecord location) async {
    try {
      final launch = widget.launchDirections ?? launchGoogleMapsDirections;
      final launched = await launch(
        ll.LatLng(location.point.latitude, location.point.longitude),
      );
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

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUserId;
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
                style: AppTextStyles.title.copyWith(fontSize: 34),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Discover local places and meet friends nearby.',
              style: AppTextStyles.body.copyWith(color: AppColors.pineMuted),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionHeader(
              title: 'Nearby Recommendations',
              action: 'See all',
              onTap: widget.onNavigateToMap,
            ),
            const SizedBox(height: AppSpacing.md),
            _NearbyRecommendations(
              positionFuture: _positionFuture,
              locations: _locations,
              onRetryPosition: _retryPosition,
              onOpenDirections: _openDirections,
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

class _NearbyRecommendations extends StatelessWidget {
  const _NearbyRecommendations({
    required this.positionFuture,
    required this.locations,
    required this.onRetryPosition,
    required this.onOpenDirections,
  });

  final Future<Position> positionFuture;
  final LocationDataSource locations;
  final VoidCallback onRetryPosition;
  final ValueChanged<MapLocationRecord> onOpenDirections;

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
            if (locationSnapshot.connectionState == ConnectionState.waiting &&
                mapLocations.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (locationSnapshot.hasError) {
              return const _EmptyCard(
                'Nearby places could not be loaded. Please try again.',
              );
            }
            final recommendations = _nearestByGroup(
              mapLocations,
              position.latitude,
              position.longitude,
            );
            if (recommendations.isEmpty) {
              return const _EmptyCard('No nearby places are available yet.');
            }
            return Column(
              children: [
                for (final recommendation in recommendations)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _RecommendationCard(
                      recommendation: recommendation,
                      onTap: () => onOpenDirections(recommendation.location),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _NearbyRecommendation {
  const _NearbyRecommendation({
    required this.location,
    required this.distanceMeters,
  });

  final MapLocationRecord location;
  final double distanceMeters;
}

List<_NearbyRecommendation> _nearestByGroup(
  List<MapLocationRecord> locations,
  double latitude,
  double longitude,
) {
  const groups = ['food_drink', 'entertainment', 'culture'];
  final recommendations = <_NearbyRecommendation>[];
  for (final group in groups) {
    _NearbyRecommendation? nearest;
    for (final location in locations) {
      if (!location.isActive ||
          !location.hasValidPoint ||
          location.group != group) {
        continue;
      }
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        location.point.latitude,
        location.point.longitude,
      );
      if (nearest == null || distance < nearest.distanceMeters) {
        nearest = _NearbyRecommendation(
          location: location,
          distanceMeters: distance,
        );
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
    final location = recommendation.location;
    return AppCard(
      width: double.infinity,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: mapLocationColor(location.group),
            foregroundColor: Colors.white,
            child: Icon(mapLocationIcon(location.iconKey), size: 25),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: AppTextStyles.title.copyWith(fontSize: 20),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${_distanceLabel(recommendation.distanceMeters)} · '
                  '${location.categoryLabel}',
                  style: AppTextStyles.body.copyWith(
                    color: mapLocationColor(location.group),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _recommendationDescription(location),
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
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: AppTextStyles.title.copyWith(fontSize: 24)),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      child: Text(message, style: AppTextStyles.body),
    );
  }
}

class _HomeAvatar extends StatelessWidget {
  const _HomeAvatar({required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final url = profile.avatarUrl;
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.shell,
      backgroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
      child: url == null || url.isEmpty
          ? Text(profile.displayName.characters.first.toUpperCase())
          : null,
    );
  }
}
