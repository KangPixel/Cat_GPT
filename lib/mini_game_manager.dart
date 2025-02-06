// lib/mini_game_manager.dart
import 'package:flutter/material.dart';
import 'status.dart';
import 'day10_stats.dart';

class MiniGameResult {
  final String gameName;
  final int totalScore;
  final int fatigueIncrease;
  final int pointsEarned;
  final String? fatigueMessage;
  final Color? fatigueMessageColor;
  final String? additionalMessage;

  MiniGameResult({
    required this.gameName,
    required this.totalScore,
    required this.fatigueIncrease,
    required this.pointsEarned,
    this.fatigueMessage,
    this.fatigueMessageColor,
    this.additionalMessage,
  });
}

class MiniGameManager {
  static final MiniGameManager _instance = MiniGameManager._internal();
  factory MiniGameManager() => _instance;
  MiniGameManager._internal();

  Future<void> processGameResult(
      BuildContext context, MiniGameResult result) async {
    // 스탯 업데이트
    catStatus.updateStatus(fatigueDelta: result.fatigueIncrease);
    day10Stats.updateStats(pointsDelta: result.pointsEarned);

    // 결과 팝업 표시
    if (context.mounted) {
      await _showResultDialog(context, result);
    }
  }

  Future<void> _showResultDialog(BuildContext context, MiniGameResult result) {
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
                  // 획득 점수/돈 표시
                  Text('$labelScore: ${result.totalScore}'),

                  // 피로도 증가와 실패 메시지
                  Row(
                    children: [
                      Text('피로도 증가: ${result.fatigueIncrease}'),
                      if (result.fatigueMessage != null &&
                          (result.additionalMessage == null ||
                              result.fatigueMessageColor ==
                                  Colors.red[700])) ...[
                        const SizedBox(width: 5),
                        Text(
                          result.fatigueMessage!,
                          style: TextStyle(
                            color: result.fatigueMessageColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // 포인트 획득과 보너스 메시지
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('획득한 포인트: ${result.pointsEarned}'),
                      if (result.fatigueMessage != null &&
                          result.additionalMessage != null &&
                          result.fatigueMessageColor == Colors.blue[700]) ...[
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.fatigueMessage!,
                                style: TextStyle(
                                  color: result.fatigueMessageColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                result.additionalMessage!,
                                style: TextStyle(
                                  color: result.fatigueMessageColor,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  // 스탯 올리기 UI
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
