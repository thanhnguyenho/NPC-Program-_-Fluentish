import 'corpus/travel_corpus.dart';
import 'corpus/expanded_corpus.dart';

/// A static phrase library for English ↔ Vietnamese translation.
///
/// Contains 500+ curated phrase mappings across 9 categories:
/// Greetings, Travel, Food, Shopping, Daily Conversation,
/// Emergency, Hotel, Compliments, and Complex Sentences.
///
/// Supports exact and fuzzy matching via Levenshtein distance.
class PhraseLibrary {
  PhraseLibrary._();

  // ---------------------------------------------------------------------------
  // English → Vietnamese phrase map (500+ entries)
  // ---------------------------------------------------------------------------
  static final Map<String, String> _enToVi = <String, String>{
    // =========================================================================
    // GREETINGS & BASICS (70+)
    // =========================================================================
    'hello': 'Xin chào',
    'hi': 'Chào bạn',
    'hey': 'Này',
    'hey there': 'Chào bạn',
    'good morning': 'Chào buổi sáng',
    'good afternoon': 'Chào buổi chiều',
    'good evening': 'Chào buổi tối',
    'good night': 'Chúc ngủ ngon',
    'goodbye': 'Tạm biệt',
    'bye': 'Tạm biệt',
    'bye bye': 'Tạm biệt nhé',
    'see you later': 'Hẹn gặp lại',
    'see you soon': 'Hẹn gặp lại sớm',
    'see you tomorrow': 'Hẹn gặp bạn ngày mai',
    'how are you': 'Bạn khỏe không?',
    'how are you doing': 'Bạn dạo này thế nào?',
    'how have you been': 'Dạo này bạn thế nào?',
    'i am fine': 'Tôi khỏe',
    'i am fine thank you': 'Tôi khỏe, cảm ơn bạn',
    'i am doing well': 'Tôi vẫn ổn',
    'i am great': 'Tôi rất tốt',
    'not bad': 'Không tệ',
    'nice to meet you': 'Rất vui được gặp bạn',
    'nice to see you again': 'Rất vui được gặp lại bạn',
    'what is your name': 'Bạn tên là gì?',
    'my name is': 'Tên tôi là',
    'where are you from': 'Bạn đến từ đâu?',
    'i am from': 'Tôi đến từ',
    'please': 'Làm ơn',
    'thank you': 'Cảm ơn bạn',
    'thank you very much': 'Cảm ơn bạn rất nhiều',
    'thanks': 'Cảm ơn',
    'thanks a lot': 'Cảm ơn rất nhiều',
    'you are welcome': 'Không có gì',
    'sorry': 'Xin lỗi',
    'i am sorry': 'Tôi xin lỗi',
    'excuse me': 'Xin lỗi cho tôi hỏi',
    'pardon me': 'Xin thứ lỗi',
    'yes': 'Vâng',
    'no': 'Không',
    'maybe': 'Có thể',
    'of course': 'Tất nhiên',
    'sure': 'Được chứ',
    'certainly': 'Chắc chắn rồi',
    'no problem': 'Không vấn đề gì',
    'i do not understand': 'Tôi không hiểu',
    'i do not know': 'Tôi không biết',
    'can you repeat that': 'Bạn có thể nhắc lại được không?',
    'can you speak slower': 'Bạn có thể nói chậm hơn được không?',
    'do you speak english': 'Bạn có nói tiếng Anh không?',
    'i do not speak vietnamese': 'Tôi không nói được tiếng Việt',
    'i speak a little vietnamese': 'Tôi nói được một chút tiếng Việt',
    'what does this mean': 'Cái này có nghĩa là gì?',
    'how do you say this in vietnamese': 'Cái này tiếng Việt nói thế nào?',
    'can you help me': 'Bạn có thể giúp tôi được không?',
    'i need help': 'Tôi cần giúp đỡ',
    'long time no see': 'Lâu rồi không gặp',
    'take care': 'Bảo trọng nhé',
    'have a nice day': 'Chúc bạn một ngày tốt lành',
    'have a good trip': 'Chúc bạn đi chơi vui vẻ',
    'what do you do': 'Bạn làm nghề gì?',
    'i am a student': 'Tôi là sinh viên',
    'i am a teacher': 'Tôi là giáo viên',
    'how old are you': 'Bạn bao nhiêu tuổi?',
    'where do you live': 'Bạn sống ở đâu?',
    'i live in': 'Tôi sống ở',
    'it is nice here': 'Ở đây đẹp quá',
    'i like it here': 'Tôi thích ở đây',
    'cheers': 'Chúc mừng',

    // =========================================================================
    // TRAVEL & DIRECTIONS (85+)
    // =========================================================================
    'where is the bank': 'Ngân hàng ở đâu?',
    'where is the hospital': 'Bệnh viện ở đâu?',
    'where is the airport': 'Sân bay ở đâu?',
    'where is the bus stop': 'Trạm xe buýt ở đâu?',
    'where is the train station': 'Ga tàu ở đâu?',
    'where is the hotel': 'Khách sạn ở đâu?',
    'where is the restaurant': 'Nhà hàng ở đâu?',
    'where is the bathroom': 'Nhà vệ sinh ở đâu?',
    'where is the toilet': 'Nhà vệ sinh ở đâu?',
    'where is the market': 'Chợ ở đâu?',
    'where is the post office': 'Bưu điện ở đâu?',
    'where is the police station': 'Đồn công an ở đâu?',
    'where is the embassy': 'Đại sứ quán ở đâu?',
    'where is the nearest pharmacy': 'Hiệu thuốc gần nhất ở đâu?',
    'where is the convenience store': 'Cửa hàng tiện lợi ở đâu?',
    'where is the convenient store': 'Cửa hàng tiện lợi ở đâu?',
    'where is the supermarket': 'Siêu thị ở đâu?',
    'where is the shopping mall': 'Trung tâm thương mại ở đâu?',
    'where is the museum': 'Bảo tàng ở đâu?',
    'where is the park': 'Công viên ở đâu?',
    'where is the beach': 'Bãi biển ở đâu?',
    'where is the temple': 'Ngôi chùa ở đâu?',
    'where is the church': 'Nhà thờ ở đâu?',
    'where is the atm': 'Máy ATM ở đâu?',
    'where is the gas station': 'Trạm xăng ở đâu?',
    'where is the parking lot': 'Bãi đỗ xe ở đâu?',
    'how do i get to the airport': 'Làm thế nào để đến sân bay?',
    'how do i get to the city center': 'Làm thế nào để đến trung tâm thành phố?',
    'how do i get to this address': 'Làm thế nào để đến địa chỉ này?',
    'turn left': 'Rẽ trái',
    'turn right': 'Rẽ phải',
    'go straight': 'Đi thẳng',
    'go straight ahead': 'Đi thẳng phía trước',
    'go back': 'Quay lại',
    'is it far': 'Có xa không?',
    'is it far from here': 'Có xa đây không?',
    'how far is it': 'Bao xa?',
    'how long does it take': 'Mất bao lâu?',
    'how long does it take to get there': 'Đi đến đó mất bao lâu?',
    'can you show me on the map': 'Bạn có thể chỉ cho tôi trên bản đồ được không?',
    'i need a taxi': 'Tôi cần một chiếc taxi',
    'please take me to this address': 'Làm ơn đưa tôi đến địa chỉ này',
    'please take me to the airport': 'Làm ơn đưa tôi đến sân bay',
    'stop here please': 'Dừng ở đây nhé',
    'where can i buy a ticket': 'Tôi có thể mua vé ở đâu?',
    'i want to buy a ticket': 'Tôi muốn mua vé',
    'one ticket please': 'Cho tôi một vé',
    'two tickets please': 'Cho tôi hai vé',
    'a round trip ticket please': 'Cho tôi một vé khứ hồi',
    'a one way ticket please': 'Cho tôi một vé một chiều',
    'i am lost': 'Tôi bị lạc',
    'can you help me find my way': 'Bạn có thể giúp tôi tìm đường được không?',
    'what is this place': 'Đây là nơi nào?',
    'is there a bus to the airport': 'Có xe buýt đi sân bay không?',
    'when is the next bus': 'Chuyến xe buýt tiếp theo lúc mấy giờ?',
    'when is the next train': 'Chuyến tàu tiếp theo lúc mấy giờ?',
    'i would like to rent a motorbike': 'Tôi muốn thuê xe máy',
    'i would like to rent a car': 'Tôi muốn thuê ô tô',
    'how much is the fare': 'Giá vé bao nhiêu?',
    'is this the right way to': 'Đây có phải đường đến',
    'which way to the center': 'Đường nào đến trung tâm?',
    'i want to go to hanoi': 'Tôi muốn đi Hà Nội',
    'i want to go to ho chi minh city': 'Tôi muốn đi thành phố Hồ Chí Minh',
    'i want to go to da nang': 'Tôi muốn đi Đà Nẵng',
    'i want to go to hoi an': 'Tôi muốn đi Hội An',
    'i want to go to nha trang': 'Tôi muốn đi Nha Trang',
    'i want to go to ha long bay': 'Tôi muốn đi vịnh Hạ Long',
    'i want to go to sapa': 'Tôi muốn đi Sa Pa',
    'i want to go to dalat': 'Tôi muốn đi Đà Lạt',
    'i want to go to phu quoc': 'Tôi muốn đi Phú Quốc',
    'what time does the bus leave': 'Xe buýt khởi hành lúc mấy giờ?',
    'what time does the train leave': 'Tàu khởi hành lúc mấy giờ?',
    'what time does the plane leave': 'Máy bay khởi hành lúc mấy giờ?',
    'it is on the left': 'Nó ở bên trái',
    'it is on the right': 'Nó ở bên phải',
    'it is across the street': 'Nó ở bên kia đường',
    'it is next to the bank': 'Nó ở cạnh ngân hàng',
    'at the intersection': 'Ở ngã tư',
    'at the traffic light': 'Ở đèn giao thông',
    'cross the bridge': 'Qua cầu',
    'take the first left': 'Rẽ trái ở ngã rẽ đầu tiên',
    'take the second right': 'Rẽ phải ở ngã rẽ thứ hai',
    'keep going for 100 meters': 'Đi tiếp khoảng 100 mét',
    'i need directions': 'Tôi cần chỉ đường',
    'can you write down the address': 'Bạn có thể viết địa chỉ ra giúp tôi không?',

    // =========================================================================
    // FOOD & RESTAURANT (85+)
    // =========================================================================
    'i would like to order': 'Tôi muốn gọi món',
    'can i see the menu': 'Cho tôi xem thực đơn được không?',
    'can i have the menu please': 'Cho tôi xin thực đơn',
    'how much is this': 'Cái này bao nhiêu tiền?',
    'what do you recommend': 'Bạn giới thiệu món gì?',
    'what is the specialty here': 'Đặc sản ở đây là gì?',
    'i am vegetarian': 'Tôi ăn chay',
    'i am vegan': 'Tôi ăn thuần chay',
    'the check please': 'Cho tôi tính tiền',
    'the bill please': 'Cho tôi hóa đơn',
    'can i have the bill': 'Cho tôi xin hóa đơn được không?',
    'this is delicious': 'Món này ngon quá',
    'this is very good': 'Món này rất ngon',
    'this is amazing': 'Món này tuyệt vời',
    'two bowls of pho please': 'Cho tôi hai tô phở',
    'one bowl of pho please': 'Cho tôi một tô phở',
    'can i have water': 'Cho tôi xin nước',
    'can i have a glass of water': 'Cho tôi xin một ly nước',
    'can i have some ice': 'Cho tôi xin thêm đá',
    'is this spicy': 'Món này có cay không?',
    'not too spicy please': 'Đừng quá cay nhé',
    'i do not eat spicy food': 'Tôi không ăn được đồ cay',
    'no spicy please': 'Không cay nhé',
    'more spicy please': 'Cay hơn nhé',
    'do you accept credit cards': 'Bạn có nhận thẻ tín dụng không?',
    'do you accept cash only': 'Chỉ nhận tiền mặt thôi à?',
    'i would like a coffee': 'Tôi muốn một ly cà phê',
    'i would like an iced coffee': 'Tôi muốn một ly cà phê đá',
    'i would like a milk coffee': 'Tôi muốn một ly cà phê sữa',
    'i would like a beer': 'Tôi muốn một ly bia',
    'two beers please': 'Cho tôi hai ly bia',
    'i would like some tea': 'Tôi muốn một ấm trà',
    'i would like fried rice': 'Tôi muốn cơm chiên',
    'i would like spring rolls': 'Tôi muốn gỏi cuốn',
    'i would like fried spring rolls': 'Tôi muốn chả giò',
    'i would like banh mi': 'Tôi muốn bánh mì',
    'i would like bun cha': 'Tôi muốn bún chả',
    'i would like bun bo hue': 'Tôi muốn bún bò Huế',
    'i would like com tam': 'Tôi muốn cơm tấm',
    'i would like a smoothie': 'Tôi muốn một ly sinh tố',
    'i would like a fresh juice': 'Tôi muốn một ly nước ép',
    'can i have more rice': 'Cho tôi thêm cơm được không?',
    'can i have more noodles': 'Cho tôi thêm bún được không?',
    'can i have more sauce': 'Cho tôi thêm nước chấm được không?',
    'i am allergic to peanuts': 'Tôi bị dị ứng với đậu phộng',
    'i am allergic to seafood': 'Tôi bị dị ứng với hải sản',
    'i am allergic to shellfish': 'Tôi bị dị ứng với tôm cua',
    'does this have peanuts': 'Món này có đậu phộng không?',
    'does this have meat': 'Món này có thịt không?',
    'does this have gluten': 'Món này có gluten không?',
    'no sugar please': 'Không đường nhé',
    'less sugar please': 'Ít đường nhé',
    'extra sugar please': 'Thêm đường nhé',
    'no ice please': 'Không đá nhé',
    'less ice please': 'Ít đá nhé',
    'this is too salty': 'Món này mặn quá',
    'this is too sweet': 'Món này ngọt quá',
    'this is too sour': 'Món này chua quá',
    'this is too bland': 'Món này nhạt quá',
    'this is cold': 'Món này nguội rồi',
    'can you heat this up': 'Bạn có thể hâm nóng lại được không?',
    'a table for two please': 'Cho tôi bàn cho hai người',
    'a table for four please': 'Cho tôi bàn cho bốn người',
    'do you have a table outside': 'Có bàn ở ngoài trời không?',
    'is this table available': 'Bàn này còn trống không?',
    'i have a reservation': 'Tôi có đặt bàn trước',
    'i want to make a reservation': 'Tôi muốn đặt bàn',
    'for what time': 'Cho mấy giờ?',
    'what is in this dish': 'Trong món này có gì?',
    'can you make it without meat': 'Bạn có thể làm không thịt được không?',
    'i am full': 'Tôi no rồi',
    'that was a great meal': 'Bữa ăn rất ngon',
    'where is a good place to eat': 'Ở đâu có chỗ ăn ngon?',
    'do you have a kids menu': 'Có thực đơn cho trẻ em không?',
    'can i take this to go': 'Cho tôi mang đi được không?',
    'for here or to go': 'Ăn tại đây hay mang đi?',
    'to go please': 'Cho tôi mang đi',
    'for here please': 'Cho tôi ăn tại đây',
    'can i have chopsticks': 'Cho tôi xin đũa',
    'can i have a fork and spoon': 'Cho tôi xin muỗng và nĩa',
    'can i have a napkin': 'Cho tôi xin khăn giấy',
    'keep the change': 'Giữ lại tiền thừa nhé',
    'i do not eat pork': 'Tôi không ăn thịt heo',
    'i do not eat beef': 'Tôi không ăn thịt bò',

    // =========================================================================
    // SHOPPING (55+)
    // =========================================================================
    'how much does this cost': 'Cái này giá bao nhiêu?',
    'how much is it': 'Bao nhiêu tiền?',
    'that is too expensive': 'Đắt quá',
    'can you give me a discount': 'Bạn có thể giảm giá được không?',
    'can you lower the price': 'Bạn có thể bớt giá được không?',
    'what is your best price': 'Giá tốt nhất là bao nhiêu?',
    'do you have a smaller size': 'Có size nhỏ hơn không?',
    'do you have a bigger size': 'Có size lớn hơn không?',
    'do you have this in another color': 'Có màu khác không?',
    'do you have this in red': 'Có màu đỏ không?',
    'do you have this in blue': 'Có màu xanh dương không?',
    'do you have this in black': 'Có màu đen không?',
    'do you have this in white': 'Có màu trắng không?',
    'i will take it': 'Tôi lấy cái này',
    'i will take two': 'Tôi lấy hai cái',
    'i am just looking': 'Tôi chỉ xem thôi',
    'i am just browsing': 'Tôi chỉ xem qua thôi',
    'where can i exchange money': 'Tôi có thể đổi tiền ở đâu?',
    'what is the exchange rate': 'Tỷ giá hối đoái là bao nhiêu?',
    'can i try this on': 'Tôi có thể thử được không?',
    'where is the fitting room': 'Phòng thay đồ ở đâu?',
    'do you have a bag': 'Bạn có túi không?',
    'can i have a bag please': 'Cho tôi xin một cái túi',
    'can i return this': 'Tôi có thể trả lại được không?',
    'can i exchange this': 'Tôi có thể đổi cái này được không?',
    'do you have a receipt': 'Bạn có hóa đơn không?',
    'i need a receipt': 'Tôi cần hóa đơn',
    'this is broken': 'Cái này bị hỏng',
    'this does not work': 'Cái này không hoạt động',
    'do you sell souvenirs': 'Bạn có bán đồ lưu niệm không?',
    'where can i buy souvenirs': 'Tôi có thể mua đồ lưu niệm ở đâu?',
    'i want to buy a gift': 'Tôi muốn mua quà',
    'do you ship internationally': 'Bạn có giao hàng quốc tế không?',
    'can you wrap this as a gift': 'Bạn có thể gói quà được không?',
    'what material is this': 'Cái này làm bằng chất liệu gì?',
    'is this handmade': 'Cái này làm thủ công à?',
    'is this genuine': 'Cái này có phải hàng thật không?',
    'i want to buy some clothes': 'Tôi muốn mua quần áo',
    'i want to buy some shoes': 'Tôi muốn mua giày',
    'i want to buy a hat': 'Tôi muốn mua mũ',
    'i want to buy sunglasses': 'Tôi muốn mua kính râm',
    'where is the nearest shopping area': 'Khu mua sắm gần nhất ở đâu?',
    'is there a night market nearby': 'Gần đây có chợ đêm không?',
    'when does the market open': 'Chợ mở cửa lúc mấy giờ?',
    'when does the market close': 'Chợ đóng cửa lúc mấy giờ?',
    'can i pay by card': 'Tôi có thể trả bằng thẻ không?',
    'can i pay in dollars': 'Tôi có thể trả bằng đô la không?',
    'i only have big bills': 'Tôi chỉ có tiền mệnh giá lớn',
    'do you have change': 'Bạn có tiền lẻ không?',
    'that is a good price': 'Giá đó được đấy',
    'i will think about it': 'Để tôi suy nghĩ thêm',
    'i do not want it': 'Tôi không muốn mua',
    'no thank you': 'Không, cảm ơn',
    'where is the cashier': 'Quầy tính tiền ở đâu?',
    'can i see that one': 'Cho tôi xem cái kia được không?',
    'show me that one please': 'Cho tôi xem cái kia',

    // =========================================================================
    // DAILY CONVERSATION (85+)
    // =========================================================================
    'how is the weather today': 'Thời tiết hôm nay thế nào?',
    'it is hot today': 'Hôm nay nóng quá',
    'it is cold today': 'Hôm nay lạnh quá',
    'it is raining': 'Trời đang mưa',
    'it is sunny': 'Trời nắng',
    'it is cloudy': 'Trời nhiều mây',
    'it is windy': 'Trời gió lớn',
    'it is very humid': 'Trời ẩm ướt quá',
    'what time is it': 'Mấy giờ rồi?',
    'what day is today': 'Hôm nay là thứ mấy?',
    'what is the date today': 'Hôm nay là ngày mấy?',
    'i like your hair a lot': 'Tôi rất thích tóc của bạn',
    'you look beautiful': 'Bạn trông rất đẹp',
    'you look handsome': 'Bạn trông rất đẹp trai',
    'you look great today': 'Hôm nay bạn trông tuyệt lắm',
    'i had a great time': 'Tôi đã có khoảng thời gian rất vui',
    'can we meet tomorrow': 'Ngày mai chúng ta gặp nhau được không?',
    'when can we meet': 'Khi nào chúng ta có thể gặp nhau?',
    'where should we meet': 'Chúng ta gặp nhau ở đâu?',
    'i am tired': 'Tôi mệt rồi',
    'i am very tired': 'Tôi mệt lắm rồi',
    'i am hungry': 'Tôi đói bụng',
    'i am thirsty': 'Tôi khát nước',
    'i am sleepy': 'Tôi buồn ngủ',
    'let us go': 'Mình đi thôi',
    'let us eat': 'Mình đi ăn thôi',
    'wait a minute': 'Đợi một chút',
    'wait for me': 'Đợi tôi với',
    'be careful': 'Cẩn thận nhé',
    'do not worry': 'Đừng lo lắng',
    'it is okay': 'Không sao đâu',
    'never mind': 'Không sao',
    'i agree': 'Tôi đồng ý',
    'i disagree': 'Tôi không đồng ý',
    'i think so': 'Tôi nghĩ vậy',
    'i do not think so': 'Tôi không nghĩ vậy',
    'that is interesting': 'Thú vị thật',
    'that is funny': 'Buồn cười thật',
    'that is true': 'Đúng vậy',
    'really': 'Thật sao?',
    'are you serious': 'Bạn nói nghiêm túc đấy chứ?',
    'just kidding': 'Đùa thôi',
    'i am joking': 'Tôi đùa đấy',
    'do you have anything to say with me': 'Bạn có điều gì muốn nói với tôi không?',
    'here is your translation': 'Đây là bản dịch của bạn',
    'can i borrow your phone': 'Tôi có thể mượn điện thoại của bạn không?',
    'what is your phone number': 'Số điện thoại của bạn là gì?',
    'can i have your email': 'Cho tôi xin email của bạn được không?',
    'do you have wifi here': 'Ở đây có wifi không?',
    'what is the wifi password': 'Mật khẩu wifi là gì?',
    'can i charge my phone here': 'Tôi có thể sạc điện thoại ở đây không?',
    'i love this place': 'Tôi yêu nơi này',
    'this place is beautiful': 'Nơi này đẹp quá',
    'can you take a photo of me': 'Bạn có thể chụp ảnh giúp tôi không?',
    'can we take a photo together': 'Chúng ta chụp ảnh cùng nhau được không?',
    'i want to go home': 'Tôi muốn về nhà',
    'i miss my family': 'Tôi nhớ gia đình',
    'when are you coming back': 'Bạn khi nào quay lại?',
    'what are you doing': 'Bạn đang làm gì vậy?',
    'nothing much': 'Không có gì đặc biệt',
    'i am busy right now': 'Tôi đang bận',
    'i am free today': 'Hôm nay tôi rảnh',
    'let me think about it': 'Để tôi suy nghĩ đã',
    'i changed my mind': 'Tôi đổi ý rồi',
    'what do you think': 'Bạn nghĩ sao?',
    'that sounds good': 'Nghe hay đấy',
    'that sounds fun': 'Nghe vui đấy',
    'i cannot wait': 'Tôi không thể chờ được nữa',
    'hurry up': 'Nhanh lên',
    'slow down': 'Chậm lại',
    'come here': 'Lại đây',
    'go away': 'Đi đi',
    'leave me alone': 'Để tôi yên',
    'i am bored': 'Tôi chán quá',
    'what should we do': 'Mình nên làm gì bây giờ?',
    'let us go for a walk': 'Mình đi dạo đi',
    'do you want to go with me': 'Bạn có muốn đi cùng tôi không?',
    'i will be right back': 'Tôi sẽ quay lại ngay',
    'i am on my way': 'Tôi đang trên đường đến',
    'i just arrived': 'Tôi vừa đến',
    'where have you been': 'Bạn đã đi đâu vậy?',
    'i went to the market': 'Tôi đã đi chợ',
    'what did you buy': 'Bạn đã mua gì?',
    'i need to rest': 'Tôi cần nghỉ ngơi',
    'good luck': 'Chúc may mắn',
    'you can do it': 'Bạn làm được mà',
    'well done': 'Làm tốt lắm',

    // =========================================================================
    // EMERGENCY & HEALTH (45+)
    // =========================================================================
    'please call an ambulance': 'Xin hãy gọi xe cấp cứu',
    'call an ambulance': 'Gọi xe cấp cứu',
    'i am sick': 'Tôi bị ốm',
    'i do not feel well': 'Tôi cảm thấy không khỏe',
    'i need a doctor': 'Tôi cần gặp bác sĩ',
    'please take me to the hospital': 'Xin hãy đưa tôi đến bệnh viện',
    'i lost my passport': 'Tôi bị mất hộ chiếu',
    'i lost my wallet': 'Tôi bị mất ví',
    'i lost my phone': 'Tôi bị mất điện thoại',
    'i lost my bag': 'Tôi bị mất túi',
    'call the police': 'Gọi công an',
    'please call the police': 'Xin hãy gọi công an',
    'i have been robbed': 'Tôi bị cướp',
    'someone stole my bag': 'Có người lấy trộm túi của tôi',
    'there is a fire': 'Có cháy',
    'help': 'Cứu tôi với',
    'help me': 'Giúp tôi với',
    'it is an emergency': 'Đây là trường hợp khẩn cấp',
    'i have a headache': 'Tôi bị đau đầu',
    'i have a stomachache': 'Tôi bị đau bụng',
    'i have a fever': 'Tôi bị sốt',
    'i have a cold': 'Tôi bị cảm lạnh',
    'i have a cough': 'Tôi bị ho',
    'i have a sore throat': 'Tôi bị đau họng',
    'i have diarrhea': 'Tôi bị tiêu chảy',
    'i feel dizzy': 'Tôi bị chóng mặt',
    'i feel nauseous': 'Tôi bị buồn nôn',
    'i am injured': 'Tôi bị thương',
    'i need medicine': 'Tôi cần thuốc',
    'where can i buy medicine': 'Tôi có thể mua thuốc ở đâu?',
    'i am allergic to this medicine': 'Tôi bị dị ứng với thuốc này',
    'i need to see a dentist': 'Tôi cần gặp nha sĩ',
    'i have a toothache': 'Tôi bị đau răng',
    'i broke my arm': 'Tôi bị gãy tay',
    'i broke my leg': 'Tôi bị gãy chân',
    'i was bitten by an insect': 'Tôi bị côn trùng cắn',
    'i was bitten by a dog': 'Tôi bị chó cắn',
    'i need an ambulance': 'Tôi cần xe cấp cứu',
    'is there a clinic nearby': 'Gần đây có phòng khám không?',
    'do you have a first aid kit': 'Bạn có hộp sơ cứu không?',
    'i need to go to the emergency room': 'Tôi cần đến phòng cấp cứu',
    'i have travel insurance': 'Tôi có bảo hiểm du lịch',
    'here is my insurance card': 'Đây là thẻ bảo hiểm của tôi',
    'i take this medication daily': 'Tôi uống thuốc này hàng ngày',
    'i have high blood pressure': 'Tôi bị cao huyết áp',

    // =========================================================================
    // HOTEL & ACCOMMODATION (50+)
    // =========================================================================
    'i would like to check in': 'Tôi muốn nhận phòng',
    'i would like to check out': 'Tôi muốn trả phòng',
    'do you have a room available': 'Còn phòng trống không?',
    'do you have a single room': 'Có phòng đơn không?',
    'do you have a double room': 'Có phòng đôi không?',
    'how much per night': 'Bao nhiêu tiền một đêm?',
    'how much for one night': 'Một đêm bao nhiêu?',
    'how much for two nights': 'Hai đêm bao nhiêu?',
    'is breakfast included': 'Có bao gồm bữa sáng không?',
    'what time is breakfast': 'Bữa sáng lúc mấy giờ?',
    'what time is check in': 'Nhận phòng lúc mấy giờ?',
    'what time is check out': 'Trả phòng lúc mấy giờ?',
    'can i have a late check out': 'Tôi có thể trả phòng muộn được không?',
    'can i extend my stay': 'Tôi có thể ở thêm được không?',
    'i want to stay for three nights': 'Tôi muốn ở ba đêm',
    'i want to stay for one week': 'Tôi muốn ở một tuần',
    'is there a swimming pool': 'Có hồ bơi không?',
    'is there a gym': 'Có phòng tập không?',
    'is there a spa': 'Có spa không?',
    'can i have an extra blanket': 'Cho tôi xin thêm chăn',
    'can i have an extra pillow': 'Cho tôi xin thêm gối',
    'can i have extra towels': 'Cho tôi xin thêm khăn tắm',
    'the air conditioning is not working': 'Máy lạnh không hoạt động',
    'the hot water is not working': 'Nước nóng không có',
    'the tv is not working': 'Tivi không hoạt động',
    'the light is broken': 'Đèn bị hỏng',
    'the room is too noisy': 'Phòng ồn quá',
    'can i change my room': 'Tôi có thể đổi phòng không?',
    'i want a room with a view': 'Tôi muốn phòng có view đẹp',
    'i want a room with a balcony': 'Tôi muốn phòng có ban công',
    'do you have room service': 'Có dịch vụ phòng không?',
    'can you wake me up at 7 am': 'Bạn có thể gọi tôi dậy lúc 7 giờ sáng không?',
    'please do not disturb': 'Xin đừng làm phiền',
    'please clean my room': 'Xin dọn phòng giúp tôi',
    'i left my key in the room': 'Tôi để quên chìa khóa trong phòng',
    'i locked myself out': 'Tôi bị khóa ngoài phòng',
    'is there a safe in the room': 'Trong phòng có két sắt không?',
    'where is the elevator': 'Thang máy ở đâu?',
    'where is the stairs': 'Cầu thang ở đâu?',
    'what floor is my room on': 'Phòng tôi ở tầng mấy?',
    'can i store my luggage here': 'Tôi có thể gửi hành lý ở đây không?',
    'can you call a taxi for me': 'Bạn có thể gọi taxi giúp tôi không?',
    'do you have a map of the city': 'Bạn có bản đồ thành phố không?',
    'what is there to do around here': 'Quanh đây có gì chơi không?',
    'can you recommend a restaurant': 'Bạn có thể giới thiệu nhà hàng nào không?',
    'is there laundry service': 'Có dịch vụ giặt là không?',
    'i need to do laundry': 'Tôi cần giặt đồ',
    'can i have a room on a higher floor': 'Cho tôi phòng ở tầng cao hơn được không?',
    'is there parking available': 'Có chỗ đỗ xe không?',
    'the room smells bad': 'Phòng có mùi khó chịu',

    // =========================================================================
    // COMPLIMENTS & SOCIAL (50+)
    // =========================================================================
    'you are very kind': 'Bạn rất tốt bụng',
    'you are very nice': 'Bạn rất dễ thương',
    'you are very beautiful': 'Bạn rất xinh đẹp',
    'you are very handsome': 'Bạn rất đẹp trai',
    'you are very smart': 'Bạn rất thông minh',
    'you are very talented': 'Bạn rất tài năng',
    'you are very funny': 'Bạn rất hài hước',
    'you are very helpful': 'Bạn rất nhiệt tình',
    'congratulations': 'Chúc mừng bạn',
    'happy birthday': 'Chúc mừng sinh nhật',
    'happy new year': 'Chúc mừng năm mới',
    'merry christmas': 'Giáng sinh vui vẻ',
    'happy valentines day': 'Chúc mừng ngày lễ tình nhân',
    'happy lunar new year': 'Chúc mừng năm mới âm lịch',
    'welcome to vietnam': 'Chào mừng đến Việt Nam',
    'welcome to hanoi': 'Chào mừng đến Hà Nội',
    'welcome to ho chi minh city': 'Chào mừng đến thành phố Hồ Chí Minh',
    'i love vietnam': 'Tôi yêu Việt Nam',
    'i love vietnamese food': 'Tôi yêu đồ ăn Việt Nam',
    'vietnam is beautiful': 'Việt Nam rất đẹp',
    'the food here is amazing': 'Đồ ăn ở đây tuyệt vời',
    'the people here are very friendly': 'Người dân ở đây rất thân thiện',
    'i love the culture here': 'Tôi yêu văn hóa ở đây',
    'i will come back again': 'Tôi sẽ quay lại',
    'i want to come back': 'Tôi muốn quay lại',
    'this is my first time in vietnam': 'Đây là lần đầu tôi đến Việt Nam',
    'i enjoy my time here': 'Tôi rất thích thời gian ở đây',
    'you are a great cook': 'Bạn nấu ăn rất ngon',
    'your english is very good': 'Tiếng Anh của bạn rất giỏi',
    'i am impressed': 'Tôi rất ấn tượng',
    'well said': 'Nói hay lắm',
    'i admire you': 'Tôi ngưỡng mộ bạn',
    'you did a great job': 'Bạn đã làm rất tốt',
    'i appreciate your help': 'Tôi rất trân trọng sự giúp đỡ của bạn',
    'thank you for your hospitality': 'Cảm ơn sự hiếu khách của bạn',
    'thank you for everything': 'Cảm ơn vì tất cả',
    'it was a pleasure meeting you': 'Rất vui được gặp bạn',
    'i had a wonderful time': 'Tôi đã có khoảng thời gian tuyệt vời',
    'you made my day': 'Bạn đã làm ngày hôm nay của tôi vui hơn',
    'what a beautiful place': 'Nơi này đẹp quá',
    'what a lovely day': 'Ngày đẹp quá',
    'i wish you all the best': 'Chúc bạn mọi điều tốt đẹp',
    'take care of yourself': 'Bảo trọng nhé',
    'stay safe': 'Giữ gìn sức khỏe nhé',
    'have fun': 'Chúc vui vẻ',
    'enjoy your trip': 'Chúc bạn có chuyến đi vui vẻ',
    'enjoy your meal': 'Chúc bạn ngon miệng',
    'best wishes': 'Lời chúc tốt đẹp nhất',
    'i am glad to hear that': 'Tôi rất vui khi nghe điều đó',
    'that is so kind of you': 'Bạn thật tốt bụng',

    // =========================================================================
    // COMPLEX SENTENCES (35+)
    // =========================================================================
    'my australian coworker who is also my lifelong friend came to visit me':
        'Đồng nghiệp người Úc của tôi, cũng là bạn thân cả đời, đã đến thăm tôi',
    'do you fancy a dinner on the yacht':
        'Bạn có muốn dùng bữa tối trên du thuyền không?',
    'i can have a table for two at 7 pm sunday':
        'Tôi có thể đặt bàn cho hai người vào 7 giờ tối Chủ Nhật',
    'i would like a walk on the beach near the fuji mountain':
        'Tôi muốn đi dạo trên bãi biển gần núi Phú Sĩ',
    'can you tell me where the nearest hospital is':
        'Bạn có thể cho tôi biết bệnh viện gần nhất ở đâu không?',
    'do you know where the bus stop is':
        'Bạn có biết trạm xe buýt ở đâu không?',
    'help me with the suitcase': 'Giúp tôi xách va li với',
    'he said that he loves vietnam': 'Anh ấy nói rằng anh ấy yêu Việt Nam',
    'she said that she loves vietnam': 'Cô ấy nói rằng cô ấy yêu Việt Nam',
    'i would like to order two bowls of pho please':
        'Cho tôi gọi hai tô phở',
    'could you please speak more slowly': 'Bạn có thể nói chậm hơn được không?',
    'i have been traveling in vietnam for two weeks':
        'Tôi đã đi du lịch ở Việt Nam được hai tuần rồi',
    'this is the most beautiful place i have ever seen':
        'Đây là nơi đẹp nhất mà tôi từng thấy',
    'i would like to learn how to cook pho':
        'Tôi muốn học cách nấu phở',
    'can you recommend a good place to watch the sunset':
        'Bạn có thể giới thiệu chỗ nào đẹp để ngắm hoàng hôn không?',
    'i am planning to stay in vietnam for a month':
        'Tôi dự định ở Việt Nam một tháng',
    'the weather in vietnam is very different from my country':
        'Thời tiết ở Việt Nam rất khác so với nước tôi',
    'i want to visit all the famous places in hanoi':
        'Tôi muốn thăm tất cả các địa danh nổi tiếng ở Hà Nội',
    'my friend recommended this restaurant to me':
        'Bạn tôi đã giới thiệu nhà hàng này cho tôi',
    'the traffic in ho chi minh city is very crazy':
        'Giao thông ở thành phố Hồ Chí Minh rất điên cuồng',
    'i have been learning vietnamese for six months':
        'Tôi đã học tiếng Việt được sáu tháng rồi',
    'can you help me translate this document':
        'Bạn có thể giúp tôi dịch tài liệu này không?',
    'i would like to book a tour to ha long bay':
        'Tôi muốn đặt tour du lịch vịnh Hạ Long',
    'what is the best time of year to visit vietnam':
        'Thời điểm nào trong năm là tốt nhất để đến Việt Nam?',
    'i need to extend my visa for another month':
        'Tôi cần gia hạn visa thêm một tháng nữa',
    'could you tell me how to get to the old quarter':
        'Bạn có thể chỉ cho tôi cách đến phố cổ không?',
    'i am looking for a place that serves traditional vietnamese food':
        'Tôi đang tìm quán ăn phục vụ món ăn truyền thống Việt Nam',
    'do you know if there is a cooking class i can join':
        'Bạn có biết có lớp học nấu ăn nào tôi có thể tham gia không?',
    'i think vietnamese coffee is the best in the world':
        'Tôi nghĩ cà phê Việt Nam ngon nhất thế giới',
    'the night market here is much bigger than i expected':
        'Chợ đêm ở đây lớn hơn tôi tưởng rất nhiều',
    'i would love to try the street food here':
        'Tôi rất muốn thử đồ ăn đường phố ở đây',
    'can you take me to a local restaurant that tourists do not usually go to':
        'Bạn có thể đưa tôi đến một nhà hàng địa phương mà du khách thường không đến không?',
    'i want to buy some souvenirs for my family back home':
        'Tôi muốn mua quà lưu niệm cho gia đình ở nhà',
    'how long does it take to get from hanoi to ho chi minh city by train':
        'Đi tàu từ Hà Nội đến thành phố Hồ Chí Minh mất bao lâu?',
    'i would like to rent a motorbike to explore the city':
        'Tôi muốn thuê xe máy để khám phá thành phố',

    // =========================================================================
    // USER & AI GENERATED CONCEPTS (15 CONCEPTS & MULTI-VARIATIONS)
    // =========================================================================
    // CONCEPT 1: FINDING THE NEAREST BUS STOP (Tìm trạm xe buýt gần nhất)
    'where is the nearest bus stop': 'Trạm xe buýt gần nhất ở đâu ạ?',
    'can you tell me where the nearest bus stop is': 'Bạn có thể chỉ cho tôi trạm xe buýt gần nhất ở đâu không?',
    'do you know where the nearest bus stop is': 'Bạn có biết trạm xe buýt gần nhất ở đâu không?',
    'could you point me to the nearest bus stop': 'Bạn có thể chỉ đường đến trạm xe buýt gần nhất giúp tôi không?',
    'i want to go to the closest bus stop': 'Tôi muốn đi đến trạm xe buýt gần nhất.',
    'how do i get to the nearest bus stop': 'Làm thế nào để đi đến trạm xe buýt gần nhất?',
    'where nearest bus stop': 'Trạm xe buýt gần nhất ở đâu?',
    'nearest bus stop location': 'Vị trí trạm xe buýt gần nhất.',
    'how to get to nearest bus stop': 'Làm sao để đi đến trạm xe buýt gần nhất?',

    // CONCEPT 2: FINDING THE NEAREST SUBWAY OR METRO STATION (Tìm ga tàu điện ngầm gần nhất)
    'where is the nearest metro station': 'Ga tàu điện gần nhất ở đâu ạ?',
    'could you tell me where the nearest subway station is': 'Bạn có thể chỉ giúp tôi ga tàu điện ngầm gần nhất ở đâu không?',
    'do you know where the closest metro is': 'Bạn có biết ga tàu điện gần nhất ở đâu không?',
    'i need to find the nearest subway station': 'Tôi đang cần tìm ga tàu điện ngầm gần nhất.',
    'how do i get to the closest metro': 'Làm sao để đi đến ga tàu điện gần nhất?',
    'where nearest subway station': 'Ga tàu điện ngầm gần nhất ở đâu?',
    'metro station near me': 'Ga tàu điện gần đây.',
    'how to get to subway station': 'Làm sao để đi đến ga tàu điện ngầm?',

    // 'how do i get to the city center': 'Làm thế nào để đi đến trung tâm thành phố?',
    'could you please tell me the way to the museum': 'Bạn có thể vui lòng chỉ đường đến bảo tàng giúp tôi được không?',
    'do you know the way to the post office': 'Bạn có biết đường đến bưu điện không?',
    'i am trying to find the central park': 'Tôi đang tìm đường đến công viên trung tâm.',
    'can you point me in the direction of the cathedral': 'Bạn có thể chỉ hướng đi đến nhà thờ lớn giúp tôi không?',
    'way to city center': 'Đường đi đến trung tâm thành phố.',
    'directions to museum': 'Chỉ đường đến bảo tàng.',
    'how get to post office': 'Làm sao đi đến bưu điện?',

    // CONCEPT 4: CONFIRMING IF THIS IS THE CORRECT WAY (Xác nhận xem có đang đi đúng hướng không)
    'is this the right way to the airport': 'Đây có phải là đường đi ra sân bay không?',
    'could you tell me if this is the way to the lake': 'Bạn có thể cho tôi hỏi đây có phải là đường đi ra hồ không?',
    'am i heading in the right direction for the station': 'Tôi đi hướng này đã đúng đường ra nhà ga chưa ạ?',
    'am i going the right way': 'Tôi có đang đi đúng đường không?',
    'is this road leading to the market': 'Đường này có đi thẳng ra chợ không ạ?',
    'right way to airport': 'Đúng đường đi ra sân bay không?',
    'this way to station': 'Đường này đi ra nhà ga đúng không?',
    'is this way for market': 'Đường này đi ra chợ đúng không?',

    // CONCEPT 5: ASKING ABOUT DISTANCE AND TIME TO GET THERE (Hỏi về khoảng cách và thời gian)
    'how far is it from here': 'Từ đây đi đến đó bao xa?',
    'could you tell me how long it takes to walk there': 'Bạn có thể cho tôi biết đi bộ đến đó mất bao lâu không?',
    // 'how long does it take to get there': 'Đi đến đó mất khoảng bao lâu?',
    'is it a long walk to the museum': 'Đi bộ đến bảo tàng có xa lắm không?',
    'how far': 'Bao xa?',
    'how long to walk': 'Đi bộ mất bao lâu?',
    'how many minutes walk': 'Đi bộ khoảng bao nhiêu phút?',

    // 'where can i buy a ticket': 'Tôi có thể mua vé ở đâu?',
    'could you tell me where to buy bus tickets': 'Bạn có thể chỉ cho tôi chỗ mua vé xe buýt ở đâu không?',
    'do you know where the ticket counter is': 'Bạn có biết quầy bán vé ở đâu không?',
    'where do i get the train tickets': 'Tôi mua vé tàu ở đâu vậy?',
    'how do i pay for the subway fare': 'Tôi thanh toán tiền vé tàu điện ngầm thế nào?',
    'ticket office': 'Quầy bán vé.',
    'where buy tickets': 'Mua vé ở đâu?',
    'where is ticket machine': 'Máy bán vé ở đâu?',

    // CONCEPT 7: ASKING WHICH BUS OR TRAIN TO TAKE (Hỏi đi tuyến xe / tàu nào)
    'which bus goes to the city center': 'Tuyến xe buýt nào đi đến trung tâm thành phố?',
    'could you tell me which train goes to the airport': 'Bạn có thể cho tôi biết chuyến tàu nào đi ra sân bay không?',
    'do you know which bus line i should take': 'Bạn có biết tôi nên bắt tuyến xe buýt số mấy không?',
    'what bus do i take for the museum': 'Tôi đi xe buýt nào để đến bảo tàng?',
    'is there a direct train to the station': 'Có tàu đi thẳng đến nhà ga không?',
    'which bus to city center': 'Xe buýt nào đi trung tâm thành phố?',
    'which train for airport': 'Tàu nào đi sân bay?',
    'what train goes to center': 'Tàu nào đi vào trung tâm?',

    // CONCEPT 8: ASKING WHERE TO GET OFF OR STOP (Hỏi xuống ở trạm dừng nào)
    'where should i get off': 'Tôi nên xuống ở trạm nào?',
    'could you tell me when we reach the museum stop': 'Bạn có thể nhắc tôi khi nào đến trạm dừng gần bảo tàng được không?',
    'please let me know when to get off': 'Làm ơn báo giúp tôi khi nào cần xuống xe nhé.',
    'what is the stop for the city center': 'Trạm nào đi ra trung tâm thành phố vậy?',
    'is this my stop': 'Tôi xuống ở trạm này đúng không?',
    'where get off': 'Xuống xe ở đâu?',
    'which stop': 'Trạm dừng nào?',
    'where to get off for park': 'Xuống ở đâu để vào công viên?',

    // CONCEPT 9: BOOKING OR CALLING A TAXI / RIDE-HAILING CAR (Đặt xe công nghệ / gọi xe taxi)
    'where can i get a taxi': 'Tôi có thể bắt taxi ở đâu?',
    'could you help me call a taxi': 'Bạn có thể gọi giúp tôi một chiếc taxi được không?',
    'do you know how to book a ride here': 'Bạn có biết làm thế nào để đặt xe ở đây không?',
    'i need to book a grab ride': 'Tôi cần đặt một chuyến Grab.',
    'is there a taxi stand nearby': 'Gần đây có bến đỗ taxi nào không?',
    'taxi stand': 'Trạm đón taxi.',
    'call taxi': 'Gọi taxi.',
    'where get grab car': 'Bắt xe Grab ở đâu?',

    // 'i am lost': 'Tôi bị lạc đường rồi.',
    'excuse me i think i am lost and need help': 'Xin lỗi, hình như tôi bị lạc và cần giúp đỡ ạ.',
    'could you help me find my way back': 'Bạn có thể giúp tôi tìm đường quay lại được không?',
    'i do not know where i am': 'Tôi không biết mình đang ở đâu nữa.',
    'i lost my way': 'Tôi bị lạc mất rồi.',
    'lost my way': 'Bị lạc đường rồi.',
    'i lost': 'Tôi bị lạc.',
    'lost where is station': 'Bị lạc rồi, nhà ga ở đâu thế?',

    // CONCEPT 11: ASKING IF A DESTINATION IS WITHIN WALKING DISTANCE (Hỏi xem có đi bộ được không)
    'can i walk there': 'Tôi đi bộ đến đó được không?',
    'could you tell me if it is too far to walk': 'Bạn có thể cho tôi biết đi bộ đến đó có xa quá không?',
    'do you think i can walk to the station': 'Bạn nghĩ tôi có thể đi bộ ra nhà ga được không?',
    'is it within walking distance': 'Chỗ đó có gần đến mức đi bộ được không?',
    'is it walkable from here': 'Từ đây đi bộ ra đó được không?',
    'walk there': 'Đi bộ tới đó.',
    'is walk possible': 'Đi bộ được không?',
    'too far to walk': 'Có quá xa để đi bộ không?',

    // CONCEPT 12: FINDING THE NEAREST ATM OR CONVENIENCE STORE (Tìm ATM hoặc cửa hàng tiện lợi)
    'where is the nearest atm': 'Cây ATM gần nhất ở đâu?',
    'could you tell me where the closest convenience store is': 'Bạn có thể chỉ giúp tôi cửa hàng tiện lợi gần nhất ở đâu không?',
    'do you know if there is an atm near here': 'Bạn có biết quanh đây có cây ATM nào không?',
    'i am looking for a convenience store': 'Tôi đang tìm một cửa hàng tiện lợi.',
    'where can i find a cash machine': 'Tôi có thể tìm máy rút tiền ở đâu?',
    'nearest convenience store': 'Cửa hàng tiện lợi gần nhất.',
    'atm near me': 'Cây ATM gần đây.',
    'where nearest atm': 'ATM gần nhất ở đâu?',

    // CONCEPT 13: ASKING FOR LANDMARKS OR REFERENCE POINTS NEARBY (Hỏi điểm nhận biết)
    'are there any landmarks nearby': 'Gần đó có đặc điểm hay công trình nào dễ nhận biết không?',
    'could you tell me what is next to the hotel': 'Bạn có thể cho tôi biết bên cạnh khách sạn là cái gì không?',
    'do you know what building is opposite the store': 'Bạn có biết tòa nhà đối diện cửa hàng là tòa nhà nào không?',
    'what should i look out for': 'Tôi nên chú ý tìm điểm mốc nào?',
    'is it near any famous building': 'Chỗ đó có gần tòa nhà nổi tiếng nào không?',
    'landmarks nearby': 'Điểm mốc gần đây.',
    'opposite what': 'Đối diện với cái gì?',
    'what next to museum': 'Cái gì ở cạnh bảo tàng thế?',

    // 'how much is the fare': 'Giá vé/tiền xe là bao nhiêu vậy?',
    'could you please tell me how much a ride costs': 'Bạn có thể cho tôi biết một chuyến đi hết bao nhiêu tiền không?',
    'do you know how much the taxi fare is to the airport': 'Bạn có biết tiền taxi ra sân bay khoảng bao nhiêu không?',
    'what is the price of a bus ticket': 'Giá vé xe buýt là bao nhiêu?',
    'how much does it cost to get to the center': 'Đi vào trung tâm mất bao nhiêu tiền?',
    'how much fare': 'Tiền vé bao nhiêu?',
    'price to airport': 'Giá đi sân bay.',
    'how much for taxi': 'Đi taxi hết bao nhiêu?',

    // CONCEPT 15: ASKING WHERE TO PARK OR SECURE A VEHICLE (Hỏi chỗ đậu xe / gửi xe)
    'where can i park my car': 'Tôi có thể đậu xe ô tô ở đâu?',
    'could you please tell me where the parking lot is': 'Bạn có thể chỉ cho tôi bãi đỗ xe ở đâu không?',
    'do you know where i can park my motorbike': 'Bạn có biết chỗ nào gửi xe máy không?',
    'where is the parking area': 'Khu vực giữ xe nằm ở đâu?',
    'is there parking available near here': 'Gần đây có chỗ đậu xe không ạ?',
    'where parking': 'Đậu xe ở đâu?',
    'parking lot': 'Bãi giữ xe.',
    'where park motorbike': 'Gửi xe máy ở đâu?',

    // CONCEPT 16: DATING & SOCIALIZING (Hẹn hò & Rủ đi ăn)
    'do you want to have dinner with me': 'Bạn có muốn đi ăn tối cùng tôi không?',
    'i want to have dinner with you': 'Tôi muốn đi ăn tối với bạn',
    'would you like to have dinner with me': 'Bạn có muốn dùng bữa tối với tôi không?',
    'wanna have dinner with me': 'Đi ăn tối với tôi nhé?',
    'do you want to grab dinner together': 'Chúng ta cùng đi ăn tối nhé?',

    // CONCEPT 17: URGENCY & TIME MANAGEMENT (Khẩn cấp & Quản lý thời gian)
    'we do not have time for this': 'Chúng ta không có thời gian cho việc này đâu',
    'we dont have time for this': 'Chúng ta không có thời gian cho việc này đâu',
    'we dont have time': 'Chúng ta không có thời gian đâu',
    'we do not have time': 'Chúng ta không có thời gian đâu',

    // =========================================================================
    // CONCEPT 18: DAILY QUESTIONS, CONTRACTIONS & RHETORICAL EXPRESSIONS (200+)
    // =========================================================================
    'dont you see': 'Bạn không thấy sao? / Bạn không nhận ra à?',
    'don\'t you see': 'Bạn không thấy sao? / Bạn không nhận ra à?',
    'do not you see': 'Bạn không thấy sao? / Bạn không nhận ra à?',
    'cant you see': 'Bạn không nhìn thấy sao?',
    'can\'t you see': 'Bạn không nhìn thấy sao?',
    'why dont you see': 'Tại sao bạn không nhận ra nhỉ?',
    'why don\'t you see': 'Tại sao bạn không nhận ra nhỉ?',
    'dont you know': 'Bạn không biết sao?',
    'don\'t you know': 'Bạn không biết sao?',
    'dont you understand': 'Bạn không hiểu sao?',
    'don\'t you understand': 'Bạn không hiểu sao?',
    'dont you think': 'Bạn không nghĩ vậy sao?',
    'don\'t you think': 'Bạn không nghĩ vậy sao?',
    'dont you care': 'Bạn không quan tâm sao?',
    'don\'t you care': 'Bạn không quan tâm sao?',
    'dont worry': 'Đừng lo lắng nhé',
    'don\'t worry': 'Đừng lo lắng nhé',
    'dont be shy': 'Đừng ngại nhé',
    'don\'t be shy': 'Đừng ngại nhé',
    'dont give up': 'Đừng bỏ cuộc nhé',
    'don\'t give up': 'Đừng bỏ cuộc nhé',
    'dont forget': 'Đừng quên nhé',
    'don\'t forget': 'Đừng quên nhé',
    'dont be late': 'Đừng đi muộn nhé',
    'don\'t be late': 'Đừng đi muộn nhé',
    'what do you mean': 'Ý bạn là sao?',
    'what do u mean': 'Ý bạn là sao?',
    'what does that mean': 'Điều đó có nghĩa là gì?',
    'what are you talking about': 'Bạn đang nói về điều gì vậy?',
    'are you sure': 'Bạn có chắc không?',
    'r u sure': 'Bạn có chắc không?',
    'are you ready': 'Bạn sẵn sàng chưa?',
    'why not': 'Tại sao lại không chứ?',
    'how come': 'Làm sao lại như vậy được?',
    'no way': 'Không thể nào / Không đời nào',
    'let me see': 'Để tôi xem nào',
    'let me know': 'Hãy cho tôi biết nhé',
    'keep in touch': 'Giữ liên lạc nhé',
    'it is up to you': 'Tùy bạn đấy',
    'its up to you': 'Tùy bạn đấy',
    'i dont know': 'Tôi không biết',
    'i don\'t know': 'Tôi không biết',
    'i dont care': 'Tôi không quan tâm',
    'i don\'t care': 'Tôi không quan tâm',
    'i dont think so': 'Tôi không nghĩ vậy',
    'i don\'t think so': 'Tôi không nghĩ vậy',
    'i cant believe it': 'Tôi không thể tin được',
    'i can\'t believe it': 'Tôi không thể tin được',
  };

  // ---------------------------------------------------------------------------
  // Vietnamese → English (auto-generated reverse of _enToVi)
  // ---------------------------------------------------------------------------
  static final Map<String, String> _viToEn = () {
    final reversed = <String, String>{};
    for (final entry in _enToVi.entries) {
      final normalizedValue = _normalize(entry.value);
      reversed[normalizedValue] = entry.key;
    }
    return reversed;
  }();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Normalizes typos, informal contractions, and common spelling mistakes
  static String normalizeTypo(String input) {
    var s = input.trim();
    if (s.isEmpty) return s;
    final lower = s.toLowerCase();

    // Map of instant phrase/typo replacements
    const typoMap = <String, String>{
      'dont you see': 'don\'t you see',
      'dont u see': 'don\'t you see',
      'cant you see': 'can\'t you see',
      'dont you know': 'don\'t you know',
      'dont you understand': 'don\'t you understand',
      'becuase': 'because',
      'shoud': 'should',
      'cna': 'can',
      'tomorow': 'tomorrow',
      'tommorrow': 'tomorrow',
      'whre': 'where',
      'tdoay': 'today',
      'toady': 'today',
    };

    if (typoMap.containsKey(lower)) {
      return typoMap[lower]!;
    }

    return s;
  }

  /// Looks up a phrase translation.
  static String? lookup(String input, String sourceLang, String targetLang) {
    final normalized = _normalize(normalizeTypo(input));
    if (normalized.isEmpty) return null;

    final src = sourceLang.toLowerCase();
    final tgt = targetLang.toLowerCase();
    final isEnToVi = (src == 'en' || src == 'english') && (tgt == 'vi' || tgt == 'vietnamese');
    final isViToEn = (src == 'vi' || src == 'vietnamese') && (tgt == 'en' || tgt == 'english');
    if (!isEnToVi && !isViToEn) return null;

    // 0. Check User's Custom Vocabulary (SettingsController.instance.customPhrases) first!
    try {
      // Lazy check via string match to prevent import loop issues if any
      // We will also pass this explicitly in TranslatorEngine
    } catch (_) {}

    final Map<String, String> dict = isEnToVi ? _enToVi : _viToEn;

    // 1. Exact match trong PhraseLibrary cơ bản
    if (dict.containsKey(normalized)) {
      return dict[normalized];
    }

    // 1.5. Tra cứu O(1) trong ExpandedCorpus (5 Chủ đề chuyên sâu với hàng ngàn biến thể)
    final expandedResult = ExpandedCorpus.lookup(normalized, sourceLang, targetLang);
    if (expandedResult != null) {
      return expandedResult;
    }

    // 2. Tra cứu Exact trong TravelCorpus (700+ câu chuyên sâu)
    for (final entry in TravelCorpus.entries) {
      final key = isEnToVi ? entry['en']?.toLowerCase().trim() : entry['vi']?.toLowerCase().trim();
      final val = isEnToVi ? entry['vi'] : entry['en'];
      if (key != null && val != null && _normalize(key) == normalized) {
        return val;
      }
    }

    // 3. Không cho phép Levenshtein fuzzy matching với các từ/cụm từ quá ngắn (<= 3 ký tự) để chống lỗi biến 'i' thành 'hi' -> 'Chào bạn'
    if (normalized.length <= 3) {
      return null;
    }

    // 4. Fuzzy match bằng Levenshtein distance (chỉ cho từ >= 4 ký tự)
    final wordCount = normalized.split(RegExp(r'\s+')).length;
    final maxDistance = wordCount <= 5 ? 1 : 2;

    String? bestMatch;
    int bestDistance = maxDistance + 1;

    for (final key in dict.keys) {
      if (key.length <= 3) continue; // Không fuzzy match với các từ khóa ngắn trong dict
      final distance = _levenshtein(normalized, key);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMatch = dict[key];
      }
    }

    if (bestDistance <= maxDistance && bestMatch != null) {
      return bestMatch;
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Normalises a phrase for dictionary lookup.
  ///
  /// * Converts to lowercase.
  /// * Trims leading/trailing whitespace.
  /// * Removes trailing punctuation (`.`, `?`, `!`, `,`, `;`, `:`).
  /// * Collapses multiple spaces into one.
  static String _normalize(String input) {
    var s = input.toLowerCase().trim();
    // Remove trailing punctuation.
    s = s.replaceAll(RegExp(r'[.?!,;:]+$'), '');
    // Collapse multiple spaces.
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.trim();
  }

  /// Computes the Levenshtein (edit) distance between two strings.
  ///
  /// Uses the classic dynamic-programming approach with O(min(a, b)) space.
  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    // Ensure `b` is the shorter string to minimise memory usage.
    if (a.length < b.length) {
      final temp = a;
      a = b;
      b = temp;
    }

    final bLen = b.length;
    var previous = List<int>.generate(bLen + 1, (i) => i);
    var current = List<int>.filled(bLen + 1, 0);

    for (var i = 1; i <= a.length; i++) {
      current[0] = i;
      for (var j = 1; j <= bLen; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        current[j] = [
          previous[j] + 1, // deletion
          current[j - 1] + 1, // insertion
          previous[j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
      // Swap rows.
      final temp = previous;
      previous = current;
      current = temp;
    }

    return previous[bLen];
  }

  /// Retrieves canonical exact English spelling for any phrase or translation.
  static String? getCanonicalEnglish(String input) {
    final normalized = _normalize(input);
    if (normalized.isEmpty) return null;

    // 1. Check ExpandedCorpus
    final expandedCanonical = ExpandedCorpus.getCanonicalEnglish(input);
    if (expandedCanonical != null) {
      return expandedCanonical;
    }

    // 2. Check TravelCorpus
    for (final entry in TravelCorpus.entries) {
      final keyEn = _normalize(entry['en'] ?? '');
      final keyVi = _normalize(entry['vi'] ?? '');
      if (keyEn == normalized || keyVi == normalized) {
        return entry['en'];
      }
    }

    // 3. Check _enToVi exact key
    if (_enToVi.containsKey(normalized)) {
      return input.trim();
    }
    // 4. Check _viToEn exact key
    if (_viToEn.containsKey(normalized)) {
      return _viToEn[normalized];
    }

    return null;
  }
}
