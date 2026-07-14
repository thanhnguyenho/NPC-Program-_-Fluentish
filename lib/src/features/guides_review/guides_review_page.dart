import 'package:flutter/material.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';

class GuidesPage extends StatelessWidget {
  const GuidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.blush,
      body: GuidesScreen(),
    );
  }
}

class GuidesScreen extends StatefulWidget {
  const GuidesScreen({super.key});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  static const _filters = ['Nearby', 'Food', 'Routes', 'Saved'];

  static const _guides = [
    _GuideItem(
      category: 'Food',
      description: 'The best local vendors near you.',
      details:
          'A short beginner guide for ordering Vietnamese street food with confidence.',
      distance: '250 m',
      icon: Icons.restaurant_outlined,
      rating: '4/5',
      title: 'Street Food Basics',
    ),
    _GuideItem(
      category: 'Routes',
      description: 'A short walk littered with interesting spots.',
      details:
          'Follow a walking route through District 1. Each stop includes a practical phrase for asking directions or meeting friends.',
      distance: '0.8 km',
      icon: Icons.map_outlined,
      rating: '5 stops',
      title: 'District 1 Walk',
    ),
    _GuideItem(
      category: 'Nearby',
      description: 'Easy phrases to use when meeting someone over coffee.',
      details: 'Practise greetings and simple conversation prompts.',
      distance: '400 m',
      icon: Icons.local_cafe_outlined,
      rating: '4.7/5',
      title: 'Cafe Conversation',
    ),
    _GuideItem(
      category: 'Saved',
      description: 'Three phrase sets and two routes available offline.',
      details:
          'A dummy saved collection that contains greetings, phrases and walking routes.',
      distance: 'Offline',
      icon: Icons.download_done_outlined,
      rating: '5 items',
      title: 'Offline Guide Pack',
    ),
  ];

  String _query = '';
  String _selectedFilter = 'Nearby';

  List<_GuideItem> get _visibleGuides {
    final query = _query.trim().toLowerCase();

    return _guides.where((guide) {
      final matchesFilter = _selectedFilter == 'Nearby'
          ? guide.category != 'Saved'
          : guide.category == _selectedFilter;
      final matchesQuery = query.isEmpty ||
          guide.title.toLowerCase().contains(query) ||
          guide.description.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  void _openGuide(_GuideItem guide) {
    showModalBottomSheet<void>(
      backgroundColor: AppColors.shell,
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.xl),
        ),
      ),
      builder: (context) => _GuideDetailsSheet(guide: guide),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guides = _visibleGuides;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BackButton(),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Fluentish Guides',
              style: AppTextStyles.title.copyWith(fontSize: 36),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              style: AppTextStyles.body.copyWith(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Search guides, places, routes...',
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.pine,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final filter in _filters)
                  ChoiceChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    showCheckmark: false,
                    onSelected: (_) {
                      setState(() => _selectedFilter = filter);
                    },
                    backgroundColor: AppColors.pineMuted,
                    selectedColor: AppColors.pine,
                    labelStyle: AppTextStyles.body.copyWith(
                      color: AppColors.blush,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (guides.isEmpty)
              const _EmptyGuides()
            else
              for (final guide in guides) ...[
                _GuideCard(
                  guide: guide,
                  onTap: () => _openGuide(guide),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            if (_selectedFilter != 'Saved') ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Saved for later',
                style: AppTextStyles.title.copyWith(fontSize: 32),
              ),
              const SizedBox(height: AppSpacing.md),
              _SavedGuideCard(
                guide: _guides.last,
                onTap: () => _openGuide(_guides.last),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GuideItem {
  const _GuideItem({
    required this.category,
    required this.description,
    required this.details,
    required this.distance,
    required this.icon,
    required this.rating,
    required this.title,
  });

  final String category;
  final String description;
  final String details;
  final String distance;
  final IconData icon;
  final String rating;
  final String title;
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.guide, required this.onTap});

  final _GuideItem guide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      height: 164,
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Container(
            width: 132,
            height: double.infinity,
            decoration: const BoxDecoration(color: AppColors.shell),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  guide.icon,
                  color: AppColors.pineMuted,
                  size: 52,
                ),
                Positioned(
                  left: AppSpacing.sm,
                  top: AppSpacing.sm,
                  child: _MetadataPill(text: guide.distance),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    guide.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${guide.distance} · ${guide.rating}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.pineMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    guide.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body,
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

class _SavedGuideCard extends StatelessWidget {
  const _SavedGuideCard({required this.guide, required this.onTap});

  final _GuideItem guide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          const Icon(
            Icons.download_done_outlined,
            color: AppColors.pine,
            size: 34,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guide.title,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(guide.description, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataPill extends StatelessWidget {
  const _MetadataPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          color: AppColors.pine,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GuideDetailsSheet extends StatelessWidget {
  const _GuideDetailsSheet({required this.guide});

  final _GuideItem guide;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          MediaQuery.viewPaddingOf(context).bottom + AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.blush,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Icon(
                guide.icon,
                color: AppColors.pine,
                size: 64,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              guide.category.toUpperCase(),
              style: AppTextStyles.body.copyWith(
                color: AppColors.pineMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              guide.title,
              style: AppTextStyles.title.copyWith(fontSize: 30),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${guide.distance} · ${guide.rating}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.pineMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(guide.details,
                style: AppTextStyles.body.copyWith(fontSize: 16)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'What this guide includes',
              style: AppTextStyles.title.copyWith(fontSize: 21),
            ),
            const SizedBox(height: AppSpacing.sm),
            const _DetailRow(
              icon: Icons.chat_bubble_outline,
              text: 'Useful phrases and pronunciation notes',
            ),
            const _DetailRow(
              icon: Icons.place_outlined,
              text: 'Local context and practical tips',
            ),
            const _DetailRow(
              icon: Icons.bookmark_border,
              text: 'Save progress for later',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.pine, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

class _EmptyGuides extends StatelessWidget {
  const _EmptyGuides();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      child: Text(
        'No guides match your search.',
        style: AppTextStyles.body,
        textAlign: TextAlign.center,
      ),
    );
  }
}
