import 'package:flutter/material.dart';
import 'package:fluentish/src/shared/widgets/app_bottom_nav.dart';
import 'package:fluentish/src/features/language/language_page.dart';
import 'package:fluentish/src/shared/theme/app_spacing.dart';
import 'package:fluentish/src/shared/theme/app_text_styles.dart';
import 'package:fluentish/src/shared/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Core focus: Language & Translator (Index 1)
  int _currentIndex = 1;

  Widget _pageForIndex(int index) {
    switch (index) {
      case 0:
        return _buildTabPlaceholder('Home Dashboard', Icons.home_outlined);
      case 1:
        return const LanguagePage();
      case 2:
        return _buildTabPlaceholder('Soundboard', Icons.volume_up_outlined);
      case 3:
        return _buildTabPlaceholder('Community Hub', Icons.groups_2_outlined);
      case 4:
        return _buildTabPlaceholder('User Profile', Icons.person_outline);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTabPlaceholder(String title, IconData icon) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBEB),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 72, color: const Color(0xFF3E4E31)),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E4E31),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This module is trimmed to keep our GitHub repository focused exclusively on the Language & Offline Translation Core.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _currentIndex = 1),
                  icon: const Icon(Icons.translate, color: Colors.white),
                  label: const Text('Go to Language & Translator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E4E31),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pageForIndex(_currentIndex),
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
  const HomeScreen({super.key, required this.onNavigateToGuides});

  final VoidCallback onNavigateToGuides;

  static const _dummyGuides = [
    _GuidePreview(
      description: 'The best local vendors near you.',
      distance: '250 m',
      icon: Icons.restaurant_outlined,
      name: 'Street Food Basics',
      rating: '4/5',
    ),
    _GuidePreview(
      description: 'A short walk littered with interesting spots.',
      distance: '0.8 km',
      icon: Icons.map_outlined,
      name: 'District 1 Walk',
      rating: '5 stops',
    ),
    _GuidePreview(
      description: 'Easy phrases to use when meeting someone over coffee.',
      distance: '400 m',
      icon: Icons.local_cafe_outlined,
      name: 'Cafe Conversation',
      rating: '4.7/5',
    ),
  ];

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
          children: [
            const _PageHeader(),
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle('Favourite Phrases'),
            const SizedBox(height: AppSpacing.md),
            const _FavouritePhrasesGrid(),
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle('Nearby Recommendations'),
            const SizedBox(height: AppSpacing.md),
            for (final guide in _dummyGuides) ...[
              _GuidePreviewCard(
                guide: guide,
                onTap: onNavigateToGuides,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle('Soundboard Favourites'),
            const SizedBox(height: AppSpacing.md),
            const _SoundboardFavourites(),
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle('Active Friends'),
            const SizedBox(height: AppSpacing.md),
            const _BlankListCard(),
            const SizedBox(height: AppSpacing.md),
            const _SectionTitle('Find your Friends'),
            const SizedBox(height: AppSpacing.md),
            const _BlankListCard(),
            const SizedBox(height: AppSpacing.xxl),
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
          'Welcome Back, <User>!',
          style: AppTextStyles.title.copyWith(fontSize: 34),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Ready for another seamless interaction with the locals?',
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

class _FavouritePhrase {
  const _FavouritePhrase({
    required this.english,
    required this.vietnamese,
  });

  final String english;
  final String vietnamese;
}

class _FavouritePhrasesGrid extends StatelessWidget {
  const _FavouritePhrasesGrid();

  static const _phrases = [
    _FavouritePhrase(english: 'Hello', vietnamese: 'Xin chào'),
    _FavouritePhrase(english: 'Thank you', vietnamese: 'Cảm ơn'),
    _FavouritePhrase(english: 'Goodbye', vietnamese: 'Tạm biệt'),
    _FavouritePhrase(english: 'Excuse me', vietnamese: 'Xin lỗi'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.md;
        final cardWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final phrase in _phrases)
              SizedBox(
                width: cardWidth,
                child: _FavouritePhraseCard(phrase: phrase),
              ),
          ],
        );
      },
    );
  }
}

class _FavouritePhraseCard extends StatelessWidget {
  const _FavouritePhraseCard({required this.phrase});

  final _FavouritePhrase phrase;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      height: 140,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  phrase.english,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                constraints: const BoxConstraints.tightFor(
                  height: 32,
                  width: 32,
                ),
                padding: EdgeInsets.zero,
                tooltip: 'Remove from favourites',
                icon: const Icon(
                  Icons.star_border_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
            ],
          ),
          Text(
            phrase.vietnamese,
            style: AppTextStyles.body.copyWith(
              color: AppColors.pineMuted,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton.filled(
              onPressed: () {},
              constraints: const BoxConstraints.tightFor(
                height: 38,
                width: 38,
              ),
              padding: EdgeInsets.zero,
              tooltip: 'Play pronunciation',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.textMuted.withValues(alpha: 0.22),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.volume_up_outlined, size: 23),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidePreview {
  const _GuidePreview({
    required this.description,
    required this.distance,
    required this.icon,
    required this.name,
    required this.rating,
  });

  final String description;
  final String distance;
  final IconData icon;
  final String name;
  final String rating;
}

class _GuidePreviewCard extends StatelessWidget {
  const _GuidePreviewCard({
    required this.guide,
    required this.onTap,
  });

  final _GuidePreview guide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      height: 158,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 116,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.shell,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  guide.icon,
                  color: AppColors.pineMuted,
                  size: 48,
                ),
                Positioned(
                  left: AppSpacing.sm,
                  top: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.pillRadius,
                      ),
                    ),
                    child: Text(
                      guide.distance,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.pine,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  guide.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(fontSize: 22),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${guide.distance} · ${guide.rating}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.pineMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  guide.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.pineMuted,
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

class _SoundboardFavourite {
  const _SoundboardFavourite({
    required this.label,
    this.isHighlighted = false,
  });

  final bool isHighlighted;
  final String label;
}

class _SoundboardFavourites extends StatelessWidget {
  const _SoundboardFavourites();

  static const _favourites = [
    _SoundboardFavourite(label: 'Ở đâu?'),
    _SoundboardFavourite(label: 'Ngon quá'),
    _SoundboardFavourite(label: 'Tính tiền', isHighlighted: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < _favourites.length; index++) ...[
          Expanded(
            child: _SoundboardFavouriteButton(
              favourite: _favourites[index],
            ),
          ),
          if (index != _favourites.length - 1)
            const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _SoundboardFavouriteButton extends StatelessWidget {
  const _SoundboardFavouriteButton({required this.favourite});

  final _SoundboardFavourite favourite;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        favourite.isHighlighted ? AppColors.pine : AppColors.pineMuted;
    final foregroundColor =
        favourite.isHighlighted ? AppColors.blush : AppColors.pine;

    return SizedBox(
      height: 64,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  favourite.label,
                  maxLines: 1,
                  style: AppTextStyles.title.copyWith(
                    color: foregroundColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
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
