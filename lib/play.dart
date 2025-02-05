// lib/play.dart

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get_it/get_it.dart';
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

  // 수박 게임(수이카 게임)용 MainGame 인스턴스는
  // '매번 새로 생성'할 수도 있고(아래 예시), 전역으로 재사용할 수도 있습니다.
  // 여기서는 "클릭 시 새 인스턴스"로 예시.
  // final MainGame _suikaGame = MainGame();

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
                    // 1) Jump Rope
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

                    // 2) Ski
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
                            // 게임 종료 상태에 따른 점수 처리
                            final score = resultMap['score'] as int;
                            final isGameOver = resultMap['gameOver'] as bool;
                            final levelCompleted =
                                resultMap['levelCompleted'] as bool;

                            // 게임이 정상적으로 끝났을 때만 결과 처리
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

                        Navigator.push<int>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BlackJackGame(gameService: _gameService!),
                          ),
                        ).then((finalWallet) {
                          if (!mounted) return;

                          if (finalWallet == null) {
                            return;
                          }

                          final moneyDiff =
                              blackjackManager.getMoneyDifference(finalWallet);

                          if (moneyDiff != 0) {
                            _gameService = null;
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

                    // 4) Watermelon(Suika) Game
                    _buildGameCard(
                      'Watermelon Game',
                      'assets/images/watermelon.png',
                      () {
                        // 세션 리셋
                        suikaGameManager.startNewSession();

                        // 매번 새 인스턴스(게임 객체) 생성
                        final MainGame newSuikaGame = MainGame();
                        newSuikaGame.setContext(context);

                        // push -> .then(...)로 결과 받기
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
              const SizedBox(height: 8),
              Expanded(
                child: Image.asset(
                  imagePath,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.contain,
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

  /// 게임 화면 빌드
  Widget _buildGameScreen(BuildContext context, FlameGame game, String title) {
    // 1) MainGame(GameState) 등록 로직
    if (game is MainGame) {
      game.setContext(context);

      // 기존 GameState가 등록된 상태라면 해제 후 다시 등록
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

    // 2) 만약 title이 "Suika Game"이라면 뒤로가기 시 팝업 + 결과 pop
    if (title == 'Suika Game') {
      return WillPopScope(
        onWillPop: () async {
          // 뒤로가기 시, 팝업으로 "예/아니오"
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
                      // "예" -> true
                      Navigator.of(dialogCtx).pop(true);
                    },
                    child: const Text("예"),
                  ),
                  TextButton(
                    onPressed: () {
                      // "아니오" -> false
                      Navigator.of(dialogCtx).pop(false);
                    },
                    child: const Text("아니오"),
                  ),
                ],
              );
            },
          );

          if (answer == true) {
            // "예" → 실제 정산 결과를 pop(...)으로 넘기기
            // ScorePresenter나 suikaGameManager, GameState에서 실제 점수/정보를 가져와서
            // 아래 resultMap을 구성하면 됩니다. (예: 999 대신 실제 점수)
            final score = GetIt.I.get<ScorePresenter>().score; // 예시
            final madeWatermelon = GetIt.I.get<GameState>().madeWatermelon;
            final fatigue = madeWatermelon ? 5 : 10;

            final resultMap = {
              'gameName': 'Suika Game',
              'totalScore': score, // 실제 점수
              'fatigueIncrease': fatigue,
              'pointsEarned': score ~/ 100, // 예시: 100점 당 1포인트
              'fatigueMessage': madeWatermelon ? '수박을 만들었어요!' : '게임 종료',
            };

            // 상위의 .then((resultMap) {...})로 값을 전달 → 정산
            Navigator.of(context).pop(resultMap);

            // WillPopScope 반환값은 무시돼도 되지만, 이미 pop했으므로 false나 true나 상관없음
            return false;
          } else {
            // "아니오" → 뒤로가기 취소
            return false;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true, // 기본 뒤로가기 아이콘
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

    // 3) 그 외 게임(점프 로프, 블랙잭, 스키)은 기존 로직(앱바 leading) 유지
    else {
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
                    gameplay.handleSettle(isGameOver: false); // 게임 정리 (BGM 등)

                    // 약간의 딜레이 후 결과 반환 및 Navigator.pop
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
                // 다른 게임은 그냥 pop
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
}
