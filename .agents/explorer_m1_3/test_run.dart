import 'dart:math';

bool _isProperNoun(String word) {
  final w = word.trim().toLowerCase();
  const properNouns = {
    'vietnam', 'việt nam', 'english', 'vietnamese', 'tiếng anh', 'tiếng việt',
    'hanoi', 'hà nội', 'ho chi minh', 'hồ chí minh', 'saigon', 'sài gòn',
    'da nang', 'đà nẵng', 'new york', 'london', 'paris', 'tokyo', 'seoul',
    'beijing', 'singapore', 'thailand', 'thái lan', 'japan', 'nhật bản',
    'korea', 'hàn quốc', 'america', 'mỹ', 'usa', 'uk', 'france', 'pháp',
    'china', 'trung quốc', 'vn123', 'i', 'nhật', 'hàn', 'nga', 'đức'
  };
  if (properNouns.contains(w)) return true;
  if (w.contains(' ')) {
    for (final pn in properNouns) {
      if (w == pn || w.startsWith('$pn ')) return true;
    }
  }
  return false;
}

String _formatInsideSentence(String text) {
  if (text.isEmpty) return text;
  if (_isProperNoun(text)) return text;
  final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  final formattedWords = <String>[];
  for (int i = 0; i < words.length; i++) {
    final w = words[i];
    if (_isProperNoun(w)) {
      formattedWords.add(w);
    } else {
      formattedWords.add(w.toLowerCase());
    }
  }
  return formattedWords.join(' ');
}

void main() {
  print('format("Bảo Tôi"): "${_formatInsideSentence("Bảo Tôi")}"');
  print('format("Bảo / Kể"): "${_formatInsideSentence("Bảo / Kể")}"');
  print('isProperNoun("Bảo"): ${_isProperNoun("Bảo")}');
  print('isProperNoun("Tôi"): ${_isProperNoun("Tôi")}');
  print('isProperNoun("i"): ${_isProperNoun("i")}');
  print('isProperNoun("Bảo Tôi"): ${_isProperNoun("Bảo Tôi")}');
}
