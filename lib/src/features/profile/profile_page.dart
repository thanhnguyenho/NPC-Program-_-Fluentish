import 'package:flutter/material.dart';

import '../../shared/shared.dart';
import '../friends/friends_page.dart';
import '../history/history_page.dart';
import '../profile_menu/profile_menu_options_page.dart';
import '../settings/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.auth,
    this.friendRepository,
    this.guideRepository,
    this.locationRepository,
  });

  final AuthGateway? auth;
  final FriendDataSource? friendRepository;
  final GuideDataSource? guideRepository;
  final LocationDataSource? locationRepository;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final AuthGateway _auth;
  late final FriendDataSource _friends;
  late final GuideDataSource _guides;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? Auth.instance;
    _friends = widget.friendRepository ?? FriendRepository();
    _guides = widget.guideRepository ?? GuideRepository();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUserId;
    return Scaffold(
      backgroundColor: AppColors.shell,
      body: StreamBuilder<PublicProfile?>(
        stream: _auth.watchCurrentProfile(),
        builder: (context, profileSnapshot) {
          final profile = profileSnapshot.data;
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  MediaQuery.paddingOf(context).top + AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.pine,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    _ProfileAvatar(profile: profile),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      profile?.displayName ?? 'Fluentish user',
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.blush,
                        fontSize: 23,
                      ),
                    ),
                    Text(
                      _auth.currentEmail ?? '',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.blush.withValues(alpha: 0.78),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (uid != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StreamBuilder<List<String>>(
                            stream: _guides.watchSavedGuideIds(uid),
                            builder: (context, snapshot) => _StatColumn(
                              value: '${snapshot.data?.length ?? 0}',
                              label: 'Saved',
                            ),
                          ),
                          const _StatColumn(value: '—', label: 'History'),
                          StreamBuilder<List<PublicProfile>>(
                            stream: _friends.watchFriends(uid),
                            builder: (context, snapshot) => _StatColumn(
                              value: '${snapshot.data?.length ?? 0}',
                              label: 'Friends',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.bottomNavHeight + AppSpacing.xl,
                  ),
                  children: [
                    const _SectionLabel('MY ACCOUNT'),
                    _AccountTile(
                      icon: Icons.person_outline,
                      label: 'MY DETAILS',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileMenuOptionsPage(),
                        ),
                      ),
                    ),
                    _AccountTile(
                      icon: Icons.star_border,
                      label: 'FAVOURITE LIST',
                      onTap: () {},
                    ),
                    _AccountTile(
                      icon: Icons.history,
                      label: 'HISTORY',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HistoryPage()),
                      ),
                    ),
                    _AccountTile(
                      icon: Icons.people_outline,
                      label: 'MY FRIENDS',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FriendsPage(
                            auth: widget.auth,
                            friendRepository: widget.friendRepository,
                            locationRepository: widget.locationRepository,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _SectionLabel('PREFERENCES'),
                    _AccountTile(
                      icon: Icons.settings_outlined,
                      label: 'SETTINGS',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Logout',
                      icon: Icons.logout,
                      backgroundColor: AppColors.blush,
                      foregroundColor: AppColors.pine,
                      onPressed: _auth.signOut,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile});

  final PublicProfile? profile;

  @override
  Widget build(BuildContext context) {
    final url = profile?.avatarUrl;
    return CircleAvatar(
      radius: 48,
      backgroundColor: AppColors.blush,
      backgroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
      child: url == null || url.isEmpty
          ? Text(
              (profile?.displayName.isNotEmpty ?? false)
                  ? profile!.displayName.characters.first.toUpperCase()
                  : '?',
              style: AppTextStyles.title.copyWith(
                color: AppColors.pine,
                fontSize: 34,
              ),
            )
          : null,
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.title.copyWith(
            color: AppColors.blush,
            fontSize: 22,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.blush.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.pine),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            const Icon(Icons.chevron_right, color: AppColors.pineMuted),
          ],
        ),
      ),
    );
  }
}
