import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:fluentish/src/features/language/translator_engine.dart';
import 'package:fluentish/src/features/common/smart_search_bar.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LanguageTranslatorScreen();
  }
}

class LanguageTranslatorScreen extends StatefulWidget {
  const LanguageTranslatorScreen({super.key});

  @override
  State<LanguageTranslatorScreen> createState() => _LanguageTranslatorScreenState();
}

class _LanguageTranslatorScreenState extends State<LanguageTranslatorScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  
  String _sourceLang = 'English';
  String _targetLang = 'Vietnamese';
  String _translatedText = 'Xin chào';
  
  bool _isSourceStarred = false;
  bool _isTargetStarred = false;
  


  // Debounce timer: only record to history AFTER user stops typing for 800ms
  Timer? _historyDebounceTimer;

  // Clean initial history & favourites
  final List<Map<String, String>> _historyList = [
    {'source': 'How much is this?', 'target': 'Cái này giá bao nhiêu?', 'time': 'Just now'},
    {'source': 'Can you speak slower?', 'target': 'Bạn có thể nói chậm lại không?', 'time': '2 mins ago'},
    {'source': 'Where is the nearest hospital?', 'target': 'Bệnh viện gần nhất ở đâu?', 'time': '10 mins ago'},
    {'source': 'Thank you very much', 'target': 'Xin cảm ơn rất nhiều', 'time': '1 hour ago'},
    {'source': 'Can you explain it again?', 'target': 'Bạn có thể giải thích lại không?', 'time': 'Yesterday'},
  ];

  @override
  void dispose() {
    _historyDebounceTimer?.cancel();
    _searchController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _onSourceTextChanged(String text) {
    final rawText = text;
    if (rawText.trim().isEmpty) {
      setState(() {
        _translatedText = '';
      });
      _historyDebounceTimer?.cancel();
      return;
    }
    
    // Translate immediately for live feedback
    setState(() {
      _translatedText = TranslatorEngine.translateSync(rawText, _sourceLang, _targetLang);
    });

    // Debounce history recording: only save AFTER user stops typing for 800ms
    _historyDebounceTimer?.cancel();
    _historyDebounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final cleanSrc = rawText.trim();
      final translated = _translatedText;
      if (cleanSrc.length >= 3 && translated.isNotEmpty && translated != cleanSrc) {
        setState(() {
          // Remove any existing "Just now" entry for similar text to avoid duplicates
          _historyList.removeWhere((item) =>
            item['time'] == 'Just now' &&
            (cleanSrc.contains(item['source']!) || item['source']!.contains(cleanSrc))
          );
          _historyList.insert(0, {
            'source': cleanSrc,
            'target': translated,
            'time': 'Just now',
          });
        });
      }
    });
  }


  void _swapLanguages() {
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
    setState(() {
      _sourceController.clear();
      _translatedText = '';
      _isSourceStarred = false;
      _isTargetStarred = false;
    });
  }

  void _clearTargetText() {
    setState(() {
      _translatedText = '';
      _isTargetStarred = false;
    });
  }

  void _copyToClipboard(String text, String label) {
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
    if (text.trim().isEmpty) return;

    // Play real audio speech out loud offline without API keys
    try {
      if (Platform.isMacOS) {
        final voice = lang == 'Vietnamese' ? 'Linh' : 'Samantha';
        Process.run('say', ['-v', voice, text]).then((res) {
          if (res.exitCode != 0) {
            Process.run('say', [text]);
          }
        });
      }
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8EDED),
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
                          color: const Color(0xFF3E4E31).withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.volume_up, color: Color(0xFF3E4E31), size: 26),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$lang Pronunciation',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E4E31),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF3E4E31).withAlpha(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E4E31),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🔊 Playing $lang audio pronunciation...',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
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
                  color: const Color(0xFF3E4E31).withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates_outlined, color: Color(0xFF3E4E31), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lang == 'Vietnamese'
                            ? 'Tip: Vietnamese is a tonal language. Pay attention to the diacritical marks!'
                            : 'Tip: Try to match the natural rhythm and stress of the phrase.',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF3E4E31)),
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

  void _startMicRecording(bool isSource) {
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
      backgroundColor: const Color(0xFFF8EDED),
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
                        child: const Icon(Icons.mic, color: Colors.redAccent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Voice Recognition ($lang)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E4E31),
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
              const Text(
                '🎙️ Tap any spoken phrase below or speak into microphone:',
                style: TextStyle(fontSize: 14, color: Colors.black54),
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
                            backgroundColor: const Color(0xFF3E4E31),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF3E4E31).withAlpha(40)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.graphic_eq, color: Color(0xFF3E4E31), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                phrase,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black38),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E4E31)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(item['source']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(item['target']!, style: const TextStyle(color: Color(0xFF3E4E31), fontSize: 15)),
                        trailing: Text(item['time']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        onTap: () {
                          setState(() {
                            _sourceController.text = item['source']!;
                            _translatedText = item['target']!;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Loaded "${item['source']}" from history!')),
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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar / Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(150),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share_outlined, size: 20, color: Colors.black87),
                  )
                ],
              ),
            ),


            Expanded(
              child: SingleChildScrollView(
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
                            SnackBar(content: Text('🔍 Searching & translating: "$val"')),
                          );
                        }
                      },
                      onSuggestionSelected: (val) {
                        setState(() {
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
                          icon: const Icon(Icons.swap_horiz, size: 28, color: primaryGreen),
                          tooltip: 'Swap Languages',
                        ),

                        _buildLangPill(_targetLang),

                        // History Icon (Leader Approved placement)
                        IconButton(
                          onPressed: _showHistorySheet,
                          icon: const Icon(Icons.history, size: 26, color: Colors.black87),
                          tooltip: 'View History & Favourites',
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // 3. Source Input Card (Top Box - Leader Approved UI)
                    Container(
                      height: 190,
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
                                    controller: _sourceController,
                                    onChanged: _onSourceTextChanged,
                                    maxLines: 4,
                                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter text here',
                                      hintStyle: TextStyle(
                                        color: Colors.black26,
                                        fontSize: 18,
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
                                          child: Icon(Icons.close, color: Colors.black54, size: 22),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isSourceStarred = !_isSourceStarred;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(_isSourceStarred
                                                ? '⭐ Starred source: "${_sourceController.text}"'
                                                : 'Unstarred source phrase'),
                                            duration: const Duration(seconds: 1),
                                            backgroundColor: primaryGreen,
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        _isSourceStarred ? Icons.star : Icons.star_border,
                                        color: _isSourceStarred ? Colors.amber : Colors.black87,
                                        size: 26,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Bottom Icons: Paste (📋), Speaker (🔊), Mic (🎙️)
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
                                () => _playAudioPronunciation(_sourceController.text, _sourceLang),
                                false,
                              ),
                              const SizedBox(width: 14),
                              _buildActionIcon(
                                Icons.mic_none_outlined,
                                'Speech to Text',
                                () => _startMicRecording(true),
                                false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 4. Target Output Card (Bottom Box - Leader Approved UI)
                    Container(
                      height: 190,
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
                                  child: Text(
                                    _translatedText.isEmpty ? 'Xin chào' : _translatedText,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: _translatedText.isEmpty ? FontWeight.normal : FontWeight.w600,
                                      color: _translatedText.isEmpty ? Colors.black26 : primaryGreen,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_translatedText.isNotEmpty && _translatedText != 'Xin chào')
                                      GestureDetector(
                                        onTap: _clearTargetText,
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(Icons.close, color: Colors.black54, size: 22),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isTargetStarred = !_isTargetStarred;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(_isTargetStarred
                                                ? '⭐ Saved "$_translatedText" to Favourites!'
                                                : 'Removed from Favourites'),
                                            duration: const Duration(seconds: 1),
                                            backgroundColor: primaryGreen,
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        _isTargetStarred ? Icons.star : Icons.star_border,
                                        color: _isTargetStarred ? Colors.amber : Colors.black87,
                                        size: 26,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Bottom Icons: Copy (📋), Speaker (🔊), Mic (🎙️) matching Leader's Figma
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildActionIcon(
                                Icons.copy_outlined,
                                'Copy Translation',
                                () => _copyToClipboard(_translatedText, 'translation'),
                                false,
                              ),
                              const SizedBox(width: 14),
                              _buildActionIcon(
                                Icons.volume_up_outlined,
                                'Listen Vietnamese Pronunciation',
                                () => _playAudioPronunciation(_translatedText, _targetLang),
                                false,
                              ),
                              const SizedBox(width: 14),
                              _buildActionIcon(
                                Icons.mic_none_outlined,
                                'Voice Input',
                                () => _startMicRecording(false),
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
    );
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

  Widget _buildActionIcon(IconData icon, String tooltip, VoidCallback onTap, bool isHighlighted) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.redAccent.withAlpha(30) : Colors.transparent,
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


