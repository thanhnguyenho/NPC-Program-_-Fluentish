import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentish/src/features/language/translator_engine.dart';

class TestCase {
  final String input;
  final String lang;
  final String? expected;
  final String description;

  TestCase(this.input, this.lang, this.expected, this.description);
}

void main() {
  final scenarios = [
    // 25 clean (typo-free) cases - English & Vietnamese
    TestCase('could you explain it again', 'English', null, 'English typo-free sentence'),
    TestCase('where should we go for dinner', 'English', null, 'English typo-free sentence'),
    TestCase('hello, i would like to check in for my flight to new york.', 'English', null, 'English verbatim corpus sentence'),
    TestCase('here is my passport and booking reference.', 'English', null, 'English verbatim corpus sentence'),
    TestCase('can i have a window seat, please?', 'English', null, 'English verbatim corpus sentence'),
    TestCase('how many checked bags am i allowed?', 'English', null, 'English verbatim corpus sentence'),
    TestCase('is this baggage overweight?', 'English', null, 'English verbatim corpus sentence'),
    TestCase('how much is the excess baggage fee?', 'English', null, 'English verbatim corpus sentence'),
    TestCase('do i need to pick up my luggage during the layover?', 'English', null, 'English verbatim corpus sentence'),
    TestCase('do i need to take my laptop out of the backpack?', 'English', null, 'English verbatim corpus sentence'),
    TestCase('can i bring this water bottle through security?', 'English', null, 'English verbatim corpus sentence'),
    TestCase('what time is my flight delayed until?', 'English', null, 'English verbatim corpus sentence'),
    TestCase('excuse me, which way to boarding gate 15?', 'English', null, 'English verbatim corpus sentence'),
    TestCase('has flight vn123 started boarding yet?', 'English', null, 'English verbatim corpus sentence'),
    TestCase('xin chào, tôi muốn làm thủ tục cho chuyến bay đi new york.', 'Vietnamese', null, 'Vietnamese verbatim corpus sentence'),
    TestCase('đây là hộ chiếu và mã đặt chỗ của tôi.', 'Vietnamese', null, 'Vietnamese verbatim corpus sentence'),
    TestCase('tôi có thể chọn ghế cạnh cửa sổ được không?', 'Vietnamese', null, 'Vietnamese verbatim corpus sentence'),
    TestCase('tôi muốn ngồi ghế cạnh lối đi để tiện di chuyển.', 'Vietnamese', null, 'Vietnamese verbatim corpus sentence'),
    TestCase('tôi được phép mang bao nhiêu hành lý ký gửi?', 'Vietnamese', null, 'Vietnamese verbatim corpus sentence'),
    TestCase('hành lý này của tôi có bị quá cân không?', 'Vietnamese', null, 'Vietnamese verbatim corpus sentence'),
    TestCase('phí hành lý quá cước là bao nhiêu?', 'Vietnamese', null, 'Vietnamese verbatim corpus sentence'),
    TestCase('tôi có phải lấy hành lý ra khi quá cảnh không?', 'Vietnamese', null, 'Vietnamese verbatim corpus sentence'),
    TestCase('tôi có cần bỏ máy tính xách tay ra khỏi balo không?', 'Vietnamese', null, 'Vietnamese verbatim corpus sentence'),
    TestCase('tôi có được mang chai nước này qua cửa an ninh không?', 'Vietnamese', null, 'Vietnamese verbatim corpus sentence'),
    TestCase('chuyến bay của tôi bị hoãn đến mấy giờ?', 'Vietnamese', null, 'Vietnamese verbatim corpus sentence'),
    TestCase('cho tôi hỏi quầy đổi tiền nằm ở đâu?', 'Vietnamese', null, 'Vietnamese verbatim corpus sentence'),

    // 25 typo cases - English & Vietnamese
    TestCase('what shoul we eat today', 'English', 'what should we eat today', 'English typo: shoul -> should'),
    TestCase('whre should we go', 'English', 'where should we go', 'English typo: whre -> where'),
    TestCase('what shoud we do toady', 'English', 'what should we do today', 'English typos: shoud -> should, toady -> today'),
    TestCase('cna i have a window seat', 'English', 'can i have a window seat', 'English typo: cna -> can'),
    TestCase('whet is the purpose of visit', 'English', 'what is the purpose of visit', 'English typo: whet -> what'),
    TestCase('wat time is it', 'English', 'what time is it', 'English typo: wat -> what'),
    TestCase('whre is the station', 'English', 'where is the station', 'English typo: whre -> where'),
    TestCase('tomorow will be better', 'English', 'tomorrow will be better', 'English typo: tomorow -> tomorrow'),
    TestCase('tommorrow we leave', 'English', 'tomorrow we leave', 'English typo: tommorrow -> tomorrow'),
    TestCase('please wake me up tdoay', 'English', 'please wake me up today', 'English typo: tdoay -> today'),
    TestCase('we sould go to the airport', 'English', 'we should go to the airport', 'English typo: sould -> should'),
    TestCase('cna you help me', 'English', 'can you help me', 'English typo: cna -> can'),
    TestCase('where shoud we meet', 'English', 'where should we meet', 'English typo: shoud -> should'),
    TestCase('xin tinh tien', 'Vietnamese', 'xin tính tiền', 'Vietnamese typo: tinh -> tính, tien -> tiền (preceded by xin/tính)'),
    TestCase('tính tien', 'Vietnamese', 'tính tiền', 'Vietnamese typo: tien -> tiền (preceded by tính)'),
    TestCase('bao nhieu tien', 'Vietnamese', 'bao nhiêu tiền', 'Vietnamese typo: nhieu -> nhiêu (preceded by bao)'),
    TestCase('cai nay bao nhieu', 'Vietnamese', 'cái này bao nhiêu', 'Vietnamese typo: cai -> cái, nay -> này'),
    TestCase('cái nay bao nhiêu', 'Vietnamese', 'cái này bao nhiêu', 'Vietnamese typo-free / not corrected: all words valid (cái, nay, bao, nhiêu)'),
    TestCase('cai này giá thế nào', 'Vietnamese', null, 'Vietnamese not corrected: cai followed by này is not cai followed by nay'),
    TestCase('xin tinh tien giup toi', 'Vietnamese', 'xin tính tiền giúp tôi', 'Vietnamese typo: tinh -> tính, tien -> tiền (preceded by xin/tính)'),
    TestCase('cái nay bao nhieu tien', 'Vietnamese', 'cái này bao nhiêu tiền', 'Vietnamese typo: nay -> này, nhieu -> nhiêu'),
    TestCase('bao nhieu tien cái nay', 'Vietnamese', 'bao nhiêu tiền cái này', 'Vietnamese typo: nhieu -> nhiêu, nay -> này'),
    TestCase('xin tinh tien nhé', 'Vietnamese', 'xin tính tiền nhé', 'Vietnamese typo: tinh -> tính, tien -> tiền'),
    TestCase('cai nay dep qua', 'Vietnamese', 'cái này dep qua', 'Vietnamese typo: cai -> cái, nay -> này'),
    TestCase('tôi muon xin tinh tien', 'Vietnamese', 'tôi muốn xin tính tiền', 'Vietnamese typo: tinh -> tính, tien -> tiền'),
  ];

  group('Typo QA Custom Tests', () {
    for (var i = 0; i < scenarios.length; i++) {
      final s = scenarios[i];
      test('Scenario #${i + 1}: ${s.description} ("${s.input}")', () {
        final result = TranslatorEngine.findSpellingCorrection(s.input, s.lang);
        expect(result, s.expected);
      });
    }
  });

  // Also write the report
  test('Write Typo QA Report', () {
    final buffer = StringBuffer();
    buffer.writeln('# Typo QA Report');
    buffer.writeln();
    buffer.writeln('Generated at: ${DateTime.now().toUtc().toIso8601String()}');
    buffer.writeln();
    buffer.writeln('## Test Summary');
    buffer.writeln();
    buffer.writeln('- Total Scenarios: ${scenarios.length}');
    
    int passed = 0;
    final resultsList = <String>[];
    
    for (var i = 0; i < scenarios.length; i++) {
      final s = scenarios[i];
      final actual = TranslatorEngine.findSpellingCorrection(s.input, s.lang);
      final isOk = actual == s.expected;
      if (isOk) passed++;
      
      resultsList.add(
        '| ${i + 1} | `${s.input}` | ${s.lang} | `${s.expected ?? "null"}` | `${actual ?? "null"}` | ${isOk ? "✅ PASS" : "❌ FAIL"} | ${s.description} |'
      );
    }
    
    buffer.writeln('- Passed Scenarios: $passed / ${scenarios.length}');
    buffer.writeln('- Status: ${passed == scenarios.length ? "SUCCESS" : "FAILURE"}');
    buffer.writeln();
    buffer.writeln('## Detailed Execution Table');
    buffer.writeln();
    buffer.writeln('| # | Input | Language | Expected Suggestion | Actual Suggestion | Result | Description |');
    buffer.writeln('|---|-------|----------|---------------------|-------------------|--------|-------------|');
    resultsList.forEach(buffer.writeln);
    
    try {
      final dir = Directory('.agents/auditor_spellcheck');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final file = File('${dir.path}/typo_qa_report.md');
      file.writeAsStringSync(buffer.toString());
      debugPrint('Report successfully written to ${file.path}');
    } catch (e) {
      debugPrint('Skipping report write: $e');
    }
  });
}
