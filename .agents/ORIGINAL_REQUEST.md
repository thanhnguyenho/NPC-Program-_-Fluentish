# Original User Request

## Initial Request — 2026-07-16T09:19:30Z

# Teamwork Project Prompt — Draft

> Status: Launched — Delegated to teamwork_preview multi-agent system
> Goal: Craft prompt → get user approval → delegate to teamwork_preview

Xây dựng hệ thống rà soát, kiểm định chéo và khắc phục triệt để lỗi dịch thuật trong `TranslatorEngine` (`translator_engine.dart` và `travel_corpus.dart`) với tiêu chuẩn của một ứng dụng dịch thuật chuyên nghiệp hàng đầu. Bắt buộc quét qua tất cả mọi câu, từ điển và pattern ít nhất 3 vòng độc lập bởi 4 Agent chuyên biệt khác nhau.

Working directory: /Users/minhdong/development/fluentish
Integrity mode: development

## Requirements

### R1. Khắc phục trúng đích 5 lỗi nghiêm trọng từ ảnh chụp màn hình thực tế (Root-Cause Bug Fixing)
- **Lỗi 1 (Gợi ý sai của Spell-Check)**: `could you explain it again` bị gợi ý thành `can you explain it again`. Yêu cầu sửa `findSpellingCorrection` để KHÔNG BAO GIỜ gợi ý sửa chính tả khi các từ trong câu gõ vào đều đã là từ hợp lệ (valid English/Vietnamese words) hoặc câu không có lỗi đánh máy (typo).
- **Lỗi 2 (Lặp từ `Bạn có thể bạn có thể... được không? được không?`)**: Xử lý triệt để đệ quy trong các mẫu câu prefix (`can you...`, `could you...`, `where is...`). Khi `translateSync(..., isSubclause: true)` được gọi bên trong một prefix pattern, kết quả trả về không được phép lặp lại các từ dẫn/dấu hỏi đã có (`bạn có thể`, `làm ơn`, `được không?`, `ở đâu?`).
- **Lỗi 3 & 4 (Viết hoa vô lý giữa câu & Tùy chọn gạch chéo thô thiển)**: `can you tell me about the plan` -> `Bạn có thể Bảo Tôi about the plan?` và `can you tell` -> `Bạn có thể Bảo / Kể?`. Tất cả từ vựng/cụm từ khi dịch ở chế độ `isSubclause: true` bắt buộc viết thường (trừ danh từ riêng như `Vietnam`, `Hanoi`) và bắt buộc chọn 1 từ tự nhiên nhất (không trả về kiểu gạch chéo `/` giữa câu hoặc bỏ sót từ tiếng Anh chưa dịch).
- **Lỗi 5 (Cụm từ ngớ ngẩn `ở đâu?nằm ở đâu`)**: Loại bỏ hoàn toàn các lỗi nối chuỗi thô, lặp dấu hỏi (`??`), lặp từ nghi vấn (`ở đâu? nằm ở đâu`, `nằm ở đâu? ở đâu?`) trong toàn bộ từ điển và pattern.

### R2. Tổ chức 4 Agents rà soát độc lập tối thiểu 3 vòng (Exhaustive 4-Agent / 3-Pass Audit)
- **Agent 1 (Corpus & Dictionary Auditor)**: Quét toàn bộ 253 câu trong `travel_corpus.dart` và hàng trăm từ trong `_dictionary`. Kiểm tra từng chữ cả 2 chiều Anh <-> Việt để loại bỏ từ dịch thô, cách diễn đạt gượng gạo hoặc sai ngữ cảnh du lịch.
- **Agent 2 (Live Streaming & Pattern Specialists)**: Kiểm tra toàn bộ logic gõ tuần tự (`_translateToVietnamesePatterns`, `_translateToEnglishPatterns`). Đảm bảo khi gõ từng chữ từ đầu đến cuối câu (progressive prefix typing), câu dịch luôn mượt mà, đúng ngữ pháp, không bị nhảy từ hay gãy cấu trúc.
- **Agent 3 (Spell-Correction & Typo QA)**: Thử nghiệm ít nhất 50 kịch bản gõ đúng và gõ sai (typo) cả tiếng Anh lẫn tiếng Việt. Đảm bảo từ gõ sai thật sự (`shoul`, `whre`, `tomorow`, `xin tinh tien`) được tự động gợi ý sửa chuẩn xác, còn câu gõ đúng (`could you explain it again`) tuyệt đối không bị báo lỗi.
- **Agent 4 (Chief Quality Judge - Người duyệt cuối cùng)**: Đóng vai trò tổng biên tập khó tính, xét duyệt chéo kết quả của 3 Agent trên qua 3 vòng lặp chỉnh sửa. Chỉ nghiệm thu khi 100% câu chữ đạt độ tự nhiên bản địa tuyệt đối và vượt qua mọi test case tự động.

## Acceptance Criteria

### Automated Verification Criteria
- [ ] Bổ sung và chạy thành công test case tái hiện chính xác 5 lỗi chụp màn hình trong `test/translator_engine_comprehensive_test.dart` (`could you explain it again` không gợi ý sửa; dịch ra `Bạn có thể giải thích lại được không?` không lặp từ; `can you tell me about the plan` dịch mượt mà không viết hoa giữa câu; `can you tell` dịch tự nhiên không có dấu `/`).
- [ ] Chạy thành công bộ kiểm thử toàn diện `flutter test test/translator_engine_comprehensive_test.dart test/audit_entire_corpus_test.dart` với 100% Passed (quét qua >5,600 tiền tố progressive và 253 câu trọn vẹn).
- [ ] Không có bất kỳ câu nào trong `TravelCorpus` hoặc output của `translateSync` chứa chuỗi lặp `??`, `ở đâu?nằm ở đâu`, `Bạn có thể Bạn có thể`, hoặc từ tiếng Anh bị bỏ sót giữa câu tiếng Việt.
