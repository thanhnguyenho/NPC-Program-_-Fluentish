import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:fluentish/src/features/language/translator_engine.dart';
import 'package:fluentish/src/features/language/phrase_library.dart';
import 'package:fluentish/src/features/common/smart_search_bar.dart';

class LanguagePage extends StatelessWidget {
  final String? initialSourceText;
  final String? initialTargetText;
  final String? initialSourceLang;
  final String? initialTargetLang;
  final String? initialQuery;

  const LanguagePage({
    super.key,
    this.initialSourceText,
    this.initialTargetText,
    this.initialSourceLang,
    this.initialTargetLang,
    this.initialQuery,
  });

  @override
  Widget build(BuildContext context) {
    return LanguageTranslatorScreen(
      initialSourceText: initialSourceText ?? initialQuery,
      initialTargetText: initialTargetText,
      initialSourceLang: initialSourceLang,
      initialTargetLang: initialTargetLang,
      initialQuery: initialQuery,
    );
  }
}

class LanguageTranslatorScreen extends StatefulWidget {
  final String? initialSourceText;
  final String? initialTargetText;
  final String? initialSourceLang;
  final String? initialTargetLang;
  final String? initialQuery;

  const LanguageTranslatorScreen({
    super.key,
    this.initialSourceText,
    this.initialTargetText,
    this.initialSourceLang,
    this.initialTargetLang,
    this.initialQuery,
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
    if (widget.initialSourceLang != null) _sourceLang = widget.initialSourceLang!;
    if (widget.initialTargetLang != null) _targetLang = widget.initialTargetLang!;
    final initText = widget.initialSourceText ?? widget.initialQuery;
    if (initText != null && initText.isNotEmpty) {
      _sourceController.text = initText;
      if (widget.initialTargetText != null && widget.initialTargetText!.isNotEmpty) {
        _translatedText = widget.initialTargetText!;
      } else {
        _onSourceTextChanged(initText);
      }
    }
  }

  @override
  void dispose() {
    _historyDebounceTimer?.cancel();
    _searchController.dispose();
    _sourceController.dispose();
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
    });

    // LAYER 1: Check phrase library cục bộ (instant, <1ms)
    final phraseResult = PhraseLibrary.lookup(rawText, _sourceLang, _targetLang);
    if (phraseResult != null) {
      setState(() {
        _translatedText = phraseResult;
        _isTranslating = false;
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
    _translationDebounceTimer = Timer(const Duration(milliseconds: 400), () async {
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
    if (source.length >= 3 && target.isNotEmpty && target != source && !target.startsWith('⚠️')) {
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

    // 1. Tìm câu tiếng Anh chuẩn chỉnh đúng chính tả (canonical English)
    String textToSpeak = text.trim();
    final canonical = PhraseLibrary.getCanonicalEnglish(textToSpeak);
    if (canonical != null && canonical.isNotEmpty) {
      textToSpeak = canonical;
    } else if (_spellingCorrectionSuggestion != null && _spellingCorrectionSuggestion!.isNotEmpty && lang.toLowerCase().contains('en')) {
      // Nếu có gợi ý sửa lỗi chính tả tiếng Anh, phát âm câu đã sửa đúng chính tả
      textToSpeak = _spellingCorrectionSuggestion!;
    } else {
      // Nếu không tìm thấy trong kho và text đang là tiếng Việt (lang là Vietnamese hoặc chứa ký tự tiếng Việt),
      // kiểm tra xem bên kia (source hoặc target) có câu tiếng Anh chuẩn không để phát âm.
      final isVi = lang.toLowerCase().contains('vi') || RegExp(r'[ăâđêôơưáàảãạéèẻẽẹíìỉĩịóòỏõọúùủũụýỳỷỹỵ]', caseSensitive: false).hasMatch(textToSpeak);
      if (isVi) {
        // Thử tìm tiếng Anh chuẩn từ ô còn lại
        final otherText = (_sourceController.text.trim() == textToSpeak) ? _translatedText : _sourceController.text;
        final otherCanonical = PhraseLibrary.getCanonicalEnglish(otherText);
        if (otherCanonical != null && otherCanonical.isNotEmpty) {
          textToSpeak = otherCanonical;
        } else if (!otherText.toLowerCase().contains('ă') && RegExp(r'^[a-zA-Z0-9\s.,?!"-]+$').hasMatch(otherText)) {
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
        Process.run('say', ['-v', 'Samantha', '-r', '175', textToSpeak]).then((res) {
          if (res.exitCode != 0) {
            // Fallback nếu Samantha không khả dụng hoặc lỗi tham số
            Process.run('say', [textToSpeak]);
          }
        });
      }
    } catch (_) {}
  }

  void _showHistorySheet() {
    FocusManager.instance.primaryFocus?.unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8EDED),
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
                  const Text(
                    '🕒 Translation History & Favourites',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E4E31)),
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
                      color: Colors.white,
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(item['source']!,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(item['target']!,
                            style: const TextStyle(
                                color: Color(0xFF3E4E31), fontSize: 15)),
                        trailing: Text(item['time']!,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
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
    // Leader approved Rose pastel background
    const backgroundColor = Color(0xFFF5EBEB);
    const primaryGreen = Color(0xFF3E4E31);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Top App Bar / Title
              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Language',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                                content:
                                    Text('🔍 Searching & translating: "$val"')),
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
                          icon: const Icon(Icons.swap_horiz,
                              size: 28, color: primaryGreen),
                          tooltip: 'Swap Languages',
                        ),

                        _buildLangPill(_targetLang),

                        // History Icon (Leader Approved placement)
                        IconButton(
                          onPressed: _showHistorySheet,
                          icon: const Icon(Icons.history,
                              size: 26, color: Colors.black87),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
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
                                    key: const ValueKey("language-source-input"),
                                    controller: _sourceController,
                                    onChanged: _onSourceTextChanged,
                                    maxLines: null,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.multiline,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF2E3825),
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter text here',
                                      hintStyle: TextStyle(
                                        color: Colors.black26,
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
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(Icons.close,
                                              color: Colors.black54, size: 22),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isSourceStarred = !_isSourceStarred;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(_isSourceStarred
                                                ? '⭐ Starred source: "${_sourceController.text}"'
                                                : 'Unstarred source phrase'),
                                            duration:
                                                const Duration(seconds: 1),
                                            backgroundColor: primaryGreen,
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        _isSourceStarred
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: _isSourceStarred
                                            ? Colors.amber
                                            : Colors.black87,
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
                        _spellingCorrectionSuggestion!.toLowerCase() != _sourceController.text.trim().toLowerCase())
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(top: 12, bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            final corrected = _spellingCorrectionSuggestion!;
                            setState(() {
                              _sourceController.text = corrected;
                              _spellingCorrectionSuggestion = null;
                              _onSourceTextChanged(corrected);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✨ Đã tự sửa chính xác: "$corrected"'),
                                duration: const Duration(milliseconds: 1400),
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
                                        text: _sourceLang == 'English' ? 'Did you mean: ' : 'Bạn có ý là: ',
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      TextSpan(
                                        text: _spellingCorrectionSuggestion!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E3A0F),
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xFF85A947),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF85A947),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF85A947).withAlpha(80),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _sourceLang == 'English' ? 'Fix it' : 'Sửa ngay',
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
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
                                  child: (_isTranslating && _translatedText.isEmpty)
                                      ? const Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFF3E4E31)),
                                          ),
                                        )
                                      : SingleChildScrollView(
                                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _translatedText.isEmpty
                                                    ? 'Here is your translation...'
                                                    : _translatedText,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  height: 1.4,
                                                  fontWeight: _translatedText.isEmpty
                                                      ? FontWeight.w400
                                                      : FontWeight.w600,
                                                  color: _translatedText.isEmpty
                                                      ? Colors.black38
                                                      : const Color(0xFF3E4E31),
                                                ),
                                              ),
                                              if (_isTranslating)
                                                const Padding(
                                                  padding: EdgeInsets.only(top: 8),
                                                  child: SizedBox(
                                                    width: 16, height: 16,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 1.5,
                                                      color: Color(0xFF85A947),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_translatedText.isNotEmpty)
                                      GestureDetector(
                                        onTap: _clearTargetText,
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(Icons.close,
                                              color: Colors.black54, size: 22),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isTargetStarred = !_isTargetStarred;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(_isTargetStarred
                                                ? '⭐ Saved "$_translatedText" to Favourites!'
                                                : 'Removed from Favourites'),
                                            duration:
                                                const Duration(seconds: 1),
                                            backgroundColor: primaryGreen,
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        _isTargetStarred
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: _isTargetStarred
                                            ? Colors.amber
                                            : Colors.black87,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        lang,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3E4E31),
        ),
      ),
    );
  }

  Widget _buildActionIcon(
      IconData icon, String tooltip, VoidCallback onTap, bool isHighlighted) {
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
          color: isHighlighted ? Colors.redAccent : const Color(0xFF3E4E31),
          size: 22,
        ),
      ),
    );
  }
}
