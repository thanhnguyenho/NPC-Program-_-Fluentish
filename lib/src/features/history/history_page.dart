import 'package:flutter/material.dart';

import 'package:fluentish/src/shared/shared.dart';

class _HistoryEntry {
  const _HistoryEntry({
    required this.term,
    required this.translation,
    required this.date,
    required this.icon,
  });

  final String term;
  final String translation;
  final String date; // group header, e.g. "Today", "Yesterday"
  final IconData icon;
}

/// Shows the user's past lookups, grouped by day, with search and a
/// "clear history" action.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _searchController = TextEditingController();
  String _query = '';

  // TODO: replace with real history pulled from local storage / backend.
  final List<_HistoryEntry> _allEntries = [
    const _HistoryEntry(
      term: 'Xin chào',
      translation: 'Hello',
      date: 'Today',
      icon: Icons.chat_bubble_outline,
    ),
    const _HistoryEntry(
      term: 'Cảm ơn',
      translation: 'Thank you',
      date: 'Today',
      icon: Icons.favorite_border,
    ),
    const _HistoryEntry(
      term: 'Bao nhiêu tiền?',
      translation: 'How much is it?',
      date: 'Yesterday',
      icon: Icons.shopping_bag_outlined,
    ),
    const _HistoryEntry(
      term: 'Ngon quá',
      translation: 'Delicious',
      date: 'Yesterday',
      icon: Icons.restaurant_outlined,
    ),
    const _HistoryEntry(
      term: 'Tạm biệt',
      translation: 'Goodbye',
      date: 'Earlier',
      icon: Icons.waving_hand_outlined,
    ),
    const _HistoryEntry(
      term: 'Nhà vệ sinh ở đâu?',
      translation: 'Where is the restroom?',
      date: 'Earlier',
      icon: Icons.wc_outlined,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<_HistoryEntry>> get _grouped {
    final filtered = _query.isEmpty
        ? _allEntries
        : _allEntries.where(
            (e) =>
                e.term.toLowerCase().contains(_query.toLowerCase()) ||
                e.translation.toLowerCase().contains(_query.toLowerCase()),
          );
    final map = <String, List<_HistoryEntry>>{};
    for (final e in filtered) {
      map.putIfAbsent(e.date, () => []).add(e);
    }
    return map;
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'This will remove all your saved lookup history. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _allEntries.clear());
              Navigator.pop(ctx);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red,)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;

    return Scaffold(
      backgroundColor: AppColors.shell,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.pine,
            padding: const EdgeInsets.fromLTRB(4, 50, AppSpacing.md, AppSpacing.md),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.blush),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'History',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.blush,
                      fontSize: 22,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.blush,
                  ),
                  tooltip: 'Clear history',
                  onPressed: _clearHistory,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: AppColors.pine),
              decoration: InputDecoration(
                hintText: 'Search history...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.cardSurface,
                contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: grouped.isEmpty
                ? const Center(
                    child: Text(
                      'No history found',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xs,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    children: [
                      for (final dateGroup in grouped.keys) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.xs,
                            top: AppSpacing.sm,
                            left: AppSpacing.xxs,
                          ),
                          child: Text(
                            dateGroup.toUpperCase(),
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            border: Border.all(color: AppColors.cardBorder),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.cardRadius,
                            ),
                          ),
                          child: Column(
                            children: [
                              for (var i = 0; i < grouped[dateGroup]!.length; i++) ...[
                                _HistoryTile(entry: grouped[dateGroup]![i]),
                                if (i != grouped[dateGroup]!.length - 1)
                                  const Divider(
                                    height: 1,
                                    indent: 52,
                                    color: AppColors.cardBorder,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final _HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: navigate to full lookup/detail view for this entry.
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.shell,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Icon(entry.icon, size: 18, color: AppColors.pine),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.term,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.pine,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    entry.translation,
                    style: AppTextStyles.body.copyWith(fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
