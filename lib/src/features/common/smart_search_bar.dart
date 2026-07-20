import 'package:flutter/material.dart';
import 'package:fluentish/src/shared/shared.dart';

/// Reusable Smart Search Bar with YouTube/Google-style Auto-complete Suggestions.
/// Matches prefix/substring against a rich practical conversational dictionary.
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
      // Airport & Travel (AI Corpus 1)
      'Xin chào, tôi muốn làm thủ tục cho chuyến bay đi New York.',
      'Tôi có thể chọn ghế cạnh cửa sổ được không?',
      'Tôi được phép mang bao nhiêu hành lý ký gửi?',
      'Hành lý này của tôi có bị quá cân không?',
      'Chuyến bay của tôi bị hoãn đến mấy giờ?',
      'Xin hỏi cổng lên máy bay số 15 ở hướng nào?',
      'Tôi muốn mua một chiếc sim du lịch có dữ liệu mạng.',
      'Có xe buýt trung chuyển từ sân bay về trung tâm thành phố không?',
      'Tôi có thể nhận phòng sớm vào lúc 10 giờ sáng được không?',
      'Tôi muốn yêu cầu trả phòng trễ vào lúc 2 giờ chiều.',
      'Xin cho tôi biết mật khẩu Wifi của khách sạn.',
      'Vui lòng mang cho tôi thêm hai chiếc khăn tắm.',
      'Tôi muốn thuê một chiếc xe máy trong ba ngày.',
      'Xin hãy chỉ tôi đường đi đến trạm tàu điện ngầm gần nhất.',
      'Máy rút tiền tự động (ATM) gần nhất nằm ở đâu?',

      // Polite Vietnamese Requests ("Xin...")
      'xin hãy chỉ tôi đường đi đến trạm xe buýt',
      'xin giúp đỡ tôi trong việc này',
      'xin hãy mở cửa giúp tôi',
      'xin hãy dẫn tôi qua đường',
      'xin cảm ơn rất nhiều',
      'xin lỗi, tôi không hiểu bạn nói gì',
      'xin vui lòng nói chậm lại một chút',
      'xin cho tôi xem thực đơn nhà hàng',
      'xin tính tiền bàn số 5 giúp tôi',

      // "how much" examples requested by user
      'how much is this?',
      'how much caffeine is good?',
      'how much for a trip to Vietnam?',
      'how much does it cost?',
      'how much time do we have left?',
      'how much is a ticket to Saigon?',

      // Daily Vietnamese & English conversational sentences
      'hôm nay chúng ta ăn gì',
      'hôm nay thời tiết thế nào',
      'hôm nay làm gì chơi đâu',
      'have you eaten anything yet?',
      'can you speak slower please?',
      'can you help me cross the street?',
      'can you open the door for me please?',
      'bạn có thể nói chậm lại không?',
      'where is the nearest hospital?',
      'where is the restroom?',
      'where should we go for dinner?',
      'what should we eat today?',
      'what time does the cafe open?',
      'cái này giá bao nhiêu tiền',
      'chúng ta đi ăn ở đâu bây giờ',
      'may i see the menu, please?',
      'check please / bill please',
      'làm ơn cho xem thực đơn',
      'tính tiền giúp tôi',
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
    if (_focusNode.hasFocus) {
      setState(() {
        _showSuggestions = widget.controller.text.trim().isNotEmpty &&
            _filteredSuggestions.isNotEmpty;
      });
    } else {
      // Delay hiding suggestions so onTap on a suggestion item fires reliably
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _showSuggestions = false;
          });
        }
      });
    }
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
    // Prioritize prefix matches (like Google suggestions), then substring matches
    final prefixMatches = widget.customSuggestions
        .where((item) => item.toLowerCase().startsWith(clean))
        .toList();
    final containsMatches = widget.customSuggestions
        .where((item) =>
            item.toLowerCase().contains(clean) &&
            !item.toLowerCase().startsWith(clean))
        .toList();

    final matches = [...prefixMatches, ...containsMatches].take(7).toList();

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
    final colors = context.fluentishColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Search Input Card
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceStrong,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: colors.border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
            onChanged: (val) {
              _filterSuggestions(val);
              widget.onChanged?.call(val);
            },
            onSubmitted: (val) {
              setState(() => _showSuggestions = false);
              _focusNode.unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
              widget.onSubmitted?.call(val);
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: colors.textSecondary,
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 10),
                child: Icon(
                  Icons.search_rounded,
                  color: colors.textPrimary,
                  size: 22,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 46),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        size: 19,
                        color: colors.textSecondary,
                      ),
                      onPressed: () {
                        widget.controller.clear();
                        _filterSuggestions('');
                        _focusNode.unfocus();
                        FocusManager.instance.primaryFocus?.unfocus();
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

        // Google / YouTube style Autocomplete Dropdown Overlay Card
        if (_showSuggestions && _filteredSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: colors.surfaceStrong,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _filteredSuggestions.asMap().entries.map((entry) {
                  final suggestion = entry.value;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        widget.controller.text = suggestion;
                        setState(() => _showSuggestions = false);
                        _focusNode.unfocus();
                        FocusManager.instance.primaryFocus?.unfocus();
                        widget.onSuggestionSelected?.call(suggestion);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.north_west_rounded,
                              size: 15,
                              color: colors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
