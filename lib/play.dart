// play.dart

import 'package:flutter/material.dart';

// 본 게임(메인) 상태들
import 'status.dart';
import 'day10_stats.dart';
import 'mini_game_manager.dart'; // MiniGameResult, miniGameManager.processGameResult 등

// jump_rope_game 패키지
import 'package:jump_rope_game/jump_rope_game.dart' as jump_rope;
import 'package:flame/game.dart';

// 다른 게임들
import 'package:flutter_blackjack_pkg/view/bj_game.dart'; // 블랙잭 화면
import 'package:flutter_blackjack_pkg/services/blackjack_manager.dart'; // 블랙잭 매니저
import 'package:flutter_suika_game/ui/main_game.dart';
import 'package:ski_master/game/game.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({Key? key}) : super(key: key);

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: catStatus.energy,
      builder: (context, energy, _) {
        if (energy < 50) {
          return Scaffold(
            appBar: AppBar(title: const Text('Play')),
            body: const Center(
              child: Text(
                'Need at least 50 energy to play!',
                style: TextStyle(fontSize: 20),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Play'),
            actions: [
              // Points 표시
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ValueListenableBuilder<int>(
                    valueListenable: day10Stats.points,
                    builder: (context, points, _) {
                      return Text(
                        'Points: $points',
                        style: const TextStyle(fontSize: 18),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: day10Stats.speed,
                      builder: (context, speed, _) {
                        return Text('Speed: $speed',
                            style: const TextStyle(fontSize: 18));
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: day10Stats.burst,
                      builder: (context, burst, _) {
                        return Text('Burst: $burst',
                            style: const TextStyle(fontSize: 18));
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: day10Stats.stamina,
                      builder: (context, stamina, _) {
                        return Text('Stamina: $stamina',
                            style: const TextStyle(fontSize: 18));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    // Jump Rope 카드
                    _buildGameCard(
                      'Jump Rope',
                      'assets/images/jump_rope.png',
                      () {
                        // 여기서 ★한 번만★ 새 세션 시작
                        jump_rope.jumpRopeManager.startNewSession();

                        // 미니게임 화면 띄우고, 종료 후 결과 받음
                        Navigator.push<MiniGameResult>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _buildGameScreen(
                              context,
                              jump_rope.JumpRopeGame(),
                              'Jump Rope',
                            ),
                          ),
                        ).then((result) {
                          if (result != null) {
                            miniGameManager.processGameResult(context, result);
                          }
                        });
                      },
                    ),

                    // 예시: Ski
                    _buildGameCard(
                      'Ski',
                      'assets/images/ski.png',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _buildGameScreen(
                              context,
                              SkiMasterGame(),
                              'Ski Master',
                            ),
                          ),
                        );
                      },
                    ),

                    // Blackjack
                    // Blackjack
                    _buildGameCard(
                      'Blackjack',
                      'assets/images/blackjack.png',
                      () {
                        if (!mounted) return;

                        final currentWallet = 10000; // 시작 금액

                        // 1) 블랙잭 세션 시작 - 시작 돈 기록
                        blackjackManager.startNewSession(currentWallet);

                        // 2) 블랙잭 게임 실행
                        Navigator.push<int>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BlackJackGame(),
                          ),
                        ).then((finalWallet) {
                          if (!mounted) return;

                          if (finalWallet == null) {
                            print('게임 취소됨');
                            blackjackManager.endSession();
                            return;
                          }

                          // 3) 돈 변화량 계산
                          final moneyDiff =
                              blackjackManager.getMoneyDifference(finalWallet);
                          print(
                              '시작 금액: ${blackjackManager.initialWallet}, 최종 금액: $finalWallet, 차액: $moneyDiff');
                          // 4) 세션 종료는 여기서 한 번만
                          blackjackManager.endSession();

                          // 5) 결과 처리
                          final fatigue =
                              (moneyDiff < 0) ? 10 : 5; // 돈을 잃으면 피로도 10, 아니면 5
                          final points = (moneyDiff > 0)
                              ? (moneyDiff ~/ 1000)
                              : 0; // 번 돈 1000당 1포인트

                          // 6) MiniGameResult 생성 및 처리
                          final result = MiniGameResult(
                            gameName: 'Blackjack',
                            totalScore: moneyDiff, // 돈 변화량
                            fatigueIncrease: fatigue,
                            pointsEarned: points,
                            fatigueMessage: moneyDiff < 0 ? "(돈을 잃었어요.)" : null,
                          );

                          // 7) 게임 결과 처리 및 팝업 표시
                          miniGameManager.processGameResult(context, result);
                        });
                      },
                    ),
                    // Watermelon
                    _buildGameCard(
                      'Watermelon Game',
                      'assets/images/watermelon.png',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _buildGameScreen(
                              context,
                              MainGame(),
                              'Suika Game',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameCard(String title, String imagePath, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 80,
              width: 80,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.games, size: 80);
              },
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  /// 실제 미니게임 화면 + 뒤로가기 로직
  Widget _buildGameScreen(BuildContext context, FlameGame game, String title) {
    final focusNode = FocusNode();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (title == 'Jump Rope') {
              final mgr = jump_rope.jumpRopeManager;
              final result = MiniGameResult(
                gameName: 'Jump Rope',
                totalScore: mgr.totalScore,
                fatigueIncrease: mgr.gameOverCount * 5,
                pointsEarned: mgr.totalScore ~/ 10,
              );
              Navigator.of(context).pop(result);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: GameWidget(
          game: game,
          focusNode: focusNode,
        ),
      ),
    );
  }
}
