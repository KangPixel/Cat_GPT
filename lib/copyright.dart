// copyright.dart
import 'package:flutter/material.dart';

class CopyrightPage extends StatelessWidget {
  const CopyrightPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '저작권 정보',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.cyan[50],
      ),
      body: Container(
        color: Colors.cyan[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCopyrightSection(
                '이미지 자료',
                [
                  '고양이 픽셀 아트: [출처 URL]',
                  '음식 아이콘: [출처 URL]',
                  '수면 아이콘: [출처 URL]',
                  '놀이 아이콘: [출처 URL]',
                  '말풍선 아이콘: [출처 URL]',
                ],
              ),
              const SizedBox(height: 20),
              _buildCopyrightSection(
                '사용된 라이브러리',
                [
                  'Flutter: https://flutter.dev',
                  'Flame: https://flame-engine.org',
                  'shared_preferences: https://pub.dev/packages/shared_preferences',
                ],
              ),
              const SizedBox(height: 20),
              _buildCopyrightSection(
                '폰트',
                [
                  '메인 폰트: [폰트 이름 및 출처]',
                ],
              ),
              const SizedBox(height: 20),
              _buildCopyrightSection(
                '기타 자료',
                [
                  '게임 효과음: [출처]',
                  '배경 음악: [출처]',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCopyrightSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 187, 210),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Colors.black,
              width: 1.5,
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
          child: Text(
            '• $item',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        )).toList(),
      ],
    );
  }
}