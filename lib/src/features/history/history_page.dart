import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fluentish/src/features/language/language_page.dart';
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
  final DateTime date;
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<_HistoryEntry>> _grouped(List<_HistoryEntry> entries) {
    final filtered = _query.isEmpty
        ? entries
        : entries.where(
            (e) =>
                e.term.toLowerCase().contains(_query.toLowerCase()) ||
                e.translation.toLowerCase().contains(_query.toLowerCase()),
          );
    final map = <String, List<_HistoryEntry>>{};
    for (final e in filtered) {
      map.putIfAbsent(_dateGroup(e.date), () => []).add(e);
    }
    return map;
  }

  String _dateGroup(DateTime date) {
    final now = DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return 'Earlier';
  }

  Stream<List<_HistoryEntry>> get _historyStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(const <_HistoryEntry>[]);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .snapshots()
        .map((snapshot) {
      final entries = snapshot.docs.map((document) {
        final data = document.data();
        final timestamp = data['createdAt'];
        return _HistoryEntry(
          term: (data['term'] ?? data['source'] ?? '').toString(),
          translation: (data['translation'] ?? data['target'] ?? '').toString(),
          date: timestamp is Timestamp ? timestamp.toDate() : DateTime(1970),
          icon: Icons.translate_outlined,
        );
      }).where((entry) => entry.term.isNotEmpty).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return entries;
    });
  }

  Future<void> _clearHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final history = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history');
    final snapshot = await history.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final document in snapshot.docs) {
      batch.delete(document.reference);
    }
    if (snapshot.docs.isNotEmpty) await batch.commit();
  }

  void _confirmClearHistory() {
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
            onPressed: () async {
              await _clearHistory();
              if (!ctx.mounted) return;
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
                  onPressed: _confirmClearHistory,
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
            child: StreamBuilder<List<_HistoryEntry>>(
              stream: _historyStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Unable to load history'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final grouped = _grouped(snapshot.data!);
                return grouped.isEmpty
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
                  );
              },
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
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LanguagePage()),
        );
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
