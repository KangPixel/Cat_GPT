// play.dart

import 'package:flutter/material.dart';

// 본 게임(메인) 상태들
import 'status.dart';
import 'day10_stats.dart';
import 'mini_game_manager.dart';

// jump_rope_game 패키지
import 'package:jump_rope_game/jump_rope_game.dart' as jump_rope;
import 'package:flame/game.dart';

// 다른 게임들
import 'package:flutter_blackjack_pkg/view/bj_game.dart';
import 'package:flutter_blackjack_pkg/services/blackjack_manager.dart';
import 'package:flutter_blackjack_pkg/services/game_service_impl.dart';
import 'package:flutter_suika_game/ui/main_game.dart';
import 'package:ski_master/game/game.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({Key? key}) : super(key: key);

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  // GameService 인스턴스를 클래스 레벨에서 static으로 선언
  static GameServiceImpl? _gameService;

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
                    // Jump Rope 카드 복원
                    _buildGameCard(
                      'Jump Rope',
                      'assets/images/jump_rope.png',
                      () {
                        jump_rope.jumpRopeManager.startNewSession();
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

                    // Ski
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
                    _buildGameCard(
                      'Blackjack',
                      'assets/images/blackjack.png',
                      () {
                        if (!mounted) return;

                        // 새로운 세션 시작이 필요한 경우에만 시작
                        if (!blackjackManager.sessionStarted) {
                          blackjackManager.startNewSession(10000);
                          _gameService = GameServiceImpl(); // 새 세션 시작할 때만 새로 생성
                        }

                        Navigator.push<int>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BlackJackGame(gameService: _gameService!),
                          ),
                        ).then((finalWallet) {
                          if (!mounted) return;

                          if (finalWallet == null) {
                            return; // 세션을 유지합니다
                          }

                          // 게임 결과 처리
                          final moneyDiff =
                              blackjackManager.getMoneyDifference(finalWallet);

                          // 세션 종료는 정산 버튼을 눌렀을 때만 수행
                          if (moneyDiff != 0) {
                            _gameService = null; // 정산 후에는 서비스 초기화
                            blackjackManager.endSession();
                            final result = MiniGameResult(
                              gameName: 'Blackjack',
                              totalScore: moneyDiff,
                              fatigueIncrease: (moneyDiff < 0) ? 10 : 5,
                              pointsEarned:
                                  (moneyDiff > 0) ? (moneyDiff ~/ 1000) : 0,
                              fatigueMessage:
                                  moneyDiff < 0 ? "(돈을 잃었어요.)" : null,
                            );

                            miniGameManager.processGameResult(context, result);
                          }
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 150,
          height: 160,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8), //상단 여백 추가
              Expanded(
                // 이미지가 카드 크기에 맞게 확장됨
                child: Image.asset(
                  imagePath,
                  height: double.infinity, // 높이를 카드 크기에 맞춤춤
                  width: double.infinity, // 너비를 카드 크기에 맞춤춤
                  fit: BoxFit.contain, //이미지가 카드 안에서 크기 맞춰짐짐
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.games, size: 100);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

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
