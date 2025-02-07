// FILE: play.dart
// (경로 예시: lib/mini_game_manager.dart or lib/play.dart, 상황에 맞게 배치)

// 기존 import 문들 + 필요한 import
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get_it/get_it.dart';

// 아래는 예시 import (이미 사용하셨던 것들)
// 실제 경로/패키지명 맞춰 사용하세요
import 'status.dart';
import 'day10_stats.dart';
import 'mini_game_manager.dart';
import 'package:jump_rope_game/jump_rope_game.dart' as jump_rope;
import 'package:flutter_blackjack_pkg/view/bj_game.dart';
import 'package:flutter_blackjack_pkg/services/blackjack_manager.dart';
import 'package:flutter_blackjack_pkg/services/game_service_impl.dart';
import 'package:flutter_suika_game/ui/main_game.dart';
import 'package:ski_master/game/game.dart';
import 'package:flutter_suika_game/src/suika_manager.dart';
import 'package:flutter_suika_game/domain/game_state.dart';
import 'package:flutter_suika_game/presenter/score_presenter.dart';
import 'package:ski_master/game/routes/gameplay.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({Key? key}) : super(key: key);

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  static GameServiceImpl? _gameService;
  late FocusNode _gameFocusNode;

  @override
  void initState() {
    super.initState();
    _gameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _gameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: catStatus.energy,
      builder: (context, energy, _) {
        // ---------------------------
        // 에너지가 부족한 경우의 화면
        // ---------------------------
        if (energy < 50) {
          return Scaffold(
            appBar: AppBar(title: const Text('Play')),
            body: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/noenergycat.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: MediaQuery.of(context).size.height * 0.45,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '놀기 위해 새로운 에너지가 필요해요!',
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'OwnglyphPDH', // 예: 사용 중인 폰트
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 3.0,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // --------------------------------
        // 에너지가 충분한 경우의 메인 화면
        // --------------------------------
        return Scaffold(
          backgroundColor: Colors.cyan[50], // 전체 배경색
          appBar: AppBar(
            title: const Text('Play'),
            actions: [
              // 포인트 표시
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
              // -------------------
              // 스탯 Progress Bar
              // -------------------
              _buildStatsBar(),
              const SizedBox(height: 20),

              // -------------------------
              // 미니게임 버튼들 (Grid)
              // -------------------------
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    // 1) Jump Rope
                    _buildGameCard(
                      'Jump Rope',
                      'assets/images/jump_rope.png',
                      () {
                        // 시작 전 에너지 체크
                        if (catStatus.energy.value < 50) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('에너지 부족'),
                              content:
                                  const Text('줄넘기를 하기 위해서는 50 이상의 에너지가 필요합니다.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('확인'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        jump_rope.jumpRopeManager.startNewSession();

                        late final jump_rope.JumpRopeGame game;

                        // 게임 종료 및 정산 처리
                        void processGameEnd() {
                          final currentFatigue =
                              jump_rope.jumpRopeManager.gameOverCount * 5;
                          final result = MiniGameResult(
                            gameName: 'Jump Rope',
                            totalScore: jump_rope.jumpRopeManager.totalScore,
                            fatigueIncrease: currentFatigue,
                            pointsEarned:
                                jump_rope.jumpRopeManager.totalScore ~/ 10,
                          );
                          Navigator.of(context).pop(result);
                        }

                        // 재시작 시도 핸들러
                        void handleRestartAttempt() {
                          final currentFatigue =
                              jump_rope.jumpRopeManager.gameOverCount * 5;
                          final remainingEnergy =
                              catStatus.energy.value - currentFatigue;

                          if (remainingEnergy < 50) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('에너지 부족'),
                                content: const Text(
                                    '게임을 계속하기 위해서는 50 이상의 에너지가 필요합니다.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // 다이얼로그 닫기
                                      processGameEnd();
                                    },
                                    child: const Text('확인'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            game.resetGame();
                          }
                        }

                        // JumpRopeGame 초기화
                        game = jump_rope.JumpRopeGame(
                          onRestartAttempt: handleRestartAttempt,
                        );

                        Navigator.push<MiniGameResult>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _buildGameScreen(
                              context,
                              game,
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

                    // 2) Ski
                    _buildGameCard(
                      'Ski',
                      'assets/images/ski.png',
                      () {
                        // 시작 전 에너지 체크
                        if (catStatus.energy.value < 50) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('에너지 부족'),
                              content:
                                  const Text('스키를 타기 위해서는 50 이상의 에너지가 필요합니다.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('확인'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _buildGameScreen(
                              context,
                              SkiMasterGame(),
                              'Ski Master',
                            ),
                          ),
                        ).then((resultMap) {
                          if (resultMap != null) {
                            final score = resultMap['score'] as int;
                            final isGameOver = resultMap['gameOver'] as bool;
                            final levelCompleted =
                                resultMap['levelCompleted'] as bool;
                            final totalFatigue =
                                resultMap['totalFatigue'] as int;
                            final fatigueSummary =
                                resultMap['fatigueSummary'] as String;
                            final returnToPlay =
                                resultMap['returnToPlay'] as bool;

                            // 게임에서 돌아올 때(레벨완 or 게임오버) 결과 처리
                            if (isGameOver || levelCompleted) {
                              final result = MiniGameResult(
                                gameName: 'Ski Master',
                                totalScore: score,
                                fatigueIncrease: totalFatigue,
                                pointsEarned: score ~/ 1000, // 1000점당 1포인트
                                fatigueMessage: fatigueSummary,
                              );

                              miniGameManager
                                  .processGameResult(context, result)
                                  .then((_) {
                                // returnToPlay가 true이면, 다시 PlayScreen으로
                                // (이미 pop되었을 테니, 겹쳐 있으면 pop 한번 더)
                                if (returnToPlay && Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              });
                            }
                          }
                        });
                      },
                    ),

                    // 3) Blackjack
                    _buildGameCard(
                      'Blackjack',
                      'assets/images/blackjack.png',
                      () {
                        if (!mounted) return;

                        if (!blackjackManager.sessionStarted) {
                          blackjackManager.startNewSession(10000);
                          _gameService = GameServiceImpl();
                        }

                        Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BlackJackGame(gameService: _gameService!),
                          ),
                        ).then((result) {
                          if (!mounted || result == null) return;

                          final finalWallet = result['wallet'] as int;
                          final pointsMultiplier =
                              result['pointsMultiplier'] as double;
                          final bonusMessage =
                              result['bonusMessage'] as Map<String, String>?;

                          final moneyDiff =
                              blackjackManager.getMoneyDifference(finalWallet);

                          if (moneyDiff != 0) {
                            _gameService = null;
                            blackjackManager.endSession();

                            final pointsEarned =
                                ((moneyDiff > 0) ? (moneyDiff ~/ 1000) : 0) *
                                    pointsMultiplier;

                            String? message;
                            Color? messageColor;
                            String? subMessage;

                            if (moneyDiff < 0) {
                              message = "(돈을 잃었어요.)";
                              messageColor = Colors.red[700];
                            } else if (bonusMessage != null) {
                              message = bonusMessage['main'];
                              subMessage = bonusMessage['sub'];
                              messageColor = Colors.blue[700];
                            }

                            final miniGameResult = MiniGameResult(
                              gameName: 'Blackjack',
                              totalScore: moneyDiff,
                              fatigueIncrease: (moneyDiff < 0) ? 10 : 5,
                              pointsEarned: pointsEarned.toInt(),
                              fatigueMessage: message,
                              fatigueMessageColor: messageColor,
                              additionalMessage: subMessage,
                            );

                            miniGameManager.processGameResult(
                                context, miniGameResult);
                          }
                        });
                      },
                    ),

                    // 4) Watermelon(Suika) Game
                    _buildGameCard(
                      'Watermelon Game',
                      'assets/images/watermelon.png',
                      () {
                        suikaGameManager.startNewSession();
                        final MainGame newSuikaGame = MainGame();
                        newSuikaGame.setContext(context);

                        Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _buildGameScreen(
                              context,
                              newSuikaGame,
                              'Suika Game',
                            ),
                          ),
                        ).then((resultMap) {
                          if (resultMap != null) {
                            final result = MiniGameResult(
                              gameName: resultMap['gameName'] as String,
                              totalScore: resultMap['totalScore'] as int,
                              fatigueIncrease:
                                  resultMap['fatigueIncrease'] as int,
                              pointsEarned: resultMap['pointsEarned'] as int,
                              fatigueMessage:
                                  resultMap['fatigueMessage'] as String?,
                            );
                            miniGameManager.processGameResult(context, result);
                          }
                        });
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

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow('SPEED   ', day10Stats.speed, Colors.blue),
          const SizedBox(height: 6),
          _buildStatRow('BURST   ', day10Stats.burst, Colors.red),
          const SizedBox(height: 6),
          _buildStatRow('STAMINA', day10Stats.stamina, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, ValueNotifier<int> stat, Color color) {
    return ValueListenableBuilder<int>(
      valueListenable: stat,
      builder: (context, value, _) {
        final ratio = (value / 100).clamp(0.0, 1.0);
        return Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: ratio,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('$value',
                style: const TextStyle(fontSize: 14, fontFamily: 'Pretendard')),
          ],
        );
      },
    );
  }

  Widget _buildGameCard(String title, String imagePath, VoidCallback onTap) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 150,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.games, size: 40);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameScreen(BuildContext context, FlameGame game, String title) {
    // 1) MainGame(GameState) 등록 로직
    if (game is MainGame) {
      game.setContext(context);

      if (GetIt.I.isRegistered<GameState>()) {
        GetIt.I.unregister<GameState>();
      }
      GetIt.I.registerSingleton<GameState>(
        GameState(
          buildContext: context,
          worldToScreen: game.worldToScreen,
          screenToWorld: game.screenToWorld,
          camera: game.camera,
          add: game.add,
        ),
      );
    }

    // 2) Suika Game이면 뒤로가기 시 팝업
    if (title == 'Suika Game') {
      return WillPopScope(
        onWillPop: () async {
          final answer = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (dialogCtx) {
              return AlertDialog(
                title: const Text("수박게임을 종료합니까?"),
                content: const Text("현재 점수를 포인트로 환산합니다."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop(true);
                    },
                    child: const Text("예"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop(false);
                    },
                    child: const Text("아니오"),
                  ),
                ],
              );
            },
          );

          if (answer == true) {
            final score = GetIt.I.get<ScorePresenter>().score;
            final madeWatermelon = GetIt.I.get<GameState>().madeWatermelon;
            final fatigue = madeWatermelon ? 5 : 10;

            final resultMap = {
              'gameName': 'Suika Game',
              'totalScore': score,
              'fatigueIncrease': fatigue,
              'pointsEarned': score ~/ 100,
              'fatigueMessage': madeWatermelon ? '수박을 만들었어요!' : '게임 종료',
            };

            Navigator.of(context).pop(resultMap);
            return false;
          } else {
            return false;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text(title),
          ),
          body: SafeArea(
            child: GameWidget(
              game: game,
              autofocus: true,
              loadingBuilder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorBuilder: (context, error) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ),
      );
    }

    // 3) 그 외 게임들의 기본 화면
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (title == 'Ski Master') {
              if (game is SkiMasterGame) {
                final gameplay = game.findByKeyName<Gameplay>(Gameplay.id);
                if (gameplay != null) {
                  gameplay.handleSettle(isGameOver: false);
                }
              }
            } else if (title == 'Jump Rope') {
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
          autofocus: true,
          loadingBuilder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorBuilder: (context, error) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
}
