import 'package:flutter/material.dart';
import 'package:fluentish/src/shared/widgets/app_bottom_nav.dart';
import 'package:fluentish/src/shared/widgets/app_card.dart';
import 'package:fluentish/src/features/language/language_page.dart';
// import 'package:fluentish/src/features/soundboard/soundboard_page.dart';
// import 'package:fluentish/src/features/community/community_page.dart';
// import 'package:fluentish/src/features/profile/profile_page.dart';
import 'package:fluentish/src/shared/theme/app_spacing.dart';
import 'package:fluentish/src/shared/theme/app_text_styles.dart';
import 'package:fluentish/src/shared/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final _pages = const [
    HomeScreen(),
    LanguagePage(),
    //SoundboardPage(),
    //CommunityPage(),
    //ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.bottomNavHeight + AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PageHeader(),
            SizedBox(height: AppSpacing.xl),
            _SectionTitle('Section Title'),
            SizedBox(height: AppSpacing.md),
            _BlankGrid(),
            SizedBox(height: AppSpacing.xl),
            _SectionTitle('Section Title'),
            SizedBox(height: AppSpacing.md),
            _LargeBlankCard(),
            SizedBox(height: AppSpacing.md),
            _LargeBlankCard(),
            SizedBox(height: AppSpacing.xl),
            _SectionTitle('Section Title'),
            SizedBox(height: AppSpacing.md),
            _BlankChipRow(),
            SizedBox(height: AppSpacing.xl),
            _SectionTitle('Section Title'),
            SizedBox(height: AppSpacing.md),
            _BlankListCard(),
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Page Title',
          style: AppTextStyles.title.copyWith(fontSize: 34),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Subtitle text',
          style: AppTextStyles.body.copyWith(
            color: AppColors.pineMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.title.copyWith(fontSize: 28),
    );
  }
}

class _BlankGrid extends StatelessWidget {
  const _BlankGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.md;
        final cardWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(
            4,
            (index) => SizedBox(
              width: cardWidth,
              child: const _SmallBlankCard(),
            ),
          ),
        );
      },
    );
  }
}

class _SmallBlankCard extends StatelessWidget {
  const _SmallBlankCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      height: 90,
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _BlankLine(width: 90, height: 14),
          SizedBox(height: AppSpacing.xs),
          _BlankLine(width: 130, height: 10),
        ],
      ),
    );
  }
}

class _LargeBlankCard extends StatelessWidget {
  const _LargeBlankCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      height: 150,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 105,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.shell,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BlankLine(width: 130, height: 16),
                SizedBox(height: AppSpacing.xs),
                _BlankLine(width: 90, height: 10),
                SizedBox(height: AppSpacing.sm),
                _BlankLine(width: double.infinity, height: 10),
                SizedBox(height: AppSpacing.xxs),
                _BlankLine(width: 160, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlankChipRow extends StatelessWidget {
  const _BlankChipRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(
        5,
        (index) => Container(
          height: 38,
          width: 88,
          decoration: BoxDecoration(
            color: AppColors.pineMuted,
            borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
          ),
        ),
      ),
    );
  }
}

class _BlankListCard extends StatelessWidget {
  const _BlankListCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: List.generate(
          4,
          (index) => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: _BlankListTile(),
          ),
        ),
      ),
    );
  }
}

class _BlankListTile extends StatelessWidget {
  const _BlankListTile();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.shell,
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _BlankLine(width: double.infinity, height: 12),
        ),
      ],
    );
  }
}

class _BlankLine extends StatelessWidget {
  const _BlankLine({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.textMuted.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
      ),
    );
  }
}
