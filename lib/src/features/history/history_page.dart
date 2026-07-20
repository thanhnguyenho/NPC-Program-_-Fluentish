import 'package:audioplayers/audioplayers.dart';
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
    this.type = 'translation',
    this.audioPath = '',
    this.category = '',
  });

  final String term;
  final String translation;
  final DateTime date;
  final String type;
  final String audioPath;
  final String category;

  bool get isSoundboard => type == 'soundboard' && audioPath.isNotEmpty;
}

/// Shows the signed-in user's past lookups, grouped by day.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _searchController = TextEditingController();
  final _audioPlayer = AudioPlayer();
  String _query = '';
  String? _playingAudioPath;

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Map<String, List<_HistoryEntry>> _grouped(List<_HistoryEntry> entries) {
    final query = _query.toLowerCase();
    final filtered = query.isEmpty
        ? entries
        : entries
            .where(
              (entry) =>
                  entry.term.toLowerCase().contains(query) ||
                  entry.translation.toLowerCase().contains(query),
            )
            .toList();
    final groups = <String, List<_HistoryEntry>>{};
    for (final entry in filtered) {
      groups.putIfAbsent(_dateGroup(entry.date), () => []).add(entry);
    }
    return groups;
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
      final entries = snapshot.docs
          .map((document) {
            final data = document.data();
            final timestamp = data['createdAt'];
            return _HistoryEntry(
              term: (data['term'] ?? data['source'] ?? '').toString(),
              translation:
                  (data['translation'] ?? data['target'] ?? '').toString(),
              date:
                  timestamp is Timestamp ? timestamp.toDate() : DateTime(1970),
              type: (data['type'] ?? 'translation').toString(),
              audioPath: (data['audioPath'] ?? '').toString(),
              category: (data['category'] ?? '').toString(),
            );
          })
          .where((entry) => entry.term.isNotEmpty)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return entries;
    });
  }

  Future<void> _openEntry(_HistoryEntry entry) async {
    if (!entry.isSoundboard) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LanguagePage(initialQuery: entry.term),
        ),
      );
      return;
    }

    try {
      await _audioPlayer.stop();
      if (mounted) setState(() => _playingAudioPath = entry.audioPath);
      await _audioPlayer.play(AssetSource(entry.audioPath));
      await _audioPlayer.onPlayerComplete.first;
    } catch (error) {
      debugPrint('Could not replay soundboard history: $error');
    } finally {
      if (mounted) setState(() => _playingAudioPath = null);
    }
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'This will remove all your saved lookup history. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _clearHistory();
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.header,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              4,
              50,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.onHeader),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'History',
                    style: AppTextStyles.title.copyWith(
                      color: colors.onHeader,
                      fontSize: 22,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: colors.onHeader,
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
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Search history...',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.cardSurface,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
                if (grouped.isEmpty) {
                  return const Center(child: Text('No history found'));
                }

                return ListView(
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
                          borderRadius:
                              BorderRadius.circular(AppSpacing.cardRadius),
                        ),
                        child: Column(
                          children: [
                            for (var index = 0;
                                index < grouped[dateGroup]!.length;
                                index++) ...[
                              _HistoryTile(
                                entry: grouped[dateGroup]![index],
                                isPlaying: _playingAudioPath ==
                                    grouped[dateGroup]![index].audioPath,
                                onTap: () =>
                                    _openEntry(grouped[dateGroup]![index]),
                              ),
                              if (index != grouped[dateGroup]!.length - 1)
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
  const _HistoryTile({
    required this.entry,
    required this.isPlaying,
    required this.onTap,
  });

  final _HistoryEntry entry;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
              child: Icon(
                entry.isSoundboard
                    ? (isPlaying ? Icons.graphic_eq : Icons.volume_up_outlined)
                    : Icons.translate_outlined,
                size: 18,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.term,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    entry.translation,
                    style: AppTextStyles.body.copyWith(fontSize: 12.5),
                  ),
                  if (entry.isSoundboard && entry.category.isNotEmpty)
                    Text(
                      'Soundboard · ${entry.category}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              entry.isSoundboard ? Icons.play_arrow : Icons.chevron_right,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
