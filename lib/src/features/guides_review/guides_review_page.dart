import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../shared/shared.dart';

class GuidesPage extends StatefulWidget {
  const GuidesPage({
    super.key,
    this.initialGuideId,
    this.onShowPlaceOnMap,
    this.auth,
    this.repository,
    this.locationRepository,
  });

  final String? initialGuideId;
  final ValueChanged<String>? onShowPlaceOnMap;
  final AuthGateway? auth;
  final GuideDataSource? repository;
  final LocationDataSource? locationRepository;

  @override
  State<GuidesPage> createState() => _GuidesPageState();
}

class _GuidesPageState extends State<GuidesPage> {
  static const _filters = ['Nearby', 'Food', 'Routes', 'Saved'];

  late final AuthGateway _auth;
  late final GuideDataSource _repository;
  late final LocationDataSource _locations;
  Position? _position;
  String _query = '';
  String _selectedFilter = 'Nearby';
  bool _openedInitialGuide = false;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? Auth.instance;
    _repository = widget.repository ?? GuideRepository();
    _locations = widget.locationRepository ?? LocationRepository();
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    try {
      final position = await _locations.currentPosition();
      if (mounted) setState(() => _position = position);
    } catch (_) {}
  }

  double? _distanceTo(PlaceRecord? place) {
    if (_position == null || place == null) return null;
    return Geolocator.distanceBetween(
      _position!.latitude,
      _position!.longitude,
      place.point.latitude,
      place.point.longitude,
    );
  }

  String _distanceLabel(double? meters) {
    if (meters == null) return 'Distance unavailable';
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  IconData _iconFor(GuideRecord guide) => switch (guide.category) {
        'food' => Icons.restaurant_outlined,
        'cafe' => Icons.local_cafe_outlined,
        'route' => Icons.map_outlined,
        _ => guide.type == GuideType.collection
            ? Icons.download_done_outlined
            : Icons.place_outlined,
      };

  List<GuideRecord> _visibleGuides(
    List<GuideRecord> guides,
    Set<String> savedIds,
  ) {
    final query = _query.trim().toLowerCase();
    return guides.where((guide) {
      final matchesFilter = switch (_selectedFilter) {
        'Food' => guide.category == 'food' || guide.category == 'cafe',
        'Routes' => guide.type == GuideType.route,
        'Saved' => savedIds.contains(guide.id),
        _ => guide.type != GuideType.collection,
      };
      final matchesQuery = query.isEmpty ||
          guide.title.toLowerCase().contains(query) ||
          guide.summary.toLowerCase().contains(query) ||
          guide.category.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  Future<void> _openGuide(
    GuideRecord guide,
    PlaceRecord? place,
    bool saved,
  ) async {
    final stops = guide.type == GuideType.route
        ? await _repository.loadStops(guide.id)
        : const <GuideStop>[];
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.shell,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            MediaQuery.viewPaddingOf(sheetContext).bottom + AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.blush,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Icon(_iconFor(guide), color: AppColors.pine, size: 64),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                guide.category.toUpperCase(),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.pineMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              Text(guide.title,
                  style: AppTextStyles.title.copyWith(fontSize: 30)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                [
                  if (place != null) _distanceLabel(_distanceTo(place)),
                  if (guide.ratingAverage != null)
                    '${guide.ratingAverage!.toStringAsFixed(1)}/5',
                  if (guide.type == GuideType.route) '${stops.length} stops',
                ].join(' · '),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.pineMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (place != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text('${place.name}\n${place.address}',
                    style: AppTextStyles.body),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(guide.content.isEmpty ? guide.summary : guide.content,
                  style: AppTextStyles.body.copyWith(fontSize: 16)),
              if (stops.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Route stops',
                    style: AppTextStyles.title.copyWith(fontSize: 21)),
                const SizedBox(height: AppSpacing.sm),
                for (final stop in stops)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.pine,
                      foregroundColor: Colors.white,
                      child: Text('${stop.order}'),
                    ),
                    title: Text(stop.name),
                    subtitle: Text(stop.instruction),
                  ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: saved ? 'Remove Saved' : 'Save Guide',
                      icon: saved ? Icons.bookmark_remove : Icons.bookmark_add,
                      backgroundColor: AppColors.pine,
                      foregroundColor: Colors.white,
                      onPressed: () async {
                        final uid = _auth.currentUserId;
                        if (uid == null) return;
                        await _repository.setSaved(
                          uid: uid,
                          guideId: guide.id,
                          saved: !saved,
                        );
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                    ),
                  ),
                ],
              ),
              if (guide.isMapVisible &&
                  guide.placeId.isNotEmpty &&
                  widget.onShowPlaceOnMap != null) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Show on map',
                  icon: Icons.map_outlined,
                  backgroundColor: AppColors.blush,
                  foregroundColor: AppColors.pine,
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.maybePop(context);
                    widget.onShowPlaceOnMap!(guide.placeId);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openInitialGuide(
    List<GuideRecord> guides,
    Map<String, PlaceRecord> places,
    Set<String> savedIds,
  ) {
    if (_openedInitialGuide || widget.initialGuideId == null) return;
    for (final guide in guides) {
      if (guide.id == widget.initialGuideId) {
        _openedInitialGuide = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _openGuide(guide, places[guide.placeId], savedIds.contains(guide.id));
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUserId;
    return Scaffold(
      backgroundColor: AppColors.blush,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<GuideRecord>>(
          stream: _repository.watchPublishedGuides(),
          builder: (context, guideSnapshot) {
            final guides = guideSnapshot.data ?? const <GuideRecord>[];
            return StreamBuilder<List<PlaceRecord>>(
              stream: _repository.watchPublishedPlaces(),
              builder: (context, placeSnapshot) {
                final places = {
                  for (final place
                      in placeSnapshot.data ?? const <PlaceRecord>[])
                    place.id: place,
                };
                final savedStream = uid == null
                    ? Stream.value(const <String>[])
                    : _repository.watchSavedGuideIds(uid);
                return StreamBuilder<List<String>>(
                  stream: savedStream,
                  builder: (context, savedSnapshot) {
                    final savedIds = (savedSnapshot.data ?? const <String>[])
                        .toSet();
                    _openInitialGuide(guides, places, savedIds);
                    final visible = _visibleGuides(guides, savedIds);
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.xxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BackButton(),
                          Text('Fluentish Guides',
                              style:
                                  AppTextStyles.title.copyWith(fontSize: 36)),
                          const SizedBox(height: AppSpacing.lg),
                          TextField(
                            onChanged: (value) =>
                                setState(() => _query = value),
                            decoration: const InputDecoration(
                              hintText: 'Search guides, places, routes...',
                              prefixIcon:
                                  Icon(Icons.search, color: AppColors.pine),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Wrap(
                            spacing: AppSpacing.sm,
                            children: [
                              for (final filter in _filters)
                                ChoiceChip(
                                  label: Text(filter),
                                  selected: _selectedFilter == filter,
                                  showCheckmark: false,
                                  onSelected: (_) => setState(
                                    () => _selectedFilter = filter,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          if (guideSnapshot.connectionState ==
                                  ConnectionState.waiting &&
                              guides.isEmpty)
                            const Center(child: CircularProgressIndicator())
                          else if (guideSnapshot.hasError)
                            AppCard(
                              child: Text(
                                'Unable to load guides: ${guideSnapshot.error}',
                              ),
                            )
                          else if (visible.isEmpty)
                            const AppCard(
                              width: double.infinity,
                              child: Text(
                                'No guides match your search.',
                                textAlign: TextAlign.center,
                              ),
                            )
                          else
                            for (final guide in visible) ...[
                              _GuideCard(
                                guide: guide,
                                place: places[guide.placeId],
                                distance: _distanceLabel(
                                  _distanceTo(places[guide.placeId]),
                                ),
                                saved: savedIds.contains(guide.id),
                                icon: _iconFor(guide),
                                onTap: () => _openGuide(
                                  guide,
                                  places[guide.placeId],
                                  savedIds.contains(guide.id),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.guide,
    required this.place,
    required this.distance,
    required this.saved,
    required this.icon,
    required this.onTap,
  });

  final GuideRecord guide;
  final PlaceRecord? place;
  final String distance;
  final bool saved;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 92,
            width: 92,
            decoration: BoxDecoration(
              color: AppColors.shell,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Icon(icon, color: AppColors.pine, size: 42),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        guide.title,
                        style: AppTextStyles.title.copyWith(fontSize: 20),
                      ),
                    ),
                    if (saved)
                      const Icon(Icons.bookmark, color: AppColors.pine),
                  ],
                ),
                Text(
                  [
                    if (place != null) distance,
                    if (guide.ratingAverage != null)
                      '${guide.ratingAverage!.toStringAsFixed(1)}/5',
                    if (guide.type == GuideType.route)
                      '${guide.stopCount} stops',
                  ].join(' · '),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.pineMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  guide.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
