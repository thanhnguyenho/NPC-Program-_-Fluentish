class SoundboardWord {
  final String english;
  final String vietnamese;
  final String category;
  final bool favourite;

  const SoundboardWord({
    required this.english,
    required this.vietnamese,
    required this.category,
    this.favourite = false,
  });
}