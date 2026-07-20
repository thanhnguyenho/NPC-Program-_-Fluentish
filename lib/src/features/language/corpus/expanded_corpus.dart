
/// Expanded offline corpus covering Topics 1 to 5:
/// 1. Greetings & Social Conversation
/// 2. Airport & Immigration
/// 3. Hotel & Accommodation
/// 4. Food & Restaurant
/// 5. Shopping & Tax Refund
///
/// Features an automatic O(1) Hash Map index built at startup for sub-millisecond lookups.
class ExpandedCorpus {
  ExpandedCorpus._();

  static const List<Map<String, dynamic>> allTopics = [
    // =========================================================================
    // TOPIC 1: GREETINGS & SOCIAL CONVERSATION
    // =========================================================================
    {
      'id': 'greet_001',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'Hello!',
      'canonical_vi': 'Chào bạn!',
      'variations_en': [
        'hi', 'hey there', 'greetings', 'hello there', 'helo', 'helllo', 'hi ya', 'sup', 'hey'
      ],
      'variations_vi': [
        'xin chào', 'chào nha', 'chao ban', 'chao bn', 'helo bạn', 'hi bn'
      ]
    },
    {
      'id': 'greet_002',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'How are you?',
      'canonical_vi': 'Bạn khỏe không?',
      'variations_en': [
        'how are you doing', 'are you okay', 'how r u', 'u ok', 'how are yuo', 'how aer you', 'how is u', 'how r yoi', 'how have you been'
      ],
      'variations_vi': [
        'bạn có khỏe không', 'bạn ổn chứ', 'dạo này thế nào', 'bạn khỏe ko'
      ]
    },
    {
      'id': 'greet_003',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'Nice to meet you.',
      'canonical_vi': 'Rất vui được gặp bạn.',
      'variations_en': [
        'pleased to meet you', 'glad to meet you', 'nice meeting you', 'it is nice to meet you', 'pleasure to meet you'
      ],
      'variations_vi': [
        'hân hạnh được gặp bạn', 'rất vui gặp bạn', 'vui được gặp bn'
      ]
    },
    {
      'id': 'greet_004',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'What is your name?',
      'canonical_vi': 'Bạn tên là gì?',
      'variations_en': [
        'may i have your name', 'what your name', 'whats your name', 'ur name please', 'what is ur name'
      ],
      'variations_vi': [
        'tên bạn là gì', 'bn tên gì', 'xin quý danh'
      ]
    },
    {
      'id': 'greet_005',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'Good morning!',
      'canonical_vi': 'Chào buổi sáng!',
      'variations_en': [
        'morning', 'gmorning', 'good mornin', 'top of the morning', 'good morn'
      ],
      'variations_vi': [
        'chào buổi sáng tốt lành', 'chao buoi sang'
      ]
    },
    {
      'id': 'greet_006',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'Good afternoon!',
      'canonical_vi': 'Chào buổi chiều!',
      'variations_en': [
        'afternoon', 'good afternon', 'g afternoon', 'good after'
      ],
      'variations_vi': [
        'chào buổi chiều tốt lành', 'chao buoi chieu'
      ]
    },
    {
      'id': 'greet_007',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'Good evening!',
      'canonical_vi': 'Chào buổi tối!',
      'variations_en': [
        'evening', 'good evenin', 'g evening', 'good even'
      ],
      'variations_vi': [
        'chào buổi tối tốt lành', 'chao buoi toi'
      ]
    },
    {
      'id': 'greet_008',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'Good night!',
      'canonical_vi': 'Chúc ngủ ngon!',
      'variations_en': [
        'night night', 'sweet dreams', 'goodnight', 'gnight', 'sleep well'
      ],
      'variations_vi': [
        'ngủ ngon nha', 'chuc ngu ngon', 'ngủ ngon b nhe'
      ]
    },
    {
      'id': 'greet_009',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'Thank you very much.',
      'canonical_vi': 'Cảm ơn bạn rất nhiều.',
      'variations_en': [
        'thank you', 'thanks a lot', 'thank u', 'thx so much', 'thank you so much', 'many thanks'
      ],
      'variations_vi': [
        'cảm ơn nhiều', 'cám ơn bạn', 'cam on nhieu'
      ]
    },
    {
      'id': 'greet_010',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'You are welcome.',
      'canonical_vi': 'Không có gì.',
      'variations_en': [
        'ur welcome', 'no problem', 'not at all', 'my pleasure', 'anytime', 'no worries'
      ],
      'variations_vi': [
        'ko có chi', 'không có chi', 'đừng bận tâm'
      ]
    },
    {
      'id': 'greet_011',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'I am sorry.',
      'canonical_vi': 'Tôi xin lỗi.',
      'variations_en': [
        'sorry', 'my apologies', 'so sorry', 'im sorry', 'apologize'
      ],
      'variations_vi': [
        'xin lỗi bạn', 'mình xin lỗi', 'xin loi'
      ]
    },
    {
      'id': 'greet_012',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'Excuse me, may I ask you a question?',
      'canonical_vi': 'Xin lỗi cho tôi hỏi một chút được không?',
      'variations_en': [
        'excuse me', 'pardon me', 'can i ask a question', 'excuse me sir', 'excuse me miss'
      ],
      'variations_vi': [
        'cho tôi hỏi thăm', 'làm ơn cho hỏi', 'xin loi cho hỏi'
      ]
    },
    {
      'id': 'greet_013',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'Do you speak English?',
      'canonical_vi': 'Bạn có nói tiếng Anh không?',
      'variations_en': [
        'can you speak english', 'do u speak english', 'speak english right', 'any english speaker here'
      ],
      'variations_vi': [
        'bạn biết tiếng anh không', 'nói tiếng anh được không'
      ]
    },
    {
      'id': 'greet_014',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'Could you please speak more slowly?',
      'canonical_vi': 'Bạn có thể nói chậm lại một chút được không?',
      'variations_en': [
        'speak slower please', 'can you slow down', 'talk slower plz', 'please speak slower'
      ],
      'variations_vi': [
        'nói chậm thôi', 'làm ơn nói chậm lại'
      ]
    },
    {
      'id': 'greet_015',
      'category': 'Greetings & Social Conversation',
      'canonical_en': 'Where are you from?',
      'canonical_vi': 'Bạn đến từ đâu?',
      'variations_en': [
        'where do you come from', 'what country are you from', 'where r u from', 'which country u from'
      ],
      'variations_vi': [
        'bạn người nước nào', 'đến từ đâu thế'
      ]
    },

    // =========================================================================
    // TOPIC 2: AIRPORT & IMMIGRATION
    // =========================================================================
    {
      'id': 'air_001',
      'category': 'Airport & Immigration',
      'canonical_en': 'Where is the check-in counter for Vietnam Airlines?',
      'canonical_vi': 'Quầy làm thủ tục của Vietnam Airlines ở đâu?',
      'variations_en': [
        'where is the vietnam airlines check in counter', 'vietnam airlines checkin counter where', 'where to check in for vietnam airlines', 'chekin counter vietnam airlines'
      ],
      'variations_vi': [
        'quầy check in vietnam airlines ở đâu', 'chỗ làm thủ tục vietnam airlines'
      ]
    },
    {
      'id': 'air_002',
      'category': 'Airport & Immigration',
      'canonical_en': 'Here is my passport and boarding pass.',
      'canonical_vi': 'Đây là hộ chiếu và thẻ lên máy bay của tôi.',
      'variations_en': [
        'here is passport and boarding pass', 'my passport and boarding pass here', 'passport boarding pass check please'
      ],
      'variations_vi': [
        'đây hộ chiếu và vé máy bay', 'passport và boarding pass đây'
      ]
    },
    {
      'id': 'air_003',
      'category': 'Airport & Immigration',
      'canonical_en': 'Can I have a window seat, please?',
      'canonical_vi': 'Tôi có thể ngồi ghế cạnh cửa sổ được không?',
      'variations_en': [
        'i want window seat please', 'window seat plz', 'can you give me window seat', 'seat by the window'
      ],
      'variations_vi': [
        'cho ngồi cạnh cửa sổ nhé', 'ghế cửa sổ được ko'
      ]
    },
    {
      'id': 'air_004',
      'category': 'Airport & Immigration',
      'canonical_en': 'I would like an aisle seat for easy access.',
      'canonical_vi': 'Tôi muốn ngồi ghế cạnh lối đi để tiện di chuyển.',
      'variations_en': [
        'aisle seat please', 'give me aisle seat', 'i prefer aisle seat', 'seat near aisle'
      ],
      'variations_vi': [
        'cho tôi ghế lối đi', 'ngồi cạnh lối đi nhé'
      ]
    },
    {
      'id': 'air_005',
      'category': 'Airport & Immigration',
      'canonical_en': 'How many checked bags am I allowed?',
      'canonical_vi': 'Tôi được phép ký gửi bao nhiêu hành lý?',
      'variations_en': [
        'how many checked baggage allowed', 'checked luggage allowance', 'how many bags can i check in', 'baggage limit how many'
      ],
      'variations_vi': [
        'được ký gửi mấy kiện hành lý', 'hành lý ký gửi bao nhiêu kg'
      ]
    },
    {
      'id': 'air_006',
      'category': 'Airport & Immigration',
      'canonical_en': 'Is this baggage overweight?',
      'canonical_vi': 'Hành lý này của tôi có bị quá cân không?',
      'variations_en': [
        'is my suitcase too heavy', 'overweight baggage right', 'does my bag exceed weight limit', 'too heavy luggage'
      ],
      'variations_vi': [
        'vali có bị quá ký không', 'hành lý bị dư cân à'
      ]
    },
    {
      'id': 'air_007',
      'category': 'Airport & Immigration',
      'canonical_en': 'How much is the excess baggage fee per kilogram?',
      'canonical_vi': 'Phí hành lý quá cước mỗi ký là bao nhiêu?',
      'variations_en': [
        'how much is overweight baggage fee', 'excess luggage cost per kg', 'overweight fee how much', 'extra weight cost'
      ],
      'variations_vi': [
        'quá ký đóng phạt bao nhiêu tiền 1 kg', 'phí hành lý quá cước thế nào'
      ]
    },
    {
      'id': 'air_008',
      'category': 'Airport & Immigration',
      'canonical_en': 'Please put a fragile tag on this suitcase.',
      'canonical_vi': 'Xin dán nhãn hàng dễ vỡ cho vali này giúp tôi.',
      'variations_en': [
        'fragile tag for this bag please', 'put fragile sticker on suitcase', 'mark this bag fragile plz'
      ],
      'variations_vi': [
        'dán tem dễ vỡ giúp tôi', 'vali đồ dễ vỡ xin cẩn thận'
      ]
    },
    {
      'id': 'air_009',
      'category': 'Airport & Immigration',
      'canonical_en': 'Which way to boarding gate number 15?',
      'canonical_vi': 'Cổng lên máy bay số 15 đi hướng nào?',
      'variations_en': [
        'where is gate 15', 'how to get to boarding gate 15', 'gate 15 location please', 'which direction gate 15'
      ],
      'variations_vi': [
        'cổng số 15 ở đâu', 'đường đi ra cửa 15'
      ]
    },
    {
      'id': 'air_010',
      'category': 'Airport & Immigration',
      'canonical_en': 'Where is the baggage claim area for international arrivals?',
      'canonical_vi': 'Khu vực nhận hành lý cho các chuyến bay quốc tế đến ở đâu?',
      'variations_en': [
        'where is baggage claim', 'luggage pickup area where', 'carousel for luggage where', 'where do i pick up my bags'
      ],
      'variations_vi': [
        'lấy hành lý ở đâu', 'băng chuyền hành lý số mấy'
      ]
    },

    // =========================================================================
    // TOPIC 3: HOTEL & ACCOMMODATION
    // =========================================================================
    {
      'id': 'hot_001',
      'category': 'Hotel & Accommodation',
      'canonical_en': 'I have a reservation under the name Nguyen.',
      'canonical_vi': 'Tôi đã đặt phòng trước dưới tên Nguyễn.',
      'variations_en': [
        'i booked a room under nguyen', 'my reservation name is nguyen', 'check in under nguyen please', 'reservation nguyen'
      ],
      'variations_vi': [
        'tôi đặt phòng tên nguyễn', 'check in tên nguyễn nhé'
      ]
    },
    {
      'id': 'hot_002',
      'category': 'Hotel & Accommodation',
      'canonical_en': 'Can I check in early right now?',
      'canonical_vi': 'Tôi có thể nhận phòng sớm ngay bây giờ được không?',
      'variations_en': [
        'can i checkin early now', 'early check in possible right now', 'check in early please', 'can we check in earlier'
      ],
      'variations_vi': [
        'nhận phòng sớm được không', 'có phòng vào luôn được ko'
      ]
    },
    {
      'id': 'hot_003',
      'category': 'Hotel & Accommodation',
      'canonical_en': 'What time is breakfast served every morning?',
      'canonical_vi': 'Bữa sáng được phục vụ lúc mấy giờ mỗi ngày?',
      'variations_en': [
        'what time breakfast starts', 'when is breakfast served', 'breakfast hours hotel', 'what time breakfast'
      ],
      'variations_vi': [
        'ăn sáng lúc mấy giờ', 'giờ ăn sáng của khách sạn'
      ]
    },
    {
      'id': 'hot_004',
      'category': 'Hotel & Accommodation',
      'canonical_en': 'What is the Wi-Fi password for this room?',
      'canonical_vi': 'Mật khẩu Wi-Fi của phòng này là gì?',
      'variations_en': [
        'whats the wifi password', 'wifi pass room please', 'how to connect wifi here', 'wifi password what'
      ],
      'variations_vi': [
        'mật khẩu wifi là gì', 'pass wifi phòng mấy'
      ]
    },
    {
      'id': 'hot_005',
      'category': 'Hotel & Accommodation',
      'canonical_en': 'Could you bring two extra bath towels to my room?',
      'canonical_vi': 'Bạn có thể mang thêm 2 khăn tắm lên phòng giúp tôi không?',
      'variations_en': [
        'bring extra towels please', 'i need two more towels in room', 'send bath towels up plz', 'extra towels room'
      ],
      'variations_vi': [
        'cho xin thêm 2 khăn tắm', 'mang khăn tắm lên phòng giúp'
      ]
    },
    {
      'id': 'hot_006',
      'category': 'Hotel & Accommodation',
      'canonical_en': 'The air conditioning in my room is not cold enough.',
      'canonical_vi': 'máy lạnh trong phòng tôi không đủ mát.',
      'variations_en': [
        'aircon not cold enough', 'ac is not working well in room', 'room is too hot ac broken', 'air conditioner not cold'
      ],
      'variations_vi': [
        'máy lạnh phòng ko mát', 'điều hòa không lạnh'
      ]
    },
    {
      'id': 'hot_007',
      'category': 'Hotel & Accommodation',
      'canonical_en': 'Can I request a late check-out until 2 PM?',
      'canonical_vi': 'Tôi có thể xin trả phòng trễ lúc 2 giờ chiều được không?',
      'variations_en': [
        'late check out 2pm please', 'can i checkout at 2 pm', 'request late checkout until 2pm', 'late check out possible'
      ],
      'variations_vi': [
        'trả phòng muộn lúc 2h chiều được không', 'cho check out trễ nhé'
      ]
    },

    // =========================================================================
    // TOPIC 4: FOOD & RESTAURANT
    // =========================================================================
    {
      'id': 'rest_001',
      'category': 'Food & Restaurant',
      'canonical_en': 'I would like to book a table for four tonight.',
      'canonical_vi': 'Tôi muốn đặt một bàn bốn người tối nay.',
      'variations_en': [
        'i want to reserve a table for four tonight', 'can i book a table for 4 tonight', 'table for 4 tonight plz', 'make a reservation for four tonight', 'book table 4 people'
      ],
      'variations_vi': [
        'đặt bàn 4 người tối nay', 'cho tôi đặt 1 bàn 4 chỗ'
      ]
    },
    {
      'id': 'rest_002',
      'category': 'Food & Restaurant',
      'canonical_en': 'Can I see the menu, please?',
      'canonical_vi': 'Cho tôi xem thực đơn được không?',
      'variations_en': [
        'can i have the menu please', 'menu please', 'show me menu plz', 'may i see the menu'
      ],
      'variations_vi': [
        'cho xin thực đơn', 'xem menu quán với'
      ]
    },
    {
      'id': 'rest_003',
      'category': 'Food & Restaurant',
      'canonical_en': 'What do you recommend as the signature dish here?',
      'canonical_vi': 'Bạn giới thiệu món đặc sản hay nổi tiếng nhất ở đây là gì?',
      'variations_en': [
        'what is your specialty', 'what do you recommend', 'signature dish here', 'whats good here', 'best dish here'
      ],
      'variations_vi': [
        'món nào ngon nhất ở đây', 'quán có đặc sản gì giới thiệu với'
      ]
    },
    {
      'id': 'rest_004',
      'category': 'Food & Restaurant',
      'canonical_en': 'Two bowls of beef pho noodle soup, please.',
      'canonical_vi': 'Cho tôi hai tô phở bò nhé.',
      'variations_en': [
        'two bowls of beef pho please', '2 beef pho plz', 'two beef pho noodles', 'order two pho bo'
      ],
      'variations_vi': [
        'cho 2 tô phở bò', 'hai bát phở bò nhé'
      ]
    },
    {
      'id': 'rest_005',
      'category': 'Food & Restaurant',
      'canonical_en': 'I am severely allergic to peanuts and seafood.',
      'canonical_vi': 'Tôi bị dị ứng nặng với đậu phộng và hải sản.',
      'variations_en': [
        'i am allergic to peanuts and seafood', 'no peanuts no seafood allergic', 'allergy to peanuts and shellfish'
      ],
      'variations_vi': [
        'tôi dị ứng lạc và hải sản', 'đừng cho đậu phộng bị dị ứng'
      ]
    },
    {
      'id': 'rest_006',
      'category': 'Food & Restaurant',
      'canonical_en': 'Not too spicy, please.',
      'canonical_vi': 'Đừng làm quá cay nhé.',
      'variations_en': [
        'not too spicy please', 'less spicy plz', 'dont make it too spicy', 'mild spicy only'
      ],
      'variations_vi': [
        'ít cay thôi nhé', 'đừng cho cay quá'
      ]
    },
    {
      'id': 'rest_007',
      'category': 'Food & Restaurant',
      'canonical_en': 'Can I have some extra ice and wet wipes?',
      'canonical_vi': 'Cho tôi xin thêm đá và khăn lạnh nhé.',
      'variations_en': [
        'extra ice and wet wipes please', 'more ice and napkins plz', 'can i get ice and tissues'
      ],
      'variations_vi': [
        'cho xin thêm đá với khăn giấy', 'lấy thêm đá và khăn lạnh'
      ]
    },
    {
      'id': 'rest_008',
      'category': 'Food & Restaurant',
      'canonical_en': 'The check, please. / Bill, please.',
      'canonical_vi': 'Cho tôi tính tiền bàn này với.',
      'variations_en': [
        'check please', 'bill please', 'can i have the bill', 'can i pay now', 'check bill please'
      ],
      'variations_vi': [
        'tính tiền bạn ơi', 'cho xin hóa đơn tính tiền'
      ]
    },
    {
      'id': 'rest_009',
      'category': 'Food & Restaurant',
      'canonical_en': 'Do you accept credit cards or only cash?',
      'canonical_vi': 'Ở đây có nhận quẹt thẻ hay chỉ nhận tiền mặt?',
      'variations_en': [
        'can i pay by credit card', 'do you accept cards', 'cash only or credit card ok', 'card payment available'
      ],
      'variations_vi': [
        'quẹt thẻ được không', 'thanh toán thẻ hay tiền mặt'
      ]
    },
    {
      'id': 'rest_010',
      'category': 'Food & Restaurant',
      'canonical_en': 'The food is delicious, thank you to the chef!',
      'canonical_vi': 'Đồ ăn rất ngon, cảm ơn đầu bếp nhé!',
      'variations_en': [
        'food is delicious thanks chef', 'very tasty meal thank you', 'amazing food thanks'
      ],
      'variations_vi': [
        'đồ ăn ngon quá cảm ơn nhiều', 'món ăn tuyệt vời'
      ]
    },

    // =========================================================================
    // TOPIC 5: SHOPPING & TAX REFUND
    // =========================================================================
    {
      'id': 'shop_001',
      'category': 'Shopping & Tax Refund',
      'canonical_en': 'How much does this item cost?',
      'canonical_vi': 'Món hàng này giá bao nhiêu tiền?',
      'variations_en': [
        'how much is this', 'what is the price of this item', 'how much cost', 'price for this item plz', 'how much is it'
      ],
      'variations_vi': [
        'cái này bao nhiêu tiền', 'giá cái này bao nhiêu'
      ]
    },
    {
      'id': 'shop_002',
      'category': 'Shopping & Tax Refund',
      'canonical_en': 'That is too expensive, can you give me a discount?',
      'canonical_vi': 'Đắt quá, bạn có thể giảm giá cho tôi một chút được không?',
      'variations_en': [
        'too expensive discount please', 'can you lower the price', 'give me discount plz', 'any discount for this expensive item'
      ],
      'variations_vi': [
        'đắt quá bớt đi bạn', 'giảm giá chút được ko'
      ]
    },
    {
      'id': 'shop_003',
      'category': 'Shopping & Tax Refund',
      'canonical_en': 'Do you have this in a larger size or another color?',
      'canonical_vi': 'Bạn có mẫu này size lớn hơn hay màu khác không?',
      'variations_en': [
        'do you have bigger size or different color', 'larger size please', 'any other color for this', 'do you have xl size'
      ],
      'variations_vi': [
        'có size to hơn ko', 'có màu khác ko bạn'
      ]
    },
    {
      'id': 'shop_004',
      'category': 'Shopping & Tax Refund',
      'canonical_en': 'Where is the fitting room so I can try this on?',
      'canonical_vi': 'Phòng thay đồ ở đâu để tôi thử chiếc áo này?',
      'variations_en': [
        'where is fitting room', 'can i try this on where is dressing room', 'fitting room location please'
      ],
      'variations_vi': [
        'phòng thử đồ ở đâu', 'thử đồ chỗ nào b'
      ]
    },
    {
      'id': 'shop_005',
      'category': 'Shopping & Tax Refund',
      'canonical_en': 'I am just browsing around right now, thank you.',
      'canonical_vi': 'Tôi chỉ xem qua đồ thôi, cảm ơn bạn nhiều.',
      'variations_en': [
        'just looking thank you', 'im just browsing around', 'just looking around thanks', 'only checking around'
      ],
      'variations_vi': [
        'mình chỉ xem thôi cám ơn', 'chỉ xem qua thôi b'
      ]
    },
    {
      'id': 'shop_006',
      'category': 'Shopping & Tax Refund',
      'canonical_en': 'Where is the tax refund counter located in this shopping mall?',
      'canonical_vi': 'Quầy làm thủ tục hoàn thuế trong trung tâm thương mại này nằm ở đâu?',
      'variations_en': [
        'where is tax refund counter', 'tax refund desk location', 'where can i get tax refund', 'tax free counter where'
      ],
      'variations_vi': [
        'quầy hoàn thuế ở đâu', 'làm hoàn thuế chỗ nào trong mall'
      ]
    },
    {
      'id': 'shop_007',
      'category': 'Shopping & Tax Refund',
      'canonical_en': 'What is the minimum purchase amount required for a tax refund?',
      'canonical_vi': 'Số tiền mua tối thiểu để được hoàn thuế là bao nhiêu?',
      'variations_en': [
        'minimum spending for tax refund', 'how much do i need to spend for tax free', 'min amount tax refund'
      ],
      'variations_vi': [
        'mua bao nhiêu thì được hoàn thuế', 'hóa đơn tối thiểu hoàn thuế'
      ]
    },
    {
      'id': 'shop_008',
      'category': 'Shopping & Tax Refund',
      'canonical_en': 'Please fill out and issue the tax refund form for me.',
      'canonical_vi': 'Vui lòng điền và xuất tờ khai hoàn thuế giúp tôi nhé.',
      'variations_en': [
        'please fill out tax refund form', 'give me tax free form please', 'issue tax refund document plz'
      ],
      'variations_vi': [
        'làm phiếu hoàn thuế giúp tôi', 'viết tờ khai hoàn thuế với'
      ]
    },
    {
      'id': 'shop_009',
      'category': 'Shopping & Tax Refund',
      'canonical_en': 'Can I combine multiple receipts to qualify for tax-free shopping?',
      'canonical_vi': 'Tôi có thể gộp nhiều hóa đơn lại để đủ điều kiện hoàn thuế không?',
      'variations_en': [
        'can i combine receipts for tax refund', 'merge bills for tax free ok', 'combine receipts tax refund right'
      ],
      'variations_vi': [
        'gộp hóa đơn hoàn thuế được ko', 'cộng dồn bill làm hoàn thuế nhé'
      ]
    },
    {
      'id': 'shop_010',
      'category': 'Shopping & Tax Refund',
      'canonical_en': 'I would like to receive my tax refund in cash, please.',
      'canonical_vi': 'Tôi muốn nhận tiền hoàn thuế bằng tiền mặt.',
      'variations_en': [
        'tax refund in cash please', 'i want cash refund not card', 'get tax free cash'
      ],
      'variations_vi': [
        'nhận tiền mặt hoàn thuế nhé', 'hoàn thuế bằng tiền mặt'
      ]
    },
    {
      'id': 'shop_011',
      'category': 'Shopping & Tax Refund',
      'canonical_en': 'How long is the warranty period for this electronic device?',
      'canonical_vi': 'Thời gian bảo hành cho thiết bị điện tử này là bao lâu?',
      'variations_en': [
        'how long is warranty', 'what is warranty period for this', 'warranty duration device'
      ],
      'variations_vi': [
        'bảo hành bao lâu', 'sản phẩm này bảo hành mấy tháng'
      ]
    },
    {
      'id': 'shop_012',
      'category': 'Shopping & Tax Refund',
      'canonical_en': 'Please give me a VAT receipt for my business purchase.',
      'canonical_vi': 'Vui lòng xuất hóa đơn VAT cho khoản mua hàng công ty tôi.',
      'variations_en': [
        'vat receipt for business please', 'can i get red invoice vat', 'issue vat invoice plz'
      ],
      'variations_vi': [
        'xuất hóa đơn đỏ vat giúp tôi', 'lấy hóa đơn vat công ty'
      ]
    },
  ];

  // ---------------------------------------------------------------------------
  // Pre-built O(1) Lookup Indices
  // ---------------------------------------------------------------------------
  static final Map<String, String> _enToViIndex = _buildEnToViIndex();
  static final Map<String, String> _viToEnIndex = _buildViToEnIndex();
  static final Map<String, String> _canonicalIndex = _buildCanonicalIndex();

  static Map<String, String> _buildEnToViIndex() {
    final map = <String, String>{};
    for (final item in allTopics) {
      final canonicalEn = _normalize(item['canonical_en'] as String);
      final canonicalVi = item['canonical_vi'] as String;
      map[canonicalEn] = canonicalVi;

      final variationsEn = item['variations_en'] as List<dynamic>? ?? [];
      for (final v in variationsEn) {
        final cleanV = _normalize(v.toString());
        if (cleanV.isNotEmpty) {
          map[cleanV] = canonicalVi;
        }
      }
    }
    return map;
  }

  static Map<String, String> _buildViToEnIndex() {
    final map = <String, String>{};
    for (final item in allTopics) {
      final canonicalVi = _normalize(item['canonical_vi'] as String);
      final canonicalEn = item['canonical_en'] as String;
      map[canonicalVi] = canonicalEn;

      final variationsVi = item['variations_vi'] as List<dynamic>? ?? [];
      for (final v in variationsVi) {
        final cleanV = _normalize(v.toString());
        if (cleanV.isNotEmpty && cleanV.length > 3) {
          map[cleanV] = canonicalEn;
        }
      }
    }
    return map;
  }

  static String _normalize(String text) {
    var s = text.toLowerCase().trim();
    s = s.replaceAll(RegExp(r'[.?!,;:]+$'), '');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.trim();
  }

  /// O(1) instant lookup against all expanded topics.
  static String? lookup(String input, String sourceLang, String targetLang) {
    final normalized = _normalize(input);
    if (normalized.isEmpty) return null;

    final src = sourceLang.toLowerCase();
    final tgt = targetLang.toLowerCase();
    final isEnToVi = (src == 'en' || src == 'english') && (tgt == 'vi' || tgt == 'vietnamese');
    final isViToEn = (src == 'vi' || src == 'vietnamese') && (tgt == 'en' || tgt == 'english');

    if (isEnToVi && _enToViIndex.containsKey(normalized)) {
      return _enToViIndex[normalized];
    }
    if (isViToEn && _viToEnIndex.containsKey(normalized)) {
      return _viToEnIndex[normalized];
    }
    return null;
  }

  static Map<String, String> _buildCanonicalIndex() {
    final map = <String, String>{};
    for (final item in allTopics) {
      final canonicalEn = item['canonical_en'] as String;
      final cleanEn = _normalize(canonicalEn);
      map[cleanEn] = canonicalEn;

      final canonicalVi = _normalize(item['canonical_vi'] as String);
      map[canonicalVi] = canonicalEn;

      final variationsEn = item['variations_en'] as List<dynamic>? ?? [];
      for (final v in variationsEn) {
        final cleanV = _normalize(v.toString());
        if (cleanV.isNotEmpty) {
          map[cleanV] = canonicalEn;
        }
      }

      final variationsVi = item['variations_vi'] as List<dynamic>? ?? [];
      for (final v in variationsVi) {
        final cleanV = _normalize(v.toString());
        if (cleanV.isNotEmpty) {
          map[cleanV] = canonicalEn;
        }
      }
    }
    return map;
  }

  /// Returns canonical correct English spelling for any input variation or translation.
  static String? getCanonicalEnglish(String input) {
    final normalized = _normalize(input);
    if (normalized.isEmpty) return null;
    return _canonicalIndex[normalized];
  }
}
