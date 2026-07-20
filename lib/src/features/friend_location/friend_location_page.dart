import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../shared/shared.dart';
import '../guides_review/guides_review_page.dart';
import 'maps_launcher.dart';

enum MapContentFilter { all, friends, guides }

class FriendLocationPage extends StatefulWidget {
  const FriendLocationPage({
    super.key,
    this.showBottomNavigation = true,
    this.initialPlaceId,
    this.auth,
    this.friendRepository,
    this.guideRepository,
    this.locationRepository,
  });

  final bool showBottomNavigation;
  final String? initialPlaceId;
  final AuthGateway? auth;
  final FriendDataSource? friendRepository;
  final GuideDataSource? guideRepository;
  final LocationDataSource? locationRepository;

  @override
  State<FriendLocationPage> createState() => _FriendLocationPageState();
}

class _FriendLocationPageState extends State<FriendLocationPage>
    with WidgetsBindingObserver {
  static const _districtOne = ll.LatLng(10.7769, 106.7009);

  final _mapController = fm.MapController();
  late final AuthGateway _auth;
  late final FriendDataSource _friends;
  late final GuideDataSource _guides;
  late final LocationDataSource _locations;

  StreamSubscription<bool>? _sharingSubscription;
  LocationSharingSession? _sharingSession;
  bool _sharingStarting = false;
  Position? _myPosition;
  MapContentFilter _filter = MapContentFilter.all;
  bool _sharingEnabled = false;
  bool _sharingBusy = false;
  String? _message;
  List<GuideStop> _activeStops = const [];
  GuideRecord? _activeRoute;
  bool _focusedInitialPlace = false;
  fm.LatLngBounds? _visibleBounds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auth = widget.auth ?? Auth.instance;
    _friends = widget.friendRepository ?? FriendRepository();
    _guides = widget.guideRepository ?? GuideRepository();
    _locations = widget.locationRepository ?? LocationRepository();
    final uid = _auth.currentUserId;
    if (uid != null) {
      _sharingSubscription = _locations.watchSharing(uid).listen((enabled) {
        if (!mounted) return;
        setState(() => _sharingEnabled = enabled);
        enabled ? _startSharing() : _stopSharing();
      });
    }
    _loadCurrentPosition(moveMap: false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _sharingEnabled) {
      _startSharing();
    } else if (state != AppLifecycleState.resumed) {
      _stopSharing();
    }
  }

  Future<void> _startSharing() async {
    final uid = _auth.currentUserId;
    if (uid == null || _sharingSession != null || _sharingStarting) return;
    _sharingStarting = true;
    try {
      final session = await _locations.startForegroundSharing(uid);
      final lifecycleState = WidgetsBinding.instance.lifecycleState;
      if (!mounted ||
          !_sharingEnabled ||
          (lifecycleState != null &&
              lifecycleState != AppLifecycleState.resumed)) {
        await session.dispose();
        return;
      }
      _sharingSession = session;
      await _loadCurrentPosition(moveMap: false);
    } catch (error) {
      if (mounted) {
        setState(() => _message = _cleanError(error));
      }
    } finally {
      _sharingStarting = false;
    }
  }

  Future<void> _stopSharing() async {
    final session = _sharingSession;
    _sharingSession = null;
    await session?.dispose();
  }

  Future<void> _toggleSharing(bool enabled) async {
    final uid = _auth.currentUserId;
    if (uid == null || _sharingBusy) return;
    setState(() => _sharingBusy = true);
    try {
      await _locations.setSharing(uid, enabled);
    } catch (error) {
      if (mounted) setState(() => _message = _cleanError(error));
    } finally {
      if (mounted) setState(() => _sharingBusy = false);
    }
  }

  Future<void> _loadCurrentPosition({required bool moveMap}) async {
    try {
      final position = await _locations.currentPosition();
      if (!mounted) return;
      setState(() {
        _myPosition = position;
        _message = null;
      });
      if (moveMap) {
        _mapController.move(
          ll.LatLng(position.latitude, position.longitude),
          15.5,
        );
      }
    } catch (error) {
      if (mounted) setState(() => _message = _cleanError(error));
    }
  }

  String _cleanError(Object error) =>
      error.toString().replaceFirst('Bad state: ', '');

  double? _distanceTo(double latitude, double longitude) {
    final position = _myPosition;
    if (position == null) return null;
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      latitude,
      longitude,
    );
  }

  String _distanceLabel(double? meters) {
    if (meters == null) return 'Distance unavailable';
    if (meters < 1000) return '${meters.round()} m away';
    return '${(meters / 1000).toStringAsFixed(1)} km away';
  }

  Future<void> _showFriend(FriendMapEntry entry) async {
    final location = entry.location;
    final point = ll.LatLng(location.point.latitude, location.point.longitude);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.shell,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ProfileAvatar(profile: entry.profile, radius: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.profile.displayName,
                        style: AppTextStyles.title.copyWith(fontSize: 23),
                      ),
                      Text(
                        _distanceLabel(_distanceTo(
                          point.latitude,
                          point.longitude,
                        )),
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Route',
              icon: Icons.directions_walk,
              backgroundColor: AppColors.pine,
              foregroundColor: Colors.white,
              onPressed: () => launchGoogleMapsDirections(point),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPlace(PlaceRecord place) async {
    final guides = await _guides.guidesForPlace(place.id);
    if (!mounted) return;
    final point = ll.LatLng(place.point.latitude, place.point.longitude);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.shell,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.82,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name,
                    style: AppTextStyles.title.copyWith(fontSize: 27)),
                const SizedBox(height: AppSpacing.xs),
                Text(place.address, style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${_distanceLabel(_distanceTo(point.latitude, point.longitude))} · ${guides.length} guide${guides.length == 1 ? '' : 's'}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.pineMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (guides.isEmpty)
                  Text('No published guides yet.', style: AppTextStyles.body)
                else
                  for (final guide in guides)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: AppCard(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guide.title,
                              style: AppTextStyles.title.copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(guide.summary, style: AppTextStyles.body),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                FilledButton.tonal(
                                  onPressed: () {
                                    Navigator.pop(sheetContext);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => GuidesPage(
                                          initialGuideId: guide.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Read Guide'),
                                ),
                                if (guide.type == GuideType.route)
                                  FilledButton.tonal(
                                    onPressed: () async {
                                      Navigator.pop(sheetContext);
                                      await _activateRoute(guide);
                                    },
                                    child: const Text('View Route'),
                                  ),
                                FilledButton.tonal(
                                  onPressed: () => _saveGuide(guide.id),
                                  child: const Text('Save'),
                                ),
                                FilledButton.tonal(
                                  onPressed: () =>
                                      launchGoogleMapsDirections(point),
                                  child: const Text('Route'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveGuide(String guideId) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    await _guides.setSaved(uid: uid, guideId: guideId, saved: true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guide saved.')),
      );
    }
  }

  Future<void> _activateRoute(GuideRecord guide) async {
    final stops = await _guides.loadStops(guide.id);
    if (!mounted || stops.isEmpty) return;
    setState(() {
      _activeRoute = guide;
      _activeStops = stops;
    });
    _mapController.move(
      ll.LatLng(stops.first.point.latitude, stops.first.point.longitude),
      15,
    );
  }

  void _focusInitialPlace(List<PlaceRecord> places) {
    if (_focusedInitialPlace || widget.initialPlaceId == null) return;
    for (final place in places) {
      if (place.id == widget.initialPlaceId) {
        _focusedInitialPlace = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(
            ll.LatLng(place.point.latitude, place.point.longitude),
            16,
          );
          _showPlace(place);
        });
        return;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sharingSubscription?.cancel();
    unawaited(_stopSharing());
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUserId;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in to view friends and guides.')),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.blush,
      bottomNavigationBar: widget.showBottomNavigation
          ? const AppBottomNav(currentIndex: 3, onItemSelected: _ignoreNavTap)
          : null,
      body: StreamBuilder<List<PlaceRecord>>(
        stream: _guides.watchPublishedPlaces(),
        builder: (context, placeSnapshot) {
          final places = placeSnapshot.data ?? const <PlaceRecord>[];
          _focusInitialPlace(places);
          return StreamBuilder<List<FriendMapEntry>>(
            stream: _friends.watchVisibleFriendLocations(uid),
            builder: (context, friendSnapshot) {
              final friends = friendSnapshot.data ?? const <FriendMapEntry>[];
              final showFriends = _filter != MapContentFilter.guides;
              final showGuides = _filter != MapContentFilter.friends;
              final visibleFriends = friends.where((friend) {
                final point = friend.location.point;
                return _visibleBounds?.contains(
                      ll.LatLng(point.latitude, point.longitude),
                    ) ??
                    true;
              }).length;
              final visibleGuides = places
                  .where((place) =>
                      _visibleBounds?.contains(ll.LatLng(
                        place.point.latitude,
                        place.point.longitude,
                      )) ??
                      true)
                  .fold<int>(0, (count, place) => count + place.guideCount);
              return Stack(
                children: [
                  fm.FlutterMap(
                    mapController: _mapController,
                    options: fm.MapOptions(
                      initialCenter: _districtOne,
                      initialZoom: 14.4,
                      minZoom: 11,
                      maxZoom: 19,
                      onPositionChanged: (camera, _) {
                        if (!mounted) return;
                        setState(() => _visibleBounds = camera.visibleBounds);
                      },
                    ),
                    children: [
                      fm.TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.fluentish.app',
                      ),
                      if (_activeStops.length > 1)
                        fm.PolylineLayer(
                          polylines: [
                            fm.Polyline(
                              points: _activeStops
                                  .map((stop) => ll.LatLng(
                                        stop.point.latitude,
                                        stop.point.longitude,
                                      ))
                                  .toList(),
                              color: Colors.blue,
                              strokeWidth: 5,
                            ),
                          ],
                        ),
                      fm.MarkerLayer(
                        markers: [
                          if (_myPosition != null)
                            fm.Marker(
                              point: ll.LatLng(
                                _myPosition!.latitude,
                                _myPosition!.longitude,
                              ),
                              width: 52,
                              height: 52,
                              child: const _CurrentUserMarker(),
                            ),
                          if (showFriends)
                            for (final friend in friends)
                              fm.Marker(
                                point: ll.LatLng(
                                  friend.location.point.latitude,
                                  friend.location.point.longitude,
                                ),
                                width: 72,
                                height: 72,
                                child: GestureDetector(
                                  onTap: () => _showFriend(friend),
                                  child: _FriendMarker(entry: friend),
                                ),
                              ),
                          if (showGuides)
                            for (final place in places)
                              fm.Marker(
                                point: ll.LatLng(
                                  place.point.latitude,
                                  place.point.longitude,
                                ),
                                width: 72,
                                height: 72,
                                child: GestureDetector(
                                  onTap: () => _showPlace(place),
                                  child: _GuideMarker(place: place),
                                ),
                              ),
                          for (final stop in _activeStops)
                            fm.Marker(
                              point: ll.LatLng(
                                stop.point.latitude,
                                stop.point.longitude,
                              ),
                              width: 40,
                              height: 40,
                              child: _RouteStopMarker(stop: stop),
                            ),
                        ],
                      ),
                      const fm.RichAttributionWidget(
                        attributions: [
                          fm.TextSourceAttribution(
                              'OpenStreetMap contributors'),
                        ],
                      ),
                    ],
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          _MapHeader(
                            friendCount: visibleFriends,
                            guideCount: visibleGuides,
                            sharingBusy: _sharingBusy,
                            sharingEnabled: _sharingEnabled,
                            onSharingChanged: _toggleSharing,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _MapFilters(
                            selected: _filter,
                            onSelected: (filter) =>
                                setState(() => _filter = filter),
                          ),
                          if (_activeRoute != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            _ActiveRouteBanner(
                              guide: _activeRoute!,
                              onClose: () => setState(() {
                                _activeRoute = null;
                                _activeStops = const [];
                              }),
                            ),
                          ],
                          if (_message != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Material(
                              color: AppColors.shell,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                child: Text(_message!),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton.small(
                              heroTag: 'current-location',
                              backgroundColor: AppColors.pine,
                              foregroundColor: Colors.white,
                              onPressed: () =>
                                  _loadCurrentPosition(moveMap: true),
                              child: const Icon(Icons.my_location),
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
        },
      ),
    );
  }

  static void _ignoreNavTap(int index) {}
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.friendCount,
    required this.guideCount,
    required this.sharingBusy,
    required this.sharingEnabled,
    required this.onSharingChanged,
  });

  final int friendCount;
  final int guideCount;
  final bool sharingBusy;
  final bool sharingEnabled;
  final ValueChanged<bool> onSharingChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.shell.withValues(alpha: 0.94),
      elevation: 4,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            const Icon(Icons.map_outlined, color: AppColors.pine),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Friends & Guides',
                    style: AppTextStyles.title.copyWith(fontSize: 18),
                  ),
                  Text(
                    '$friendCount friends · $guideCount guides',
                    style: AppTextStyles.body.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Text('Share', style: AppTextStyles.body.copyWith(fontSize: 11)),
            Switch.adaptive(
              value: sharingEnabled,
              onChanged: sharingBusy ? null : onSharingChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapFilters extends StatelessWidget {
  const _MapFilters({required this.selected, required this.onSelected});

  final MapContentFilter selected;
  final ValueChanged<MapContentFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final filter in MapContentFilter.values)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: ChoiceChip(
              label: Text(switch (filter) {
                MapContentFilter.all => 'All',
                MapContentFilter.friends => 'Friends',
                MapContentFilter.guides => 'Guides',
              }),
              selected: selected == filter,
              showCheckmark: false,
              onSelected: (_) => onSelected(filter),
            ),
          ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile, required this.radius});

  final PublicProfile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = profile.avatarUrl;
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.blush,
      backgroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
      child: url == null || url.isEmpty
          ? Text(
              profile.displayName.characters.first.toUpperCase(),
              style: AppTextStyles.title.copyWith(color: AppColors.pine),
            )
          : null,
    );
  }
}

class _FriendMarker extends StatelessWidget {
  const _FriendMarker({required this.entry});

  final FriendMapEntry entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: entry.profile.isOnline ? Colors.green : AppColors.pineMuted,
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: _ProfileAvatar(profile: entry.profile, radius: 22),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            entry.profile.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _GuideMarker extends StatelessWidget {
  const _GuideMarker({required this.place});

  final PlaceRecord place;

  IconData get icon => switch (place.category) {
        'food' => Icons.restaurant,
        'cafe' => Icons.local_cafe,
        'route' => Icons.route,
        _ => Icons.place,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: AppColors.pine,
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Icon(icon, color: Colors.white),
        ),
        if (place.guideCount > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.blush,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${place.guideCount} guides',
                style: const TextStyle(fontSize: 8)),
          ),
      ],
    );
  }
}

class _CurrentUserMarker extends StatelessWidget {
  const _CurrentUserMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration:
            const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
      ),
    );
  }
}

class _RouteStopMarker extends StatelessWidget {
  const _RouteStopMarker({required this.stop});

  final GuideStop stop;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: stop.name,
      child: CircleAvatar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: Text('${stop.order}'),
      ),
    );
  }
}

class _ActiveRouteBanner extends StatelessWidget {
  const _ActiveRouteBanner({required this.guide, required this.onClose});

  final GuideRecord guide;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pine,
      borderRadius: BorderRadius.circular(18),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.route, color: Colors.white),
        title: Text(guide.title, style: const TextStyle(color: Colors.white)),
        subtitle: Text('${guide.stopCount} stops',
            style: const TextStyle(color: Colors.white70)),
        trailing: IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ),
    );
  }
}
