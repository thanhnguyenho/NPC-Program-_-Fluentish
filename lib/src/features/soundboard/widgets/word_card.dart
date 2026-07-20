import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WordCard extends StatefulWidget {
  final String id;
  final String english;
  final String vietnamese;
  final String category;
  final String englishAudio;
  final String vietnameseAudio;
  final bool isVietnamese;
  final bool favourite;
  final VoidCallback? onFavouriteChanged;

  const WordCard({
    super.key,
    required this.id,
    required this.english,
    required this.vietnamese,
    required this.category,
    required this.englishAudio,
    required this.vietnameseAudio,
    required this.isVietnamese,
    this.favourite = false,
    this.onFavouriteChanged,
  });

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  late bool _isFavourite;

  @override
  void initState() {
    super.initState();

    _isFavourite = widget.favourite;

    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;

      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void didUpdateWidget(covariant WordCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.favourite != widget.favourite) {
      setState(() {
        _isFavourite = widget.favourite;
      });
    }
  }

  Future<void> _playAudio() async {
    final audioPath = widget.isVietnamese
        ? widget.vietnameseAudio
        : widget.englishAudio;

    if (audioPath.isEmpty) return;

    try {
      await _audioPlayer.stop();

      setState(() {
        _isPlaying = true;
      });

      await _audioPlayer.play(
        AssetSource(audioPath),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isPlaying = false;
      });

      debugPrint('Error playing audio: $error');
    }
  }

  Future<void> _toggleFavourite() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('User not logged in');
      return;
    }

    final languageId = widget.isVietnamese
        ? 'vietnamese'
        : 'english';
    final favouriteId = '${widget.id}_$languageId';

    final favouriteReference = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favouriteSoundboardBites')
        .doc(favouriteId);

    try {
      if (_isFavourite) {
        await favouriteReference.delete();
      } else {
        await favouriteReference.set({
          'english': widget.english,
          'vietnamese': widget.vietnamese,
          'category': widget.category,
          'englishAudio': widget.englishAudio,
          'vietnameseAudio': widget.vietnameseAudio,
          'preferredLanguage': widget.isVietnamese
              ? 'vietnamese'
              : 'english',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      setState(() {
        _isFavourite = !_isFavourite;
      });

      widget.onFavouriteChanged?.call();

    } catch (error) {
      debugPrint('Error toggling favourite: $error');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _playAudio,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isPlaying
              ? const Color(0xFF868F54)
              : const Color(0xFFF8F5F1).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.isVietnamese
                        ? widget.english
                        : widget.vietnamese,
                    style: TextStyle(
                      color: _isPlaying
                          ? Colors.white
                          : const Color(0xFF3E4E31),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _toggleFavourite,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _isFavourite
                        ? Icons.star
                        : Icons.star_border,
                    color: _isFavourite
                        ? Colors.amber
                        : _isPlaying
                            ? Colors.white
                            : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.isVietnamese
                  ? widget.vietnamese
                  : widget.english,
              style: TextStyle(
                color: _isPlaying
                    ? Colors.white
                    : const Color(0xFF3E4E31).withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),

            const Spacer(),

            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: _isPlaying
                      ? const Color(0xFF4E5A45)
                      : const Color(0xFF3E4E31).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying
                      ? Icons.graphic_eq
                      : Icons.volume_up,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}