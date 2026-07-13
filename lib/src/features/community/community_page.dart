import 'package:flutter/material.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.bottomNavHeight + AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Header(),
            SizedBox(height: AppSpacing.xl),
            _SectionTitle('Active Friends'),
            SizedBox(height: AppSpacing.md),
            _FriendsPlaceholder(),
            SizedBox(height: AppSpacing.xl),
            _SectionTitle('Find a Friend'),
            SizedBox(height: AppSpacing.md),
            _MapPlaceholder(height: 210),
            SizedBox(height: AppSpacing.xl),
            _SectionTitle('Nearby Notes'),
            SizedBox(height: AppSpacing.md),
            _NotesPlaceholder(),
            SizedBox(height: AppSpacing.xl),
            _SectionTitle('Find your Way'),
            SizedBox(height: AppSpacing.md),
            _RoutePlaceholder(),
            SizedBox(height: AppSpacing.xl),
            _SectionTitle('Connect with Fluentish'),
            SizedBox(height: AppSpacing.md),
            _SocialPlaceholder(),
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fluentish Community',
            style: AppTextStyles.title.copyWith(fontSize: 34)),
        const SizedBox(height: AppSpacing.xs),
        Text('Subtitle text',
            style: AppTextStyles.body.copyWith(color: AppColors.pineMuted)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.title.copyWith(fontSize: 28));
}

class _FriendsPlaceholder extends StatelessWidget {
  const _FriendsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: List.generate(8, (_) => const _FriendPlaceholder()),
      ),
    );
  }
}

class _FriendPlaceholder extends StatelessWidget {
  const _FriendPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 58,
      child: Column(
        children: [
          CircleAvatar(radius: 27, backgroundColor: AppColors.shell),
          SizedBox(height: AppSpacing.xs),
          _BlankLine(width: 48),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      height: height,
      padding: EdgeInsets.zero,
      child: const Center(
          child:
              Icon(Icons.map_outlined, size: 52, color: AppColors.pineMuted)),
    );
  }
}

class _NotesPlaceholder extends StatelessWidget {
  const _NotesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: List.generate(
          2,
          (_) => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                CircleAvatar(radius: 24, backgroundColor: AppColors.shell),
                SizedBox(width: AppSpacing.md),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      _BlankLine(width: 145),
                      SizedBox(height: AppSpacing.xs),
                      _BlankLine(width: 105),
                    ])),
                SizedBox(width: AppSpacing.sm),
                _BlankPill(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoutePlaceholder extends StatelessWidget {
  const _RoutePlaceholder();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const SizedBox(
              height: 170,
              child: Center(
                  child: Icon(Icons.map_outlined,
                      size: 48, color: AppColors.pineMuted))),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(children: const [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _BlankLine(width: 130, height: 14),
                    SizedBox(height: AppSpacing.xs),
                    _BlankLine(width: 190),
                  ])),
              _BlankPill(),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SocialPlaceholder extends StatelessWidget {
  const _SocialPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BlankLine(width: 200, height: 16),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
                5,
                (_) => const CircleAvatar(
                    radius: 22, backgroundColor: AppColors.pineMuted)),
          ),
          const SizedBox(height: AppSpacing.md),
          const _BlankLine(width: double.infinity),
        ],
      ),
    );
  }
}

class _BlankLine extends StatelessWidget {
  const _BlankLine({required this.width, this.height = 10});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.textMuted.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        ),
      );
}

class _BlankPill extends StatelessWidget {
  const _BlankPill();

  @override
  Widget build(BuildContext context) => Container(
        width: 68,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.pineMuted,
          borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        ),
      );
}
