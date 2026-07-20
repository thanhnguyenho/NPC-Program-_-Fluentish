import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../shared/shared.dart';
import '../friend_location/maps_launcher.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({
    super.key,
    this.auth,
    this.friendRepository,
    this.locationRepository,
  });

  final AuthGateway? auth;
  final FriendDataSource? friendRepository;
  final LocationDataSource? locationRepository;

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late final AuthGateway _auth;
  late final FriendDataSource _friends;
  late final LocationDataSource _locations;
  int _selectedTab = 0;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? Auth.instance;
    _friends = widget.friendRepository ?? FriendRepository();
    _locations = widget.locationRepository ?? LocationRepository();
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    try {
      final position = await _locations.currentPosition();
      if (mounted) setState(() => _position = position);
    } catch (_) {}
  }

  Future<void> _searchUsers() async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    final controller = TextEditingController();
    List<PublicProfile> results = const [];
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add a friend'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Search username',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (query) async {
                    final found = await _friends.searchProfiles(query, uid);
                    setDialogState(() => results = found);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                if (results.isEmpty)
                  const Text('Enter a username and press search.')
                else
                  for (final profile in results)
                    ListTile(
                      leading: _Avatar(profile: profile),
                      title: Text(profile.displayName),
                      subtitle: Text('@${profile.username}'),
                      trailing: IconButton(
                        tooltip: 'Send request',
                        icon: const Icon(Icons.person_add_alt_1),
                        onPressed: () async {
                          try {
                            await _friends.sendRequest(uid, profile.uid);
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(content: Text('Request sent.')),
                              );
                            }
                          } catch (error) {
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(content: Text('$error')),
                              );
                            }
                          }
                        },
                      ),
                    ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final found =
                    await _friends.searchProfiles(controller.text, uid);
                setDialogState(() => results = found);
              },
              child: const Text('Search'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  String _distanceLabel(FriendMapEntry friend) {
    final position = _position;
    if (position == null) return 'Location shared';
    final meters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      friend.location.point.latitude,
      friend.location.point.longitude,
    );
    return meters < 1000
        ? '${meters.round()} m away'
        : '${(meters / 1000).toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUserId;
    final colors = context.fluentishColors;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Sign in first.')));
    }
    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.header,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              8,
              50,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.onHeader),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Friends',
                    style: AppTextStyles.title.copyWith(
                      color: colors.onHeader,
                      fontSize: 22,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Add a friend',
                  onPressed: _searchUsers,
                  icon: Icon(Icons.person_add, color: colors.onHeader),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Friends')),
                      ButtonSegment(value: 1, label: Text('Requests')),
                      ButtonSegment(value: 2, label: Text('Nearby')),
                    ],
                    selected: {_selectedTab},
                    onSelectionChanged: (selection) =>
                        setState(() => _selectedTab = selection.first),
                  ),
                ),
                Expanded(
                  child: switch (_selectedTab) {
                    0 => _FriendsList(uid: uid, repository: _friends),
                    1 => _RequestsList(uid: uid, repository: _friends),
                    _ => _NearbyList(
                        uid: uid,
                        repository: _friends,
                        distanceLabel: _distanceLabel,
                      ),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendsList extends StatelessWidget {
  const _FriendsList({required this.uid, required this.repository});

  final String uid;
  final FriendDataSource repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PublicProfile>>(
      stream: repository.watchFriends(uid),
      builder: (context, snapshot) {
        final friends = snapshot.data ?? const <PublicProfile>[];
        if (snapshot.connectionState == ConnectionState.waiting &&
            friends.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (friends.isEmpty) {
          return const _EmptyState(
            icon: Icons.people_outline,
            message: 'No friends yet. Use the add button to find someone.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: friends.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final friend = friends[index];
            return AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _Avatar(profile: friend),
                title: Text(friend.displayName),
                subtitle: Text(
                  '@${friend.username} · ${friend.isOnline ? 'Online' : 'Offline'}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _RequestsList extends StatelessWidget {
  const _RequestsList({required this.uid, required this.repository});

  final String uid;
  final FriendDataSource repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendRequestRecord>>(
      stream: repository.watchIncomingRequests(uid),
      builder: (context, snapshot) {
        final requests = snapshot.data ?? const <FriendRequestRecord>[];
        if (requests.isEmpty) {
          return const _EmptyState(
            icon: Icons.mark_email_unread_outlined,
            message: 'No pending friend requests.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return FutureBuilder<PublicProfile?>(
              future: repository.getProfile(request.senderId),
              builder: (context, profileSnapshot) {
                final profile = profileSnapshot.data;
                return AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: profile == null
                        ? const CircleAvatar(child: Icon(Icons.person))
                        : _Avatar(profile: profile),
                    title: Text(profile?.displayName ?? 'Fluentish user'),
                    subtitle:
                        Text(profile == null ? '' : '@${profile.username}'),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          tooltip: 'Accept',
                          onPressed: () => repository.acceptRequest(request),
                          icon: const Icon(Icons.check, color: Colors.green),
                        ),
                        IconButton(
                          tooltip: 'Decline',
                          onPressed: () => repository.declineRequest(request),
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _NearbyList extends StatelessWidget {
  const _NearbyList({
    required this.uid,
    required this.repository,
    required this.distanceLabel,
  });

  final String uid;
  final FriendDataSource repository;
  final String Function(FriendMapEntry) distanceLabel;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendMapEntry>>(
      stream: repository.watchVisibleFriendLocations(uid),
      builder: (context, snapshot) {
        final friends = snapshot.data ?? const <FriendMapEntry>[];
        if (friends.isEmpty) {
          return const _EmptyState(
            icon: Icons.location_off_outlined,
            message: 'No friends are sharing a current location.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: friends.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final friend = friends[index];
            return AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _Avatar(profile: friend.profile),
                title: Text(friend.profile.displayName),
                subtitle: Text(distanceLabel(friend)),
                trailing: FilledButton(
                  onPressed: () => launchGoogleMapsDirections(
                    ll.LatLng(
                      friend.location.point.latitude,
                      friend.location.point.longitude,
                    ),
                  ),
                  child: const Text('Route'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final url = profile.avatarUrl;
    return CircleAvatar(
      backgroundColor: AppColors.shell,
      backgroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
      child: url == null || url.isEmpty
          ? Text(profile.displayName.characters.first.toUpperCase())
          : null,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: AppColors.pineMuted),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
