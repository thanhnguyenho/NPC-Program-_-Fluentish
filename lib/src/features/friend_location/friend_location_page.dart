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
  static const _friends = [
    _LocationFriend(
      avatarAsset: AppAssets.friendVinhTien,
      color: Color(0xFF93CF75),
      id: 'vinh-tien',
      name: 'Vĩnh Tiến',
      note: '"Library later. I saved the route."',
      pinAvatarAsset: AppAssets.friendVinhTienPin,
      position: LatLng(10.7797, 106.6998),
      previewOffset: Offset(0.25, 0.68),
    ),
    _LocationFriend(
      avatarAsset: AppAssets.friendTanPhat,
      color: Color(0xFF6C8F57),
      id: 'tan-phat',
      name: 'Tấn Phát',
      note: '"On campus now. Meet by the gate."',
      pinAvatarAsset: AppAssets.friendTanPhat,
      position: LatLng(10.7733, 106.7033),
      previewOffset: Offset(0.18, 0.54),
    ),
    _LocationFriend(
      avatarAsset: AppAssets.friendKeem,
      color: Color(0xFF3E4E31),
      id: 'keem',
      name: 'Keem',
      note: '"New vocab drop. Come practice."',
      pinAvatarAsset: AppAssets.friendKeem,
      position: LatLng(10.7812, 106.7047),
      previewOffset: Offset(0.76, 0.34),
    ),
    _LocationFriend(
      avatarAsset: AppAssets.friendAnhQuan,
      color: Color(0xFF8A9554),
      id: 'anhquan',
      name: 'AnhQuan',
      note: '"Free to chat after class."',
      pinAvatarAsset: AppAssets.friendAnhQuan,
      position: LatLng(10.7748, 106.6967),
      previewOffset: Offset(0.58, 0.76),
    ),
  ];

  GoogleMapController? _mapController;
  final _osmMapController = fm.MapController();
  _LocationFriend? _selectedFriend = _friends.first;
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
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.figmaFrameWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.bottomNavHeight + AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _FriendLocationHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
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
                ],
              ),
            ),
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
    required this.id,
    required this.name,
    required this.note,
    this.pinAvatarAsset,
    required this.position,
    required this.previewOffset,
  });

  final String? avatarAsset;
  final Color color;
  final String id;
  final String name;
  final String note;
  final String? pinAvatarAsset;
  final LatLng position;
  final Offset previewOffset;

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

class _FriendLocationHeader extends StatelessWidget {
  const _FriendLocationHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Friend Location',
                style: GoogleFonts.gulzar(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  height: 38 / 32,
                  letterSpacing: 0,
                ),
              ),
              Text(
                'Nearby friends',
                style: GoogleFonts.inter(
                  color: AppColors.textSoft,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 18 / 14,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const _LocationChip(label: 'District 1'),
      ],
    );
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
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 28,
            color: AppColors.pine.withValues(alpha: 0.12),
            offset: const Offset(0, 16),
            spreadRadius: -12,
          ),
        ],
        color: const Color(0xFFE6DED2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxBubbleHeight = constraints.maxHeight > AppSpacing.xl
                ? constraints.maxHeight - AppSpacing.xl
                : constraints.maxHeight;

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
                Positioned(
                  left: AppSpacing.lg,
                  top: AppSpacing.lg,
                  child: _MapStatusPill(
                    label: hasGoogleMap ? 'Google Maps' : 'OpenStreetMap',
                  ),
                ),
                Positioned(
                  right: AppSpacing.lg,
                  top: AppSpacing.lg,
                  child: _MapActionButton(
                    icon: Icons.my_location_outlined,
                    label: 'Current location',
                    onTap: onCurrentLocationTap,
                  ),
                ),
                Positioned(
                  left: AppSpacing.lg,
                  top: 74,
                  child: _LocationChip(label: '${friends.length} nearby'),
                ),
                if (!hasGoogleMap)
                  const Positioned(
                    left: AppSpacing.lg,
                    top: 118,
                    child: _OsmAttributionBadge(),
                  ),
                if (locationMessage != null)
                  Positioned(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    top: hasGoogleMap ? 118 : 148,
                    child: _LocationMessage(message: locationMessage!),
                  ),
                if (selectedFriend != null)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: onFriendDismissed,
                    ),
                  ),
                if (selectedFriend != null)
                  Positioned(
                    bottom: AppSpacing.lg,
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxBubbleHeight),
                      child: _FriendActionBubble(
                        friend: selectedFriend!,
                        onDismissed: onFriendDismissed,
                        onEtaSelected: onEtaSelected,
                        onQuickActionTap: onQuickActionTap,
                        onRouteTap: onRouteTap,
                        selectedEta: selectedEta,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
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
        fm.MarkerLayer(
          markers: [
            for (final friend in friends)
              fm.Marker(
                point: friend.osmPosition,
                height: 96,
                width: 104,
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
            DecoratedBox(
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
                  friend.name,
                  style: GoogleFonts.inter(
                    color: AppColors.pine,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: isSelected ? 52 : 42,
              width: isSelected ? 52 : 42,
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
          ],
        ),
      ),
    );
  }
}

class _FriendActionBubble extends StatelessWidget {
  const _FriendActionBubble({
    required this.friend,
    required this.onDismissed,
    required this.onEtaSelected,
    required this.onQuickActionTap,
    required this.onRouteTap,
    required this.selectedEta,
  });

  final _LocationFriend friend;
  final VoidCallback onDismissed;
  final ValueChanged<String> onEtaSelected;
  final ValueChanged<String> onQuickActionTap;
  final VoidCallback onRouteTap;
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
                        onRouteTap: onRouteTap,
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
    required this.onRouteTap,
  });

  final ValueChanged<String> onQuickActionTap;
  final VoidCallback onRouteTap;

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
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 46,
          child: _ActionChipButton(
            label: 'Route',
            onPressed: onRouteTap,
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
