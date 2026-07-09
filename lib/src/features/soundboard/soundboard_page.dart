import 'package:flutter/material.dart';
import 'widgets/language_toggle.dart';
import 'widgets/category_filter.dart';
import 'widgets/word_card.dart';

class SoundboardPage extends StatelessWidget {
  const SoundboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEDADA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: LanguageToggle(),
              ),

              const SizedBox(height: 24),
              CategoryFilter(),

              const SizedBox(height: 24),
              Expanded(
                  child: GridView.count(
                      physics: const ClampingScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: const [
                    WordCard(
                      english: 'Hello',
                      vietnamese: 'Xin chào',
                    ),
                    WordCard(
                      english: 'Thank you',
                      vietnamese: 'Cảm ơn',
                    ),
                    WordCard(
                      english: 'Goodbye',
                      vietnamese: 'Tạm biệt',
                    ),
                    WordCard(
                      english: 'Please',
                      vietnamese: 'Làm ơn',
                    ),
                    WordCard(
                      english:"You're welcome",
                      vietnamese: 'Không sao đâu',
                    ),
                    WordCard(
                      english:"I'm sorry",
                      vietnamese: 'Tôi xin lỗi',
                    ),
                    WordCard(
                      english:'Excuse me',
                      vietnamese: 'Xin lỗi',
                    ),
                    WordCard(
                      english:'Yes',
                      vietnamese: 'Vâng',
                    ),
                    WordCard(
                      english:'No',
                      vietnamese: 'Không',
                    ),
                    WordCard(
                      english:'Me',
                      vietnamese: 'Tôi',
                    ),
                    WordCard(
                      english:'What?',
                      vietnamese: 'Cái gì?',
                    ),
                    WordCard(
                      english: 'Who?',
                      vietnamese: 'Ai?',
                    ),
                    WordCard(
                      english: 'When?',
                      vietnamese: 'Khi nào?',
                    ),
                    WordCard(
                      english: 'Where?',
                      vietnamese: 'Ở đâu?',
                    ),
                    WordCard(
                      english: 'Why?',
                      vietnamese: 'Tại sao?',
                    ),
                    WordCard(
                      english: 'How?',
                      vietnamese: 'Như thế nào?',
                    ),
                    WordCard(
                      english: 'Very good',
                      vietnamese: 'Rất tốt',
                    ),
                    WordCard(
                      english: '0',
                      vietnamese: 'Không',
                    ),
                    WordCard(
                      english: '1',
                      vietnamese: 'Một',
                    ),
                    WordCard(
                      english: '2',
                      vietnamese: 'Hai',
                    ),
                    WordCard(
                      english: '3',
                      vietnamese: 'Ba',
                    ),
                    WordCard(
                      english: '4',
                      vietnamese: 'Bốn',
                    ),
                    WordCard(
                      english: '5',
                      vietnamese: 'Năm',
                    ),
                    WordCard(
                      english: '6',
                      vietnamese: 'Sáu',
                    ),
                    WordCard(
                      english: '7',
                      vietnamese: 'Bảy',
                    ),
                    WordCard(
                      english: '8',
                      vietnamese: 'Tám',
                    ),
                    WordCard(
                      english: '9',
                      vietnamese: 'Chín',
                    ),
                    WordCard(
                      english: '10',
                      vietnamese: 'Mười',
                    ),
                    WordCard(
                      english: '100',
                      vietnamese: 'Trăm',
                    ),
                    WordCard(
                      english: '1,000',
                      vietnamese: 'Ngàn',
                    ),
                    WordCard(
                      english: '10,000',
                      vietnamese: 'Mười ngàn',
                    ),
                    WordCard(
                      english: '100,000',
                      vietnamese: 'Một trăm ngàn',
                    ),
                    WordCard(
                      english: '1,000,000',
                      vietnamese: 'Triệu',
                    ),
                  ]))
            ],
          ),
        ),
      ),
    );
  }
}
