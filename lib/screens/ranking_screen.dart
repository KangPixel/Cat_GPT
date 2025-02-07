import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RankingScreen extends StatelessWidget {
  final List<Map<String, dynamic>> raceResults;
  final bool isPlayerWinner;

  const RankingScreen({
    Key? key,
    required this.raceResults,
    required this.isPlayerWinner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏁 경주 결과 🏁')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isPlayerWinner) // ✅ Player가 1위면 불꽃 애니메이션
              Column(
                children: [
                  Lottie.asset(
                    'assets/fireworks.json', // 🎆 불꽃 애니메이션
                    width: 200,
                    height: 200,
                    repeat: true, // 🔥 무한 반복
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '🎉 축하합니다! 🎉\nPlayer 고양이가 우승했습니다!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            else // ❌ 1등 못했을 때 위로 애니메이션 + 메시지
              Column(
                children: [
                  Lottie.asset(
                    'assets/cheer.json', // 😢 위로하는 애니메이션
                    width: 200,
                    height: 200,
                    repeat: true, // 🔄 무한 반복
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '아쉽지만 다음에 한번 더! 🐱',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            const Text(
              '🏆 최종 순위 🏆',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...raceResults.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> result = entry.value;
              return Text(
                '${index + 1}위: ${result['name']}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: result['name'] == 'Player' ? Colors.red : Colors.black,
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
