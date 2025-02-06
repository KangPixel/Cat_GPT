import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get_it/get_it.dart';

// 기존 상단 코드 내 import들
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
                // 배경 이미지
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/noenergycat.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                // 하단 중앙에 안내 텍스트
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '놀기 위해 새로운 에너지가 필요해요!',
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'OwnglyphPDH',
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.5),
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
          backgroundColor: Colors.cyan[50], // 하단 코드의 전체 배경색 반영
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
                            onRestartAttempt: handleRestartAttempt);

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

                    // 2) Ski Master
                    _buildGameCard(
                      'Ski',
                      'assets/images/ski.png',
                      () {
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

                            if (isGameOver || levelCompleted) {
                              final result = MiniGameResult(
                                gameName: 'Ski Master',
                                totalScore: score,
                                fatigueIncrease: 5,
                                pointsEarned: score ~/ 100,
                              );
                              miniGameManager.processGameResult(
                                  context, result);
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

  // -------------------------------------------------------------
  // 하단 코드에서 가져온 '스탯 바(Progress Bar)' UI 컴포넌트들
  // -------------------------------------------------------------
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
        final ratio = (value / 100).clamp(0.0, 1.0); // 0~1 범위로
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

  // -------------------------------------------------------------
  // 하단 코드의 GameCard 스타일 + 상단 코드의 로직 연결
  // -------------------------------------------------------------
  Widget _buildGameCard(String title, String imagePath, VoidCallback onTap) {
    return Card(
      color: Colors.transparent, // 투명 카드
      elevation: 0, // 그림자 제거
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        // SizedBox로 감싸 크기를 제한
        child: SizedBox(
          width: 150, // 카드 전체 가로
          height: 150, // 카드 전체 세로
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: 150, // 이미지 가로
                  height: 150, // 이미지 세로
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

  // -------------------------------------------------------
  // 상단 코드의 고급 _buildGameScreen 로직(WillPopScope 등)
  // -------------------------------------------------------
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

    // 2) Suika Game이면 뒤로가기 시 팝업 + 결과 반환(WillPopScope)
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
              focusNode: _gameFocusNode,
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

                  Future.delayed(const Duration(milliseconds: 500), () {
                    final resultMap = {
                      'score': gameplay.score,
                      'gameOver': false,
                      'levelCompleted': false,
                      'additionalFatigue': 5,
                    };
                    Navigator.of(context).pop(resultMap);
                  });
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
          focusNode: _gameFocusNode,
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
