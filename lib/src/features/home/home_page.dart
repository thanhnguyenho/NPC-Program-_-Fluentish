import 'package:flutter/material.dart';
import '../../shared/shared.dart';
import '../community/community_page.dart';
import '../friends/friends_page.dart';
import '../guides_review/guides_review_page.dart';
import '../language/language_page.dart';
import '../profile/profile_page.dart';
import '../soundboard/soundboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Core focus: Language & Translator (Index 1)
  int _currentIndex = 1;

  Widget _pageForIndex(int index) {
    return switch (index) {
      0 => HomeScreen(
          onNavigateToGuides: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GuidesPage()),
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
    required this.onNavigateToGuides,
    this.auth,
    this.friendRepository,
    this.guideRepository,
  });

  final VoidCallback onNavigateToGuides;
  final AuthGateway? auth;
  final FriendDataSource? friendRepository;
  final GuideDataSource? guideRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final colors = context.fluentishColors;
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
              'Discover language guides and meet friends nearby.',
              style: AppTextStyles.body.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionHeader(
              title: 'Nearby Recommendations',
              action: 'See all',
              onTap: widget.onNavigateToGuides,
            ),
            const SizedBox(height: AppSpacing.md),
            StreamBuilder<List<GuideRecord>>(
              stream: _guides.watchPublishedGuides(),
              builder: (context, snapshot) {
                final guides = (snapshot.data ?? const <GuideRecord>[])
                    .where((guide) =>
                        guide.isMapVisible &&
                        guide.type != GuideType.collection)
                    .take(3)
                    .toList();
                if (snapshot.connectionState == ConnectionState.waiting &&
                    guides.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (guides.isEmpty) {
                  return const _EmptyCard('No published guides yet.');
                }
                return Column(
                  children: [
                    for (final guide in guides)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: AppCard(
                          onTap: widget.onNavigateToGuides,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              guide.type == GuideType.route
                                  ? Icons.route
                                  : Icons.place,
                              color: colors.textPrimary,
                            ),
                            title: Text(guide.title),
                            subtitle: Text(
                              guide.summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
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
                                  style: AppTextStyles.body.copyWith(
                                    color: colors.textPrimary,
                                    fontSize: 11,
                                  ),
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
    final url = profile.avatarUrl;
    final colors = context.fluentishColors;
    return CircleAvatar(
      radius: 28,
      backgroundColor: colors.surfaceStrong,
      backgroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
      child: url == null || url.isEmpty
          ? Text(profile.displayName.characters.first.toUpperCase())
          : null,
    );
  }
}
