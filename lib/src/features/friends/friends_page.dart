import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/shared.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  static const _planItems = [
    '1. Practice 5 food phrases',
    '2. Start District 1 Walk',
    '3. Message a nearby friend',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.figmaFrameWidth,
            ),
            child: const _TodayPlanSection(),
          ),
        ),
      ),
    );
  }
}

class _TodayPlanSection extends StatelessWidget {
  const _TodayPlanSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Today’s Plan',
          style: GoogleFonts.gulzar(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w400,
            height: 38 / 30,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppCard(
          height: 118,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in FriendsPage._planItems)
                  Text(item, style: _planItemStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TextStyle get _planItemStyle {
    return GoogleFonts.itim(
      color: AppColors.pine,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1,
      letterSpacing: 0,
    );
  }
}
