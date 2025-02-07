import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:just_audio/just_audio.dart';

class RankingScreen extends StatefulWidget {
  final List<Map<String, dynamic>> raceResults;
  final bool isPlayerWinner;

  const RankingScreen({
    Key? key,
    required this.raceResults,
    required this.isPlayerWinner,
  }) : super(key: key);

  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playSound(widget.isPlayerWinner ? 'assets/fireworks.wav' : 'assets/clap.ogg');
  }

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.setAsset(soundPath); // 🔹 just_audio 방식으로 파일 설정
      await _audioPlayer.play(); // 🔊 재생
    } catch (e) {
      debugPrint("❌ Error playing sound: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏁 경주 결과 🏁')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.isPlayerWinner)
              Column(
                children: [
                  Lottie.asset(
                    'assets/fireworks.json',
                    width: 200,
                    height: 200,
                    repeat: true,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '🎉 축하합니다! 🎉\nPlayer 고양이가 우승했습니다!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Lottie.asset(
                    'assets/cheer.json',
                    width: 200,
                    height: 200,
                    repeat: true,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '아쉽지만 다음에 한번 더! 🐱',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
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
            ...widget.raceResults.asMap().entries.map((entry) {
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
