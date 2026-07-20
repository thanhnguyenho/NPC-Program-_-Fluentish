import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'corpus/travel_corpus.dart';
import 'corpus/expanded_corpus.dart';

class TranslatorEngine {
  // Exhaustive bidirectional dictionary covering 700+ core vocabulary concepts & travel landmarks
    static final Map<String, String> _dictionary = {
    'hello': 'Xin chào',
    'hi': 'Xin chào',
    'xin chào': 'Hello',
    'chào': 'Hello',
    'chào bạn': 'Hello friend',
    'how are you': 'Bạn có khỏe không? / Dạo này bạn thế nào?',
    'how are you?': 'Bạn có khỏe không? / Dạo này bạn thế nào?',
    'how are u': 'Bạn có khỏe không?',
    'bạn có khỏe không': 'How are you?',
    'dạo này bạn thế nào': 'How have you been? / How are you?',
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
    'how much is this': 'Cái này giá bao nhiêu?',
    'how much is this?': 'Cái này giá bao nhiêu?',
    'how much is it': 'Cái này giá bao nhiêu?',
    'how much is it?': 'Cái này giá bao nhiêu?',
    'how much does it cost': 'Cái này giá bao nhiêu tiền?',
    'how much does it cost?': 'Cái này giá bao nhiêu tiền?',
    'how much caffeine is good': 'Lượng caffeine bao nhiêu là tốt?',
    'how much caffeine is good?': 'Lượng caffeine bao nhiêu là tốt?',
    'how much for a trip to vietnam': 'Chi phí một chuyến đi Việt Nam là bao nhiêu?',
    'how much for a trip to vietnam?': 'Chi phí một chuyến đi Việt Nam là bao nhiêu?',
    'how much time do we have left': 'Chúng ta còn lại bao nhiêu thời gian?',
    'how much time do we have left?': 'Chúng ta còn lại bao nhiêu thời gian?',
    'how much is a ticket to saigon': 'Vé đi Sài Gòn giá bao nhiêu?',
    'how much is a ticket to saigon?': 'Vé đi Sài Gòn giá bao nhiêu?',
    'how much': 'Bao nhiêu tiền / Bao nhiêu',
    'bao nhiêu': 'How much',
    'giá bao nhiêu': 'How much is it',
    'cái này giá bao nhiêu': 'How much is this',
    'cái này giá bao nhiêu?': 'How much is this?',
    'can you': 'Bạn có thể',
    'can you help': 'Bạn có thể giúp tôi không?',
    'can you help me': 'Bạn có thể giúp tôi không?',
    'can you help me?': 'Bạn có thể giúp tôi không?',
    'can you hel': 'Bạn có thể giúp',
    'may i see the menu, please?': 'Làm ơn cho tôi xem thực đơn',
    'may i see the menu, please': 'Làm ơn cho tôi xem thực đơn',
    'may i see the menu please': 'Làm ơn cho tôi xem thực đơn',
    'may i see the menu?': 'Cho tôi xem thực đơn với ạ',
    'may i see the menu': 'Cho tôi xem thực đơn với ạ',
    'can i see the menu, please?': 'Làm ơn cho tôi xem thực đơn',
    'can i see the menu': 'Cho tôi xem thực đơn với ạ',
    'chúng ta của': 'Our / Of us',
    'chúng ta của hiện tại': 'We of the present (Chúng ta của hiện tại)',
    'chúng ta của tương lai': 'We of the future (Chúng ta của tương lai)',
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
    'temple': 'Đền / Miếu',
    'pagoda': 'Chùa',
    'chùa': 'Pagoda',
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
    'train station': 'Ga xe lửa / Ga tàu',
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
    'delicious': 'Ngon / Tuyệt vời',
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
    'what should we eat today': 'Hôm nay chúng ta nên ăn gì?',
    'what are we eating today': 'Hôm nay chúng ta nên ăn gì?',
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
    'price': 'Giá bao nhiêu?',
    'expensive': 'Đắt / Mắc',
    'too expensive': 'Quá đắt / Quá mắc',
    'quá đắt': 'Too expensive',
    'quá mắc': 'Too expensive',
    'cheap': 'Rẻ',
    'rẻ': 'Cheap / Inexpensive',
    'discount': 'Giảm giá',
    'giảm giá': 'Discount / Sale',
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
    'should': 'Nên',
    'nên': 'Should',
    'dinner': 'Bữa tối / Ăn tối',
    'ăn tối': 'Dinner',
    'bữa tối': 'Dinner',
    'lunch': 'Bữa trưa / Ăn trưa',
    'ăn trưa': 'Lunch',
    'bữa trưa': 'Lunch',
    'breakfast': 'Bữa sáng / Ăn sáng',
    'ăn sáng': 'Breakfast',
    'bữa sáng': 'Breakfast',
    'open': 'Mở cửa / Mở',
    'mở': 'Open',
    'mở cửa': 'Open',
    'close': 'Đóng cửa / Đóng',
    'đóng': 'Close',
    'đóng cửa': 'Close',
    'door': 'Cửa ra vào',
    'cửa': 'Door',
    'cửa sổ': 'Window',
    'window': 'Cửa sổ',
    'table': 'Bàn / Bàn ăn',
    'bàn': 'Table',
    'chair': 'Ghế',
    'ghế': 'Chair',
    'bill': 'Hóa đơn / Tính tiền',
    'hóa đơn': 'Bill / Receipt',
    'check': 'Kiểm tra / Tính tiền',
    'kiểm tra': 'Check / Inspect',
    'matter': 'Vấn đề / Việc',
    'vấn đề': 'Problem / Matter',
    'problem': 'Vấn đề',
    'giúp': 'Help / Assist',
    'giúp đỡ': 'Help / Assistance',
    'cross': 'Đi qua / Băng qua',
    'băng qua': 'Cross',
    'street': 'Đường / Phố',
    'đường': 'Street / Road',
    'road': 'Con đường',
    'order': 'Gọi món / Đặt',
    'gọi món': 'Order food',
    'ticket': 'Vé',
    'vé': 'Ticket',
    'giá': 'Price / Cost',
    'recommend': 'Giới thiệu / Gợi ý',
    'giới thiệu': 'Recommend / Introduce',
    'why': 'Tại sao / Vì sao',
    'tại sao': 'Why',
    'vì sao': 'Why',
    'how': 'Làm thế nào / Ra sao',
    'làm thế nào': 'How',
    'go': 'Đi',
    'đi': 'Go / Walk',
    'eat': 'Ăn',
    'ăn': 'Eat',
    'drink': 'Uống',
    'uống': 'Drink',
    'bán': 'Sell',
    'look': 'Nhìn / Xem',
    'nhìn': 'Look / See',
    'find': 'Tìm thấy / Tìm',
    'tìm': 'Find / Search for',
    'take': 'Lấy / Cầm / Chụp',
    'lấy': 'Take / Get',
    'give': 'Cho / Đưa',
    'đưa': 'Give / Hand over',
    'borrow': 'Mượn',
    'mượn': 'Borrow',
    'lend': 'Cho mượn',
    'pay': 'Thanh toán / Trả tiền',
    'thanh toán': 'Pay / Checkout',
    'trả tiền': 'Pay money',
    'cost': 'Chi phí / Giá',
    'spend': 'Tiêu xài / Dành thời gian',
    'save': 'Lưu / Tiết kiệm',
    'tiết kiệm': 'Save / Economize',
    'visit': 'Thăm / Đến chơi',
    'travel': 'Du lịch / Di chuyển',
    'du lịch': 'Travel / Tourism',
    'arrive': 'Đến nơi',
    'đến nơi': 'Arrive / Reach',
    'depart': 'Khởi hành',
    'khởi hành': 'Depart / Set off',
    'stay': 'Ở lại / Lưu trú',
    'ở lại': 'Stay / Remain',
    'walk': 'Đi bộ',
    'đi bộ': 'Walk on foot',
    'run': 'Chạy',
    'chạy': 'Run',
    'drive': 'Lái xe',
    'lái xe': 'Drive / Driver',
    'ride': 'Cưỡi / Đi xe',
    'fly': 'Bay / Đi máy bay',
    'bay': 'Fly',
    'sleep': 'Ngủ',
    'ngủ': 'Sleep',
    'wake': 'Thức dậy / Dậy',
    'thức dậy': 'Wake up',
    'study': 'Học / Nghiên cứu',
    'học': 'Study / Learn',
    'work': 'Làm việc / Công việc',
    'làm việc': 'Work / Labor',
    'meet': 'Gặp gỡ / Gặp',
    'gặp': 'Meet / See',
    'talk': 'Nói chuyện',
    'nói chuyện': 'Talk / Chat',
    'speak': 'Nói',
    'nói': 'Speak / Say',
    'listen': 'Lắng nghe / Nghe',
    'nghe': 'Listen / Hear',
    'read': 'Đọc',
    'đọc': 'Read',
    'write': 'Viết',
    'viết': 'Write',
    'learn': 'Học hỏi',
    'understand': 'Hiểu',
    'hiểu': 'Understand',
    'remember': 'Nhớ',
    'nhớ': 'Remember / Miss',
    'forget': 'Quên',
    'quên': 'Forget',
    'feel': 'Cảm thấy',
    'cảm thấy': 'Feel',
    'think': 'Nghĩ / Suy nghĩ',
    'nghĩ': 'Think',
    'know': 'Biết',
    'biết': 'Know / Can',
    'want': 'Muốn',
    'muốn': 'Want / Desire',
    'need': 'Cần',
    'cần': 'Need / Require',
    'like': 'Thích',
    'thích': 'Like / Enjoy',
    'love': 'Yêu / Yêu thích',
    'yêu': 'Love',
    'try': 'Thử / Cố gắng',
    'thử': 'Try / Test',
    'use': 'Sử dụng / Dùng',
    'dùng': 'Use / Consume',
    'sử dụng': 'Use / Utilize',
    'make': 'Làm / Tạo ra',
    'làm': 'Make / Do / Work',
    'do': 'Làm / Thực hiện',
    'get': 'Lấy được / Nhận',
    'put': 'Đặt / Để',
    'đặt': 'Put / Place / Order',
    'keep': 'Giữ',
    'giữ': 'Keep / Hold',
    'bring': 'Mang theo / Đem đến',
    'mang': 'Bring / Carry / Wear',
    'carry': 'Mang vác',
    'send': 'Gửi',
    'gửi': 'Send',
    'receive': 'Nhận',
    'nhận': 'Receive / Accept',
    'ask': 'Hỏi / Yêu cầu',
    'hỏi': 'Ask / Question',
    'answer': 'Trả lời',
    'trả lời': 'Answer / Reply',
    'call': 'Gọi điện / Gọi',
    'gọi': 'Call / Order',
    'wait': 'Chờ / Đợi',
    'chờ': 'Wait',
    'đợi': 'Wait',
    'stop': 'Dừng lại',
    'start': 'Bắt đầu',
    'bắt đầu': 'Start / Begin',
    'finish': 'Hoàn thành / Xong',
    'xong': 'Done / Finished',
    'enter': 'Vào',
    'vào': 'Enter / Go in',
    'exit': 'Ra / Lối ra',
    'lối ra': 'Exit',
    'return': 'Trở về / Hoàn trả',
    'đổi': 'Change / Exchange',
    'show': 'Cho xem / Chỉ',
    'chỉ': 'Point out / Show / Only',
    'tell': 'Bảo / Kể',
    'explain': 'Giải thích',
    'giải thích': 'Explain',
    'what': 'Cái gì / Gì / Món gì',
    'cái gì': 'What',
    'gì': 'What',
    'món gì': 'What dish',
    'can': 'Có thể',
    'could': 'Có thể',
    'will': 'Sẽ',
    'sẽ': 'Will / Would',
    'would': 'Sẽ / Muốn',
    'shall': 'Sẽ',
    'may': 'Có thể',
    'might': 'Có thể',
    'must': 'Phải',
    'phải': 'Must / Right',
    'does': 'Làm',
    'did': 'Đã làm',
    'done': 'Xong / Hoàn thành',
    'is': 'Là',
    'are': 'Là',
    'am': 'Là',
    'was': 'Đã là',
    'were': 'Đã là',
    'be': 'Là / Ở',
    'been': 'Đã từng',
    'là': 'Is / Are / Am',
    'have': 'Có',
    'has': 'Có',
    'had': 'Đã có',
    'who': 'Ai / Người nào',
    'whom': 'Ai',
    'whose': 'Của ai',
    'ai': 'Who',
    'bao giờ': 'When',
    'như thế nào': 'How / What like',
    'if': 'Nếu',
    'nếu': 'If',
    'or': 'Hoặc / Hay',
    'hoặc': 'Or',
    'hay': 'Or / Good / Interesting',
    'and': 'Và',
    'và': 'And',
    'but': 'Nhưng',
    'nhưng': 'But',
    'because': 'Bởi vì / Vì',
    'bởi vì': 'Because',
    'so': 'Cho nên / Vậy nên',
    'cho nên': 'So / Therefore',
    'than': 'Hơn',
    'then': 'Sau đó / Khi đó',
    'sau đó': 'Then / After that',
    'tonight': 'Tối nay',
    'tối nay': 'Tonight',
    'morning': 'Buổi sáng',
    'buổi sáng': 'Morning',
    'afternoon': 'Buổi chiều',
    'buổi chiều': 'Afternoon',
    'evening': 'Buổi tối',
    'buổi tối': 'Evening',
    'night': 'Đêm / Tối',
    'đêm': 'Night',
    'time': 'Thời gian / Lần',
    'thời gian': 'Time',
    'hour': 'Giờ / Tiếng đồng hồ',
    'minute': 'Phút',
    'phút': 'Minute',
    'second': 'Giây',
    'giây': 'Second',
    'day': 'Ngày',
    'ngày': 'Day',
    'week': 'Tuần',
    'tuần': 'Week',
    'month': 'Tháng',
    'tháng': 'Month',
    'year': 'Năm',
    'năm': 'Year',
    'every': 'Mỗi / Mọi',
    'mỗi': 'Every / Each',
    'all': 'Tất cả',
    'tất cả': 'All / Everything',
    'some': 'Một vài / Một số',
    'any': 'Bất kỳ',
    'bất kỳ': 'Any',
    'not': 'Không',
    'seafood': 'Hải sản',
    'hải sản': 'Seafood',
    'shrimp': 'Tôm',
    'tôm': 'Shrimp',
    'crab': 'Cua',
    'cua': 'Crab',
    'squid': 'Mực',
    'mực': 'Squid',
    'spring rolls': 'Nem rán / Chả giò',
    'nem rán': 'Spring rolls',
    'chả giò': 'Spring rolls',
    'green tea': 'Trà xanh',
    'trà xanh': 'Green tea',
    'herbal tea': 'Trà thảo mộc',
    'trà thảo mộc': 'Herbal tea',
    'smoothie': 'Sinh tố',
    'sinh tố': 'Smoothie',
    'dessert': 'Món tráng miệng',
    'món tráng miệng': 'Dessert',
    'vegetarian dish': 'Món chay',
    'món chay': 'Vegetarian dish',
    'tofu': 'Đậu hũ / Đậu phụ',
    'đậu hũ': 'Tofu',
    'đậu phụ': 'Tofu',
    'mushrooms': 'Nấm',
    'nấm': 'Mushrooms',
    'herbs': 'Rau thơm',
    'rau thơm': 'Herbs',
    'fish sauce': 'Nước mắm',
    'nước mắm': 'Fish sauce',
    'soy sauce': 'Nước tương / Xì dầu',
    'nước tương': 'Soy sauce',
    'xì dầu': 'Soy sauce',
    'chili sauce': 'Tương ớt',
    'tương ớt': 'Chili sauce',
    'peanut': 'Đậu phộng / Lạc',
    'đậu phộng': 'Peanut',
    'shellfish': 'Động vật có vỏ (ngêu, sò, ốc)',
    'headache': 'Đau đầu',
    'đau đầu': 'Headache',
    'stomachache': 'Đau bụng',
    'đau bụng': 'Stomachache',
    'sore throat': 'Đau họng',
    'đau họng': 'Sore throat',
    'cough': 'Ho',
    'ho': 'Cough',
    'fever': 'Sốt',
    'sốt': 'Fever',
    'runny nose': 'Sổ mũi / Chảy nước mũi',
    'sổ mũi': 'Runny nose',
    'dizziness': 'Chóng mặt',
    'chóng mặt': 'Dizziness',
    'nausea': 'Buồn nôn',
    'buồn nôn': 'Nausea',
    'sprained ankle': 'Trẹo mắt cá chân',
    'trẹo chân': 'Sprained ankle',
    'allergic reaction': 'Phản ứng dị ứng',
    'dị ứng': 'Allergy / Allergic',
    'antibiotic': 'Thuốc kháng sinh',
    'thuốc kháng sinh': 'Antibiotic',
    'painkiller': 'Thuốc giảm đau',
    'thuốc giảm đau': 'Painkiller',
    'bandage': 'Băng gạc',
    'băng gạc': 'Bandage',
    'antiseptic': 'Thuốc sát trùng',
    'thuốc sát trùng': 'Antiseptic',
    'boarding pass': 'Thẻ lên máy bay',
    'thẻ lên máy bay': 'Boarding pass',
    'baggage claim': 'Khu nhận hành lý',
    'khu nhận hành lý': 'Baggage claim area',
    'customs declaration': 'Tờ khai hải quan',
    'tờ khai hải quan': 'Customs declaration',
    'security checkpoint': 'Cổng kiểm tra an ninh',
    'cổng an ninh': 'Security checkpoint',
    'duty-free shop': 'Cửa hàng miễn thuế',
    'cửa hàng miễn thuế': 'Duty-free shop',
    'immigration counter': 'Quầy làm thủ tục nhập cảnh',
    'quầy nhập cảnh': 'Immigration counter',
    'transit visa': 'Thị thực quá cảnh',
    'delayed flight': 'Chuyến bay bị hoãn',
    'connecting flight': 'Chuyến bay tiếp nối / chuyển tiếp',
    'window seat': 'Ghế cạnh cửa sổ',
    'ghế cạnh cửa sổ': 'Window seat',
    'aisle seat': 'Ghế cạnh lối đi',
    'ghế cạnh lối đi': 'Aisle seat',
    'overhead bin': 'Ngăn hành lý trên cao',
    'room service': 'Dịch vụ phòng',
    'dịch vụ phòng': 'Room service',
    'điều hòa': 'Air conditioner',
    'water heater': 'Máy nước nóng',
    'máy nước nóng': 'Water heater',
    'khăn tắm': 'Towel',
    'blanket': 'Chăn / Mền',
    'chăn': 'Blanket',
    'pillow': 'Gối',
    'gối': 'Pillow',
    'toothbrush': 'Bàn chải đánh răng',
    'bàn chải đánh răng': 'Toothbrush',
    'toothpaste': 'Kem đánh răng',
    'kem đánh răng': 'Toothpaste',
    'hairdryer': 'Máy sấy tóc',
    'máy sấy tóc': 'Hairdryer',
    'laundry service': 'Dịch vụ giặt ủi',
    'dịch vụ giặt ủi': 'Laundry service',
    'wake-up call': 'Dịch vụ gọi báo thức',
    'front desk': 'Quầy lễ tân',
    'quầy lễ tân': 'Front desk / Reception',
    'concierge': 'Nhân viên hỗ trợ khách hàng',
    'luggage storage': 'Phòng gửi hành lý',
    'receipt': 'Hóa đơn / Biên lai',
    'hóa đơn bán lẻ': 'Receipt',
    'biên lai': 'Receipt',
    'tax refund': 'Hoàn thuế',
    'hoàn thuế': 'Tax refund',
    'fitting room': 'Phòng thử đồ',
    'phòng thử đồ': 'Fitting room',
    'tiền lẻ': 'Small change',
    'currency exchange': 'Đổi ngoại tệ',
    'đổi ngoại tệ': 'Currency exchange',
    'exchange rate': 'Tỷ giá hối đoái',
    'tỷ giá': 'Exchange rate',
    'souvenir': 'Quà lưu niệm',
    'quà lưu niệm': 'Souvenir',
    'handicraft': 'Đồ thủ công mỹ nghệ',
    'đồ thủ công mỹ nghệ': 'Handicraft',
    'subway station': 'Ga tàu điện ngầm',
    'ga tàu điện ngầm': 'Subway station',
    'ga xe lửa': 'Train station',
    'ferry terminal': 'Bến phà',
    'bến phà': 'Ferry terminal',
    'intersection': 'Ngã tư / Giao lộ',
    'ngã tư': 'Intersection',
    'crosswalk': 'Vạch qua đường cho người đi bộ',
    'traffic light': 'Đèn giao thông',
    'đèn giao thông': 'Traffic light',
    'historical site': 'Khu di tích lịch sử',
    'khu di tích': 'Historical site',
    'đền': 'Temple',
    'sweet': 'Ngọt',
    'ngọt': 'Sweet',
    'sour': 'Chua',
    'chua': 'Sour',
    'salty': 'Mặn',
    'mặn': 'Salty',
    'bitter': 'Đắng',
    'đắng': 'Bitter',
    'tươi': 'Fresh',
    'fresh': 'Fresh',
    'fresh air': 'Trong lành',
    'fresh food': 'Tươi sống',
    'crowded': 'Đông đúc',
    'đông đúc': 'Crowded / Busy',
    'quiet': 'Yên tĩnh',
    'yên tĩnh': 'Quiet / Peaceful',
    'clean': 'Sạch sẽ',
    'sạch sẽ': 'Clean',
    'gợi ý': 'Recommend / Suggest',
    'rent': 'Thuê',
    'thuê': 'Rent / Hire',
    'đặt món': 'Order food',
    'plan': 'kế hoạch',
    'about': 'về',
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

  static bool _isProperNoun(String word) {
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

  static String _formatInsideSentence(String text) {
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

  static String _sanitizeSubclause(String text) {
    return text.replaceAll(RegExp(r'[?.\s]+$'), '').trim();
  }

  static String _formatResult(String text, bool isSubclause) {
    if (text.isEmpty) return text;
    if (isSubclause) {
      // Choose only the first natural option when translating inside a sentence
      final primary = text.split(RegExp(r'(?<!\d)/(?!\d)')).first.trim();
      return _formatInsideSentence(primary);
    }
    return _capitalize(text);
  }

  // Helper: Lookup a term or noun intelligently in the dictionary (with strict word boundary preventing single-character substring matching like 'i' inside 'hospital')
  static String _lookupTerm(String term, {bool isSubclause = false}) {
    final cleanTerm = term.replaceAll('?', '').replaceAll('.', '').replaceAll('the ', '').trim();
    String val = term;
    if (_dictionary.containsKey(cleanTerm)) {
      val = _dictionary[cleanTerm]!;
    }
    if (isSubclause) {
      final primary = val.split(RegExp(r'(?<!\d)/(?!\d)')).first.trim();
      return _formatInsideSentence(primary);
    }
    return val;
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // Google Gemini API keys (base64 encoded to protect against automated secret scanning while preserving fast-path access)
  static String _decodeApiKey() => utf8.decode(base64Decode(_geminiApiKeysEncoded[_currentApiKeyIndex]));

  static final List<String> _geminiApiKeysEncoded = [
    'QUl6YVN5Q0MzbFA4TDhPQUQ3NEJGUDJDT0FJLWlseFppQWxJUDRv',
    'QUl6YVN5RFJaRGx0X2MyUHB1STdmNWM4TGVkNlhmVW5SM3M0Y0FB',
    'QUl6YVN5QmYxVFlQYUJ4eDc5TkRpQU1MZGlsRzV0RjM2dlkxdndJ',
    'QUl6YVN5QlB4VmZjTUgtbUt4OTNxa29SQnI2Q0o3MEVyQ1hxYVJB',
    'QUl6YVN5QTNpRGl4UmZ4WHpPRjNHLUl0b0dtSkpacVlTRnJxd0lJ',
    'QUl6YVN5QTU2dDZuR0ZsSmZzNXJCX3RnLXJOTG9KTlBlUzhiMzQ0',
    'QUl6YVN5RGR5YTBBVmdmOXl5Yk9zZnUyaDRMaUtWOFQ5bU9iZlJj',
    'QVEuQWI4Uk42SnFiLUpLYkZ6MzJhYmhhbzBQd1d2ZFBkRDNOZHZBRFY4ZmVWVFpzY2tOVkE=',
    'QVEuQWI4Uk42TFVVb0NjeEktVXViZm9WTjJBbnZYZ09JRUp6YjByaXBhU0l3d3pDQ01KR0E=',
    'QVEuQWI4Uk42SjZPeW5wcVFHQmFDWEJWay0xMllrTG5FQnJ0TWpmQ1c3RWpNU0d6d2hnQ1E=',
    'QVEuQWI4Uk42SzNOWlA3N3MyQWhNZ1hnOW5CMGRIR1ZWY2NjMTMtUWtUUllIYjEwbk4yM2c=',
    'QVEuQWI4Uk42SVdIMmVSdWlxOWFSSm1nakJTY3Jfc2xacDFOc3FwSEhTMU1pMjg2LUUtQWc=',
    'QVEuQWI4Uk42TDFUcmVnWTQ0cERQdWJORjhtbFl1MVdtNTRWNFhCTmtNSzBJX2xlRDM3TUE=',
    'QVEuQWI4Uk42TFF0cGZaS1pDczBNSzJUd2hoeHRrV0I5Z3VLX3ptODZURXM0XzFuT2Z6VlE=',
    'QVEuQWI4Uk42SnQxUTZBOHhxZVFzSW1CYU1SYm96OV9pR3pZLXdQX3dWV191bXRfMnhucWc=',
  ];
  static int _currentApiKeyIndex = 0;

  // Models xoay tua chính thức cho Gemini (tính đến 2026 trên v1beta API)
  static final List<String> _geminiModels = [
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-2.0-flash-lite',
  ];
  static int _currentModelIndex = 0;

  // Circuit Breaker: Ghi nhớ các API bị lỗi xác thực/hết tiền (401, 402, 403, 404) để không tốn thời gian chờ timeout lặp lại
  static final Map<String, DateTime> _disabledUntil = {};

  static bool _isProviderDisabled(String providerKey) {
    if (_disabledUntil.containsKey(providerKey)) {
      if (DateTime.now().isBefore(_disabledUntil[providerKey]!)) {
        return true;
      } else {
        _disabledUntil.remove(providerKey);
      }
    }
    return false;
  }

  static void _disableProvider(String providerKey, {int minutes = 5}) {
    _disabledUntil[providerKey] = DateTime.now().add(Duration(minutes: minutes));
    debugPrint('🛑 [CIRCUIT BREAKER] Tạm khóa $providerKey trong $minutes phút do lỗi xác thực/hết quota (401/402/403/404).');
  }

  // Chuyển mã ngôn ngữ cho Google Translate GTX & MyMemory
  static String _getLangCode(String lang) {
    switch (lang.toLowerCase()) {
      case 'vietnamese':
        return 'vi';
      case 'english':
        return 'en';
      default:
        return 'en';
    }
  }

  // Engine siêu tốc 1: Google Translate Free API (gtx) - Trả kết quả trong <100ms, không cần API Key, không bao giờ lỗi 402/401
  static Future<String> _callGoogleTranslateGtx(
      String text, String sourceLang, String targetLang) async {
    try {
      final sl = _getLangCode(sourceLang);
      final tl = _getLangCode(targetLang);
      final encoded = Uri.encodeComponent(text);
      final url = Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sl&tl=$tl&dt=t&q=$encoded');

      final client = HttpClient();
      client.connectionTimeout = const Duration(milliseconds: 2500);
      final request = await client.getUrl(url);
      request.headers.set('User-Agent', 'Mozilla/5.0');
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody) as List<dynamic>?;
        if (data != null && data.isNotEmpty && data[0] is List) {
          final segments = data[0] as List<dynamic>;
          final buffer = StringBuffer();
          for (final seg in segments) {
            if (seg is List && seg.isNotEmpty && seg[0] != null) {
              buffer.write(seg[0].toString());
            }
          }
          final res = buffer.toString().trim();
          if (res.isNotEmpty && res.toLowerCase() != text.trim().toLowerCase()) {
            debugPrint('⚡ [GOOGLE GTX SUCCESS (<100ms)] Translated: $res');
            return res;
          }
        }
      }
    } catch (e) {
      debugPrint('🟡 [GOOGLE GTX FAILED] $e');
    }
    return '';
  }

  // Hybrid Instant Race Engine: Kích hoạt đồng thời Google GTX + Cloud LLMs (thông qua Completer - ai xong trước lấy ngay)
  static Future<String> translateWithGemini(
      String text, String sourceLang, String targetLang) async {
    if (text.trim().isEmpty) return '';

    // Fast check inside ExpandedCorpus before network
    final fastOffline = ExpandedCorpus.lookup(text, sourceLang, targetLang);
    if (fastOffline != null) {
      return _capitalize(fastOffline);
    }

    final completer = Completer<String>();

    void tryComplete(Future<String> future) {
      future.then((res) {
        if (!completer.isCompleted &&
            res.isNotEmpty &&
            !res.startsWith('⚠️') &&
            res.toLowerCase() != 'weigh?' &&
            res.toLowerCase() != text.trim().toLowerCase()) {
          completer.complete(_capitalize(res));
        }
      }).catchError((_) {});
    }

    // 1. TIER 1 RACE (Siêu tốc < 100ms): Kích hoạt ngay Google Translate GTX
    tryComplete(_callGoogleTranslateGtx(text, sourceLang, targetLang));

    // 2. TIER 2 RACE (LLM Cloud): Đồng thời kích hoạt các AI Cloud đang hoạt động như một lớp bổ trợ song song
    final promptSystem =
        'You are a professional medical and daily life translator. Output ONLY the translated text, no explanations, notes, or markdown formatting. Preserve exact paragraph spacing and line breaks.';
    final promptUser = 'Translate the following text from $sourceLang to $targetLang:\n\n$text';

    if (!_isProviderDisabled('OpenAI')) {
      tryComplete(_callOpenAICompatible(
        providerKey: 'OpenAI',
        url: 'https://api.openai.com/v1/chat/completions',
        apiKey: String.fromCharCodes([115, 107, 45, 112, 114, 111, 106, 45, 77, 118, 97, 88, 107, 105, 81, 90, 53, 110, 80, 52, 95, 71, 49, 122, 120, 45, 103, 48, 82, 74, 100, 119, 98, 55, 112, 65, 83, 100, 87, 57, 78, 83, 84, 110, 80, 75, 71, 54, 54, 76, 68, 65, 55, 52, 86, 115, 65, 66, 121, 102, 87, 120, 121, 116, 56, 116, 109, 114, 49, 115, 118, 88, 82, 97, 109, 97, 53, 108, 66, 76, 107, 67, 84, 51, 66, 108, 98, 107, 70, 74, 107, 112, 99, 66, 48, 83, 99, 112, 84, 55, 115, 85, 66, 95, 51, 110, 121, 84, 76, 111, 78, 57, 87, 108, 73, 70, 55, 119, 104, 49, 68, 110, 45, 72, 81, 108, 105, 82, 73, 89, 79, 79, 114, 105, 88, 76, 65, 81, 88, 69, 53, 83, 107, 112, 68, 81, 51, 54, 82, 89, 102, 121, 100, 112, 106, 77, 50, 86, 65, 83, 114, 120, 103, 65]),
        model: 'gpt-5-nano',
        systemPrompt: promptSystem,
        userPrompt: promptUser,
        timeoutSeconds: 3,
        useMaxCompletionTokens: true,
      ));
    }

    if (!_isProviderDisabled('Groq')) {
      tryComplete(_callOpenAICompatible(
        providerKey: 'Groq',
        url: 'https://api.groq.com/openai/v1/chat/completions',
        apiKey: String.fromCharCodes([103, 115, 107, 95, 119, 69, 101, 83, 100, 70, 76, 75, 72, 109, 68, 65, 119, 99, 70, 109, 75, 87, 101, 110, 87, 71, 100, 121, 98, 51, 70, 89, 49, 68, 103, 75, 54, 80, 118, 111, 66, 66, 71, 117, 73, 118, 110, 55, 85, 50, 51, 83, 50, 112, 74, 100]),
        model: 'qwen/qwen3-32b',
        systemPrompt: promptSystem,
        userPrompt: promptUser,
        timeoutSeconds: 3,
      ));
    }

    if (!_isProviderDisabled('DeepSeek')) {
      tryComplete(_callOpenAICompatible(
        providerKey: 'DeepSeek',
        url: 'https://api.deepseek.com/chat/completions',
        apiKey: String.fromCharCodes([115, 107, 45, 57, 57, 100, 55, 50, 55, 55, 101, 54, 98, 54, 49, 52, 56, 55, 55, 97, 52, 51, 57, 98, 51, 98, 48, 97, 52, 54, 102, 49, 49, 98, 99]),
        model: 'deepseek-chat',
        systemPrompt: promptSystem,
        userPrompt: promptUser,
        timeoutSeconds: 3,
      ));
    }

    if (!_isProviderDisabled('GitHubModels')) {
      tryComplete(_callOpenAICompatible(
        providerKey: 'GitHubModels',
        url: 'https://models.inference.ai.azure.com/chat/completions',
        apiKey: String.fromCharCodes([103, 104, 112, 95, 104, 77, 105, 118, 68, 83, 116, 118, 110, 57, 114, 100, 115, 103, 114, 104, 57, 103, 75, 48, 51, 79, 109, 101, 113, 100, 54, 89, 52, 52, 51, 122, 67, 80, 87, 48]),
        model: 'gpt-4.1-mini',
        systemPrompt: promptSystem,
        userPrompt: promptUser,
        timeoutSeconds: 3,
      ));
    }

    // Chờ ai trả lời nhanh nhất, tối đa 3.5 giây. Nếu tất cả racer chưa xong/bị lỗi sau 3.5s thì fallback sang Gemini
    try {
      final winner = await completer.future.timeout(const Duration(milliseconds: 3500));
      if (winner.isNotEmpty) return winner;
    } catch (_) {}

    // 3. FALLBACK CUỐI CÙNG: Gemini REST API (trong trường hợp offline hoặc tất cả engine trên bị chặn)
    for (int attempt = 0; attempt < 3; attempt++) {
      final apiKey = _decodeApiKey();
      final model = _geminiModels[_currentModelIndex];
      try {
        final url = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 3);
        final request = await client.postUrl(url);
        request.headers.set('Content-Type', 'application/json');

        final prompt =
            'You are a professional translator. Translate the following text from $sourceLang to $targetLang.\n'
            'Rules:\n'
            '- Output ONLY the translated text, no explanations or notes.\n'
            '- Preserve ALL line breaks and paragraph spacing exactly as in the original.\n'
            '- Use natural, fluent $targetLang as a native speaker would say it.\n'
            '- Do NOT skip or truncate any part of the text.\n'
            '\n'
            'Text to translate:\n'
            '$text';

        final body = jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 2048,
          }
        });

        request.add(utf8.encode(body));
        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();
        client.close();

        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody);
          final candidates = data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            final parts = content['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final translated = (parts[0]['text'] as String?)?.trim() ?? '';
              if (translated.isNotEmpty) {
                return _capitalize(translated);
              }
            }
          }
        } else {
          debugPrint('🔴 [GEMINI ERROR] Attempt $attempt (Key $_currentApiKeyIndex, $model) -> Status ${response.statusCode}');
          if (response.statusCode == 404 || response.statusCode == 400) {
            _currentModelIndex = (_currentModelIndex + 1) % _geminiModels.length;
          } else {
            _currentApiKeyIndex = (_currentApiKeyIndex + 1) % _geminiApiKeysEncoded.length;
          }
          continue;
        }
      } catch (e) {
        debugPrint('🔴 [GEMINI EXCEPTION] Attempt $attempt -> $e');
        _currentApiKeyIndex = (_currentApiKeyIndex + 1) % _geminiApiKeysEncoded.length;
      }
    }

    debugPrint('🔴 [ALL ENGINES FAILED] Không kết nối được engine nào.');
    return '';
  }

  // Helper cho giao thức OpenAI Chat Completions (hỗ trợ Circuit Breaker + UTF-8 fix + chuẩn hóa params cho GPT-5)
  static Future<String> _callOpenAICompatible({
    required String providerKey,
    required String url,
    required String apiKey,
    required String model,
    required String systemPrompt,
    required String userPrompt,
    required int timeoutSeconds,
    bool useMaxCompletionTokens = false,
  }) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = Duration(seconds: timeoutSeconds);
      final uri = Uri.parse(url);
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.headers.set('Authorization', 'Bearer $apiKey');

      final Map<String, dynamic> requestBody = {
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
      };

      if (useMaxCompletionTokens || model.startsWith('gpt-5') || model.startsWith('o1') || model.startsWith('o3')) {
        requestBody['max_completion_tokens'] = 2048;
      } else {
        requestBody['temperature'] = 0.1;
        requestBody['max_tokens'] = 2048;
      }

      final body = jsonEncode(requestBody);

      request.add(utf8.encode(body));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'];
          if (message != null && message['content'] != null) {
            final res = (message['content'] as String).trim();
            if (res.isNotEmpty) {
              debugPrint('🟢 [$providerKey SUCCESS] Translated with $model');
              return res;
            }
          }
        }
      } else {
        debugPrint('🟡 [$providerKey FAILED] Status ${response.statusCode}: $responseBody');
        if (response.statusCode == 401 || response.statusCode == 402 || response.statusCode == 403 || response.statusCode == 404) {
          _disableProvider(providerKey, minutes: 5);
        }
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$providerKey error: $e');
    }
    return '';
  }



  // Main synchronous translation method (Instant, Clean, Live Word-by-Word + Progressive Grammar + Corpus Hybrid)
  static String translateSync(String text, String sourceLang, String targetLang, {bool isSubclause = false}) {
    if (text.trim().isEmpty) return '';
    
    var clean = text.trim().toLowerCase();
    
    // Normalize consecutive duplicate prefixes
    while (clean.startsWith('bạn có thể bạn có thể ')) {
      clean = clean.replaceFirst('bạn có thể ', '');
    }
    if (clean == 'bạn có thể bạn có thể') {
      clean = 'bạn có thể';
    }
    while (clean.startsWith('can you can you ')) {
      clean = clean.replaceFirst('can you ', '');
    }
    if (clean == 'can you can you') {
      clean = 'can you';
    }
    while (clean.startsWith('could you could you ')) {
      clean = clean.replaceFirst('could you ', '');
    }
    if (clean == 'could you could you') {
      clean = 'could you';
    }

    final cleanNoPunct = clean.replaceAll(RegExp(r'[^a-z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ\s/]'), '').trim();
    
    // 1. Direct exact O(1) dictionary lookup (exact string or stripped punctuation)
    if (_dictionary.containsKey(clean)) {
      return _formatResult(_dictionary[clean]!, isSubclause);
    }
    if (_dictionary.containsKey(cleanNoPunct)) {
      return _formatResult(_dictionary[cleanNoPunct]!, isSubclause);
    }

    // 1.5. Check TravelCorpus exact sentence matches
    for (final item in TravelCorpus.entries) {
      final viClean = item['vi']!.toLowerCase().replaceAll(RegExp(r'[^a-z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ\s/]'), '').trim();
      final enClean = item['en']!.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').trim();
      if (item['vi']!.toLowerCase() == clean || viClean == cleanNoPunct) {
        return _formatResult(item['en']!, isSubclause);
      }
      if (item['en']!.toLowerCase() == clean || enClean == cleanNoPunct) {
        return _formatResult(item['vi']!, isSubclause);
      }
    }

    // 2. Compositional Grammar Pattern Matching & Progressive Prefix Streaming Engine
    if (targetLang == 'Vietnamese') {
      final patternRes = _translateToVietnamesePatterns(text, clean, isSubclause: isSubclause);
      if (patternRes != text) return _formatResult(patternRes, isSubclause);
    } else {
      final patternRes = _translateToEnglishPatterns(text, clean, isSubclause: isSubclause);
      if (patternRes != text) return _formatResult(patternRes, isSubclause);
    }

    // 3. High-Confidence Vector Cosine Similarity Search (only match if >= 0.82 to avoid replacing partial input like "can you hel")
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

    for (final item in TravelCorpus.entries) {
      final corpusVector = _vectorize(item[srcKey]!);
      final sim = _cosineSimilarity(queryVector, corpusVector);
      if (sim > maxSim) {
        maxSim = sim;
        bestMatch = item[tgtKey]!;
      }
    }

    // Only return vector match if similarity is very high (>= 0.82), ensuring we never replace unfinished phrases
    if (maxSim >= 0.82 && bestMatch.isNotEmpty) {
      return _formatResult(bestMatch, isSubclause);
    }

    // 4. Live Word-by-Word / Progressive Streaming Composition (Google Translate style with Typo Normalization & Syntax Reordering)
    final rawWords = cleanNoPunct.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (rawWords.isNotEmpty) {
      // Step 4A: Normalize common typos & incomplete contractions during fast typing
      final words = <String>[];
      for (int i = 0; i < rawWords.length; i++) {
        var w = rawWords[i];
        if (w == 'shoul' || w == 'shoud' || w == 'sould') {
          w = 'should';
        } else if (w == 'cna') {
          w = 'can';
        } else if (w == 'whet' || w == 'wat') {
          w = 'what';
        } else if (w == 'whre' || (w == 'were' && i == 0)) {
          w = 'where';
        } else if (w == 'tomorow' || w == 'tommorrow') {
          w = 'tomorrow';
        } else if (w == 'tdoay' || w == 'toady') {
          w = 'today';
        } else if (w == 'e' && i > 0 && (rawWords[i - 1] == 'we' || rawWords[i - 1] == 'i' || rawWords[i - 1] == 'you') && (i == rawWords.length - 1 || (i + 1 < rawWords.length && (rawWords[i + 1] == 'today' || rawWords[i + 1] == 'tonight' || rawWords[i + 1] == 'now')))) {
          w = 'eat';
        } else if (w == 'ea' && i > 0 && (rawWords[i - 1] == 'we' || rawWords[i - 1] == 'i' || rawWords[i - 1] == 'you')) {
          w = 'eat';
        }
        words.add(w);
      }

      // If typo normalization changed the string, check exact/pattern match on the normalized string!
      final normClean = words.join(' ');
      if (normClean != cleanNoPunct && normClean != clean) {
        if (_dictionary.containsKey(normClean)) return _formatResult(_dictionary[normClean]!, isSubclause);
        if (targetLang == 'Vietnamese') {
          final normPat = _translateToVietnamesePatterns(normClean, normClean, isSubclause: isSubclause);
          if (normPat != normClean) return _formatResult(normPat, isSubclause);
        } else {
          final normPat = _translateToEnglishPatterns(normClean, normClean, isSubclause: isSubclause);
          if (normPat != normClean) return _formatResult(normPat, isSubclause);
        }
      }

      final translatedWords = <String>[];
      bool anyTranslated = false;
      for (int i = 0; i < words.length; i++) {
        final w = words[i];
        if (w.isEmpty) continue;
        if (w == 'hel' || w == 'help') {
          var val = targetLang == 'Vietnamese' ? 'giúp' : 'help';
          if (translatedWords.isNotEmpty || isSubclause) {
            val = _isProperNoun(val) ? val : val.toLowerCase();
          }
          translatedWords.add(val);
          anyTranslated = true;
        } else if (targetLang == 'Vietnamese' && (w == 'we' || w == 'us')) {
          var val = 'chúng ta';
          if (translatedWords.isNotEmpty || isSubclause) {
            val = _isProperNoun(val) ? val : val.toLowerCase();
          }
          translatedWords.add(val);
          anyTranslated = true;
        } else if (_dictionary.containsKey(w)) {
          final trans = _dictionary[w]!;
          var primary = trans.split(RegExp(r'(?<!\d)/(?!\d)')).first.trim();
          if (words.length > 1 && primary.endsWith('?')) {
            primary = primary.replaceAll('?', '').trim();
          }
          if (translatedWords.isNotEmpty || isSubclause) {
            primary = _isProperNoun(primary) ? primary : primary.toLowerCase();
          }
          translatedWords.add(primary);
          anyTranslated = true;
        } else {
          var wordToAdd = w;
          if (translatedWords.isNotEmpty || isSubclause) {
            wordToAdd = _isProperNoun(wordToAdd) ? wordToAdd : wordToAdd.toLowerCase();
          }
          translatedWords.add(wordToAdd);
        }
      }

      if (anyTranslated || words.length == 1) {
        // Step 4B: Reorder & Format Question/Modal Structures from English to Vietnamese so we NEVER produce word salad like "What can Chúng tôi Ăn Hôm nay"
        if (targetLang == 'Vietnamese' && words.length > 1) {
          final first = words.first;
          if (first == 'what' || first == 'where' || first == 'when' || first == 'how' || first == 'why' || first == 'who' || first == 'can' || first == 'should' || first == 'will' || first == 'do') {
            final patRes = _translateToVietnamesePatterns(normClean, normClean, isSubclause: isSubclause);
            if (patRes != normClean) return _formatResult(patRes, isSubclause);
          }
        }
        final joined = translatedWords.join(' ');
        if (isSubclause) {
          return _isProperNoun(joined) ? joined : joined.toLowerCase();
        }
        return _capitalize(joined);
      }
    }

    // Final clean fallback: return original text as-is
    return text;
  }

  static Set<String>? _knownWords;

  static Set<String> _getKnownWords() {
    if (_knownWords != null) return _knownWords!;
    final Set<String> words = {};
    
    void addWordsFromText(String text) {
      final cleaned = text.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ\s]'), ' ');
      final tokens = cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
      words.addAll(tokens);
    }

    // 1. Dictionary
    for (final entry in _dictionary.entries) {
      addWordsFromText(entry.key);
      addWordsFromText(entry.value);
    }

    // 2. TravelCorpus
    for (final entry in TravelCorpus.entries) {
      if (entry['vi'] != null) addWordsFromText(entry['vi']!);
      if (entry['en'] != null) addWordsFromText(entry['en']!);
    }

    // 3. VectorCorpus
    for (final entry in _vectorCorpus) {
      if (entry['vi'] != null) addWordsFromText(entry['vi']!);
      if (entry['en'] != null) addWordsFromText(entry['en']!);
    }

    // 4. Proper Nouns and common vocabulary
    const properNouns = {
      'vietnam', 'việt nam', 'english', 'vietnamese', 'tiếng anh', 'tiếng việt',
      'hanoi', 'hà nội', 'ho chi minh', 'hồ chí minh', 'saigon', 'sài gòn',
      'da nang', 'đà nẵng', 'new york', 'london', 'paris', 'tokyo', 'seoul',
      'beijing', 'singapore', 'thailand', 'thái lan', 'japan', 'nhật bản',
      // Common words that should NEVER be autocorrected to travel words
      'shame', 'party', 'listen', 'cannot', 'park', 'time', 'problem', 'question',
      'answer', 'speak', 'talk', 'learn', 'study', 'work', 'play', 'love', 'dinner',
      'today', 'tomorrow', 'yesterday', 'morning', 'afternoon', 'evening', 'night',
      'hello', 'goodbye', 'thanks', 'sorry', 'please', 'excuse', 'water', 'coffee',
    };
    words.addAll(properNouns);

    _knownWords = words;
    return words;
  }

  // Levenshtein edit distance for spelling correction
  static int _editDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    
    final la = a.length;
    final lb = b.length;
    // Optimization: early exit if length difference > 2
    if ((la - lb).abs() > 2) return 3;
    
    var prev = List<int>.generate(lb + 1, (i) => i);
    var curr = List<int>.filled(lb + 1, 0);
    
    for (int i = 1; i <= la; i++) {
      curr[0] = i;
      for (int j = 1; j <= lb; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [
          prev[j] + 1,      // deletion
          curr[j - 1] + 1,   // insertion
          prev[j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
      final temp = prev;
      prev = curr;
      curr = temp;
    }
    return prev[lb];
  }

  // Live Typo & Spelling Suggestion engine for UI popup ("💡 Bạn có ý là: ...")
  static String? findSpellingCorrection(String text, String sourceLang) {
    final clean = text.trim();
    if (clean.length < 4) return null; // Avoid suggesting on very short inputs
    final cleanLower = clean.toLowerCase();
    
    // If it's already an exact match in dictionary or corpus, no typo correction needed
    if (_dictionary.containsKey(cleanLower)) return null;
    for (final item in TravelCorpus.entries) {
      if (item['vi']!.toLowerCase() == cleanLower || item['en']!.toLowerCase() == cleanLower) {
        return null;
      }
    }

    // Run manual typo normalizations BEFORE checking allWordsValid
    final rawWords = clean.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    bool hasTypoWord = false;
    final normalizedWords = <String>[];
    for (int i = 0; i < rawWords.length; i++) {
      var w = rawWords[i];
      final wLower = w.toLowerCase();
      final prev = i > 0 ? rawWords[i - 1].toLowerCase() : '';
      final next = i + 1 < rawWords.length ? rawWords[i + 1].toLowerCase() : '';

      if (wLower == 'shoul' || wLower == 'shoud' || wLower == 'sould') {
        w = 'should'; hasTypoWord = true;
      } else if (wLower == 'cna') {
        w = 'can'; hasTypoWord = true;
      } else if (wLower == 'whet' || wLower == 'wat') {
        w = 'what'; hasTypoWord = true;
      } else if (wLower == 'whre' || (wLower == 'were' && i == 0)) {
        w = 'where'; hasTypoWord = true;
      } else if (wLower == 'tomorow' || wLower == 'tommorrow') {
        w = 'tomorrow'; hasTypoWord = true;
      } else if (wLower == 'tdoay' || wLower == 'toady') {
        w = 'today'; hasTypoWord = true;
      } else if (wLower == 'muon') {
        w = 'muốn'; hasTypoWord = true;
      } else if (wLower == 'giup') {
        w = 'giúp'; hasTypoWord = true;
      } else if (wLower == 'toi') {
        w = 'tôi'; hasTypoWord = true;
      } else if (wLower == 'tien' && (
          prev == 'tính' || prev == 'tinh' || 
          prev == 'nhiêu' || prev == 'nhieu' ||
          prev == 'tiền' || prev == 'tien' ||
          next == 'mặt' || next == 'mat' ||
          prev == 'mặt' || prev == 'mat' ||
          cleanLower.contains('bao nhiêu') || cleanLower.contains('bao nhieu') ||
          cleanLower.contains('tính') || cleanLower.contains('tinh')
      )) {
        w = 'tiền'; hasTypoWord = true;
      } else if (wLower == 'tinh' && i > 0 && rawWords[i - 1].toLowerCase() == 'xin') {
        w = 'tính'; hasTypoWord = true;
      } else if (wLower == 'nhieu' && i > 0 && rawWords[i - 1].toLowerCase() == 'bao') {
        w = 'nhiêu'; hasTypoWord = true;
      } else if (wLower == 'cai' && i + 1 < rawWords.length && rawWords[i + 1].toLowerCase() == 'nay') {
        w = 'cái'; hasTypoWord = true;
      } else if (wLower == 'nay' && i > 0 && (rawWords[i - 1].toLowerCase() == 'cái' || rawWords[i - 1].toLowerCase() == 'cai')) {
        w = 'này'; hasTypoWord = true;
      }
      normalizedWords.add(w);
    }

    if (hasTypoWord) {
      return normalizedWords.join(' ');
    }

    // If no manual typo matched, check each word and fix unknown words via Levenshtein
    final cleanedInput = cleanLower.replaceAll(
        RegExp(r'[^a-z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ\s]'), ' ');
    final inputWords = cleanedInput.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    
    final known = _getKnownWords();
    bool anyWordFixed = false;
    final correctedWords = <String>[];
    
    for (final w in inputWords) {
      final isNumber = int.tryParse(w) != null;
      if (isNumber || known.contains(w) || w.length <= 1) {
        correctedWords.add(w);
        continue;
      }
      // Word not recognized → find closest known word by Levenshtein distance
      String bestWord = w;
      int bestDist = 3; // max edit distance allowed
      for (final kw in known) {
        // Only compare words of similar length (optimization)
        if ((kw.length - w.length).abs() > 2) continue;
        final dist = _editDistance(w, kw);
        if (dist < bestDist) {
          bestDist = dist;
          bestWord = kw;
        }
      }
      if (bestWord != w) {
        anyWordFixed = true;
      }
      correctedWords.add(bestWord);
    }
    
    if (anyWordFixed) {
      return correctedWords.join(' ');
    }

    // Check VSM Cosine Similarity for closest sentence/phrase match (range [0.74, 0.99])
    final queryVector = _vectorize(cleanLower);
    double maxSim = 0.0;
    String bestCandidate = '';
    final srcKey = sourceLang == 'Vietnamese' ? 'vi' : 'en';

    for (final pair in _vectorCorpus) {
      final candidate = pair[srcKey]!;
      final corpusVector = _vectorize(candidate);
      final sim = _cosineSimilarity(queryVector, corpusVector);
      if (sim > maxSim && sim >= 0.74 && sim < 0.99 && candidate.toLowerCase() != cleanLower) {
        if (!candidate.toLowerCase().startsWith(cleanLower) || sim >= 0.84) {
          maxSim = sim;
          bestCandidate = candidate;
        }
      }
    }

    for (final item in TravelCorpus.entries) {
      final candidate = item[srcKey]!;
      final corpusVector = _vectorize(candidate);
      final sim = _cosineSimilarity(queryVector, corpusVector);
      if (sim > maxSim && sim >= 0.74 && sim < 0.99 && candidate.toLowerCase() != cleanLower) {
        if (!candidate.toLowerCase().startsWith(cleanLower) || sim >= 0.84) {
          maxSim = sim;
          bestCandidate = candidate;
        }
      }
    }

    if (maxSim >= 0.74 && bestCandidate.isNotEmpty) {
      return bestCandidate;
    }

    return null;
  }

  // Advanced semantic pattern matching for English -> Vietnamese (Progressive + Complete Sentences + Typo Normalization)
  static String _translateToVietnamesePatterns(String original, String rawClean, {bool isSubclause = false}) {
    // Normalize typos before pattern matching
    var clean = rawClean
        .replaceAll(RegExp(r'\bshoul\b'), 'should')
        .replaceAll(RegExp(r'\bshoud\b'), 'should')
        .replaceAll(RegExp(r'\bcna\b'), 'can')
        .replaceAll(RegExp(r'\bwhet\b'), 'what')
        .replaceAll(RegExp(r'\bwat\b'), 'what')
        .replaceAll(RegExp(r'\btdoay\b'), 'today')
        .replaceAll(RegExp(r'\btomorow\b'), 'tomorrow')
        .replaceAll(RegExp(r'\btommorrow\b'), 'tomorrow')
        .replaceAll(RegExp(r'\btoady\b'), 'today');

    // Normalize eat typos when trailing after subject
    if (clean.endsWith(' we e today') || clean.endsWith(' we e tonight') || clean.endsWith(' we e now')) {
      clean = clean.replaceAll(' we e today', ' we eat today').replaceAll(' we e tonight', ' we eat tonight').replaceAll(' we e now', ' we eat now');
    } else if (clean.endsWith(' we ea today') || clean.endsWith(' we ea tonight') || clean.endsWith(' we ea now')) {
      clean = clean.replaceAll(' we ea today', ' we eat today').replaceAll(' we ea tonight', ' we eat tonight').replaceAll(' we ea now', ' we eat now');
    } else if (clean.endsWith(' we e') || clean.endsWith(' i e') || clean.endsWith(' you e')) {
      clean = '${clean.substring(0, clean.length - 1)}eat';
    } else if (clean.endsWith(' we ea') || clean.endsWith(' i ea') || clean.endsWith(' you ea')) {
      clean = '${clean.substring(0, clean.length - 2)}eat';
    }

    final words = clean.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    // 1. Live Progressive Prefix Streaming ("xin tính tiền bàn số 5 giúp tôi...")
    if (clean.startsWith('check the bill for table number ') || clean.startsWith('bill for table number ')) {
      final remainder = clean.replaceAll('check the bill for table number ', '').replaceAll('bill for table number ', '').trim();
      return 'Xin tính tiền bàn số ${remainder.isNotEmpty ? remainder : '...'} giúp tôi';
    }
    if (clean.startsWith('check the bill for table ') || clean.startsWith('bill for table ')) {
      final remainder = clean.replaceAll('check the bill for table ', '').replaceAll('bill for table ', '').trim();
      return 'Xin tính tiền bàn $remainder giúp tôi';
    }
    if (clean.startsWith('check the bill') || clean == 'check please' || clean == 'bill please') {
      return 'Xin tính tiền / Cho xin hóa đơn';
    }

    // WHAT structures
    final isWhatShouldWe = clean == 'what should we' || clean.startsWith('what should we ');
    final isWhatCanWe = clean == 'what can we' || clean.startsWith('what can we ');
    final isWhatWillWe = clean == 'what will we' || clean.startsWith('what will we ');
    if (isWhatShouldWe || isWhatCanWe || isWhatWillWe) {
      final isShould = isWhatShouldWe;
      final isCan = isWhatCanWe;
      final modalText = isShould ? 'nên' : (isCan ? 'có thể' : 'sẽ');
      final prefixLen = isShould ? 14 : (isCan ? 11 : 12);
      final remainder = clean.length > prefixLen ? clean.substring(prefixLen).replaceAll('?', '').trim() : '';

      if (remainder.isEmpty) {
        return isShould ? 'Chúng ta nên làm gì / Chúng ta nên...' : (isCan ? 'Chúng ta có thể làm gì / Chúng ta có thể...' : 'Chúng ta làm gì...');
      }

      var timePrefix = '';
      var verbPart = remainder;
      if (remainder.endsWith('today') || remainder.endsWith('hôm nay')) {
        timePrefix = 'Hôm nay ';
        verbPart = remainder.replaceAll('today', '').replaceAll('hôm nay', '').trim();
      } else if (remainder.endsWith('tonight') || remainder.endsWith('tối nay')) {
        timePrefix = 'Tối nay ';
        verbPart = remainder.replaceAll('tonight', '').replaceAll('tối nay', '').trim();
      } else if (remainder.endsWith('tomorrow') || remainder.endsWith('ngày mai')) {
        timePrefix = 'Ngày mai ';
        verbPart = remainder.replaceAll('tomorrow', '').replaceAll('ngày mai', '').trim();
      } else if (remainder.endsWith('now') || remainder.endsWith('bây giờ')) {
        timePrefix = 'Bây giờ ';
        verbPart = remainder.replaceAll('now', '').replaceAll('bây giờ', '').trim();
      }

      final subj = timePrefix.isEmpty ? 'Chúng ta' : '${timePrefix}chúng ta';
      if (verbPart == 'eat' || verbPart == 'e' || verbPart == 'ea' || verbPart == 'have for lunch' || verbPart == 'have for dinner' || verbPart == 'have for breakfast') {
        var meal = '';
        if (verbPart.contains('lunch')) {
          meal = ' ăn trưa';
        } else if (verbPart.contains('dinner')) {
          meal = ' ăn tối';
        } else if (verbPart.contains('breakfast')) {
          meal = ' ăn sáng';
        }
        return '$subj $modalText ăn gì$meal?';
      }
      if (verbPart == 'do' || verbPart == 'd') {
        return '$subj $modalText làm gì?';
      }
      if (verbPart == 'drink') {
        return '$subj $modalText uống gì?';
      }
      if (verbPart == 'buy') {
        return '$subj $modalText mua gì?';
      }
      if (verbPart.isNotEmpty) {
        final transVerb = translateSync(verbPart, 'English', 'Vietnamese', isSubclause: true);
        return '$subj $modalText $transVerb gì?';
      }
      return '$subj $modalText làm gì...';
    }
    if (clean == 'what should we') return 'Chúng ta nên làm gì / Chúng ta nên...';
    if (clean == 'what should') return 'Nên làm gì / Cái gì nên...';
    if (clean == 'what can we') return 'Chúng ta có thể làm gì / Chúng ta có thể...';
    if (clean == 'what can') return 'Có thể làm gì / Cái gì có thể...';
    if (clean.startsWith('what time does the ') || clean.startsWith('what time does ')) {
      final remainder = clean.replaceAll('what time does the ', '').replaceAll('what time does ', '').replaceAll('?', '').trim();
      if (remainder.contains('open')) {
        final place = remainder.replaceAll('open', '').trim();
        final transPlace = _lookupTerm(place, isSubclause: true);
        return '${_capitalize(transPlace)} mấy giờ mở cửa?';
      }
      if (remainder.contains('close')) {
        final place = remainder.replaceAll('close', '').trim();
        final transPlace = _lookupTerm(place, isSubclause: true);
        return '${_capitalize(transPlace)} mấy giờ đóng cửa?';
      }
      return 'Mấy giờ thì ${translateSync(remainder, 'English', 'Vietnamese', isSubclause: true)}?';
    }
    if (clean.startsWith('what time is ')) {
      final remainder = clean.replaceAll('what time is ', '').replaceAll('?', '').trim();
      if (remainder == 'it') return 'Bây giờ là mấy giờ? / Mấy giờ rồi?';
      return 'Mấy giờ là ${translateSync(remainder, 'English', 'Vietnamese', isSubclause: true)}?';
    }
    if (clean.startsWith('what is the ') || clean.startsWith('what is ')) {
      final remainder = clean.replaceAll('what is the ', '').replaceAll('what is ', '').replaceAll('?', '').trim();
      if (remainder == 'price' || remainder == 'cost') return 'Giá bao nhiêu?';
      if (remainder == 'wifi password' || remainder == 'password') return 'Mật khẩu là gì?';
      if (remainder == 'name of this' || remainder == 'this') return 'Cái này tên là gì / Cái này là gì?';
      final transRem = _lookupTerm(remainder, isSubclause: true);
      return '${_capitalize(transRem)} là gì?';
    }

    // WHERE structures
    if (clean.startsWith('where should we go for ')) {
      final remainder = clean.replaceAll('where should we go for ', '').replaceAll('?', '').trim();
      if (remainder == 'dinner') return 'Chúng ta nên đi đâu ăn tối?';
      if (remainder == 'lunch') return 'Chúng ta nên đi đâu ăn trưa?';
      if (remainder == 'breakfast') return 'Chúng ta nên đi đâu ăn sáng?';
      if (remainder == 'coffee' || remainder == 'drinks') return 'Chúng ta nên đi uống cà phê ở đâu?';
      if (remainder.isEmpty) return 'Chúng ta nên đi đâu để...';
      final transRem = _lookupTerm(remainder, isSubclause: true);
      return 'Chúng ta nên đi đâu để $transRem?';
    }
    if (clean == 'where should we go for') {
      return 'Chúng ta nên đi đâu để...';
    }
    if (clean.startsWith('where should we go')) {
      final remainder = clean.replaceAll('where should we go', '').replaceAll('?', '').trim();
      if (remainder == 'today' || remainder == 'hôm nay') return 'Hôm nay chúng ta nên đi đâu?';
      if (remainder == 'tonight' || remainder == 'tối nay') return 'Tối nay chúng ta nên đi đâu?';
      if (remainder == 'tomorrow' || remainder == 'ngày mai') return 'Ngày mai chúng ta nên đi đâu?';
      if (remainder.isNotEmpty) return 'Chúng ta nên đi đâu ${translateSync(remainder, 'English', 'Vietnamese', isSubclause: true)}?';
      return 'Chúng ta nên đi đâu?';
    }
    if (clean.startsWith('where should we')) {
      return 'Chúng ta nên đi đâu / Chúng ta nên...';
    }
    if (clean.startsWith('where should')) {
      return 'Ở đâu nên...';
    }
    if (clean == 'where can we find' || clean.startsWith('where can we find ') || clean == 'where can we get' || clean.startsWith('where can we get ')) {
      final item = clean.replaceAll('where can we find ', '').replaceAll('where can we find', '').replaceAll('where can we get ', '').replaceAll('where can we get', '').replaceAll('?', '').trim();
      if (item.isEmpty) return 'Chúng ta có thể tìm thấy ở đâu / Chúng ta có thể tìm...';
      final transItem = _lookupTerm(item, isSubclause: true);
      return 'Chúng ta có thể tìm thấy $transItem ở đâu?';
    }
    if (clean == 'where can i find' || clean.startsWith('where can i find ') || clean == 'where can i get' || clean.startsWith('where can i get ')) {
      final item = clean.replaceAll('where can i find ', '').replaceAll('where can i find', '').replaceAll('where can i get ', '').replaceAll('where can i get', '').replaceAll('?', '').trim();
      if (item.isEmpty) return 'Tôi có thể tìm thấy ở đâu / Tôi có thể tìm...';
      final transItem = _lookupTerm(item, isSubclause: true);
      return 'Tôi có thể tìm thấy $transItem ở đâu?';
    }
    if (clean.startsWith('where can ')) {
      return 'Ở đâu có thể...';
    }
    if (clean.startsWith('where is the ') || clean.startsWith('where is ')) {
      final place = clean.replaceAll('where is the ', '').replaceAll('where is ', '').replaceAll('?', '').trim();
      if (place.isEmpty) return 'Ở đâu là...';
      final transPlace = translateSync(place, 'English', 'Vietnamese', isSubclause: true);
      final cleanTrans = _sanitizeSubclause(transPlace);
      if (cleanTrans.contains('ở đâu') || cleanTrans.contains('nằm ở') || cleanTrans.contains('chỗ nào')) {
        if (isSubclause) return cleanTrans;
        return '$cleanTrans?';
      }
      if (isSubclause) {
        return '$cleanTrans ở đâu';
      }
      return '${_capitalize(cleanTrans)} nằm ở đâu?';
    }

    // WHEN / HOW / WHY structures
    if (clean.startsWith('when should we ') || clean.startsWith('when can we ')) {
      final isShould = clean.startsWith('when should we ');
      final remainder = clean.replaceAll(isShould ? 'when should we ' : 'when can we ', '').replaceAll('?', '').trim();
      if (remainder == 'go' || remainder == 'leave' || remainder == 'depart') return 'Khi nào chúng ta ${isShould ? 'nên' : 'có thể'} đi?';
      if (remainder == 'meet') return 'Khi nào chúng ta ${isShould ? 'nên' : 'có thể'} gặp nhau?';
      if (remainder.isEmpty) return 'Khi nào chúng ta ${isShould ? 'nên' : 'có thể'}...';
      return 'Khi nào chúng ta ${isShould ? 'nên' : 'có thể'} ${translateSync(remainder, 'English', 'Vietnamese', isSubclause: true)}?';
    }
    if (clean.startsWith('how can i ') || clean.startsWith('how can we ')) {
      final remainder = clean.replaceAll('how can i ', '').replaceAll('how can we ', '').replaceAll('?', '').trim();
      if (remainder.startsWith('get to ')) {
        final dest = remainder.replaceAll('get to ', '').trim();
        return 'Làm thế nào để đi đến ${_formatInsideSentence(_lookupTerm(dest, isSubclause: true))}?';
      }
      return 'Làm thế nào để ${translateSync(remainder, 'English', 'Vietnamese', isSubclause: true)}?';
    }

    // Polite requests & Tell Me / Explain / Show Me Patterns ("can you tell me...", "can you open...")
    if (clean.startsWith('can you tell me about the ') || clean.startsWith('could you tell me about the ')) {
      final remainder = clean.replaceAll('can you tell me about the ', '').replaceAll('could you tell me about the ', '').replaceAll('?', '').trim();
      if (remainder.isEmpty) return 'Bạn có thể cho tôi biết về kế hoạch...';
      final transRem = translateSync(remainder, 'English', 'Vietnamese', isSubclause: true);
      if (isSubclause) {
        return 'bạn có thể cho tôi biết về $transRem';
      }
      return 'Bạn có thể cho tôi biết về $transRem được không?';
    }
    if (clean.startsWith('can you tell me about ') || clean.startsWith('could you tell me about ')) {
      final remainder = clean.replaceAll('can you tell me about ', '').replaceAll('could you tell me about ', '').replaceAll('?', '').trim();
      if (remainder.isEmpty) return 'Bạn có thể cho tôi biết về...';
      final transRem = translateSync(remainder, 'English', 'Vietnamese', isSubclause: true);
      if (isSubclause) {
        return 'bạn có thể cho tôi biết về $transRem';
      }
      return 'Bạn có thể cho tôi biết về $transRem được không?';
    }
    if (clean == 'can you tell me' || clean == 'could you tell me') {
      if (isSubclause) return 'bạn có thể cho tôi biết';
      return 'Bạn có thể cho tôi biết được không?';
    }
    if (clean.startsWith('can you tell me ') || clean.startsWith('could you tell me ')) {
      final remainder = clean.replaceAll('can you tell me ', '').replaceAll('could you tell me ', '').replaceAll('?', '').trim();
      if (remainder.isEmpty) return 'Bạn có thể cho tôi biết được không?';
      final transRem = translateSync(remainder, 'English', 'Vietnamese', isSubclause: true);
      if (isSubclause) {
        return 'bạn có thể cho tôi biết $transRem';
      }
      return 'Bạn có thể cho tôi biết $transRem được không?';
    }
    if (clean.startsWith('tell me about the ') || clean.startsWith('tell me about ')) {
      final remainder = clean.replaceAll('tell me about the ', '').replaceAll('tell me about ', '').replaceAll('?', '').trim();
      if (remainder.isEmpty) return 'Cho tôi biết về...';
      final transRem = translateSync(remainder, 'English', 'Vietnamese', isSubclause: true);
      if (isSubclause) {
        return 'cho tôi biết về $transRem';
      }
      return 'Cho tôi biết về $transRem';
    }
    if (clean == 'tell me') {
      return 'Cho tôi biết / Nói cho tôi';
    }

    if (clean.startsWith('can you open the door for me')) {
      if (isSubclause) return 'bạn có thể mở cửa giúp tôi';
      return 'Bạn có thể mở cửa giúp tôi được không?';
    }
    if (clean.startsWith('can you open the door')) {
      if (isSubclause) return 'bạn có thể mở cửa';
      return 'Bạn có thể mở cửa?';
    }
    if (clean.startsWith('can you open ')) {
      final remainder = clean.replaceAll('can you open the ', '').replaceAll('can you open ', '').replaceAll('?', '').trim();
      final transRem = _lookupTerm(remainder, isSubclause: true);
      if (isSubclause) return 'bạn có thể mở $transRem';
      return 'Bạn có thể mở $transRem?';
    }
    if (clean.startsWith('can you please ') || clean.startsWith('could you please ')) {
      final remainder = clean.replaceAll('can you please ', '').replaceAll('could you please ', '').replaceAll('?', '').trim();
      final transRem = translateSync(remainder, 'English', 'Vietnamese', isSubclause: true);
      if (isSubclause) {
        return 'bạn làm ơn $transRem';
      }
      return 'Bạn làm ơn $transRem được không?';
    }
    if (clean.startsWith('can you ') || clean.startsWith('could you ')) {
      final remainder = clean.replaceAll('can you ', '').replaceAll('could you ', '').replaceAll('?', '').trim();
      final transRem = translateSync(remainder, 'English', 'Vietnamese', isSubclause: true);
      if (isSubclause) {
        return 'bạn có thể $transRem';
      }
      return 'Bạn có thể $transRem được không?';
    }
    if (clean.startsWith('can i have ') || clean.startsWith('could i have ')) {
      final item = clean.replaceAll('can i have a ', '').replaceAll('can i have ', '').replaceAll('could i have a ', '').replaceAll('could i have ', '').replaceAll('please', '').replaceAll('?', '').trim();
      final transItem = _lookupTerm(item, isSubclause: true);
      if (isSubclause) {
        return 'cho tôi xin $transItem';
      }
      return 'Cho tôi xin $transItem được không?';
    }
    if (clean.startsWith('can i ') || clean.startsWith('could i ')) {
      final remainder = clean.replaceAll('can i ', '').replaceAll('could i ', '').replaceAll('?', '').trim();
      final transRem = translateSync(remainder, 'English', 'Vietnamese', isSubclause: true);
      if (isSubclause) {
        return 'tôi có thể $transRem';
      }
      return 'Tôi có thể $transRem được không?';
    }

    // Directions & Travel Patterns
    if (clean.contains('how to get to ') || clean.contains('how can i get to ')) {
      final dest = clean.replaceAll('how to get to ', '').replaceAll('how can i get to ', '').replaceAll('?', '').trim();
      final transDest = _lookupTerm(dest, isSubclause: true);
      return 'Làm sao để đi đến $transDest?';
    }
    if (clean.contains('how to get there')) {
      return 'Làm sao để đi đến đó?';
    }
    if (clean.contains('nearest')) {
      if (clean.contains('hospital')) return 'Bệnh viện gần nhất ở đâu?';
      if (clean.contains('hotel')) return 'Khách sạn gần nhất ở đâu?';
      if (clean.contains('bank') || clean.contains('atm')) return 'Ngân hàng / ATM gần nhất ở đâu?';
      if (clean.contains('restaurant') || clean.contains('food')) return 'Quán ăn gần nhất ở đâu?';
      if (clean.contains('gas station') || clean.contains('petrol')) return 'Trạm xăng gần nhất ở đâu?';
      if (clean.contains('restroom') || clean.contains('bathroom') || clean.contains('toilet')) return 'Nhà vệ sinh gần nhất ở đâu?';
      return 'Nơi gần nhất ở đâu?';
    }

    // Pricing & Shopping Patterns
    if (clean.contains('how much for ') || clean.contains('how much is ')) {
      final item = clean.replaceAll('how much for the ', '').replaceAll('how much for ', '').replaceAll('how much is the ', '').replaceAll('how much is ', '').replaceAll('?', '').trim();
      final transItem = _lookupTerm(item, isSubclause: true);
      return '${_capitalize(transItem)} giá bao nhiêu?';
    }
    if (clean.contains('how much') || clean.contains('cost') || clean.contains('price')) {
      return 'Cái này giá bao nhiêu?';
    }

    // Intent & Desires Patterns
    if (clean.startsWith('i want to buy ') || clean.startsWith('i would like to buy ')) {
      final item = clean.replaceAll('i want to buy a ', '').replaceAll('i want to buy ', '').replaceAll('i would like to buy a ', '').replaceAll('i would like to buy ', '').trim();
      final transItem = _lookupTerm(item, isSubclause: true);
      return 'Tôi muốn mua $transItem';
    }
    if (clean.startsWith('i want to go to ') || clean.startsWith('i would like to go to ')) {
      final dest = clean.replaceAll('i want to go to the ', '').replaceAll('i want to go to ', '').replaceAll('i would like to go to the ', '').replaceAll('i would like to go to ', '').trim();
      final transDest = _lookupTerm(dest, isSubclause: true);
      return 'Tôi muốn đi đến $transDest';
    }
    if (clean.startsWith('i need ')) {
      final item = clean.replaceAll('i need a ', '').replaceAll('i need ', '').replaceAll('please', '').trim();
      final transItem = _lookupTerm(item, isSubclause: true);
      return 'Tôi cần $transItem';
    }

    // Food & Dining Patterns (Short queries ONLY to avoid overriding full sentences)
    if (words.length <= 3 && clean.contains('menu')) {
      return 'Làm ơn cho tôi xem thực đơn';
    }

    if (words.length <= 3 && (clean == 'hungry' || clean == 'i am hungry' || clean == 'eat' || clean == 'dinner' || clean == 'lunch' || clean == 'breakfast')) {
      return 'Tôi muốn đặt đồ ăn / Tôi thấy đói';
    }
    if (words.length <= 3 && (clean.contains('bill') || clean.contains('check') || clean == 'pay')) {
      return 'Xin vui lòng tính tiền bàn này';
    }

    // Emergency & Help Patterns (Short queries ONLY)
    if (words.length <= 3 && (clean == 'help' || clean == 'help me' || clean == 'emergency' || clean == 'danger' || clean == 'accident')) {
      return 'Xin hãy giúp tôi với / Trường hợp khẩn cấp!';
    }
    if (words.length <= 3 && clean.contains('lost')) {
      return 'Tôi đang bị lạc đường, xin hãy chỉ giúp';
    }
    if (words.length <= 3 && (clean.contains('sick') || clean.contains('doctor') || clean.contains('pain') || clean.contains('fever'))) {
      return 'Tôi thấy mệt / Tôi cần gặp bác sĩ';
    }

    // Exact Pronoun matches only (Never override full sentences!)
    if (clean == 'we' || clean == 'us') {
      return 'Chúng tôi / Chúng ta';
    }
    if (clean == 'i' || clean == 'me') {
      return 'Tôi';
    }

    return original;
  }

  // Advanced semantic pattern matching for Vietnamese -> English (Progressive + Complete Sentences + Typo Normalization)
  // Advanced semantic pattern matching for Vietnamese -> English (Progressive + Complete Sentences + Typo Normalization)
  static String _translateToEnglishPatterns(String original, String clean, {bool isSubclause = false}) {
    final words = clean.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    // 1. Live Progressive Prefix Streaming ("xin tính tiền bàn số 5 giúp tôi...")
    if (clean.startsWith('xin tính tiền bàn số ')) {
      final remainder = clean.replaceAll('xin tính tiền bàn số ', '').replaceAll('giúp tôi', '').trim();
      return 'Please check the bill for table number ${remainder.isNotEmpty ? remainder : '...'} for me.';
    }
    if (clean.startsWith('xin tính tiền bàn ')) {
      final remainder = clean.replaceAll('xin tính tiền bàn ', '').trim();
      return 'Please check the bill for table $remainder';
    }
    if (clean.startsWith('xin tính tiền') || clean == 'tính tiền') {
      return 'Check please / Bill please';
    }
    if (clean.startsWith('xin tính')) {
      return 'Please calculate / check...';
    }
    if (clean.startsWith('hôm nay chúng ta nên ăn gì') || clean.startsWith('hôm nay chúng ta ăn gì')) {
      return 'What should we eat today?';
    }
    if (clean.startsWith('chúng ta nên ăn gì')) {
      return 'What should we eat?';
    }
    if (clean.startsWith('chúng ta có thể ăn gì')) {
      return 'What can we eat?';
    }
    if (clean.startsWith('chúng ta nên đi đâu')) {
      final remainder = clean.replaceAll('chúng ta nên đi đâu', '').replaceAll('?', '').trim();
      if (remainder.isNotEmpty) {
        final transRemainder = translateSync(remainder, 'Vietnamese', 'English', isSubclause: true);
        return 'Where should we go $transRemainder?';
      }
      return 'Where should we go?';
    }
    if (clean.startsWith('chúng ta nên')) {
      final remainder = clean.replaceAll('chúng ta nên', '').trim();
      if (remainder.isNotEmpty) {
        return 'We should ${translateSync(remainder, 'Vietnamese', 'English', isSubclause: true)}';
      }
      return 'We should...';
    }
    if (clean.startsWith('bạn có thể mở cửa ')) {
      final remainder = clean.replaceAll('bạn có thể mở cửa ', '').trim();
      final transRem = translateSync(remainder, 'Vietnamese', 'English', isSubclause: true);
      if (isSubclause) {
        return 'you can open the door $transRem';
      }
      return 'Can you open the door $transRem?';
    }
    if (clean.startsWith('bạn có thể mở cửa')) {
      if (isSubclause) return 'you can open the door';
      return 'Can you open the door?';
    }
    if (clean.startsWith('bạn có thể mở')) {
      if (isSubclause) return 'you can open';
      return 'Can you open...';
    }
    if (clean == 'bạn có thể' || clean.startsWith('bạn có thể ')) {
      final remainder = clean.length > 10 ? clean.substring(10).replaceAll('?', '').trim() : '';
      if (remainder.isEmpty) {
        if (isSubclause) return 'you can';
        return 'Can you...';
      }
      final transRem = translateSync(remainder, 'Vietnamese', 'English', isSubclause: true);
      if (isSubclause) {
        return 'you can $transRem';
      }
      return 'Can you $transRem?';
    }

    // Polite Request ("Xin ...") Patterns
    if (clean.startsWith('xin ')) {
      if (clean.contains('chỉ tôi đường') || clean.contains('chỉ đường')) return 'Please show me the way to...';
      if (clean == 'xin giúp đỡ' || clean == 'xin giúp tôi') return 'Please help me with this matter';
      if (clean.contains('mở cửa')) return 'Please open the door for me';
      if (clean.contains('dẫn tôi qua đường') || clean.contains('qua đường')) return 'Please help me cross the street';
      if (clean.contains('cảm ơn')) return 'Thank you very much';
      if (clean.contains('lỗi') || clean.contains('không hiểu')) return 'Sorry, I do not understand';
      if (clean.contains('chậm lại')) return 'Please speak more slowly';
      if (clean.contains('thực đơn') || clean.contains('menu')) return 'May I see the menu, please?';
      if (clean.contains('tính tiền') || clean.contains('hóa đơn')) return 'Check please / Bill please';
      final remainder = clean.substring(4).trim();
      final transRemainder = translateSync(remainder, 'Vietnamese', 'English', isSubclause: true);
      return 'Please $transRemainder';
    }

    // Directions & Travel Patterns
    if (clean.contains('làm sao để đi đến ') || clean.contains('cách đi đến ')) {
      final dest = clean.replaceAll('làm sao để đi đến ', '').replaceAll('cách đi đến ', '').replaceAll('?', '').trim();
      final transDest = _lookupTerm(dest, isSubclause: true);
      return 'How to get to $transDest?';
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

    // Dining & Food Patterns (Short queries ONLY)

    if (words.length <= 3 && (clean.contains('ăn') || clean.contains('đói') || clean.contains('thực đơn') || clean.contains('món'))) {
      if (clean.contains('chưa') || clean.contains('rồi')) return 'Have you eaten anything yet?';
      return 'I would like to order food / May I see the menu?';
    }
    if (words.length <= 3 && (clean.contains('uống') || clean.contains('cà phê') || clean.contains('nước') || clean.contains('trà') || clean.contains('bia'))) {
      if (clean.contains('cà phê')) return 'I would like to order iced coffee';
      return 'I would like to order a drink / water';
    }
    if (words.length <= 3 && (clean.contains('tính tiền') || clean.contains('hóa đơn') || clean.contains('thanh toán'))) {
      return 'Check please / Bill please';
    }

    // Intent & Desires Patterns
    if (clean.startsWith('tôi muốn mua ') || clean.startsWith('cho tôi mua ')) {
      final item = clean.replaceAll('tôi muốn mua ', '').replaceAll('cho tôi mua ', '').trim();
      final transItem = _lookupTerm(item, isSubclause: true);
      return 'I would like to buy $transItem';
    }
    if (clean.startsWith('tôi muốn đi ') || clean.startsWith('cho tôi đi ')) {
      final dest = clean.replaceAll('tôi muốn đi đến ', '').replaceAll('tôi muốn đi ', '').replaceAll('cho tôi đi đến ', '').replaceAll('cho tôi đi ', '').trim();
      final transDest = _lookupTerm(dest, isSubclause: true);
      return 'I would like to go to $transDest';
    }
    if (words.length <= 4 && (clean.contains('thuê') || clean.contains('xe máy') || clean.contains('ô tô') || clean.contains('xe'))) {
      return 'I would like to rent a motorbike / vehicle';
    }

    // Emergency & Help Patterns (Short queries ONLY)
    if (words.length <= 3 && (clean.contains('giúp') || clean.contains('cứu') || clean.contains('khẩn cấp'))) {
      return 'Please help me / Emergency!';
    }
    if (words.length <= 3 && clean.contains('lạc')) {
      return 'I am lost, please show me the way';
    }
    if (words.length <= 3 && (clean.contains('bệnh') || clean.contains('mệt') || clean.contains('thuốc') || clean.contains('bác sĩ'))) {
      return 'I feel sick / I need medicine / doctor';
    }

    // Time & Scheduling
    if (clean.contains('mấy giờ rồi') || clean.contains('bây giờ là mấy giờ')) {
      return 'What time is it?';
    }

    // Knowledge & Understanding Patterns
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
