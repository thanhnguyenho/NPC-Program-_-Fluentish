import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:io';
import 'package:fluentish/src/features/language/translator_engine.dart';
import 'package:fluentish/src/features/language/phrase_library.dart';
import 'package:fluentish/src/features/common/smart_search_bar.dart';
import 'package:fluentish/src/services/settings_controller.dart';
import 'package:fluentish/src/shared/shared.dart';

class LanguagePage extends StatelessWidget {
  final String? initialSourceText;
  final String? initialTargetText;
  final String? initialSourceLang;
  final String? initialTargetLang;
  final String? initialQuery;
  final AuthGateway? auth;
  final FavouriteDataSource? favouriteRepository;

  const LanguagePage({
    super.key,
    this.initialSourceText,
    this.initialTargetText,
    this.initialSourceLang,
    this.initialTargetLang,
    this.initialQuery,
    this.auth,
    this.favouriteRepository,
  });

  @override
  Widget build(BuildContext context) {
    return LanguageTranslatorScreen(
      initialSourceText: initialSourceText ?? initialQuery,
      initialTargetText: initialTargetText,
      initialSourceLang: initialSourceLang,
      initialTargetLang: initialTargetLang,
      initialQuery: initialQuery,
      auth: auth,
      favouriteRepository: favouriteRepository,
    );
  }
}

class LanguageTranslatorScreen extends StatefulWidget {
  final String? initialSourceText;
  final String? initialTargetText;
  final String? initialSourceLang;
  final String? initialTargetLang;
  final String? initialQuery;
  final AuthGateway? auth;
  final FavouriteDataSource? favouriteRepository;

  const LanguageTranslatorScreen({
    super.key,
    this.initialSourceText,
    this.initialTargetText,
    this.initialSourceLang,
    this.initialTargetLang,
    this.initialQuery,
    this.auth,
    this.favouriteRepository,
  });

  @override
  State<LanguageTranslatorScreen> createState() =>
      _LanguageTranslatorScreenState();
}

class _LanguageTranslatorScreenState extends State<LanguageTranslatorScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();

  String _sourceLang = 'English';
  String _targetLang = 'Vietnamese';
  String _translatedText = '';

  bool _isSourceStarred = false;
  bool _isTargetStarred = false;
  bool _isFavouriteBusy = false;
  late final AuthGateway _auth;
  late final FavouriteDataSource _favourites;
  StreamSubscription<List<FavouritePhraseRecord>>? _favouriteSubscription;
  List<FavouritePhraseRecord> _savedPhrases = const [];
  String? _spellingCorrectionSuggestion;
  bool _isTranslating = false;
  Timer? _translationDebounceTimer;
  // Debounce timer: only record to history AFTER user stops typing for 800ms
  Timer? _historyDebounceTimer;
  int _translateRequestId = 0;

  // Clean initial history & favourites
  final List<Map<String, String>> _historyList = [
    {
      'source': 'How much is this?',
      'target': 'Cái này giá bao nhiêu?',
      'time': 'Just now'
    },
    {
      'source': 'Can you speak slower?',
      'target': 'Bạn có thể nói chậm lại không?',
      'time': '2 mins ago'
    },
    {
      'source': 'Where is the nearest hospital?',
      'target': 'Bệnh viện gần nhất ở đâu?',
      'time': '10 mins ago'
    },
    {
      'source': 'Thank you very much',
      'target': 'Xin cảm ơn rất nhiều',
      'time': '1 hour ago'
    },
    {
      'source': 'Can you explain it again?',
      'target': 'Bạn có thể giải thích lại không?',
      'time': 'Yesterday'
    },
  ];

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? Auth.instance;
    _favourites = widget.favouriteRepository ?? FavouriteRepository();
    _sourceLang =
        widget.initialSourceLang ?? SettingsController.instance.sourceLanguage;
    _targetLang =
        widget.initialTargetLang ?? SettingsController.instance.targetLanguage;
    final initText = widget.initialSourceText ?? widget.initialQuery;
    if (initText != null && initText.isNotEmpty) {
      _sourceController.text = initText;
      if (widget.initialTargetText != null &&
          widget.initialTargetText!.isNotEmpty) {
        _translatedText = widget.initialTargetText!;
      } else {
        _onSourceTextChanged(initText);
      }
    }
    final uid = _auth.currentUserId;
    if (uid != null) {
      _favouriteSubscription =
          _favourites.watchFavouritePhrases(uid).listen((phrases) {
        if (!mounted) return;
        setState(() {
          _savedPhrases = phrases;
          _syncStarredState();
        });
      });
    }
  }

  @override
  void dispose() {
    _translationDebounceTimer?.cancel();
    _historyDebounceTimer?.cancel();
    _searchController.dispose();
    _sourceController.dispose();
    _favouriteSubscription?.cancel();
    super.dispose();
  }

  bool _looksLikeVietnamese(String text) {
    final lower = text.toLowerCase().trim();
    const vnChars =
        'ăâđêôơưáàảãạấầẩẫậéèẻẽẹếềểễệíìỉĩịóòỏõọốồổỗộớờởỡợúùủũụứừửữựýỳỷỹỵ';
    for (int i = 0; i < lower.length; i++) {
      if (vnChars.contains(lower[i])) return true;
    }
    const vnPrefixes = [
      'xin ',
      'xin',
      'hôm nay',
      'bạn',
      'tôi',
      'chúng ta',
      'làm sao',
      'cái này',
      'ở đâu',
      'ăn gì',
      'bao nhiêu',
      'chào',
      'cảm ơn'
    ];
    for (final w in vnPrefixes) {
      if (lower.startsWith(w) || lower.contains(' $w ')) return true;
    }
    return false;
  }

  void _onSourceTextChanged(String text) {
    final rawText = text;
    if (rawText.trim().isEmpty) {
      setState(() {
        _translatedText = '';
        _spellingCorrectionSuggestion = null;
        _isTranslating = false;
      });
      _translationDebounceTimer?.cancel();
      _historyDebounceTimer?.cancel();
      return;
    }

    // Auto-detect direction
    if (_looksLikeVietnamese(rawText)) {
      _sourceLang = 'Vietnamese';
      _targetLang = 'English';
    } else {
      _sourceLang = 'English';
      _targetLang = 'Vietnamese';
    }

    // Spell-check chạy ngay
    setState(() {
      _spellingCorrectionSuggestion =
          TranslatorEngine.findSpellingCorrection(rawText, _sourceLang);
      _isSourceStarred = false;
      _isTargetStarred = false;
    });

    // LAYER 1: Check phrase library cục bộ (instant, <1ms)
    final phraseResult =
        PhraseLibrary.lookup(rawText, _sourceLang, _targetLang);
    if (phraseResult != null) {
      setState(() {
        _translatedText = phraseResult;
        _isTranslating = false;
        _syncStarredState();
      });
      _translationDebounceTimer?.cancel();
      // Lưu lịch sử
      _saveToHistory(rawText.trim(), phraseResult);
      return;
    }

    // Không match phrase library → hiện loading + gọi Gemini
    setState(() {
      _translatedText = '';
      _isTranslating = true;
    });

    final currentReqId = ++_translateRequestId;

    // Debounce 400ms rồi gọi dịch đồng thời
    _translationDebounceTimer?.cancel();
    _translationDebounceTimer =
        Timer(const Duration(milliseconds: 400), () async {
      if (!mounted || currentReqId != _translateRequestId) return;
      final cleanSrc = rawText.trim();
      if (cleanSrc.isEmpty) return;

      // LAYER 2: Gọi dịch Hybrid Race Engine
      final result = await TranslatorEngine.translateWithGemini(
          cleanSrc, _sourceLang, _targetLang);

      if (!mounted || currentReqId != _translateRequestId) return;

      if (result.isNotEmpty) {
        setState(() {
          _translatedText = result;
          _isTranslating = false;
          _syncStarredState();
        });
        _saveToHistory(cleanSrc, result);
      } else {
        setState(() {
          _translatedText = _sourceLang == 'English'
              ? '⚠️ Không thể dịch lúc này. Vui lòng thử lại sau.'
              : '⚠️ Unable to translate right now. Please try again later.';
          _isTranslating = false;
        });
      }
    });
  }

  void _saveToHistory(String source, String target) {
    if (source.length >= 3 &&
        target.isNotEmpty &&
        target != source &&
        !target.startsWith('⚠️')) {
      setState(() {
        _historyList.removeWhere((item) =>
            item['time'] == 'Just now' &&
            (source.contains(item['source']!) ||
                item['source']!.contains(source)));
        _historyList.insert(0, {
          'source': source,
          'target': target,
          'time': 'Just now',
        });
      });
      unawaited(_persistHistory(source, target));
    }
  }

  Future<void> _persistHistory(String source, String target) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final id = _historyDocumentId(
        '$source|$target|$_sourceLang|$_targetLang',
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .doc(id)
          .set({
        'term': source,
        'translation': target,
        'source': source,
        'target': target,
        'sourceLanguage': _sourceLang,
        'targetLanguage': _targetLang,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      debugPrint('Could not save translation history: $error');
    }
  }

  String _historyDocumentId(String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.toLowerCase().codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash.toRadixString(16);
  }

  FavouritePhraseRecord? _matchingFavourite() {
    final source = _sourceController.text.trim().toLowerCase();
    final target = _translatedText.trim().toLowerCase();
    if (source.isEmpty || target.isEmpty) return null;
    for (final phrase in _savedPhrases) {
      if (phrase.sourceText.trim().toLowerCase() == source &&
          phrase.translatedText.trim().toLowerCase() == target &&
          phrase.sourceLanguage == _sourceLang &&
          phrase.targetLanguage == _targetLang) {
        return phrase;
      }
    }
    return null;
  }

  void _syncStarredState() {
    final isSaved = _matchingFavourite() != null;
    _isSourceStarred = isSaved;
    _isTargetStarred = isSaved;
  }

  Future<void> _toggleFavourite() async {
    if (_isFavouriteBusy) return;
    final source = _sourceController.text.trim();
    final target = _translatedText.trim();
    if (source.isEmpty ||
        target.isEmpty ||
        target.startsWith('⚠️') ||
        _isTranslating) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Translate a phrase before saving it.')),
      );
      return;
    }
    final uid = _auth.currentUserId;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to save favourite phrases.')),
      );
      return;
    }
    final existing = _matchingFavourite();
    setState(() {
      _isFavouriteBusy = true;
      _isSourceStarred = existing == null;
      _isTargetStarred = existing == null;
    });
    try {
      if (existing != null) {
        await _favourites.removeFavouritePhrase(uid, existing.id);
      } else {
        await _favourites.saveFavouritePhrase(
          uid,
          sourceText: source,
          translatedText: target,
          sourceLanguage: _sourceLang,
          targetLanguage: _targetLang,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existing == null
              ? 'Phrase saved to favourites.'
              : 'Phrase removed from favourites.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(_syncStarredState);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update favourite phrase.')),
      );
      debugPrint('Could not update favourite phrase: $error');
    } finally {
      if (mounted) setState(() => _isFavouriteBusy = false);
    }
  }

  void _swapLanguages() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      final tempLang = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = tempLang;

      final tempText = _sourceController.text;
      _sourceController.text = _translatedText;
      _translatedText = tempText;

      final tempStar = _isSourceStarred;
      _isSourceStarred = _isTargetStarred;
      _isTargetStarred = tempStar;
    });
    SettingsController.instance.setLanguagePair(_sourceLang, _targetLang);
  }

  void _clearSourceText() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _sourceController.clear();
      _translatedText = '';
      _isSourceStarred = false;
      _isTargetStarred = false;
      _spellingCorrectionSuggestion = null;
    });
  }

  void _clearTargetText() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _translatedText = '';
      _isTargetStarred = false;
    });
  }

  void _copyToClipboard(String text, String label) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📋 Copied "$text" to clipboard!'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF3E4E31),
        ),
      );
    }
  }

  void _pasteFromClipboard() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    if (data != null && data.text != null) {
      setState(() {
        _sourceController.text = data.text!;
        _onSourceTextChanged(data.text!);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📋 Pasted: "${data.text!}"'),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF3E4E31),
        ),
      );
    }
  }

  void _playAudioPronunciation(String text, String lang) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (text.trim().isEmpty) return;
    final colors = context.fluentishColors;

    // 1. Tìm câu tiếng Anh chuẩn chỉnh đúng chính tả (canonical English)
    String textToSpeak = text.trim();
    final canonical = PhraseLibrary.getCanonicalEnglish(textToSpeak);
    if (canonical != null && canonical.isNotEmpty) {
      textToSpeak = canonical;
    } else if (_spellingCorrectionSuggestion != null &&
        _spellingCorrectionSuggestion!.isNotEmpty &&
        lang.toLowerCase().contains('en')) {
      // Nếu có gợi ý sửa lỗi chính tả tiếng Anh, phát âm câu đã sửa đúng chính tả
      textToSpeak = _spellingCorrectionSuggestion!;
    } else {
      // Nếu không tìm thấy trong kho và text đang là tiếng Việt (lang là Vietnamese hoặc chứa ký tự tiếng Việt),
      // kiểm tra xem bên kia (source hoặc target) có câu tiếng Anh chuẩn không để phát âm.
      final isVi = lang.toLowerCase().contains('vi') ||
          RegExp(r'[ăâđêôơưáàảãạéèẻẽẹíìỉĩịóòỏõọúùủũụýỳỷỹỵ]',
                  caseSensitive: false)
              .hasMatch(textToSpeak);
      if (isVi) {
        // Thử tìm tiếng Anh chuẩn từ ô còn lại
        final otherText = (_sourceController.text.trim() == textToSpeak)
            ? _translatedText
            : _sourceController.text;
        final otherCanonical = PhraseLibrary.getCanonicalEnglish(otherText);
        if (otherCanonical != null && otherCanonical.isNotEmpty) {
          textToSpeak = otherCanonical;
        } else if (!otherText.toLowerCase().contains('ă') &&
            RegExp(r'^[a-zA-Z0-9\s.,?!"-]+$').hasMatch(otherText)) {
          textToSpeak = otherText;
        } else {
          // Chỉ phát âm các câu và chữ đúng chính tả tiếng Anh -> Không phát âm tiếng Việt hoặc câu lỗi
          return;
        }
      }
    }

    // 2. Phát âm chuẩn tiếng Anh trên macOS / Mobile
    try {
      if (Platform.isMacOS) {
        // Dừng lệnh say cũ ngay lập tức (dùng runSync để đảm bảo không bị xung đột khi lặp lại)
        try {
          Process.runSync('killall', ['say']);
        } catch (_) {}

        // Sử dụng giọng tiếng Anh chuẩn (Samantha hoặc Eddy / Alex) với tốc độ rõ ràng tự nhiên (-r 175)
        Process.run('say', ['-v', 'Samantha', '-r', '175', textToSpeak])
            .then((res) {
          if (res.exitCode != 0) {
            // Fallback nếu Samantha không khả dụng hoặc lỗi tham số
            Process.run('say', [textToSpeak]);
          }
        });
      }
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.accent.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.volume_up,
                          color: colors.textPrimary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$lang Pronunciation',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Display the text being pronounced
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.surfaceStrong,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🔊 Playing $lang audio pronunciation...',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Pronunciation tip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.accent.withAlpha(28),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: colors.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lang == 'Vietnamese'
                            ? 'Tip: Vietnamese is a tonal language. Pay attention to the diacritical marks!'
                            : 'Tip: Try to match the natural rhythm and stress of the phrase.',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // Kept for the optional voice-input UI, which is currently hidden.
  // ignore: unused_element
  void _startMicRecording(bool isSource) {
    final colors = context.fluentishColors;
    final lang = isSource ? _sourceLang : _targetLang;
    final samples = (lang == 'English')
        ? [
            'How much is this?',
            'Can you speak slower?',
            'Where is the nearest hospital?',
            'Can you explain it again?',
            'I would like to buy coffee',
          ]
        : [
            'Cái này giá bao nhiêu?',
            'Bạn có thể nói chậm lại không?',
            'Bệnh viện gần nhất ở đâu?',
            'Bạn có thể giải thích lại không?',
            'Tôi muốn mua cà phê',
          ];

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(22),
          height: 380,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic,
                            color: Colors.redAccent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Voice Recognition ($lang)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '🎙️ Tap any spoken phrase below or speak into microphone:',
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: samples.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final phrase = samples[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          if (isSource) {
                            _sourceController.text = phrase;
                            _onSourceTextChanged(phrase);
                          } else {
                            _translatedText = phrase;
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✨ Voice recognized: "$phrase"'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: colors.header,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: colors.surfaceStrong,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.graphic_eq,
                              color: colors.textPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                phrase,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: colors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHistorySheet() {
    final colors = context.fluentishColors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🕒 Translation History & Favourites',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _historyList.length,
                  itemBuilder: (context, index) {
                    final item = _historyList[index];
                    return Card(
                      color: colors.surfaceStrong,
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(
                          item['source']!,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(item['target']!,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 15,
                            )),
                        trailing: Text(item['time']!,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            )),
                        onTap: () {
                          setState(() {
                            _sourceController.text = item['source']!;
                            _translatedText = item['target']!;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Loaded "${item['source']}" from history!')),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;

    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Top App Bar / Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Language',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.share_outlined,
                          size: 20,
                          color: colors.textPrimary,
                        ),
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // 1. Leader Approved Universal Search Bar ("Search phrases...")
                        SmartSearchBar(
                          controller: _searchController,
                          hintText: 'Search phrases or vocab...',
                          onSubmitted: (val) {
                            if (val.isNotEmpty) {
                              setState(() {
                                _sourceController.text = val;
                                _onSourceTextChanged(val);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        '🔍 Searching & translating: "$val"')),
                              );
                            }
                          },
                          onSuggestionSelected: (val) {
                            setState(() {
                              _searchController.text = val;
                              _sourceController.text = val;
                              _onSourceTextChanged(val);
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        // 2. Language Switcher Bar with History Icon on far right
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLangPill(_sourceLang),

                            IconButton(
                              onPressed: _swapLanguages,
                              icon: Icon(
                                Icons.swap_horiz,
                                size: 28,
                                color: colors.textPrimary,
                              ),
                              tooltip: 'Swap Languages',
                            ),

                            _buildLangPill(_targetLang),

                            // History Icon (Leader Approved placement)
                            IconButton(
                              onPressed: _showHistorySheet,
                              icon: Icon(
                                Icons.history,
                                size: 26,
                                color: colors.textPrimary,
                              ),
                              tooltip: 'View History & Favourites',
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // 3. Source Input Card (Top Box - Leader Approved UI)
                        Container(
                          height: 280,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: null,
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Input area + Clear (✕) + Star (⭐) at top right
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        key: const ValueKey(
                                            "language-source-input"),
                                        controller: _sourceController,
                                        onChanged: _onSourceTextChanged,
                                        maxLines: 4,
                                        style: TextStyle(
                                          fontSize: 18,
                                          height: 1.4,
                                          fontWeight: FontWeight.w500,
                                          color: colors.textPrimary,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter text here',
                                          hintStyle: TextStyle(
                                            color: colors.textSecondary,
                                            fontSize: 18,
                                            height: 1.4,
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          filled: false,
                                          fillColor: Colors.transparent,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_sourceController.text.isNotEmpty)
                                          GestureDetector(
                                            onTap: _clearSourceText,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Icon(
                                                Icons.close,
                                                color: colors.textSecondary,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: _toggleFavourite,
                                          child: Icon(
                                            _isSourceStarred
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: _isSourceStarred
                                                ? Colors.amber
                                                : colors.textPrimary,
                                            size: 26,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Bottom Icons: Paste (📋), Speaker (🔊) (Removed mic as requested)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _buildActionIcon(
                                    Icons.paste_outlined,
                                    'Paste from Clipboard',
                                    _pasteFromClipboard,
                                    false,
                                  ),
                                  const SizedBox(width: 14),
                                  _buildActionIcon(
                                    Icons.volume_up_outlined,
                                    'Listen Pronunciation',
                                    () => _playAudioPronunciation(
                                        _sourceController.text, _sourceLang),
                                    false,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Sleek Spelling & Typo Auto-Correction Suggestion Box ("💡 Bạn có ý là: ... [Sửa ngay]")
                        if (_spellingCorrectionSuggestion != null &&
                            _spellingCorrectionSuggestion!.isNotEmpty &&
                            _spellingCorrectionSuggestion!.toLowerCase() !=
                                _sourceController.text.trim().toLowerCase())
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(top: 12, bottom: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF85A947).withAlpha(35),
                                  const Color(0xFF85A947).withAlpha(15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF85A947).withAlpha(140),
                                width: 1.3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF85A947).withAlpha(20),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                final corrected =
                                    _spellingCorrectionSuggestion!;
                                setState(() {
                                  _sourceController.text = corrected;
                                  _spellingCorrectionSuggestion = null;
                                  _onSourceTextChanged(corrected);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '✨ Đã tự sửa chính xác: "$corrected"'),
                                    duration:
                                        const Duration(milliseconds: 1400),
                                    backgroundColor: const Color(0xFF85A947),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline,
                                    color: Color(0xFF2E3825),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF2E3825),
                                          height: 1.3,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: _sourceLang == 'English'
                                                ? 'Did you mean: '
                                                : 'Bạn có ý là: ',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          TextSpan(
                                            text:
                                                _spellingCorrectionSuggestion!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E3A0F),
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  Color(0xFF85A947),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF85A947),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF85A947)
                                              .withAlpha(80),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _sourceLang == 'English'
                                          ? 'Fix it'
                                          : 'Sửa ngay',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // 4. Target Output Card (Bottom Box - Leader Approved UI)
                        Container(
                          height: 280,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: null,
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Translated Text + Clear (✕) + Star (⭐) at top right
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _isTranslating
                                          ? Align(
                                              alignment: Alignment.topLeft,
                                              child: CircularProgressIndicator(
                                                color: colors.accent,
                                              ),
                                            )
                                          : Text(
                                              _translatedText.isEmpty
                                                  ? 'Here is your translation...'
                                                  : _translatedText,
                                              style: TextStyle(
                                                fontSize: 18,
                                                height: 1.4,
                                                fontWeight:
                                                    _translatedText.isEmpty
                                                        ? FontWeight.w400
                                                        : FontWeight.w600,
                                                color: _translatedText.isEmpty
                                                    ? colors.textSecondary
                                                    : colors.textPrimary,
                                              ),
                                            ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_translatedText.isNotEmpty)
                                          GestureDetector(
                                            onTap: _clearTargetText,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Icon(
                                                Icons.close,
                                                color: colors.textSecondary,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: _toggleFavourite,
                                          child: Icon(
                                            _isTargetStarred
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: _isTargetStarred
                                                ? Colors.amber
                                                : colors.textPrimary,
                                            size: 26,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Bottom Icons: Copy (📋), Speaker (🔊)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _buildActionIcon(
                                    Icons.copy_outlined,
                                    'Copy Translation',
                                    () => _copyToClipboard(
                                        _translatedText, 'translation'),
                                    false,
                                  ),
                                  const SizedBox(width: 14),
                                  _buildActionIcon(
                                    Icons.volume_up_outlined,
                                    'Listen Vietnamese Pronunciation',
                                    () => _playAudioPronunciation(
                                        _translatedText, _targetLang),
                                    false,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildLangPill(String lang) {
    final colors = context.fluentishColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceStrong,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        lang,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildActionIcon(
      IconData icon, String tooltip, VoidCallback onTap, bool isHighlighted) {
    final colors = context.fluentishColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: isHighlighted
              ? Colors.redAccent.withAlpha(30)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isHighlighted ? Colors.redAccent : colors.textPrimary,
          size: 22,
        ),
      ),
    );
  }
}
