import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../shared/shared.dart';
import 'google_maps_api_status.dart';
import 'maps_launcher.dart';

class FriendLocationPage extends StatefulWidget {
  const FriendLocationPage({super.key});

  @override
  State<FriendLocationPage> createState() => _FriendLocationPageState();
}

class _FriendLocationPageState extends State<FriendLocationPage> {
  static const _districtOne = LatLng(10.7769, 106.7009);
  static const _districtOneOsm = ll.LatLng(10.7769, 106.7009);
  static const _mePosition = ll.LatLng(10.7772, 106.6997);
  static const _friends = [
    _LocationFriend(
      avatarAsset: AppAssets.friendChloe,
      color: Color(0xFF93CF75),
      distanceLabel: '0.8 km',
      hasPulse: true,
      id: 'chloe',
      mapNote: 'Coffee after class?',
      name: 'Thanh Nguyen (Chloe)',
      note: '"Coffee after class?"',
      pinAvatarAsset: AppAssets.friendChloe,
      position: LatLng(10.7798, 106.6955),
      previewOffset: Offset(0.18, 0.34),
      showMapNote: false,
    ),
    _LocationFriend(
      avatarAsset: AppAssets.friendChris,
      color: Color(0xFF3E4E31),
      distanceLabel: '1.1 km',
      hasVibeBadge: true,
      id: 'chris',
      mapNote: 'OMW in 8 min.',
      name: 'Chris Crowne',
      note: '"OMW in 8 min."',
      pinAvatarAsset: AppAssets.friendChris,
      position: LatLng(10.7841, 106.7009),
      previewOffset: Offset(0.72, 0.22),
    ),
    _LocationFriend(
      avatarAsset: AppAssets.friendMary,
      color: Color(0xFFB8A2D8),
      distanceLabel: '1.3 km',
      hasPulse: true,
      id: 'mary',
      mapNote: 'Saved you a seat.',
      name: 'mary ⟡ ﾟ.',
      note: '"Saved you a seat."',
      pinAvatarAsset: AppAssets.friendMary,
      position: LatLng(10.7819, 106.7065),
      previewOffset: Offset(0.76, 0.42),
      showMapNote: false,
    ),
    _LocationFriend(
      avatarAsset: AppAssets.friendDongMinh,
      color: Color(0xFF6C8F57),
      distanceLabel: '1.6 km',
      hasPulse: true,
      id: 'dong-minh',
      mapNote: 'Study room later.',
      name: 'Đồng Minh',
      note: '"Study room later."',
      pinAvatarAsset: AppAssets.friendDongMinh,
      position: LatLng(10.7682, 106.7022),
      previewOffset: Offset(0.34, 0.76),
      showMapNote: false,
    ),
    _LocationFriend(
      avatarAsset: AppAssets.friendVinhTien,
      color: Color(0xFF93CF75),
      distanceLabel: '0.2 km',
      hasPulse: true,
      id: 'vinh-tien',
      mapNote: 'Library later.',
      name: 'Vĩnh Tiến',
      note: '"Library later. I saved the route."',
      pinAvatarAsset: AppAssets.friendVinhTienPin,
      position: LatLng(10.776, 106.6974),
      previewOffset: Offset(0.25, 0.68),
    ),
    _LocationFriend(
      avatarAsset: AppAssets.friendTanPhat,
      color: Color(0xFF6C8F57),
      distanceLabel: '2.3 km',
      id: 'tan-phat',
      mapNote: 'On campus now.',
      name: 'Tấn Phát',
      note: '"On campus now. Meet by the gate."',
      pinAvatarAsset: AppAssets.friendTanPhat,
      position: LatLng(10.7714, 106.7045),
      previewOffset: Offset(0.18, 0.54),
    ),
    _LocationFriend(
      avatarAsset: AppAssets.friendKeem,
      color: Color(0xFF3E4E31),
      distanceLabel: '1.9 km',
      id: 'keem',
      mapNote: 'New vocab drop.',
      name: 'Keem',
      note: '"New vocab drop. Come practice."',
      pinAvatarAsset: AppAssets.friendKeem,
      position: LatLng(10.776, 106.7068),
      previewOffset: Offset(0.76, 0.34),
    ),
    _LocationFriend(
      avatarAsset: AppAssets.friendAnhQuan,
      color: Color(0xFF8A9554),
      distanceLabel: '0.4 km',
      id: 'anhquan',
      mapNote: 'Free to chat.',
      name: 'AnhQuan',
      note: '"Free to chat after class."',
      pinAvatarAsset: AppAssets.friendAnhQuan,
      position: LatLng(10.771, 106.6955),
      previewOffset: Offset(0.58, 0.76),
    ),
  ];

  GoogleMapController? _mapController;
  final _osmMapController = fm.MapController();
  _LocationFriend? _selectedFriend = _friends[4];
  bool _myLocationEnabled = false;
  String? _locationMessage;
  String _selectedEta = '5 min';

  static void _ignoreNavTap(int index) {}

  Set<Marker> get _markers {
    return {
      for (final friend in _friends)
        Marker(
          markerId: MarkerId(friend.id),
          position: friend.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(friend.markerHue),
          infoWindow: InfoWindow(title: friend.name, snippet: friend.note),
          onTap: () => setState(() => _selectedFriend = friend),
        ),
    };
  }

  Future<void> _focusCurrentLocation() async {
    setState(() => _locationMessage = 'Checking location...');

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationMessage = 'Turn on location services first.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      setState(() => _locationMessage = 'Location permission denied.');
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationMessage = 'Enable location in Settings.');
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    final target = LatLng(position.latitude, position.longitude);

    setState(() {
      _myLocationEnabled = true;
      _locationMessage = 'Using your current location.';
    });

    if (hasGoogleMapsApiKey) {
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 15),
        ),
      );
      return;
    }

    _osmMapController.move(ll.LatLng(target.latitude, target.longitude), 15);
  }

  void _selectFriend(_LocationFriend friend) {
    setState(() => _selectedFriend = friend);

    if (hasGoogleMapsApiKey) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: friend.position, zoom: 15.5),
        ),
      );
      return;
    }

    _osmMapController.move(friend.osmPosition, 15.5);
  }

  void _dismissFriend() {
    setState(() => _selectedFriend = null);
  }

  Future<void> _openSelectedRoute() async {
    final friend = _selectedFriend;
    if (friend == null) {
      return;
    }

    final didLaunch = await launchGoogleMapsDirections(friend.position);
    if (!didLaunch && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  void _selectEta(String eta) {
    setState(() => _selectedEta = eta);
  }

  void _showAction(String action) {
    final friend = _selectedFriend;
    if (friend == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action ${friend.name}')),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFriend = _selectedFriend;

    return Scaffold(
      backgroundColor: AppColors.blush,
      bottomNavigationBar: const AppBottomNav(
        currentIndex: 3,
        onItemSelected: _ignoreNavTap,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.figmaFrameWidth,
          ),
          child: _MapShell(
            friends: _friends,
            hasGoogleMap: hasGoogleMapsApiKey,
            locationMessage: _locationMessage,
            markers: _markers,
            myLocationEnabled: _myLocationEnabled,
            onCurrentLocationTap: _focusCurrentLocation,
            onEtaSelected: _selectEta,
            onFriendDismissed: _dismissFriend,
            onFriendSelected: _selectFriend,
            onMapCreated: (controller) => _mapController = controller,
            osmMapController: _osmMapController,
            onRouteTap: _openSelectedRoute,
            onQuickActionTap: _showAction,
            selectedEta: _selectedEta,
            selectedFriend: selectedFriend,
          ),
        ),
      ),
    );
  }
}

class _LocationFriend {
  const _LocationFriend({
    this.avatarAsset,
    required this.color,
    required this.distanceLabel,
    this.hasPulse = false,
    this.hasVibeBadge = false,
    required this.id,
    required this.mapNote,
    required this.name,
    required this.note,
    this.pinAvatarAsset,
    required this.position,
    required this.previewOffset,
    this.showMapNote = true,
  });

  final String? avatarAsset;
  final Color color;
  final String distanceLabel;
  final bool hasPulse;
  final bool hasVibeBadge;
  final String id;
  final String mapNote;
  final String name;
  final String note;
  final String? pinAvatarAsset;
  final LatLng position;
  final Offset previewOffset;
  final bool showMapNote;

  ll.LatLng get osmPosition => ll.LatLng(position.latitude, position.longitude);

  double get markerHue {
    if (color == AppColors.pine) {
      return BitmapDescriptor.hueGreen;
    }
    if (color == const Color(0xFF93CF75)) {
      return BitmapDescriptor.hueYellow;
    }
    return BitmapDescriptor.hueCyan;
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        color: Colors.white.withValues(alpha: 0.42),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: AppColors.pine,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _MapTopPanel extends StatelessWidget {
  const _MapTopPanel();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.58)),
            borderRadius: BorderRadius.circular(24),
            color: AppColors.blush.withValues(alpha: 0.76),
            boxShadow: [
              BoxShadow(
                blurRadius: 22,
                color: AppColors.pine.withValues(alpha: 0.12),
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 36,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.52),
                      foregroundColor: AppColors.pine,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Friend Location',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.gulzar(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          height: 26 / 22,
                          letterSpacing: 0,
                        ),
                      ),
                      Text(
                        'Nearby friends',
                        style: GoogleFonts.inter(
                          color: AppColors.textSoft,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 14 / 12,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const _LocationChip(label: 'District 1'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapShell extends StatelessWidget {
  const _MapShell({
    required this.friends,
    required this.hasGoogleMap,
    required this.locationMessage,
    required this.markers,
    required this.myLocationEnabled,
    required this.onCurrentLocationTap,
    required this.onEtaSelected,
    required this.onFriendDismissed,
    required this.onFriendSelected,
    required this.onMapCreated,
    required this.osmMapController,
    required this.onQuickActionTap,
    required this.onRouteTap,
    required this.selectedEta,
    required this.selectedFriend,
  });

  final List<_LocationFriend> friends;
  final bool hasGoogleMap;
  final String? locationMessage;
  final Set<Marker> markers;
  final bool myLocationEnabled;
  final VoidCallback onCurrentLocationTap;
  final ValueChanged<String> onEtaSelected;
  final VoidCallback onFriendDismissed;
  final ValueChanged<_LocationFriend> onFriendSelected;
  final ValueChanged<GoogleMapController> onMapCreated;
  final fm.MapController osmMapController;
  final ValueChanged<String> onQuickActionTap;
  final VoidCallback onRouteTap;
  final String selectedEta;
  final _LocationFriend? selectedFriend;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bubbleTop = constraints.maxHeight >= 690 ? 236.0 : 170.0;
          final bubbleHeight = constraints.maxHeight >= 690 ? 374.0 : 350.0;

          return Stack(
            children: [
              Positioned.fill(
                child: hasGoogleMap
                    ? _GoogleMapSurface(
                        markers: markers,
                        myLocationEnabled: myLocationEnabled,
                        onMapCreated: onMapCreated,
                      )
                    : _OpenStreetMapSurface(
                        controller: osmMapController,
                        friends: friends,
                        onFriendSelected: onFriendSelected,
                        selectedFriend: selectedFriend,
                      ),
              ),
              const Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.xl,
                child: _MapTopPanel(),
              ),
              Positioned(
                right: AppSpacing.xl,
                top: 108,
                child: _MapActionButton(
                  icon: Icons.my_location_outlined,
                  label: 'Current location',
                  onTap: onCurrentLocationTap,
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                top: 114,
                child: _MapStatusPill(
                  label: hasGoogleMap ? 'Google Maps' : 'OpenStreetMap',
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                top: 158,
                child: _LocationChip(label: '${friends.length} nearby'),
              ),
              if (!hasGoogleMap)
                const Positioned(
                  left: AppSpacing.lg,
                  top: 202,
                  child: _OsmAttributionBadge(),
                ),
              if (locationMessage != null)
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: hasGoogleMap ? 158 : 232,
                  child: _LocationMessage(message: locationMessage!),
                ),
              if (selectedFriend != null)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onFriendDismissed,
                  ),
                ),
              Positioned(
                bottom: AppSpacing.md,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: _FriendQuickStrip(
                  friends: friends,
                  onFriendSelected: onFriendSelected,
                  onRouteTap: onRouteTap,
                  selectedFriend: selectedFriend,
                ),
              ),
              if (selectedFriend != null)
                Positioned(
                  left: 31,
                  right: 31,
                  top: bubbleTop,
                  child: SizedBox(
                    height: bubbleHeight,
                    child: _FriendActionBubble(
                      friend: selectedFriend!,
                      onDismissed: onFriendDismissed,
                      onEtaSelected: onEtaSelected,
                      onQuickActionTap: onQuickActionTap,
                      selectedEta: selectedEta,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _GoogleMapSurface extends StatelessWidget {
  const _GoogleMapSurface({
    required this.markers,
    required this.myLocationEnabled,
    required this.onMapCreated,
  });

  final Set<Marker> markers;
  final bool myLocationEnabled;
  final ValueChanged<GoogleMapController> onMapCreated;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      compassEnabled: false,
      initialCameraPosition: const CameraPosition(
        target: _FriendLocationPageState._districtOne,
        zoom: 14.4,
      ),
      mapToolbarEnabled: false,
      markers: markers,
      myLocationButtonEnabled: false,
      myLocationEnabled: myLocationEnabled,
      onMapCreated: onMapCreated,
      zoomControlsEnabled: false,
    );
  }
}

class _OpenStreetMapSurface extends StatelessWidget {
  const _OpenStreetMapSurface({
    required this.controller,
    required this.friends,
    required this.onFriendSelected,
    required this.selectedFriend,
  });

  final fm.MapController controller;
  final List<_LocationFriend> friends;
  final ValueChanged<_LocationFriend> onFriendSelected;
  final _LocationFriend? selectedFriend;

  @override
  Widget build(BuildContext context) {
    final featuredFriend = friends.firstWhere(
      (friend) => friend.hasVibeBadge,
      orElse: () => friends.first,
    );

    return fm.FlutterMap(
      mapController: controller,
      options: const fm.MapOptions(
        initialCenter: _FriendLocationPageState._districtOneOsm,
        initialZoom: 14.4,
        maxZoom: 18,
        minZoom: 12,
      ),
      children: [
        fm.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.fluentish.app',
        ),
        fm.PolylineLayer(
          polylines: [
            fm.Polyline(
              color: AppColors.pine.withValues(alpha: 0.34),
              points: [
                _FriendLocationPageState._mePosition,
                featuredFriend.osmPosition,
              ],
              strokeWidth: 3,
            ),
          ],
        ),
        fm.MarkerLayer(
          markers: [
            const fm.Marker(
              point: _FriendLocationPageState._mePosition,
              height: 76,
              width: 76,
              child: _MeMapMarker(),
            ),
            for (final friend in friends)
              fm.Marker(
                point: friend.osmPosition,
                height: 150,
                width: 122,
                child: _FriendMapPin(
                  friend: friend,
                  isSelected: friend == selectedFriend,
                  onTap: () => onFriendSelected(friend),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _OsmAttributionBadge extends StatelessWidget {
  const _OsmAttributionBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withValues(alpha: 0.72),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          'OpenStreetMap contributors',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: AppColors.pine,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _MapStatusPill extends StatelessWidget {
  const _MapStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        color: Colors.white.withValues(alpha: 0.68),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.pine,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _LocationMessage extends StatelessWidget {
  const _LocationMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.74),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          message,
          style: GoogleFonts.inter(
            color: AppColors.pine,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: SizedBox(
        height: 42,
        width: 42,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.72),
            foregroundColor: AppColors.pine,
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
          ),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

class _FriendQuickStrip extends StatelessWidget {
  const _FriendQuickStrip({
    required this.friends,
    required this.onFriendSelected,
    required this.onRouteTap,
    required this.selectedFriend,
  });

  final List<_LocationFriend> friends;
  final ValueChanged<_LocationFriend> onFriendSelected;
  final VoidCallback onRouteTap;
  final _LocationFriend? selectedFriend;

  @override
  Widget build(BuildContext context) {
    final selected = selectedFriend;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.62)),
            borderRadius: BorderRadius.circular(24),
            color: AppColors.blush.withValues(alpha: 0.78),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                color: AppColors.pine.withValues(alpha: 0.16),
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Friends nearby',
                        style: GoogleFonts.gulzar(
                          color: AppColors.pine,
                          fontSize: 23,
                          fontWeight: FontWeight.w400,
                          height: 28 / 23,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    if (selected != null) ...[
                      Text(
                        selected.distanceLabel,
                        style: GoogleFonts.inter(
                          color: AppColors.textSoft,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          height: 13 / 11,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        height: 28,
                        width: 70,
                        child: _ActionChipButton(
                          isSelected: true,
                          label: 'Route',
                          onPressed: onRouteTap,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 66,
                  child: ListView.separated(
                    clipBehavior: Clip.none,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return _FriendStripCard(
                        friend: friend,
                        isSelected: friend == selectedFriend,
                        onTap: () => onFriendSelected(friend),
                      );
                    },
                    itemCount: friends.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: AppSpacing.sm),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FriendStripCard extends StatelessWidget {
  const _FriendStripCard({
    required this.friend,
    required this.isSelected,
    required this.onTap,
  });

  final _LocationFriend friend;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'View ${friend.name}',
      selected: isSelected,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 146,
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? AppColors.pine
                  : Colors.white.withValues(alpha: 0.64),
              width: isSelected ? 1.4 : 1,
            ),
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withValues(alpha: isSelected ? 0.78 : 0.52),
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: friend.color.withValues(alpha: 0.2),
                      offset: const Offset(0, 5),
                    ),
                  ],
                  color: friend.color,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: _FriendAvatarContent(
                  asset: friend.avatarAsset,
                  friend: friend,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      friend.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: AppColors.pine,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        height: 13 / 11,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${friend.distanceLabel} · ${friend.mapNote}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: AppColors.textSoft,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        height: 11 / 9,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendMapPin extends StatelessWidget {
  const _FriendMapPin({
    required this.friend,
    required this.isSelected,
    required this.onTap,
  });

  final _LocationFriend friend;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${friend.name} location pin',
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (friend.showMapNote) ...[
              _MapNoteBubble(label: friend.mapNote),
              const SizedBox(height: AppSpacing.xxs),
            ],
            _FriendPinAvatar(friend: friend, isSelected: isSelected),
            const SizedBox(height: AppSpacing.xxs),
            _MapNameLabel(label: friend.name),
          ],
        ),
      ),
    );
  }
}

class _MapNoteBubble extends StatelessWidget {
  const _MapNoteBubble({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: Colors.black.withValues(alpha: 0.22),
                offset: const Offset(0, 4),
              ),
            ],
            color: const Color(0xFF292929).withValues(alpha: 0.92),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: const Color(0xFFFAFAF5),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                height: 13 / 11,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -5,
          child: Transform.rotate(
            angle: 0.785398,
            child: Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: const Color(0xFF292929).withValues(alpha: 0.92),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapNameLabel extends StatelessWidget {
  const _MapNameLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(13),
        color: Colors.white.withValues(alpha: 0.72),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: AppColors.pine,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _FriendPinAvatar extends StatelessWidget {
  const _FriendPinAvatar({
    required this.friend,
    required this.isSelected,
  });

  final _LocationFriend friend;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final avatarSize = isSelected ? 54.0 : 42.0;
    final auraSize = isSelected || friend.hasPulse ? 72.0 : 50.0;
    final focusSize = isSelected || friend.hasPulse ? 58.0 : 50.0;

    return SizedBox.square(
      dimension: auraSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color:
                  friend.color.withValues(alpha: friend.hasPulse ? 0.24 : 0.16),
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(dimension: auraSize),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.58),
                width: 2,
              ),
              color: friend.color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(dimension: focusSize),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: avatarSize,
            width: avatarSize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  blurRadius: isSelected ? 22 : 12,
                  color: friend.color.withValues(alpha: 0.35),
                  offset: const Offset(0, 8),
                ),
              ],
              color: friend.color,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: _FriendAvatarContent(
              asset: friend.pinAvatarAsset ?? friend.avatarAsset,
              friend: friend,
              fontSize: isSelected ? 18 : 15,
            ),
          ),
          Positioned(
            bottom: auraSize * 0.14,
            right: auraSize * 0.14,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                color: const Color(0xFF93CF75),
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(dimension: 10),
            ),
          ),
          if (friend.hasVibeBadge)
            Positioned(
              right: auraSize * 0.02,
              top: auraSize * 0.02,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  color: AppColors.pine,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.square(
                  dimension: 22,
                  child: Icon(
                    Icons.near_me,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MeMapMarker extends StatelessWidget {
  const _MeMapMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFD7E3F7).withValues(alpha: 0.26),
            shape: BoxShape.circle,
          ),
          child: const SizedBox.square(dimension: 70),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFD7E3F7).withValues(alpha: 0.40),
            shape: BoxShape.circle,
          ),
          child: const SizedBox.square(dimension: 60),
        ),
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.96), width: 3),
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                color: AppColors.pine.withValues(alpha: 0.24),
                offset: const Offset(0, 8),
              ),
            ],
            color: const Color(0xFFD7E3F7),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _FriendActionBubble extends StatelessWidget {
  const _FriendActionBubble({
    required this.friend,
    required this.onDismissed,
    required this.onEtaSelected,
    required this.onQuickActionTap,
    required this.selectedEta,
  });

  final _LocationFriend friend;
  final VoidCallback onDismissed;
  final ValueChanged<String> onEtaSelected;
  final ValueChanged<String> onQuickActionTap;
  final String selectedEta;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 17, sigmaY: 17),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 26,
                      color: AppColors.pine.withValues(alpha: 0.18),
                      offset: const Offset(0, 14),
                    ),
                  ],
                  color: Colors.white.withValues(alpha: 0.82),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _FriendLargeAvatar(friend: friend),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        friend.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: AppColors.pine,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 22 / 18,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        friend.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: AppColors.textSoft,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 16 / 12,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _MessageField(friend: friend),
                      const SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Tell ${friend.name}: I'm coming",
                          style: GoogleFonts.inter(
                            color: AppColors.pine,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            height: 16 / 13,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Send a quick heads-up before you meet.',
                          style: GoogleFonts.inter(
                            color: AppColors.textSoft.withValues(alpha: 0.86),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: 12 / 10,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _EtaRow(
                        onSelected: onEtaSelected,
                        selectedEta: selectedEta,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _VisitButton(
                        onPressed: () => onQuickActionTap('Visit note sent to'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _QuickActionRow(
                        onQuickActionTap: onQuickActionTap,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: AppSpacing.md,
            top: AppSpacing.md,
            child: Tooltip(
              message: 'Close',
              child: SizedBox.square(
                dimension: 32,
                child: IconButton.filledTonal(
                  onPressed: onDismissed,
                  icon: const Icon(Icons.close, size: 16),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.72),
                    foregroundColor: AppColors.pine,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendLargeAvatar extends StatelessWidget {
  const _FriendLargeAvatar({required this.friend});

  final _LocationFriend friend;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: AppColors.pine.withValues(alpha: 0.16),
            offset: const Offset(0, 8),
          ),
        ],
        color: friend.color,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: _FriendAvatarContent(
        asset: friend.avatarAsset,
        friend: friend,
        fontSize: 24,
      ),
    );
  }
}

class _FriendAvatarContent extends StatelessWidget {
  const _FriendAvatarContent({
    required this.asset,
    required this.friend,
    required this.fontSize,
  });

  final String? asset;
  final _LocationFriend friend;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final imageAsset = asset;
    if (imageAsset != null) {
      return Image.asset(
        imageAsset,
        fit: BoxFit.contain,
        semanticLabel: '${friend.name} avatar',
      );
    }

    return Center(
      child: Text(
        friend.name.characters.first,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _MessageField extends StatelessWidget {
  const _MessageField({required this.friend});

  final _LocationFriend friend;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withValues(alpha: 0.78),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      alignment: Alignment.centerLeft,
      child: Text(
        'Message ${friend.name}...',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: const Color(0xFF7A7E73),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 15 / 12,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _EtaRow extends StatelessWidget {
  const _EtaRow({
    required this.onSelected,
    required this.selectedEta,
  });

  final ValueChanged<String> onSelected;
  final String selectedEta;

  static const _etas = ['5 min', '10 min', 'after class'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final eta in _etas) ...[
          Expanded(
            flex: eta == 'after class' ? 2 : 1,
            child: _ActionChipButton(
              isSelected: eta == selectedEta,
              label: eta,
              onPressed: () => onSelected(eta),
            ),
          ),
          if (eta != _etas.last) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _VisitButton extends StatelessWidget {
  const _VisitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 176,
      child: _ActionChipButton(
        isSelected: true,
        label: 'Send visit note',
        onPressed: onPressed,
      ),
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow({
    required this.onQuickActionTap,
  });

  final ValueChanged<String> onQuickActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionChipButton(
            isSelected: true,
            label: 'Chat',
            onPressed: () => onQuickActionTap('Chat opened for'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionChipButton(
            label: 'React',
            onPressed: () => onQuickActionTap('Reacted to'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionChipButton(
            label: 'Poke',
            onPressed: () => onQuickActionTap('Poked'),
          ),
        ),
      ],
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.label,
    required this.onPressed,
    this.isSelected = false,
  });

  final bool isSelected;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor:
              isSelected ? AppColors.pine : const Color(0xFF868F54),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.32)),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              height: 12 / 10,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
