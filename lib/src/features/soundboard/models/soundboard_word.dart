class SoundboardWord {
  final String english;
  final String vietnamese;
  final String category;
  final String englishAudio;
  final String vietnameseAudio;
  final bool favourite;

  const SoundboardWord({
    required this.english,
    required this.vietnamese,
    required this.category,
    required this.englishAudio,
    required this.vietnameseAudio,
    this.favourite = false,
  });
}