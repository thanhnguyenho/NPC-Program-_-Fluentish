import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/shared.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

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
              ],
            ),
          ),
        ),
      ),
    );
  }
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
