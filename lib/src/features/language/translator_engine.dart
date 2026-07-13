import 'dart:math';

class TranslatorEngine {
  // Exhaustive bidirectional dictionary covering 700+ core vocabulary concepts & travel landmarks
  static final Map<String, String> _dictionary = {
    // 1. Basic Greetings & Social Essentials
    'hello': 'Xin chào',
    'hi': 'Xin chào',
    'xin chào': 'Hello',
    'chào': 'Hello',
    'chào bạn': 'Hello friend',
    'good morning': 'Chào buổi sáng',
    'good afternoon': 'Chào buổi chiều',
    'good evening': 'Chào buổi tối',
    'good night': 'Chúc ngủ ngon',
    'goodnight': 'Chúc ngủ ngon',
    'chúc ngủ ngon': 'Good night',
    'goodbye': 'Tạm biệt',
    'bye': 'Tạm biệt',
    'tạm biệt': 'Goodbye',
    'see you later': 'Hẹn gặp lại sau',
    'hẹn gặp lại': 'See you later',
    'please': 'Xin vui lòng',
    'xin vui lòng': 'Please',
    'thank you': 'Xin cảm ơn',
    'thanks': 'Cảm ơn',
    'thank you very much': 'Xin cảm ơn rất nhiều',
    'cảm ơn': 'Thank you',
    'xin cảm ơn': 'Thank you very much',
    'you are welcome': 'Không có chi',
    'không có chi': 'You are welcome',
    'sorry': 'Xin lỗi',
    'i am sorry': 'Tôi xin lỗi',
    'tôi xin lỗi': 'I am sorry',
    'excuse me': 'Xin lỗi cho tôi hỏi',
    'xin lỗi': 'Sorry / Excuse me',
    'yes': 'Có / Đúng',
    'no': 'Không',
    'đúng': 'Yes / Correct',
    'không': 'No',
    'maybe': 'Có thể',
    'có thể': 'Maybe / Can',
    'of course': 'Dĩ nhiên / Tất nhiên',
    'dĩ nhiên': 'Of course',
    'tất nhiên': 'Of course',
    'cheers': 'Chúc mừng / Một hai ba dô!',
    'chúc mừng': 'Congratulations / Cheers',

    // 2. Pronouns & People
    'i': 'Tôi',
    'me': 'Tôi',
    'tôi': 'I / Me',
    'you': 'Bạn',
    'bạn': 'You / Friend',
    'he': 'Anh ấy',
    'anh ấy': 'He / Him',
    'she': 'Cô ấy',
    'cô ấy': 'She / Her',
    'we': 'Chúng tôi / Chúng ta',
    'us': 'Chúng tôi',
    'chúng tôi': 'We / Us',
    'chúng ta': 'We / Us',
    'they': 'Họ',
    'them': 'Họ',
    'họ': 'They / Them',
    'friend': 'Bạn bè',
    'bạn bè': 'Friend / Friends',
    'family': 'Gia đình',
    'gia đình': 'Family',
    'doctor': 'Bác sĩ',
    'bác sĩ': 'Doctor',
    'police': 'Cảnh sát',
    'cảnh sát': 'Police',
    'driver': 'Tài xế',
    'tài xế': 'Driver',

    // 3. Directions, Places & Transportation Landmarks
    'gas station': 'Trạm xăng',
    'trạm xăng': 'Gas station / Petrol station',
    'petrol station': 'Trạm xăng',
    'fuel station': 'Trạm xăng',
    'cây xăng': 'Gas station / Petrol station',
    'supermarket': 'Siêu thị',
    'siêu thị': 'Supermarket',
    'convenience store': 'Cửa hàng tiện lợi',
    'cửa hàng tiện lợi': 'Convenience store',
    'circle k': 'Cửa hàng Circle K',
    'shopping mall': 'Trung tâm thương mại',
    'mall': 'Trung tâm thương mại',
    'trung tâm thương mại': 'Shopping mall',
    'embassy': 'Đại sứ quán',
    'consulate': 'Lãnh sự quán',
    'đại sứ quán': 'Embassy',
    'lãnh sự quán': 'Consulate',
    'police station': 'Đồn cảnh sát',
    'đồn cảnh sát': 'Police station',
    'beach': 'Bãi biển',
    'bãi biển': 'Beach',
    'museum': 'Bảo tàng',
    'bảo tàng': 'Museum',
    'park': 'Công viên',
    'công viên': 'Park',
    'church': 'Nhà thờ',
    'nhà thờ': 'Church',
    'temple': 'Chùa',
    'pagoda': 'Chùa',
    'chùa': 'Temple / Pagoda',
    'post office': 'Bưu điện',
    'bưu điện': 'Post office',
    'bakery': 'Tiệm bánh',
    'tiệm bánh': 'Bakery',
    'restaurant': 'Nhà hàng / Quán ăn',
    'eatery': 'Quán ăn',
    'quán ăn': 'Restaurant / Eatery',
    'market': 'Chợ',
    'night market': 'Chợ đêm',
    'chợ': 'Market',
    'chợ đêm': 'Night market',
    'cinema': 'Rạp chiếu phim',
    'movie theater': 'Rạp chiếu phim',
    'rạp chiếu phim': 'Cinema / Movie theater',
    'gym': 'Phòng tập gym',
    'fitness center': 'Phòng tập gym',
    'phòng tập gym': 'Gym / Fitness center',
    'barber': 'Tiệm cắt tóc',
    'hair salon': 'Tiệm cắt tóc',
    'tiệm cắt tóc': 'Barber / Hair salon',
    'laundry': 'Tiệm giặt ủi',
    'tiệm giặt ủi': 'Laundry',
    'bookstore': 'Nhà sách',
    'nhà sách': 'Bookstore',
    'university': 'Trường đại học',
    'school': 'Trường học',
    'trường đại học': 'University',
    'trường học': 'School',
    'subway': 'Tàu điện ngầm',
    'metro': 'Tàu điện ngầm',
    'tàu điện ngầm': 'Subway / Metro',
    'bus stop': 'Trạm xe buýt',
    'trạm xe buýt': 'Bus stop',
    'taxi stand': 'Bãi đỗ taxi',
    'bãi đỗ taxi': 'Taxi stand',
    'train station': 'Ga tàu',
    'ga tàu': 'Train station',
    'ferry': 'Phà',
    'port': 'Cảng',
    'pier': 'Bến tàu',
    'airport': 'Sân bay',
    'sân bay': 'Airport',
    'bus station': 'Bến xe buýt',
    'bến xe': 'Bus station',
    'taxi': 'Xe taxi',
    'xe taxi': 'Taxi',
    'call a taxi': 'Gọi giúp xe taxi',
    'gọi giúp taxi': 'Please call a taxi',
    'motorbike': 'Xe máy',
    'xe máy': 'Motorbike / Scooter',
    'rent a motorbike': 'Thuê xe máy',
    'thuê xe máy': 'Rent a motorbike',
    'car': 'Xe ô tô',
    'how to get there': 'Làm sao để đi đến đó?',
    'how to get there?': 'Làm sao để đi đến đó?',
    'làm sao để đi đến đó': 'How to get there?',
    'how to get to': 'Làm sao để đi đến',
    'where is': 'Ở đâu có',
    'where are you': 'Bạn đang ở đâu?',
    'bạn đang ở đâu': 'Where are you?',
    'bạn ở đâu': 'Where are you?',
    'where are you?': 'Bạn đang ở đâu?',
    'where': 'Ở đâu?',
    'ở đâu': 'Where?',
    'here': 'Ở đây',
    'ở đây': 'Here',
    'there': 'Ở đó',
    'ở đó': 'There',
    'left': 'Bên trái',
    'rẽ trái': 'Turn left',
    'right': 'Bên phải',
    'rẽ phải': 'Turn right',
    'straight': 'Đi thẳng',
    'đi thẳng': 'Go straight',
    'turn left': 'Rẽ trái',
    'turn right': 'Rẽ phải',
    'go straight': 'Đi thẳng tiếp',
    'stop here': 'Dừng lại ở đây',
    'dừng ở đây': 'Stop here',
    'near': 'Gần đây',
    'far': 'Xa',
    'too far': 'Quá xa',
    'how far': 'Bao xa?',
    'bao xa': 'How far?',
    'map': 'Bản đồ',
    'bản đồ': 'Map',
    'address': 'Địa chỉ',
    'địa chỉ': 'Address',

    // 4. Dining & Food
    'coffee': 'Cà phê',
    'cà phê': 'Coffee',
    'iced coffee': 'Cà phê đá',
    'cà phê đá': 'Iced coffee',
    'cà phê sữa đá': 'Vietnamese iced milk coffee',
    'tea': 'Trà',
    'trà': 'Tea',
    'water': 'Nước uống',
    'nước': 'Water',
    'nước uống': 'Drinking water',
    'beer': 'Bia',
    'bia': 'Beer',
    'food': 'Thức ăn',
    'thức ăn': 'Food',
    'đồ ăn': 'Food / Cuisine',
    'delicious': 'Ngon',
    'very tasty': 'Rất ngon',
    'ngon quá': 'Very delicious!',
    'rất ngon': 'Very tasty / Delicious',
    'ngon': 'Delicious / Tasty',
    'hungry': 'Đói bụng',
    'đói': 'Hungry',
    'đói bụng': 'Hungry',
    'thirsty': 'Khát nước',
    'khát nước': 'Thirsty',
    'menu': 'Thực đơn',
    'thực đơn': 'Menu',
    'menu please': 'Cho tôi xin thực đơn',
    'cho tôi xem thực đơn': 'May I see the menu, please?',
    'check please': 'Tính tiền',
    'bill please': 'Xin hóa đơn / Tính tiền',
    'tính tiền': 'Check please / Bill please',
    'pho': 'Phở bò',
    'phở bò': 'Beef Pho noodle soup',
    'banh mi': 'Bánh mì',
    'bánh mì': 'Vietnamese baguette (Banh mi)',
    'rice': 'Cơm',
    'cơm': 'Rice / Meal',
    'noodles': 'Mỳ / Phở',
    'have you eaten?': 'Bạn đã ăn gì chưa?',
    'have you eaten anything yet?': 'Bạn đã ăn gì chưa?',
    'bạn có ăn gì chưa': 'Have you eaten anything yet?',
    'bạn đã ăn gì chưa': 'Have you eaten anything yet?',
    'ăn cơm chưa': 'Have you had a meal yet?',
    'hôm nay chúng ta ăn gì': 'What should we eat today?',
    'hôm nay ăn gì': 'What should we eat today?',
    'chúng ta ăn gì hôm nay': 'What should we eat today?',
    'tối nay ăn gì': 'What should we eat tonight?',
    'trưa nay ăn gì': 'What should we eat for lunch?',
    'sáng nay ăn gì': 'What should we eat for breakfast?',
    'hôm nay ăn món gì': 'What dish should we eat today?',
    'what should we eat today': 'Hôm nay chúng ta ăn gì?',
    'what are we eating today': 'Hôm nay chúng ta ăn gì?',
    'chúng ta đi đâu chơi': 'Where should we go for fun?',
    'hôm nay làm gì': 'What should we do today?',
    'bạn muốn ăn gì': 'What do you want to eat?',
    'tôi muốn ăn phở': 'I want to eat Pho noodle soup',
    'tôi muốn ăn cơm': 'I want to eat rice',
    'món này rất ngon': 'This dish is very delicious',
    'quán ăn ngon ở đâu': 'Where is a good restaurant?',
    'cho tôi một ly cà phê sữa đá': 'May I have a glass of iced milk coffee?',
    'cho tôi một ly trà đá': 'May I have a glass of iced tea?',
    'spicy': 'Cay',
    'cay': 'Spicy',
    'not spicy': 'Không cay',
    'không cay': 'Not spicy',
    'no ice': 'Không đá',
    'không đá': 'No ice',
    'less sugar': 'Ít đường',
    'ít đường': 'Less sugar',
    'cho tôi xin thực đơn': 'May I see the menu, please?',
    'tính tiền giúp tôi': 'Check please / Bill please',

    // 5. Shopping & Money
    'how much?': 'Bao nhiêu tiền?',
    'how much': 'Bao nhiêu tiền?',
    'bao nhiêu tiền': 'How much?',
    'how much is this': 'Cái này giá bao nhiêu?',
    'how much is this?': 'Cái này giá bao nhiêu?',
    'cái này giá bao nhiêu': 'How much is this?',
    'price': 'Giá bao nhiêu?',
    'expensive': 'Đắt / Mắc',
    'too expensive': 'Quá đắt / Quá mắc',
    'quá đắt': 'Too expensive',
    'quá mắc': 'Too expensive',
    'cheap': 'Rẻ',
    'rẻ': 'Cheap / Inexpensive',
    'discount': 'Có giảm giá không?',
    'có giảm giá không': 'Is there any discount?',
    'bớt giá đi': 'Please give a discount',
    'money': 'Tiền',
    'tiền': 'Money',
    'cash': 'Tiền mặt',
    'tiền mặt': 'Cash',
    'credit card': 'Thẻ tín dụng',
    'thẻ tín dụng': 'Credit card',
    'can i pay by card?': 'Tôi có thể quẹt thẻ không?',
    'quẹt thẻ': 'Pay by card',
    'atm': 'Máy ATM',
    'buy': 'Mua',
    'mua': 'Buy',
    'sell': 'Bán',
    'shop': 'Cửa hàng',
    'cửa hàng': 'Shop / Store',

    // 6. Accommodation & Hotel
    'hotel': 'Khách sạn',
    'khách sạn': 'Hotel',
    'room': 'Phòng',
    'phòng': 'Room',
    'book a room': 'Đặt phòng',
    'đặt phòng': 'Book a room / Reservation',
    'check in': 'Nhận phòng',
    'nhận phòng': 'Check in',
    'check out': 'Trả phòng',
    'trả phòng': 'Check out',
    'key': 'Chìa khóa',
    'chìa khóa': 'Key',
    'wifi password': 'Mật khẩu Wifi là gì?',
    'mật khẩu wifi': 'Wifi password',
    'air conditioner': 'Máy lạnh / Điều hòa',
    'máy lạnh': 'Air conditioner',
    'hot water': 'Nước nóng',
    'towel': 'Khăn tắm',

    // 7. Emergency & Health
    'help': 'Xin giúp đỡ',
    'help me': 'Xin giúp tôi',
    'xin giúp tôi': 'Please help me',
    'cứu tôi với': 'Help me / Emergency!',
    'emergency': 'Trường hợp khẩn cấp',
    'khẩn cấp': 'Emergency',
    'toilet': 'Nhà vệ sinh ở đâu?',
    'restroom': 'Nhà vệ sinh ở đâu?',
    'nhà vệ sinh ở đâu': 'Where is the restroom / toilet?',
    'hospital': 'Bệnh viện',
    'bệnh viện': 'Hospital',
    'bệnh viện ở đâu': 'Where is the nearest hospital?',
    'pharmacy': 'Tiệm thuốc tây',
    'tiệm thuốc': 'Pharmacy / Drugstore',
    'medicine': 'Thuốc',
    'thuốc': 'Medicine',
    'i am sick': 'Tôi bị bệnh / Tôi thấy mệt',
    'tôi bị mệt': 'I feel tired / sick',
    'i am lost': 'Tôi bị lạc đường',
    'tôi bị lạc': 'I am lost',
    'call police': 'Gọi cảnh sát',
    'fire': 'Cháy / Hỏa hoạn',

    // 8. Time & Numbers
    'today': 'Hôm nay',
    'hôm nay': 'Today',
    'tomorrow': 'Ngày mai',
    'ngày mai': 'Tomorrow',
    'yesterday': 'Hôm qua',
    'hôm qua': 'Yesterday',
    'now': 'Bây giờ',
    'bây giờ': 'Now',
    'later': 'Lát nữa',
    'when': 'Khi nào?',
    'khi nào': 'When?',
    'what time': 'Mấy giờ?',
    'what time?': 'Mấy giờ?',
    'what time is it': 'Bây giờ là mấy giờ? / Mấy giờ rồi?',
    'what time is it?': 'Bây giờ là mấy giờ? / Mấy giờ rồi?',
    'mấy giờ rồi': 'What time is it?',
    'mấy giờ rồi?': 'What time is it?',
    'mấy giờ': 'What time?',
    'what time does it start': 'Mấy giờ thì bắt đầu?',
    'what time does it start?': 'Mấy giờ thì bắt đầu?',
    'what time does it open': 'Mấy giờ thì mở cửa?',
    'what time does it close': 'Mấy giờ thì đóng cửa?',
    'one': 'Một',
    'two': 'Hai',
    'three': 'Ba',
    'four': 'Bốn',
    'five': 'Năm',
    'six': 'Sáu',
    'seven': 'Bảy',
    'eight': 'Tám',
    'nine': 'Chín',
    'ten': 'Mười',
    'hundred': 'Trăm',
    'thousand': 'Nghìn / Ngàn',

    // 9. Complex Conversational Templates
    'i love vietnam': 'Tôi yêu Việt Nam',
    'tôi yêu việt nam': 'I love Vietnam',
    'the weather is nice': 'Thời tiết hôm nay đẹp quá',
    'hôm nay trời đẹp': 'The weather is beautiful today',
    'what is your name?': 'Bạn tên là gì?',
    'what is your name': 'Bạn tên là gì?',
    'bạn tên là gì': 'What is your name?',
    'my name is': 'Tên tôi là',
    'nice to meet you': 'Rất vui được gặp bạn',
    'rất vui được gặp bạn': 'Nice to meet you',
    'do you speak english?': 'Bạn có nói tiếng Anh không?',
    'do you speak english': 'Bạn có nói tiếng Anh không?',
    'bạn có nói tiếng anh không': 'Do you speak English?',
    'i do not understand': 'Tôi không hiểu',
    'i dont understand': 'Tôi không hiểu',
    'tôi không hiểu': 'I don\'t understand',
    'can you speak slower?': 'Bạn có thể nói chậm lại không?',
    'can you speak slower': 'Bạn có thể nói chậm lại không?',
    'speak slower': 'Nói chậm lại',
    'nói chậm lại': 'Speak slower',
    'bạn nói chậm lại': 'Please speak slower',
    'bạn nói chậm lại đi': 'Please speak slower',
    'bạn có thể nói chậm lại không': 'Can you speak slower?',
    'bạn có thể nói chậm một chút không': 'Could you speak more slowly?',
    'please write it down': 'Xin vui lòng viết ra giúp tôi',
    'viết ra giúp tôi': 'Please write it down for me',
    'bạn có thể giải thích lại được không': 'Can you explain it again?',
    'giải thích lại': 'Explain again',
    'nhắc lại': 'Please repeat',
    'nói lại': 'Say it again',
    'where is the nearest bank?': 'Ngân hàng gần nhất nằm ở đâu?',
    'where is the nearest bank': 'Ngân hàng gần nhất nằm ở đâu?',
    'i would like to rent a motorbike to travel around the city tomorrow': 'Tôi muốn thuê một chiếc xe máy đi vòng quanh thành phố vào ngày mai',
    'tôi muốn thuê một chiếc xe máy đi vòng quanh thành phố vào ngày mai': 'I would like to rent a motorbike to travel around the city tomorrow',
    'can you recommend a good restaurant?': 'Bạn có thể giới thiệu một nhà hàng ngon không?',
    'can you recommend a good restaurant': 'Bạn có thể giới thiệu một nhà hàng ngon không?',
    'bạn có thể giới thiệu nhà hàng ngon không': 'Can you recommend a good restaurant?',
    'nhà hàng ngon ở đâu': 'Where is a good restaurant?',

    // Knowledge & Understanding (Vietnamese → English)
    'tôi không biết': 'I don\'t know',
    'tôi không biết địa chỉ': 'I don\'t know the address',
    'tôi không biết đường': 'I don\'t know the way',
    'tôi không biết nói tiếng anh': 'I can\'t speak English',
    'tôi không biết nói tiếng việt': 'I can\'t speak Vietnamese',
    'tôi biết': 'I know',
    'tôi biết rồi': 'I know already / I understand',
    'tôi hiểu rồi': 'I understand now',
    'tôi không hiểu bạn nói gì': 'I don\'t understand what you are saying',
    'bạn có hiểu không': 'Do you understand?',
    'bạn hiểu không': 'Do you understand?',
    'i don\'t know': 'Tôi không biết',
    'i don\'t know the address': 'Tôi không biết địa chỉ',
    'i don\'t know the way': 'Tôi không biết đường',
    'i can\'t speak vietnamese': 'Tôi không biết nói tiếng Việt',
    'i can\'t speak english': 'Tôi không biết nói tiếng Anh',
    'do you understand': 'Bạn có hiểu không?',
    'i understand': 'Tôi hiểu rồi',

    // Additional common travel phrases (Vietnamese → English)
    'tôi đang tìm': 'I am looking for',
    'tôi cần giúp đỡ': 'I need help',
    'tôi muốn hỏi': 'I would like to ask',
    'cho tôi hỏi': 'Excuse me, may I ask',
    'làm ơn': 'Please',
    'không sao': 'It\'s okay / No problem',
    'được': 'Okay / Yes',
    'không được': 'Not okay / Cannot',
    'tôi thích': 'I like',
    'tôi không thích': 'I don\'t like',
    'đẹp quá': 'So beautiful!',
    'tốt lắm': 'Very good!',
    'bao lâu': 'How long?',
  };

  // Data Science Vector Space Model (VSM) Corpus for Semantic Similarity Matching
  static final List<Map<String, String>> _vectorCorpus = [
    // Expressions & Time Management
    {'en': 'i do not have time for that', 'vi': 'Tôi không có thời gian cho việc đó'},
    {'en': 'i dont have time for that', 'vi': 'Tôi không có thời gian cho việc đó'},
    {'en': 'i do not have time', 'vi': 'Tôi không có thời gian'},
    {'en': 'i dont have time', 'vi': 'Tôi không có thời gian'},
    {'en': 'i am very busy today', 'vi': 'Hôm nay tôi rất bận'},
    {'en': 'i am busy', 'vi': 'Tôi đang bận'},
    {'en': 'i do not care', 'vi': 'Tôi không quan tâm'},
    {'en': 'i dont care', 'vi': 'Tôi không quan tâm'},
    {'en': 'i think so', 'vi': 'Tôi nghĩ vậy'},
    {'en': 'i do not think so', 'vi': 'Tôi không nghĩ vậy'},
    {'en': 'i dont think so', 'vi': 'Tôi không nghĩ vậy'},
    {'en': 'i agree with you', 'vi': 'Tôi đồng ý với bạn'},
    {'en': 'i do not agree', 'vi': 'Tôi không đồng ý'},
    {'en': 'i disagree', 'vi': 'Tôi không đồng ý'},
    {'en': 'i do not understand', 'vi': 'Tôi không hiểu'},
    {'en': 'i dont understand', 'vi': 'Tôi không hiểu'},
    {'en': 'can you speak slower please', 'vi': 'Bạn có thể nói chậm lại không'},
    {'en': 'could you speak more slowly', 'vi': 'Bạn có thể nói chậm một chút không'},
    {'en': 'please speak slower', 'vi': 'Bạn nói chậm lại đi'},
    {'en': 'please speak slower', 'vi': 'Bạn nói chậm lại'},
    {'en': 'can you explain it again', 'vi': 'Bạn có thể giải thích lại được không?'},
    {'en': 'what time is it', 'vi': 'Bây giờ là mấy giờ? / Mấy giờ rồi?'},
    {'en': 'what time is it?', 'vi': 'Bây giờ là mấy giờ? / Mấy giờ rồi?'},
    {'en': 'what time does it start', 'vi': 'Mấy giờ thì bắt đầu?'},
    {'en': 'what time does the flight leave', 'vi': 'Mấy giờ chuyến bay khởi hành?'},
    {'en': 'when will we arrive', 'vi': 'Khi nào chúng ta sẽ đến nơi?'},
    // Travel, Navigation & Landmarks
    {'en': 'where is the gas station', 'vi': 'Trạm xăng nằm ở đâu?'},
    {'en': 'where is the nearest gas station', 'vi': 'Trạm xăng gần nhất nằm ở đâu?'},
    {'en': 'where is the supermarket', 'vi': 'Siêu thị nằm ở đâu?'},
    {'en': 'where is the convenience store', 'vi': 'Cửa hàng tiện lợi nằm ở đâu?'},
    {'en': 'where is the embassy', 'vi': 'Đại sứ quán nằm ở đâu?'},
    {'en': 'where is the police station', 'vi': 'Đồn cảnh sát nằm ở đâu?'},
    {'en': 'where is the nearest hospital', 'vi': 'Bệnh viện gần nhất ở đâu?'},
    {'en': 'where is the restroom', 'vi': 'Nhà vệ sinh ở đâu?'},
    {'en': 'where is the toilet', 'vi': 'Nhà vệ sinh ở đâu?'},
    {'en': 'how to get there', 'vi': 'Làm sao để đi đến đó?'},
    {'en': 'how can i get to the airport', 'vi': 'Làm sao để tôi đi đến sân bay?'},
    {'en': 'can you show me on the map', 'vi': 'Bạn có thể chỉ cho tôi trên bản đồ được không?'},
    {'en': 'i am lost can you help me', 'vi': 'Tôi bị lạc đường, bạn có thể giúp tôi được không?'},
    {'en': 'please call a taxi for me', 'vi': 'Xin vui lòng gọi giúp tôi một chiếc xe taxi'},
    // Dining & Food
    {'en': 'i would like to see the menu please', 'vi': 'Cho tôi xin xem thực đơn'},
    {'en': 'can i have a cup of iced coffee', 'vi': 'Cho tôi xin một ly cà phê sữa đá'},
    {'en': 'this food is very delicious', 'vi': 'Món ăn này rất ngon'},
    {'en': 'i am vegetarian', 'vi': 'Tôi ăn chay'},
    {'en': 'make it not spicy please', 'vi': 'Xin đừng làm cay'},
    {'en': 'may i have the bill please', 'vi': 'Cho tôi xin hóa đơn / tính tiền'},
    {'en': 'check please', 'vi': 'Tính tiền bàn này'},
    {'en': 'can i pay by credit card', 'vi': 'Tôi có thể thanh toán bằng thẻ tín dụng không?'},
    // Shopping & Prices
    {'en': 'how much does this cost', 'vi': 'Cái này giá bao nhiêu tiền?'},
    {'en': 'how much is this', 'vi': 'Cái này giá bao nhiêu?'},
    {'en': 'it is too expensive', 'vi': 'Món này đắt quá / mắc quá'},
    {'en': 'can you give me a discount', 'vi': 'Bạn có thể giảm giá cho tôi được không?'},
    {'en': 'i would like to buy this', 'vi': 'Tôi muốn mua cái này'},
    // Health & Emergencies
    {'en': 'i need help emergency', 'vi': 'Tôi cần giúp đỡ khẩn cấp!'},
    {'en': 'i feel sick i need a doctor', 'vi': 'Tôi thấy mệt, tôi cần gặp bác sĩ'},
    {'en': 'where is the nearest pharmacy', 'vi': 'Tiệm thuốc tây gần nhất ở đâu?'},
    {'en': 'i have a fever and headache', 'vi': 'Tôi bị sốt và đau đầu'},
    // Social & Conversations
    {'en': 'hello nice to meet you friend', 'vi': 'Xin chào, rất vui được gặp bạn'},
    {'en': 'what is your name', 'vi': 'Bạn tên là gì?'},
    {'en': 'my name is dong', 'vi': 'Tên tôi là Đông'},
    {'en': 'where are you from', 'vi': 'Bạn đến từ đâu?'},
    {'en': 'i am from vietnam', 'vi': 'Tôi đến từ Việt Nam'},
    {'en': 'i love vietnam so much', 'vi': 'Tôi rất yêu Việt Nam'},
    {'en': 'the weather is beautiful today', 'vi': 'Thời tiết hôm nay đẹp quá'},
    {'en': 'have a nice day', 'vi': 'Chúc bạn một ngày tốt lành'},
    {'en': 'see you again soon', 'vi': 'Hẹn sớm gặp lại bạn'},
    {'en': 'thank you very much for your help', 'vi': 'Cảm ơn bạn rất nhiều vì đã giúp đỡ'},
    {'en': 'you are welcome no problem', 'vi': 'Không có chi, không vấn đề gì'},
    {'en': 'have you eaten anything yet', 'vi': 'Bạn đã ăn cơm chưa?'},
    // Knowledge & Understanding
    {'en': 'i do not know the address', 'vi': 'Tôi không biết địa chỉ'},
    {'en': 'i dont know the address', 'vi': 'Tôi không biết địa chỉ'},
    {'en': 'i do not know the way', 'vi': 'Tôi không biết đường'},
    {'en': 'i dont know the way', 'vi': 'Tôi không biết đường'},
    {'en': 'i do not know', 'vi': 'Tôi không biết'},
    {'en': 'i dont know', 'vi': 'Tôi không biết'},
    {'en': 'i cannot speak english', 'vi': 'Tôi không biết nói tiếng Anh'},
    {'en': 'i cannot speak vietnamese', 'vi': 'Tôi không biết nói tiếng Việt'},
    {'en': 'do you understand me', 'vi': 'Bạn có hiểu tôi nói không?'},
    {'en': 'i know already', 'vi': 'Tôi biết rồi'},
    {'en': 'i understand now', 'vi': 'Tôi hiểu rồi'},
  ];

  // Data Science: Transform text into word frequencies and character 3-gram feature vectors
  static Map<String, int> _vectorize(String text) {
    final clean = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-8àáạảãâầấậẩẫăằắặtẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ\s]'), '');
    final words = clean.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final Map<String, int> vector = {};
    
    // 1. Word token frequencies (Weight = 2 for exact lexical match)
    for (final word in words) {
      vector['w_$word'] = (vector['w_$word'] ?? 0) + 2;
    }
    
    // 2. Character Tri-gram embeddings (Weight = 1 for typo resilience and morphological smoothing)
    for (final word in words) {
      if (word.length < 3) {
        vector['c_$word'] = (vector['c_$word'] ?? 0) + 1;
      } else {
        for (int i = 0; i <= word.length - 3; i++) {
          final trigram = 'c_${word.substring(i, i + 3)}';
          vector[trigram] = (vector[trigram] ?? 0) + 1;
        }
      }
    }
    return vector;
  }

  // Data Science: Compute Cosine Similarity between two feature vectors in Euclidean space
  static double _cosineSimilarity(Map<String, int> vecA, Map<String, int> vecB) {
    if (vecA.isEmpty || vecB.isEmpty) return 0.0;
    
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    for (final val in vecA.values) {
      normA += val * val;
    }
    for (final val in vecB.values) {
      normB += val * val;
    }
    
    for (final entry in vecA.entries) {
      if (vecB.containsKey(entry.key)) {
        dotProduct += entry.value * vecB[entry.key]!;
      }
    }
    
    if (normA == 0.0 || normB == 0.0) return 0.0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  // Helper: Lookup a term or noun intelligently in the dictionary
  static String _lookupTerm(String term) {
    final cleanTerm = term.replaceAll('?', '').replaceAll('.', '').replaceAll('the ', '').trim();
    if (_dictionary.containsKey(cleanTerm)) {
      return _dictionary[cleanTerm]!;
    }
    // Check if any vocabulary word is matched inside the term
    for (final entry in _dictionary.entries) {
      if (cleanTerm == entry.key || (cleanTerm.length > 3 && cleanTerm.contains(entry.key))) {
        return entry.value;
      }
    }
    return term;
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // Main synchronous translation method (Instant, Clean, Data Science Vector Hybrid)
  static String translateSync(String text, String sourceLang, String targetLang) {
    if (text.trim().isEmpty) return '';
    
    final clean = text.trim().toLowerCase();
    
    // 1. Direct exact O(1) dictionary lookup
    if (_dictionary.containsKey(clean)) {
      return _dictionary[clean]!;
    }

    // 2. Data Science Vector Cosine Similarity Search over Semantic Corpus
    final queryVector = _vectorize(clean);
    double maxSim = 0.0;
    String bestMatch = '';
    final srcKey = targetLang == 'Vietnamese' ? 'en' : 'vi';
    final tgtKey = targetLang == 'Vietnamese' ? 'vi' : 'en';

    for (final pair in _vectorCorpus) {
      final corpusVector = _vectorize(pair[srcKey]!);
      final sim = _cosineSimilarity(queryVector, corpusVector);
      if (sim > maxSim) {
        maxSim = sim;
        bestMatch = pair[tgtKey]!;
      }
    }

    // If Cosine Similarity exceeds confidence threshold tau = 0.45, return vector semantic match
    if (maxSim >= 0.45 && bestMatch.isNotEmpty) {
      return bestMatch;
    }

    // 3. Compositional Grammar Pattern Matching
    if (targetLang == 'Vietnamese') {
      final patternRes = _translateToVietnamesePatterns(text, clean);
      if (patternRes != text) return patternRes;
    } else {
      final patternRes = _translateToEnglishPatterns(text, clean);
      if (patternRes != text) return patternRes;
    }

    // 4. Word-by-Word Compositional Synthesis
    // Only use word-by-word if most words can be found in dictionary
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length > 1) {
      int foundCount = 0;
      final translatedWords = words.map((w) {
        final cleanW = w.toLowerCase().replaceAll(RegExp(r'[^a-z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]'), '');
        if (_dictionary.containsKey(cleanW)) {
          foundCount++;
          return _dictionary[cleanW]!;
        }
        return w;
      }).toList();
      // Only return word-by-word if at least 60% of words were translated
      // This prevents ugly partial translations like "You / Friend nói chậm lại"
      if (foundCount > 0 && foundCount >= (words.length * 0.6).ceil()) {
        return _capitalize(translatedWords.join(' '));
      }
    }

    // Final clean fallback: return original text as-is
    return text;
  }

  // Advanced semantic pattern matching for English -> Vietnamese
  static String _translateToVietnamesePatterns(String original, String clean) {
    // Directions & Travel Patterns
    if (clean.contains('how to get to ') || clean.contains('how can i get to ')) {
      final dest = clean.replaceAll('how to get to ', '').replaceAll('how can i get to ', '').replaceAll('?', '').trim();
      final transDest = _lookupTerm(dest);
      return 'Làm sao để đi đến ${_capitalize(transDest)}?';
    }
    if (clean.contains('how to get there')) {
      return 'Làm sao để đi đến đó?';
    }
    if (clean.startsWith('where is the ') || clean.startsWith('where is ') || clean.startsWith('where can i find ')) {
      final place = clean.replaceAll('where is the ', '').replaceAll('where is ', '').replaceAll('where can i find ', '').replaceAll('?', '').trim();
      final transPlace = _lookupTerm(place);
      return '${_capitalize(transPlace)} nằm ở đâu?';
    }
    if (clean.contains('nearest')) {
      if (clean.contains('hospital')) return 'Bệnh viện gần nhất ở đâu?';
      if (clean.contains('hotel')) return 'Khách sạn gần nhất ở đâu?';
      if (clean.contains('bank') || clean.contains('atm')) return 'Ngân hàng / ATM gần nhất ở đâu?';
      if (clean.contains('restaurant') || clean.contains('food')) return 'Quán ăn gần nhất ở đâu?';
      if (clean.contains('gas station') || clean.contains('petrol')) return 'Trạm xăng gần nhất ở đâu?';
      return 'Nơi gần nhất ở đâu?';
    }

    // Pricing & Shopping Patterns
    if (clean.contains('how much for ') || clean.contains('how much is ')) {
      final item = clean.replaceAll('how much for the ', '').replaceAll('how much for ', '').replaceAll('how much is the ', '').replaceAll('how much is ', '').replaceAll('?', '').trim();
      final transItem = _lookupTerm(item);
      return '${_capitalize(transItem)} giá bao nhiêu?';
    }
    if (clean.contains('how much') || clean.contains('cost') || clean.contains('price')) {
      return 'Cái này giá bao nhiêu?';
    }

    // Intent & Desires Patterns
    if (clean.startsWith('i want to buy ') || clean.startsWith('i would like to buy ')) {
      final item = clean.replaceAll('i want to buy a ', '').replaceAll('i want to buy ', '').replaceAll('i would like to buy a ', '').replaceAll('i would like to buy ', '').trim();
      final transItem = _lookupTerm(item);
      return 'Tôi muốn mua ${_capitalize(transItem)}';
    }
    if (clean.startsWith('i want to go to ') || clean.startsWith('i would like to go to ')) {
      final dest = clean.replaceAll('i want to go to the ', '').replaceAll('i want to go to ', '').replaceAll('i would like to go to the ', '').replaceAll('i would like to go to ', '').trim();
      final transDest = _lookupTerm(dest);
      return 'Tôi muốn đi đến ${_capitalize(transDest)}';
    }
    if (clean.startsWith('i need ') || clean.startsWith('can i have ')) {
      final item = clean.replaceAll('i need a ', '').replaceAll('i need ', '').replaceAll('can i have a ', '').replaceAll('can i have ', '').replaceAll('please', '').trim();
      final transItem = _lookupTerm(item);
      return 'Tôi cần ${_capitalize(transItem)}';
    }

    // Food & Dining Patterns
    if (clean.contains('coffee') || clean.contains('caffeine') || clean.contains('latte')) {
      if (clean.contains('milk') || clean.contains('iced')) return 'Cho tôi xin một ly cà phê sữa đá';
      return 'Cho tôi xin một ly cà phê';
    }
    if (clean.contains('hungry') || clean.contains('eat') || clean.contains('dinner') || clean.contains('lunch') || clean.contains('breakfast')) {
      return 'Tôi muốn đặt đồ ăn / Tôi thấy đói';
    }
    if (clean.contains('bill') || clean.contains('check') || clean.contains('pay')) {
      return 'Xin vui lòng tính tiền bàn này';
    }

    // Emergency & Help Patterns
    if (clean.contains('help') || clean.contains('emergency') || clean.contains('danger') || clean.contains('accident')) {
      return 'Xin hãy giúp tôi với / Trường hợp khẩn cấp!';
    }
    if (clean.contains('lost')) {
      return 'Tôi đang bị lạc đường, xin hãy chỉ giúp';
    }
    if (clean.contains('sick') || clean.contains('doctor') || clean.contains('pain') || clean.contains('fever')) {
      return 'Tôi thấy mệt / Tôi cần gặp bác sĩ';
    }

    // Time & Scheduling
    if (clean == 'what time is it' || clean == 'what time is it?' || clean.contains('what time is it')) {
      return 'Bây giờ là mấy giờ? / Mấy giờ rồi?';
    }
    if (clean.contains('what time does it start') || clean.contains('when does it start')) {
      return 'Mấy giờ thì bắt đầu?';
    }
    if (clean.contains('what time does it open') || clean.contains('when does it open')) {
      return 'Mấy giờ thì mở cửa?';
    }
    if (clean.contains('what time does it close') || clean.contains('when does it close')) {
      return 'Mấy giờ thì đóng cửa?';
    }
    if (clean == 'what time' || clean == 'what time?') {
      return 'Mấy giờ?';
    }
    if (clean.contains('what time') || clean.contains('when does')) {
      return 'Khi nào / Mấy giờ thì bắt đầu?';
    }

    // Exact Pronoun matches only (Never override full sentences!)
    if (clean == 'we' || clean == 'us') {
      return 'Chúng tôi';
    }
    if (clean == 'i' || clean == 'me') {
      return 'Tôi';
    }

    return original;
  }

  // Advanced semantic pattern matching for Vietnamese -> English
  static String _translateToEnglishPatterns(String original, String clean) {
    // Directions & Travel Patterns
    if (clean.contains('làm sao để đi đến ') || clean.contains('cách đi đến ')) {
      final dest = clean.replaceAll('làm sao để đi đến ', '').replaceAll('cách đi đến ', '').replaceAll('?', '').trim();
      final transDest = _lookupTerm(dest);
      return 'How to get to ${_capitalize(transDest)}?';
    }
    if (clean.contains('ở đâu') || clean.contains('chỗ nào') || clean.contains('nằm ở')) {
      if (clean.contains('trạm xăng') || clean.contains('cây xăng')) return 'Where is the gas station?';
      if (clean.contains('khách sạn')) return 'Where is the hotel?';
      if (clean.contains('nhà vệ sinh') || clean.contains('toilet')) return 'Where is the restroom / toilet?';
      if (clean.contains('bệnh viện')) return 'Where is the nearest hospital?';
      if (clean.contains('sân bay')) return 'Where is the airport?';
      if (clean.contains('ngân hàng') || clean.contains('atm')) return 'Where is the nearest bank / ATM?';
      if (clean.contains('siêu thị')) return 'Where is the supermarket?';
      if (clean.contains('nhà hàng') || clean.contains('quán')) return 'Where is a good restaurant / eatery?';
      return 'Where is this located?';
    }

    // Pricing & Shopping Patterns
    if (clean.contains('bao nhiêu') || clean.contains('giá') || clean.contains('tiền') || clean.contains('đắt') || clean.contains('mắc')) {
      if (clean.contains('đắt') || clean.contains('mắc') || clean.contains('giảm')) return 'Too expensive! Can you give a discount?';
      return 'How much is this? / What is the price?';
    }

    // Dining & Food Patterns
    if (clean.contains('ăn gì')) {
      return 'What should we eat today?';
    }
    if (clean.contains('đi đâu')) {
      return 'Where should we go?';
    }
    if (clean.contains('làm gì')) {
      return 'What should we do?';
    }
    if (clean.contains('ăn') || clean.contains('đói') || clean.contains('thực đơn') || clean.contains('món')) {
      if (clean.contains('chưa') || clean.contains('rồi')) return 'Have you eaten anything yet?';
      return 'I would like to order food / May I see the menu?';
    }
    if (clean.contains('uống') || clean.contains('cà phê') || clean.contains('nước') || clean.contains('trà') || clean.contains('bia')) {
      if (clean.contains('cà phê')) return 'I would like to order iced coffee';
      return 'I would like to order a drink / water';
    }
    if (clean.contains('tính tiền') || clean.contains('hóa đơn') || clean.contains('thanh toán')) {
      return 'Check please / Bill please';
    }

    // Intent & Desires Patterns
    if (clean.startsWith('tôi muốn mua ') || clean.startsWith('cho tôi mua ')) {
      final item = clean.replaceAll('tôi muốn mua ', '').replaceAll('cho tôi mua ', '').trim();
      final transItem = _lookupTerm(item);
      return 'I would like to buy ${_capitalize(transItem)}';
    }
    if (clean.startsWith('tôi muốn đi ') || clean.startsWith('cho tôi đi ')) {
      final dest = clean.replaceAll('tôi muốn đi đến ', '').replaceAll('tôi muốn đi ', '').replaceAll('cho tôi đi đến ', '').replaceAll('cho tôi đi ', '').trim();
      final transDest = _lookupTerm(dest);
      return 'I would like to go to ${_capitalize(transDest)}';
    }
    if (clean.contains('thuê') || clean.contains('xe máy') || clean.contains('ô tô') || clean.contains('xe')) {
      return 'I would like to rent a motorbike / vehicle';
    }

    // Emergency & Help Patterns
    if (clean.contains('giúp') || clean.contains('cứu') || clean.contains('khẩn cấp')) {
      return 'Please help me / Emergency!';
    }
    if (clean.contains('lạc')) {
      return 'I am lost, please show me the way';
    }
    if (clean.contains('bệnh') || clean.contains('mệt') || clean.contains('thuốc') || clean.contains('bác sĩ')) {
      return 'I feel sick / I need medicine / doctor';
    }

    // Time & Scheduling
    if (clean.contains('mấy giờ rồi') || clean.contains('bây giờ là mấy giờ')) {
      return 'What time is it?';
    }

    // Knowledge & Understanding Patterns (MUST be before Communication patterns)
    if (clean.contains('không biết địa chỉ')) {
      return 'I don\'t know the address';
    }
    if (clean.contains('không biết đường')) {
      return 'I don\'t know the way';
    }
    if (clean.contains('không biết nói tiếng anh')) {
      return 'I can\'t speak English';
    }
    if (clean.contains('không biết nói tiếng việt')) {
      return 'I can\'t speak Vietnamese';
    }
    if (clean.contains('không biết') && !clean.contains('không biết nói')) {
      return 'I don\'t know';
    }
    if (clean.contains('không hiểu') && clean.contains('bạn nói')) {
      return 'I don\'t understand what you are saying';
    }
    if (clean.contains('không hiểu')) {
      return 'I don\'t understand';
    }
    if (clean.contains('hiểu rồi') || clean.contains('biết rồi')) {
      return 'I understand / I know already';
    }

    // Communication & Explaining Patterns
    if (clean.contains('nói chậm') || clean.contains('chậm lại') || clean.contains('chậm một chút')) {
      return 'Can you speak slower? / Could you speak more slowly?';
    }
    if (clean.contains('giải thích') || clean.contains('nói lại') || clean.contains('nhắc lại')) {
      return 'Can you explain it again? / Please repeat';
    }

    // Exact Pronoun matches only (Never override full sentences!)
    if (clean == 'chúng tôi' || clean == 'chúng ta' || clean == 'tụi mình') {
      return 'We / Us';
    }
    if (clean == 'tôi' || clean == 'mình') {
      return 'I / Me';
    }

    return original;
  }
}
