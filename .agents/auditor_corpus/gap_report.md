# Gap Audit Report: Travel Corpus & Vocabulary Dictionary

## Executive Summary
This report presents the findings of a comprehensive audit of the travel corpus (`travel_corpus.dart`) containing **253 entries** and the vocabulary dictionary (`_dictionary` in `translator_engine.dart`) containing **925 entries** for the Fluentish app. The audit identified **0 double question marks**, **2 slashes (multiple choices) in the travel corpus**, **207 slashes in the dictionary**, **34 duplicate dictionary keys**, and **12 critical phrasing or contextual issues** (such as medical hallucinations and homophone conflicts).

---

## 1. Clean Translation Rule Violations

### 1.1. Double Question Marks
* **Travel Corpus**: 0 found.
* **Dictionary**: 0 found.

### 1.2. Multiple Choices with Slashes
Slashes (`/`) indicate multiple choices, which leads to awkward UI rendering or unpolished translation outputs if not parsed.

#### A. Travel Corpus (2 items)
These entries present multiple options inside a single sentence, forcing the user to see or speak slashes.
1. **Index 81 (Line 411)**:
   * **Vietnamese**: `Tôi muốn mua một vé một chiều/khứ hồi.`
   * **English**: `I would like to buy a one-way/round-trip ticket.`
   * *Problem*: Users cannot speak/learn "một chiều/khứ hồi" in one sentence. These should be split into two separate entries.
2. **Index 98 (Line 498)**:
   * **Vietnamese**: `Cửa hàng tiện lợi gần nhất có mở cửa 24/24 không?`
   * **English**: `Is the nearest convenience store open 24/7?`
   * *Problem*: Contains slashes (`24/24` and `24/7`). Although standard terms, they trigger slash-matching logic.

#### B. Dictionary (207 items)
There are 207 keys/values containing slashes, representing synonyms, regional options, or multiple choices.
Examples of problematic dictionary entries:
* `'how are you'`: `'Bạn có khỏe không? / Dạo này bạn thế nào?'`
* `'cheers'`: `'Chúc mừng / Một hai ba dô!'`
* `'noodles'`: `'Mỳ / Phở'` (Different dishes combined under one term)
* `'expensive'`: `'Đắt / Mắc'` (Regional terms)
* `'too expensive'`: `'Quá đắt / Quá mắc'`
* `'air conditioner'`: `'Máy lạnh / Điều hòa'`
* `'cửa'`: `'Door / Window'` (Combines two distinct nouns; very confusing)
* `'đường'`: `'Street / Road / Sugar'` (Severe context collision—translating "đường" in food could output "street" or "road")
* `'năm'`: `'Year / Five'` (Homophone conflict: number vs. calendar unit)
* `'fresh'`: `'Tươi sống / Trong lành'` (Context collision: "tươi sống" is for raw food/seafood, "trong lành" is for clean air)
* `'change'`: `'Tiền lẻ / Tiền thừa'` (Different meanings: change from transaction vs. small bills)
* `'temple'`: `'Đền / Miếu'` (Different religious structures)

---

## 2. Duplicate Keys in Vocabulary Dictionary (34 items)
These keys appear multiple times in the `_dictionary` map, which leads to redundancy and overriding behavior in Dart's Map initialization.

| Duplicate Key | Line Numbers (Original / Duplicate) | Conflict / Translation Difference |
|---|---|---|
| `'phở bò'` | Line 275 / Line 773 | `Beef Pho noodle soup` vs. `Beef noodle soup` |
| `'cà phê sữa đá'` | Line 246 / Line 778 | `Vietnamese iced milk coffee` vs. `Iced milk coffee` |
| `'air conditioner'` | Line 356 / Line 862 | Both translate to `Máy lạnh / Điều hòa` |
| `'máy lạnh'` | Line 357 / Line 863 | Both translate to `Air conditioner` |
| `'towel'` | Line 359 / Line 867 | Both translate to `Khăn tắm` |
| `'discount'` | Line 323 / Line 893 | `Có giảm giá không?` (question) vs. `Giảm giá` (noun) |
| `'giảm giá'` | Line 540 / Line 894 | `Discount / Sale` vs. `Discount / Sale` |
| `'credit card'` | Line 330 / Line 897 | Both translate to `Thẻ tín dụng` |
| `'thẻ tín dụng'` | Line 331 / Line 898 | Both translate to `Credit card` |
| `'cash'` | Line 328 / Line 899 | Both translate to `Tiền mặt` |
| `'tiền mặt'` | Line 329 / Line 900 | Both translate to `Cash` |
| `'change'` | Line 671 / Line 901 | `Thay đổi / Đổi tiền` vs. `Tiền lẻ / Tiền thừa` |
| `'bus stop'` | Line 183 / Line 916 | Both translate to `Trạm xe buýt` |
| `'trạm xe buýt'` | Line 184 / Line 917 | Both translate to `Bus stop` |
| `'train station'` | Line 187 / Line 918 | `Ga tàu` vs. `Ga xe lửa / Ga tàu` |
| `'convenience store'` | Line 129 / Line 927 | Both translate to `Cửa hàng tiện lợi` |
| `'cửa hàng tiện lợi'` | Line 130 / Line 928 | Both translate to `Convenience store` |
| `'police station'` | Line 139 / Line 929 | Both translate to `Đồn cảnh sát` |
| `'đồn cảnh sát'` | Line 140 / Line 930 | Both translate to `Police station` |
| `'embassy'` | Line 135 / Line 931 | Both translate to `Đại sứ quán` |
| `'đại sứ quán'` | Line 137 / Line 932 | Both translate to `Embassy` |
| `'museum'` | Line 143 / Line 933 | Both translate to `Bảo tàng` |
| `'bảo tàng'` | Line 144 / Line 934 | Both translate to `Museum` |
| `'temple'` | Line 149 / Line 937 | `Chùa` vs. `Đền / Miếu` |
| `'pagoda'` | Line 150 / Line 939 | Both translate to `Chùa` |
| `'chùa'` | Line 151 / Line 940 | `Temple / Pagoda` vs. `Pagoda` |
| `'night market'` | Line 160 / Line 941 | Both translate to `Chợ đêm` |
| `'chợ đêm'` | Line 162 / Line 942 | Both translate to `Night market` |
| `'spicy'` | Line 304 / Line 945 | Both translate to `Cay` |
| `'cay'` | Line 305 / Line 946 | Both translate to `Spicy` |
| `'delicious'` | Line 257 / Line 955 | `Ngon` vs. `Ngon / Tuyệt vời` |
| `'ngon'` | Line 261 / Line 956 | `Delicious / Tasty` vs. `Delicious / Tasty` |
| `'recommend'` | Line 541 / Line 965 | `Giới thiệu / Gợi ý` vs. `Gợi ý / Giới thiệu` |
| `'order'` | Line 535 / Line 969 | `Gọi món / Đặt` vs. `Đặt món / Gọi món` |

---

## 3. Phrasing, Grammatical, and Contextual Issues

### 3.1. Travel Corpus Issues (12 Items)

1. **Sentence Index 783-784 (Line 783)**:
   * **Vietnamese**: `Tôi bị đau bụng khan và sốt nhẹ từ chiều hôm qua.`
   * **English**: `I have had a stomach ache and a mild fever since yesterday afternoon.`
   * *Problem*: **Medical Hallucination**. "đau bụng khan" (dry stomach ache) is a non-existent medical term in Vietnamese. This is likely a hallucination mixing up "ho khan" (dry cough) with "đau bụng".
   * *Proposed Fix*: `Tôi bị đau bụng và sốt nhẹ từ chiều hôm qua.`

2. **Sentence Index 1207-1208 (Line 1207)**:
   * **Vietnamese**: `Tôi bị đau bụng gay gắt từ tối qua, có lẽ tôi đã ăn phải đồ không hợp vệ sinh.`
   * **English**: `I have had severe stomach pain since last night, maybe I ate something unhygienic.`
   * *Problem*: **Awkward Phrasing**. "đau bụng gay gắt" is extremely awkward in Vietnamese. "Gay gắt" is reserved for weather (nắng gay gắt) or voice/arguments. The correct medical term is "đau bụng dữ dội".
   * *Proposed Fix*: `Tôi bị đau bụng dữ dội từ tối qua, có lẽ tôi đã ăn phải đồ không hợp vệ sinh.`

3. **Sentence Index 1028-1029 (Line 1028)**:
   * **Vietnamese**: `Tôi muốn thuê một chiếc xe máy số tay trong ba ngày, thủ tục cần những gì?'`
   * **English**: `I want to rent a manual motorbike for three days, what procedures are required?`
   * *Problem*: **Awkward/Literal Translation**. "xe máy số tay" is not used in Vietnamese. Vehicles with gears are called "xe số" or "xe côn tay" (clutch motorbike).
   * *Proposed Fix*: `Tôi muốn thuê một chiếc xe số trong ba ngày, thủ tục cần những gì?` or `...thuê một chiếc xe côn tay...`

4. **Sentence Index 1283-1284 (Line 1283)**:
   * **Vietnamese**: `Tôi bị để quên chiếc ô ở sảnh chờ lúc nãy, không biết có ai nhặt được không?`
   * **English**: `I left my umbrella in the lobby earlier, has anyone turned it in?`
   * *Problem*: **Grammatical Issue**. "Tôi bị để quên" uses passive "bị" on an active verb of forgetting "để quên", making it sound like someone forced the user to forget the umbrella.
   * *Proposed Fix*: `Tôi để quên chiếc ô ở sảnh chờ lúc nãy, không biết có ai nhặt được không?`

5. **Sentence Index 589-590 (Line 589)**:
   * **Vietnamese**: `Xin làm ơn không cho bột ngọt hay đậu phộng vào món ăn của tôi.`
   * **English**: `Please do not put MSG or peanuts in my dish.`
   * *Problem*: **Redundancy**. "Xin làm ơn" is a redundant polite marker combining "Xin" and "Làm ơn".
   * *Proposed Fix*: `Vui lòng không cho bột ngọt hay đậu phộng vào món ăn của tôi.`

6. **Sentence Index 931-932 (Line 931)**:
   * **Vietnamese**: `Hệ thống nước nóng trong phòng tắm hình như đang bị trục trặc.`
   * **English**: `The hot water system in the bathroom seems to be malfunctioning.`
   * *Problem*: **Overly Technical Context**. "Hệ thống nước nóng" (hot water system) is too engineering-focused. Hotel guests usually complain about the "nước nóng" (hot water) or "vòi nước nóng" (hot water tap/shower) itself.
   * *Proposed Fix*: `Nước nóng trong phòng tắm hình như bị hỏng.` or `Vòi nước nóng trong phòng tắm hình như bị trục trặc.`

7. **Sentence Index 604-605 (Line 604)**:
   * **Vietnamese**: `Cho tôi xin thêm đá và khăn lạnh nhé.`
   * **English**: `Please give me some extra ice and wet tissues.`
   * *Problem*: **Literal English**. "wet tissues" is a literal translation of "khăn lạnh". "Wet wipes" or "wet towels" is more natural for restaurant dining.
   * *Proposed Fix*: `Please give me some extra ice and wet wipes.`

8. **Sentence Index 473-474 (Line 473)**:
   * **Vietnamese**: `Khoảng cách từ đây đến đó mất bao nhiêu phút đi bộ?`
   * **English**: `How many minutes walk is it from here to there?`
   * *Problem*: **Awkward English**. "How many minutes walk is it..." is slightly awkward.
   * *Proposed Fix**: `How many minutes does it take to walk from here to there?` or `How long is the walk from here to there?`

9. **Sentence Index 159-160 (Line 159)**:
   * **Vietnamese**: `Tôi đã đặt phòng trước dưới tên Nguyễn.`
   * **English**: `I have a reservation under the name Nguyen.`
   * *Problem*: **Literal Phrasing**. "dưới tên Nguyễn" is a literal translation of "under the name". A more natural Vietnamese expression is "cho tôi hỏi, tôi có đặt phòng dưới tên Nguyễn" or "Tôi đã đặt phòng tên là Nguyễn."
   * *Proposed Fix*: `Tôi đã đặt phòng tên là Nguyễn.`

10. **Sentence Index 1227-1228 (Line 1227)**:
    * **Vietnamese**: `Đây là số điện thoại của người thân liên hệ khẩn cấp của tôi trong trường hợp cần thiết.`
    * **English**: `This is the phone number of my emergency contact relative in case of necessity.`
    * *Problem*: **Wordy/Awkward English**. "in case of necessity" is very literal. It should be "in case of emergency".
    * *Proposed Fix*: `This is my emergency contact number relative in case of emergency.` or `This is the phone number of my emergency contact.`

11. **Sentence Index 1232-1233 (Line 1232)**:
    * **Vietnamese**: `Tôi bị dị ứng thời tiết nổi mẩn ngứa khắp tay, bạn có loại kem bôi ngoài da nào tốt không?`
    * **English**: `I have a weather allergy with itchy rashes across my arm, do you have any good topical cream?`
    * *Problem*: **Incorrect Terminology & Mismatch**. "weather allergy" is a literal translation of "dị ứng thời tiết" (which is common in Vietnamese). In English, people usually say "seasonal allergy" or "hives from the weather". Also, "khắp tay" (plural or general arm area) is translated as singular "across my arm".
    * *Proposed Fix*: `I have seasonal allergies with itchy rashes on my arms, do you have any good topical cream?`

12. **Sentence Index 947-948 (Line 947)**:
    * **Vietnamese**: `Tôi ăn chay trường, quán có món nào hoàn toàn không dùng thịt và mỡ động vật không?`
    * **English**: `I am a strict vegetarian, does the restaurant have any dishes completely without meat and animal fat?`
    * *Problem*: **Literal/Wordy English**. "completely without meat and animal fat" is very literal.
    * *Proposed Fix*: `I am vegan, does the restaurant have any dishes with no meat or animal products?`

---

## 4. Key Recommendations & Remediation Plan

1. **Split Multi-Choice Slashes in Corpus**: Convert the single slash-containing entry for ticket booking (one-way/round-trip) into two distinct entries to maintain clean UI translations.
2. **Resolve Dictionary Overrides**: Remove the 34 duplicate keys in `_dictionary` by keeping the most accurate translation and consolidating regional/synonym variants.
3. **Handle Slashes in Dictionary Outputs**: Clean up slashes in dictionary values or ensure the translation engine always splits on `/` to choose a single clean term when outputting translations, avoiding displaying slashes in full-sentence context.
4. **Fix Medical and Awkward Phrasings**: Apply the proposed corrections for "đau bụng khan", "đau bụng gay gắt", "xe máy số tay", and "Tôi bị để quên" in `travel_corpus.dart`.
