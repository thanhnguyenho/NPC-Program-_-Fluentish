class SoundboardWord {
  final String english;
  final String vietnamese;
  final String category;
  final String audioPath;
  final bool favourite;

  const SoundboardWord({
    required this.english,
    required this.vietnamese,
    required this.category,
    required this.audioPath,
    this.favourite = false,
  });
}