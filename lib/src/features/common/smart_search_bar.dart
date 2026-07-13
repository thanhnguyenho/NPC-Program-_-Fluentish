import 'package:flutter/material.dart';

/// Reusable Smart Search Bar with YouTube/Google-style Auto-complete Suggestions.
/// Easily pluggable across any page in Fluentish (Language, Community, Soundboard).
class SmartSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onSuggestionSelected;
  final List<String> customSuggestions;

  const SmartSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search vocab, grammar, sentences...',
    this.onChanged,
    this.onSubmitted,
    this.onSuggestionSelected,
    this.customSuggestions = const [
      'hôm nay chúng ta ăn gì',
      'how much is this?',
      'have you eaten anything yet?',
      'can you speak slower?',
      'where is the nearest hospital?',
      'xin cảm ơn rất nhiều',
      'tôi không hiểu',
      'cái này giá bao nhiêu',
      'what should we eat today?',
      'bạn có thể nói chậm lại không?',
      'chúng ta đi đâu chơi',
      'hôm nay làm gì',
      'may i see the menu, please?',
      'check please / bill please',
    ],
  });

  @override
  State<SmartSearchBar> createState() => _SmartSearchBarState();
}

class _SmartSearchBarState extends State<SmartSearchBar> {
  final FocusNode _focusNode = FocusNode();
  List<String> _filteredSuggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus &&
          widget.controller.text.trim().isNotEmpty &&
          _filteredSuggestions.isNotEmpty;
    });
  }

  void _filterSuggestions(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    final clean = query.trim().toLowerCase();
    final matches = widget.customSuggestions
        .where((item) => item.toLowerCase().contains(clean))
        .take(6)
        .toList();

    setState(() {
      _filteredSuggestions = matches;
      _showSuggestions = _focusNode.hasFocus && matches.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Input Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(240),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3E4E31),
            ),
            onChanged: (val) {
              _filterSuggestions(val);
              widget.onChanged?.call(val);
            },
            onSubmitted: (val) {
              setState(() => _showSuggestions = false);
              widget.onSubmitted?.call(val);
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF3E4E31)),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        widget.controller.clear();
                        _filterSuggestions('');
                        widget.onChanged?.call('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
            ),
          ),
        ),

        // YouTube/Google-style Autocomplete Dropdown Overlay Card
        if (_showSuggestions && _filteredSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E9E2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._filteredSuggestions.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final suggestion = entry.value;
                  final isLast = idx == _filteredSuggestions.length - 1;

                  return InkWell(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(idx == 0 ? 20 : 0),
                      bottom: Radius.circular(isLast ? 20 : 0),
                    ),
                    onTap: () {
                      widget.controller.text = suggestion;
                      setState(() => _showSuggestions = false);
                      _focusNode.unfocus();
                      widget.onSuggestionSelected?.call(suggestion);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.history,
                            size: 18,
                            color: Color(0xFF6B8E5E),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF3E4E31),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.north_west,
                            size: 14,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }
}
