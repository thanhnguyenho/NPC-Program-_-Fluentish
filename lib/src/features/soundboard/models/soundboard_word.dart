class SoundboardWord {
  final String id;
  final String english;
  final String vietnamese;
  final String category;
  final String englishAudio;
  final String vietnameseAudio;
  final bool favourite;

  const SoundboardWord({
    required this.id,
    required this.english,
    required this.vietnamese,
    required this.category,
    required this.englishAudio,
    required this.vietnameseAudio,
    this.favourite = false,
  });
}