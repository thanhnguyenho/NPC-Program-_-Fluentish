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
          final email = _auth.currentEmail ?? '';
          final displayName = profile?.displayName.trim();
          final name = (displayName != null && displayName.isNotEmpty)
              ? displayName
              : (email.contains('@')
                  ? email.split('@').first
                  : 'Fluentish user');
          final avatarUrl = profile?.avatarUrl;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                expandedHeight: 400,
                backgroundColor: AppColors.pine,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.pine,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      56,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 62,
                          backgroundColor: AppColors.blush,
                          backgroundImage:
                              avatarUrl != null && avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : null,
                          child: avatarUrl == null || avatarUrl.isEmpty
                              ? Text(
                                  name.isNotEmpty
                                      ? name.substring(0, 1).toUpperCase()
                                      : '?',
                                  style: AppTextStyles.title.copyWith(
                                    color: AppColors.pine,
                                    fontSize: 34,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          name,
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.blush,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.blush.withValues(alpha: 0.75),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (uid != null)
                                StreamBuilder<List<String>>(
                                  stream: _guides.watchSavedGuideIds(uid),
                                  builder: (context, snapshot) => _StatColumn(
                                    value: '${snapshot.data?.length ?? 0}',
                                    label: 'Saved',
                                  ),
                                )
                              else
                                const _StatColumn(value: '0', label: 'Saved'),
                              const _StatColumn(value: '—', label: 'History'),
                              if (uid != null)
                                StreamBuilder<List<PublicProfile>>(
                                  stream: _friends.watchFriends(uid),
                                  builder: (context, snapshot) => _StatColumn(
                                    value: '${snapshot.data?.length ?? 0}',
                                    label: 'Friends',
                                  ),
                                )
                              else
                                const _StatColumn(value: '0', label: 'Friends'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.bottomNavHeight + AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      const _SectionLabel('MY ACCOUNT'),
                      _AccountTile(
                        icon: Icons.person_outline,
                        iconBg: AppColors.blush,
                        label: 'MY DETAILS',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileMenuOptionsPage(),
                          ),
                        ),
                      ),
                      _AccountTile(
                        icon: Icons.star_border,
                        iconBg: AppColors.blush,
                        label: 'FAVOURITE LIST',
                        onTap: () {},
                      ),
                      _AccountTile(
                        icon: Icons.history,
                        iconBg: AppColors.blush,
                        label: 'HISTORY',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const HistoryPage()),
                        ),
                      ),
                      _AccountTile(
                        icon: Icons.people_outline,
                        iconBg: AppColors.blush,
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
                      const SizedBox(height: AppSpacing.xs),
                      const _SectionLabel('PREFERENCES'),
                      _AccountTile(
                        icon: Icons.build_outlined,
                        iconBg: AppColors.blush,
                        label: 'SETTINGS',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SettingsPage()),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Logout',
                        icon: Icons.logout,
                        backgroundColor: AppColors.blush,
                        foregroundColor: AppColors.pine,
                        onPressed: () async {
                          await _auth.signOut();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const WelcomePage()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
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
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.blush.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.pineMuted,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.pine,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.pine,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.pineMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
