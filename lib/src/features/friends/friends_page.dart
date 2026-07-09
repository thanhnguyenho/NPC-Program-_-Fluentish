import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/shared.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  static const _friends = [
    _Friend(
      avatar: AppAssets.friendChloe,
      distance: '0.8 km',
      isOnline: true,
      name: 'Thanh Nguyen (Chloe)',
      note: 'Coffee after class?',
    ),
    _Friend(
      avatar: AppAssets.friendChris,
      distance: '1.1 km',
      hasRoute: true,
      isOnline: true,
      name: 'Chris Crowne',
      note: 'OMW in 8 min.',
    ),
    _Friend(
      avatar: AppAssets.friendMary,
      distance: '1.3 km',
      isOnline: true,
      name: 'mary ⟡ ﾟ.',
      note: 'Saved you a seat.',
    ),
    _Friend(
      avatar: AppAssets.friendMinh,
      distance: '1.6 km',
      isOnline: true,
      name: 'Đồng Minh',
      note: 'Study room later.',
    ),
    _Friend(
      avatar: AppAssets.friendKeem,
      distance: '1.9 km',
      isOnline: true,
      name: 'Keem',
      note: 'New vocab drop.',
    ),
    _Friend(
      avatar: AppAssets.friendPhat,
      distance: '2.3 km',
      name: 'Tấn Phát',
      note: 'On campus now.',
    ),
    _Friend(
      avatar: AppAssets.friendAnhQuan,
      distance: '0.4 km',
      isOnline: true,
      name: 'AnhQuan',
      note: 'Free to chat.',
    ),
    _Friend(
      avatar: AppAssets.friendVinhTien,
      distance: '0.2 km',
      name: 'Vĩnh Tiến',
      note: 'Library later.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.figmaFrameWidth,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FriendsHeader(),
                _FriendsNearbySection(),
                AppBottomNav(
                  currentIndex: 3,
                  onItemSelected: _ignoreNavTap,
                ),
                _CloseNowSection(),
                _FriendsFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _ignoreNavTap(int index) {}
}

class _Friend {
  const _Friend({
    required this.avatar,
    required this.distance,
    this.hasRoute = false,
    this.isOnline = false,
    required this.name,
    required this.note,
  });

  final String avatar;
  final String distance;
  final bool hasRoute;
  final bool isOnline;
  final String name;
  final String note;
}

class _FriendsHeader extends StatelessWidget {
  const _FriendsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 79, 22, 0),
      child: Column(
        children: [
          SizedBox(
            height: 51,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_left),
                    iconSize: 26,
                    color: Colors.black,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      height: 44,
                      width: 44,
                    ),
                    tooltip: 'Back',
                  ),
                ),
                Text(
                  'Friends',
                  style: GoogleFonts.gulzar(
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    height: 48 / 32,
                    letterSpacing: 0,
                  ),
                  textAlign: TextAlign.center,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 36,
                    width: 43,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.pine,
                        foregroundColor: AppColors.blush,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Icon(Icons.add, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          const _SearchField(),
          const SizedBox(height: 16),
          const _FriendTabs(),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xEBD7D0C5),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.black.withValues(alpha: 0.62)),
          const SizedBox(width: 11),
          Text(
            'Search friends...',
            style: GoogleFonts.inter(
              color: Colors.black.withValues(alpha: 0.55),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 22 / 16,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendTabs extends StatelessWidget {
  const _FriendTabs();

  static const _tabs = ['Friends', 'Requests', 'Nearby'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < _tabs.length; index++) ...[
          Expanded(
            child: _FriendTab(
              isSelected: index == 0,
              label: _tabs[index],
            ),
          ),
          if (index != _tabs.length - 1) const SizedBox(width: 18),
        ],
      ],
    );
  }
}

class _FriendTab extends StatelessWidget {
  const _FriendTab({
    required this.isSelected,
    required this.label,
  });

  final bool isSelected;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pine : const Color(0xFF868F54),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected ? AppColors.blush : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 18 / 13,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _FriendsNearbySection extends StatelessWidget {
  const _FriendsNearbySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Friends nearby',
                    style: GoogleFonts.gulzar(
                      color: AppColors.pine,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      height: 30 / 24,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  '8 friends',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF4E5A45),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 14 / 11,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          for (final friend in FriendsPage._friends) ...[
            _FriendRow(friend: friend),
            if (friend != FriendsPage._friends.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({required this.friend});

  final _Friend friend;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.52)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: const Color(0xFF2B3824).withValues(alpha: 0.08),
            offset: const Offset(0, 6),
            spreadRadius: -8,
          ),
        ],
        color: Colors.white.withValues(alpha: 0.34),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          _FriendAvatar(friend: friend),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.pine,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 15 / 12,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  friend.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xE64E5A45),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w400,
                    height: 12 / 9.5,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 50,
            child: Text(
              friend.distance,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: const Color(0xFF868F54),
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                height: 12 / 9.5,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          if (friend.hasRoute) ...[
            const SizedBox(width: 6),
            const _RouteChip(),
          ],
          const SizedBox(width: 6),
          SizedBox(
            height: 32,
            width: 42,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.pine.withValues(alpha: 0.94),
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Icon(Icons.chat_bubble_outline, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({required this.friend});

  final _Friend friend;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      width: 42,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipOval(
              child: Image.asset(friend.avatar, fit: BoxFit.cover),
            ),
          ),
          if (friend.isOnline)
            Positioned(
              bottom: 1,
              right: 0,
              child: Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.5),
                  color: const Color(0xFF93CF75),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RouteChip extends StatelessWidget {
  const _RouteChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 46,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x470F4DB2)),
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x1F1A75F2),
      ),
      alignment: Alignment.center,
      child: Text(
        'Route',
        style: GoogleFonts.inter(
          color: const Color(0xFF0F4DB2),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _CloseNowSection extends StatelessWidget {
  const _CloseNowSection();

  static const _routes = [
    _CloseFriend(
      avatar: AppAssets.friendVinhTien,
      distance: '0.2 km · 5 min walk',
      name: 'Vĩnh Tiến',
    ),
    _CloseFriend(
      avatar: AppAssets.friendAnhQuan,
      distance: '0.4 km · 8 min walk',
      name: 'AnhQuan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 67, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Close Now',
                      style: GoogleFonts.gulzar(
                        color: Colors.black,
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                        height: 32 / 27,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Nearest friends with route shortcuts',
                      style: GoogleFonts.inter(
                        color: const Color(0xC74E5A45),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        height: 15 / 11.5,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const _NearbyPill(),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 146,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.58)),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  blurRadius: 28,
                  color: AppColors.pine.withValues(alpha: 0.13),
                  offset: const Offset(0, 14),
                  spreadRadius: -10,
                ),
              ],
              color: const Color(0xADF8F5F1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned(
                  bottom: -15,
                  left: -19,
                  right: -16,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color(0x6BE7E9D8),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(11, 17, 11, 0),
                  child: Row(
                    children: [
                      for (var index = 0; index < _routes.length; index++) ...[
                        Expanded(
                            child: _CloseFriendCard(friend: _routes[index])),
                        if (index != _routes.length - 1)
                          const SizedBox(width: 17),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseFriend {
  const _CloseFriend({
    required this.avatar,
    required this.distance,
    required this.name,
  });

  final String avatar;
  final String distance;
  final String name;
}

class _NearbyPill extends StatelessWidget {
  const _NearbyPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 82,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 28,
            color: AppColors.pine.withValues(alpha: 0.07),
            offset: const Offset(0, 14),
            spreadRadius: -10,
          ),
        ],
        color: Colors.white.withValues(alpha: 0.50),
      ),
      alignment: Alignment.center,
      child: Text(
        '2 nearby',
        style: GoogleFonts.inter(
          color: AppColors.pine,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 11 / 10,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _CloseFriendCard extends StatelessWidget {
  const _CloseFriendCard({required this.friend});

  final _CloseFriend friend;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.66)),
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.44),
      ),
      padding: const EdgeInsets.fromLTRB(7, 11, 8, 8),
      child: Row(
        children: [
          _CloseAvatar(asset: friend.avatar),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.pine,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    height: 14 / 11.5,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  friend.distance,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.textSoft,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w400,
                    height: 12 / 9.5,
                    letterSpacing: 0,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 20,
                  width: 74,
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.pine,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Route',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        height: 11 / 9.5,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseAvatar extends StatelessWidget {
  const _CloseAvatar({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: 46,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: ClipOval(
              child: Image.asset(asset, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            bottom: 3,
            right: 3,
            child: Container(
              height: 9,
              width: 9,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.2),
                color: const Color(0xFF4CBD51),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendsFooter extends StatelessWidget {
  const _FriendsFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 306,
      margin: const EdgeInsets.only(top: 48),
      decoration: const BoxDecoration(
        color: Color(0xFFF2D6D6),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -43,
            top: 36,
            child: Transform.rotate(
              angle: 0.14,
              child: Container(
                height: 38,
                width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
            ),
          ),
          Positioned(
            right: -56,
            top: -10,
            child: Transform.rotate(
              angle: -0.17,
              child: Container(
                height: 40,
                width: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0x29B2C4AD),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 20,
            right: 20,
            top: 26,
            child: _FooterCard(),
          ),
          Positioned(
            left: 26,
            bottom: 21,
            child: Text(
              '© 2026 Fluentish. All rights reserved.',
              style: GoogleFonts.inter(
                color: const Color(0x944E5A45),
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 13 / 10,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterCard extends StatelessWidget {
  const _FooterCard();

  static const _socials = [
    _SocialLink(label: 'fb', icon: 'f', color: Color(0xFF2F6FDA)),
    _SocialLink(label: 'insta', icon: '◎', color: Color(0xFFE44D7A)),
    _SocialLink(label: 'tiktok', icon: 't', color: Color(0xFF10151A)),
    _SocialLink(label: 'mail', icon: '✉', color: AppColors.pine),
    _SocialLink(label: 'web', icon: '⊕', color: Color(0xFF96A35B)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 232,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            color: const Color(0xFF1F291A).withValues(alpha: 0.18),
            offset: const Offset(0, 14),
            spreadRadius: -12,
          ),
        ],
        color: Colors.white.withValues(alpha: 0.52),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 141,
            top: 11,
            child: Container(
              height: 5,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: const Color(0x2E142421),
              ),
            ),
          ),
          Positioned(
            left: 19,
            top: 31,
            child: Container(
              height: 39,
              width: 39,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: const Color(0xFF1F291A).withValues(alpha: 0.24),
                    offset: const Offset(0, 6),
                    spreadRadius: -5,
                  ),
                ],
                color: const Color(0xFFF2D6D6),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(AppAssets.fluentishLogo, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            left: 77,
            right: 24,
            top: 30,
            child: Text(
              'Connect with Fluentish',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: const Color(0xFF121C1A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 20 / 18,
                letterSpacing: 0,
              ),
            ),
          ),
          Positioned(
            left: 77,
            right: 24,
            top: 57,
            child: Text(
              'Follow updates, community notes, and\nnearby language moments.',
              style: GoogleFonts.inter(
                color: const Color(0xB82B3833),
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 14 / 11,
                letterSpacing: 0,
              ),
            ),
          ),
          Positioned(
            left: 27,
            right: 27,
            top: 103,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final social in _socials) _SocialButton(social: social),
              ],
            ),
          ),
          Positioned(
            left: 27,
            right: 29,
            top: 171,
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.58)),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withValues(alpha: 0.46),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'hello@fluentish.app',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xDB17241F),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Text(
                    'Privacy · Terms',
                    style: GoogleFonts.inter(
                      color: const Color(0x944E5A45),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialLink {
  const _SocialLink({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final String icon;
  final String label;
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.social});

  final _SocialLink social;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      child: Column(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: const Color(0xFF1F291A).withValues(alpha: 0.10),
                  offset: const Offset(0, 4),
                  spreadRadius: -7,
                ),
              ],
              color: social.color,
            ),
            alignment: Alignment.center,
            child: Text(
              social.icon,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            social.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: const Color(0x944E5A45),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
