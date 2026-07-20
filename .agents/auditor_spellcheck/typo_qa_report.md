# Typo QA Report

Generated at: 2026-07-20T13:40:00.060785Z

## Test Summary

- Total Scenarios: 51
- Passed Scenarios: 51 / 51
- Status: SUCCESS

## Detailed Execution Table

| # | Input | Language | Expected Suggestion | Actual Suggestion | Result | Description |
|---|-------|----------|---------------------|-------------------|--------|-------------|
| 1 | `could you explain it again` | English | `null` | `null` | ✅ PASS | English typo-free sentence |
| 2 | `where should we go for dinner` | English | `null` | `null` | ✅ PASS | English typo-free sentence |
| 3 | `hello, i would like to check in for my flight to new york.` | English | `null` | `null` | ✅ PASS | English verbatim corpus sentence |
| 4 | `here is my passport and booking reference.` | English | `null` | `null` | ✅ PASS | English verbatim corpus sentence |
| 5 | `can i have a window seat, please?` | English | `null` | `null` | ✅ PASS | English verbatim corpus sentence |
| 6 | `how many checked bags am i allowed?` | English | `null` | `null` | ✅ PASS | English verbatim corpus sentence |
| 7 | `is this baggage overweight?` | English | `null` | `null` | ✅ PASS | English verbatim corpus sentence |
| 8 | `how much is the excess baggage fee?` | English | `null` | `null` | ✅ PASS | English verbatim corpus sentence |
| 9 | `do i need to pick up my luggage during the layover?` | English | `null` | `null` | ✅ PASS | English verbatim corpus sentence |
| 10 | `do i need to take my laptop out of the backpack?` | English | `null` | `null` | ✅ PASS | English verbatim corpus sentence |
| 11 | `can i bring this water bottle through security?` | English | `null` | `null` | ✅ PASS | English verbatim corpus sentence |
| 12 | `what time is my flight delayed until?` | English | `null` | `null` | ✅ PASS | English verbatim corpus sentence |
| 13 | `excuse me, which way to boarding gate 15?` | English | `null` | `null` | ✅ PASS | English verbatim corpus sentence |
| 14 | `has flight vn123 started boarding yet?` | English | `null` | `null` | ✅ PASS | English verbatim corpus sentence |
| 15 | `xin chào, tôi muốn làm thủ tục cho chuyến bay đi new york.` | Vietnamese | `null` | `null` | ✅ PASS | Vietnamese verbatim corpus sentence |
| 16 | `đây là hộ chiếu và mã đặt chỗ của tôi.` | Vietnamese | `null` | `null` | ✅ PASS | Vietnamese verbatim corpus sentence |
| 17 | `tôi có thể chọn ghế cạnh cửa sổ được không?` | Vietnamese | `null` | `null` | ✅ PASS | Vietnamese verbatim corpus sentence |
| 18 | `tôi muốn ngồi ghế cạnh lối đi để tiện di chuyển.` | Vietnamese | `null` | `null` | ✅ PASS | Vietnamese verbatim corpus sentence |
| 19 | `tôi được phép mang bao nhiêu hành lý ký gửi?` | Vietnamese | `null` | `null` | ✅ PASS | Vietnamese verbatim corpus sentence |
| 20 | `hành lý này của tôi có bị quá cân không?` | Vietnamese | `null` | `null` | ✅ PASS | Vietnamese verbatim corpus sentence |
| 21 | `phí hành lý quá cước là bao nhiêu?` | Vietnamese | `null` | `null` | ✅ PASS | Vietnamese verbatim corpus sentence |
| 22 | `tôi có phải lấy hành lý ra khi quá cảnh không?` | Vietnamese | `null` | `null` | ✅ PASS | Vietnamese verbatim corpus sentence |
| 23 | `tôi có cần bỏ máy tính xách tay ra khỏi balo không?` | Vietnamese | `null` | `null` | ✅ PASS | Vietnamese verbatim corpus sentence |
| 24 | `tôi có được mang chai nước này qua cửa an ninh không?` | Vietnamese | `null` | `null` | ✅ PASS | Vietnamese verbatim corpus sentence |
| 25 | `chuyến bay của tôi bị hoãn đến mấy giờ?` | Vietnamese | `null` | `null` | ✅ PASS | Vietnamese verbatim corpus sentence |
| 26 | `cho tôi hỏi quầy đổi tiền nằm ở đâu?` | Vietnamese | `null` | `null` | ✅ PASS | Vietnamese verbatim corpus sentence |
| 27 | `what shoul we eat today` | English | `what should we eat today` | `what should we eat today` | ✅ PASS | English typo: shoul -> should |
| 28 | `whre should we go` | English | `where should we go` | `where should we go` | ✅ PASS | English typo: whre -> where |
| 29 | `what shoud we do toady` | English | `what should we do today` | `what should we do today` | ✅ PASS | English typos: shoud -> should, toady -> today |
| 30 | `cna i have a window seat` | English | `can i have a window seat` | `can i have a window seat` | ✅ PASS | English typo: cna -> can |
| 31 | `whet is the purpose of visit` | English | `what is the purpose of visit` | `what is the purpose of visit` | ✅ PASS | English typo: whet -> what |
| 32 | `wat time is it` | English | `what time is it` | `what time is it` | ✅ PASS | English typo: wat -> what |
| 33 | `whre is the station` | English | `where is the station` | `where is the station` | ✅ PASS | English typo: whre -> where |
| 34 | `tomorow will be better` | English | `tomorrow will be better` | `tomorrow will be better` | ✅ PASS | English typo: tomorow -> tomorrow |
| 35 | `tommorrow we leave` | English | `tomorrow we leave` | `tomorrow we leave` | ✅ PASS | English typo: tommorrow -> tomorrow |
| 36 | `please wake me up tdoay` | English | `please wake me up today` | `please wake me up today` | ✅ PASS | English typo: tdoay -> today |
| 37 | `we sould go to the airport` | English | `we should go to the airport` | `we should go to the airport` | ✅ PASS | English typo: sould -> should |
| 38 | `cna you help me` | English | `can you help me` | `can you help me` | ✅ PASS | English typo: cna -> can |
| 39 | `where shoud we meet` | English | `where should we meet` | `where should we meet` | ✅ PASS | English typo: shoud -> should |
| 40 | `xin tinh tien` | Vietnamese | `xin tính tiền` | `xin tính tiền` | ✅ PASS | Vietnamese typo: tinh -> tính, tien -> tiền (preceded by xin/tính) |
| 41 | `tính tien` | Vietnamese | `tính tiền` | `tính tiền` | ✅ PASS | Vietnamese typo: tien -> tiền (preceded by tính) |
| 42 | `bao nhieu tien` | Vietnamese | `bao nhiêu tiền` | `bao nhiêu tiền` | ✅ PASS | Vietnamese typo: nhieu -> nhiêu (preceded by bao) |
| 43 | `cai nay bao nhieu` | Vietnamese | `cái này bao nhiêu` | `cái này bao nhiêu` | ✅ PASS | Vietnamese typo: cai -> cái, nay -> này |
| 44 | `cái nay bao nhiêu` | Vietnamese | `cái này bao nhiêu` | `cái này bao nhiêu` | ✅ PASS | Vietnamese typo-free / not corrected: all words valid (cái, nay, bao, nhiêu) |
| 45 | `cai này giá thế nào` | Vietnamese | `null` | `null` | ✅ PASS | Vietnamese not corrected: cai followed by này is not cai followed by nay |
| 46 | `xin tinh tien giup toi` | Vietnamese | `xin tính tiền giúp tôi` | `xin tính tiền giúp tôi` | ✅ PASS | Vietnamese typo: tinh -> tính, tien -> tiền (preceded by xin/tính) |
| 47 | `cái nay bao nhieu tien` | Vietnamese | `cái này bao nhiêu tiền` | `cái này bao nhiêu tiền` | ✅ PASS | Vietnamese typo: nay -> này, nhieu -> nhiêu |
| 48 | `bao nhieu tien cái nay` | Vietnamese | `bao nhiêu tiền cái này` | `bao nhiêu tiền cái này` | ✅ PASS | Vietnamese typo: nhieu -> nhiêu, nay -> này |
| 49 | `xin tinh tien nhé` | Vietnamese | `xin tính tiền nhé` | `xin tính tiền nhé` | ✅ PASS | Vietnamese typo: tinh -> tính, tien -> tiền |
| 50 | `cai nay dep qua` | Vietnamese | `cái này dep qua` | `cái này dep qua` | ✅ PASS | Vietnamese typo: cai -> cái, nay -> này |
| 51 | `tôi muon xin tinh tien` | Vietnamese | `tôi muốn xin tính tiền` | `tôi muốn xin tính tiền` | ✅ PASS | Vietnamese typo: tinh -> tính, tien -> tiền |
