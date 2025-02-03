//lib/mini_game_manager.dart
import 'package:flutter/material.dart';
import 'status.dart';
import 'day10_stats.dart';

class MiniGameResult {
  final String gameName;
  final int totalScore; // Jump Rope에서는 "획득 점수", Blackjack에서는 "획득 돈"으로 표시
  final int fatigueIncrease;
  final int pointsEarned;
  final String? fatigueMessage; // 피로도 관련 메시지 추가

  MiniGameResult({
    required this.gameName,
    required this.totalScore,
    required this.fatigueIncrease,
    required this.pointsEarned,
    this.fatigueMessage, // 선택적 파라미터
  });
}

class MiniGameManager {
  static final MiniGameManager _instance = MiniGameManager._internal();
  factory MiniGameManager() => _instance;
  MiniGameManager._internal();

  Future<void> processGameResult(
      BuildContext context, MiniGameResult result) async {
    // 스탯 업데이트
    catStatus.updateStatus(
      fatigueDelta: result.fatigueIncrease,
      energyDelta: -result.fatigueIncrease,
    ); // 피로도만큼 에너지 감소
    day10Stats.updateStats(pointsDelta: result.pointsEarned);

    // 결과 팝업 표시
    if (context.mounted) {
      await _showResultDialog(context, result);
    }
  }

  Future<void> _showResultDialog(BuildContext context, MiniGameResult result) {
    // 게임 이름에 따라 "총 획득 돈" vs "총 획득 점수" 분기
    final labelScore = (result.gameName == 'Blackjack') ? '총 획득 돈' : '총 획득 점수';

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${result.gameName} 결과'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 여기서 분기한 labelScore 사용
                  Text('$labelScore: ${result.totalScore}'),
                  Row(
                    children: [
                      Text('피로도 증가: ${result.fatigueIncrease}'),
                      if (result.fatigueMessage != null) ...[
                        const SizedBox(width: 5),
                        Text(
                          result.fatigueMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                  Text('획득한 포인트: ${result.pointsEarned}'),

                  // 점수(포인트)로 스탯 올리는 로직은 기존과 동일
                  if (result.pointsEarned > 0) ...[
                    const SizedBox(height: 20),
                    const Text('포인트로 스탯 올리기 (10포인트당 1스탯)'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatButton(
                          context,
                          '스피드',
                          () {
                            setState(() {
                              if (day10Stats.points.value >= 10 &&
                                  day10Stats.speed.value < 100) {
                                day10Stats.updateStats(
                                  speedDelta: 1,
                                  pointsDelta: -10,
                                );
                              }
                            });
                          },
                          day10Stats.speed.value,
                        ),
                        _buildStatButton(
                          context,
                          '버스트',
                          () {
                            setState(() {
                              if (day10Stats.points.value >= 10 &&
                                  day10Stats.burst.value < 100) {
                                day10Stats.updateStats(
                                  burstDelta: 1,
                                  pointsDelta: -10,
                                );
                              }
                            });
                          },
                          day10Stats.burst.value,
                        ),
                        _buildStatButton(
                          context,
                          '스태미나',
                          () {
                            setState(() {
                              if (day10Stats.points.value >= 10 &&
                                  day10Stats.stamina.value < 100) {
                                day10Stats.updateStats(
                                  staminaDelta: 1,
                                  pointsDelta: -10,
                                );
                              }
                            });
                          },
                          day10Stats.stamina.value,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ValueListenableBuilder<int>(
                        valueListenable: day10Stats.points,
                        builder: (context, points, _) {
                          return Text(
                            '남은 포인트: $points',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatButton(BuildContext context, String label,
      VoidCallback onPressed, int currentValue) {
    return Column(
      children: [
        Text('$label\n($currentValue)'),
        IconButton(
          icon: const Icon(Icons.add_circle),
          onPressed: currentValue < 100 && day10Stats.points.value >= 10
              ? onPressed
              : null,
        ),
      ],
    );
  }
}

// 싱글톤 인스턴스
final miniGameManager = MiniGameManager();
