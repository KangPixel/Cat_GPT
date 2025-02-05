//packages/ski_master/lib/game/routes/level_complete.dart
import 'package:flutter/material.dart';

class LevelComplete extends StatelessWidget {
  const LevelComplete({
    required this.nStars,
    required this.currentLevel,
    required this.currentScore, // 추가: 현재 점수
    required this.clearCount, // 추가: 클리어 횟수
    super.key,
    this.onNextPressed,
    this.onRetryPressed,
    this.onSettlePressed, // 추가: 정산 버튼 콜백
  });

  static const id = 'LevelComplete';
  static const maxLevels = 3;

  final int nStars;
  final int currentLevel;
  final int currentScore;
  final int clearCount;
  final VoidCallback? onNextPressed;
  final VoidCallback? onRetryPressed;
  final VoidCallback? onSettlePressed;

  @override
  Widget build(BuildContext context) {
    final bool showNextButton = nStars != 0 && currentLevel < maxLevels;

    return Scaffold(
      backgroundColor: const Color.fromARGB(210, 229, 238, 238),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Level Completed',
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  nStars >= 1 ? Icons.star : Icons.star_border,
                  color: nStars >= 1 ? Colors.amber : Colors.black,
                  size: 50,
                ),
                Icon(
                  nStars >= 2 ? Icons.star : Icons.star_border,
                  color: nStars >= 2 ? Colors.amber : Colors.black,
                  size: 50,
                ),
                Icon(
                  nStars >= 3 ? Icons.star : Icons.star_border,
                  color: nStars >= 3 ? Colors.amber : Colors.black,
                  size: 50,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'Score: $currentScore',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 15),
            if (showNextButton)
              SizedBox(
                width: 150,
                child: OutlinedButton(
                  onPressed: onNextPressed,
                  child: const Text('Next Level'),
                ),
              ),
            const SizedBox(height: 5),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: onRetryPressed,
                child: Text('Retry (피로도 +${clearCount * 5})'),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.2),
                ),
                onPressed: onSettlePressed,
                child: const Text('정산하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
