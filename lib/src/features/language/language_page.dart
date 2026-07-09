import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluentish/src/features/language/translator_engine.dart';

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
  
  bool _isSourceListening = false;
  bool _isTargetListening = false;
  
  bool _isPlayingAudio = false;
  String _audioPlayingText = '';

  // In-memory history and favorites storage for live demo
  final List<Map<String, String>> _historyList = [
    {'source': 'Hello', 'target': 'Xin chào', 'time': 'Just now'},
    {'source': 'Coffee', 'target': 'Cà phê', 'time': '2 mins ago'},
    {'source': 'Thank you', 'target': 'Cảm ơn', 'time': '5 mins ago'},
  ];

  void _onSourceTextChanged(String text) {
    final rawText = text;
    if (rawText.trim().isEmpty) {
      setState(() {
        _translatedText = '';
      });
      return;
    }
    
    setState(() {
      _translatedText = TranslatorEngine.translateSync(rawText, _sourceLang, _targetLang);
      if (rawText.trim().length > 1 && _translatedText.isNotEmpty) {
        final cleanSrc = rawText.trim();
        // Prevent keystroke spam in History: update index 0 while typing the same phrase
        if (_historyList.isNotEmpty && _historyList[0]['time'] == 'Just now' && 
            (cleanSrc.startsWith(_historyList[0]['source']!) || _historyList[0]['source']!.startsWith(cleanSrc))) {
          _historyList[0] = {
            'source': cleanSrc,
            'target': _translatedText,
            'time': 'Just now',
          };
        } else {
          _historyList.insert(0, {
            'source': cleanSrc,
            'target': _translatedText,
            'time': 'Just now',
          });
        }
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
    setState(() {
      _isPlayingAudio = true;
      _audioPlayingText = '$lang pronunciation: "$text"';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text('🔊 Speaking $lang: "$text"')),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF3E4E31),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
          _audioPlayingText = '';
        });
      }
    });
  }

  void _startMicRecording(bool isSource) {
    setState(() {
      if (isSource) {
        _isSourceListening = !_isSourceListening;
        _isTargetListening = false;
      } else {
        _isTargetListening = !_isTargetListening;
        _isSourceListening = false;
      }
    });

    final activeListening = isSource ? _isSourceListening : _isTargetListening;

    if (activeListening) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.mic, color: Colors.redAccent),
              SizedBox(width: 10),
              Text('🎙️ Microphone active... Listening to speech...'),
            ],
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Color(0xFF3E4E31),
        ),
      );

      // Simulate voice input recognition after 2.5 seconds
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted && (isSource ? _isSourceListening : _isTargetListening)) {
          setState(() {
            if (isSource) {
              _isSourceListening = false;
              const simulatedVoice = 'how much is this';
              _sourceController.text = simulatedVoice;
              _onSourceTextChanged(simulatedVoice);
            } else {
              _isTargetListening = false;
              _translatedText = 'Cái này giá bao nhiêu tiền vậy cô?';
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✨ Voice recognized successfully!'),
              duration: Duration(seconds: 1),
              backgroundColor: Color(0xFF3E4E31),
            ),
          );
        }
      });
    }
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

            // Audio Playing feedback banner if active
            if (_isPlayingAudio)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.volume_up, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _audioPlayingText,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
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
                        decoration: const InputDecoration(
                          hintText: 'Search phrases...',
                          hintStyle: TextStyle(color: Colors.black38, fontSize: 15),
                          prefixIcon: Icon(Icons.search, color: Colors.black54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
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
                        border: _isSourceListening ? Border.all(color: Colors.redAccent, width: 2) : null,
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
                                    decoration: InputDecoration(
                                      hintText: _isSourceListening ? '🎙️ Listening... Speak now...' : 'Enter text here',
                                      hintStyle: TextStyle(
                                        color: _isSourceListening ? Colors.redAccent : Colors.black26,
                                        fontSize: 18,
                                      ),
                                      border: InputBorder.none,
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
                                _isSourceListening ? Icons.mic : Icons.mic_none_outlined,
                                'Speech to Text',
                                () => _startMicRecording(true),
                                _isSourceListening,
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
                        border: _isTargetListening ? Border.all(color: Colors.redAccent, width: 2) : null,
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
                                _isTargetListening ? Icons.mic : Icons.mic_none_outlined,
                                'Voice Input',
                                () => _startMicRecording(false),
                                _isTargetListening,
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

            // 5. Bottom Navigation Bar (Matching Figma exactly)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF3E4E31),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, 'Home', false),
                  _buildNavItem(Icons.translate, 'Language', true),
                  _buildNavItem(Icons.volume_up_outlined, 'Soundboard', false),
                  _buildNavItem(Icons.people_outline, 'Community', false),
                  _buildNavItem(Icons.person_outline, 'Profile', false),
                ],
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

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white60,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}


