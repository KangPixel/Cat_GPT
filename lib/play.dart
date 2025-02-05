import 'package:flutter/material.dart';

// ✅ 스탯 관련 임포트
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
          backgroundColor: Colors.cyan[50], // 전체 배경색
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
              // ✅ 스탯 UI (막대바 추가)
              _buildStatsBar(),

              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildGameCard('JUMP ROPE', 'assets/images/jump_rope.png', () {
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
                    }),

                    _buildGameCard('SKI', 'assets/images/ski.png', () {
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
                    }),

                    _buildGameCard('BLACKJACK', 'assets/images/blackjack.png', () {
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

                        final moneyDiff = blackjackManager.getMoneyDifference(finalWallet);

                        if (moneyDiff != 0) {
                          _gameService = null;
                          blackjackManager.endSession();
                          final result = MiniGameResult(
                            gameName: 'Blackjack',
                            totalScore: moneyDiff,
                            fatigueIncrease: (moneyDiff < 0) ? 10 : 5,
                            pointsEarned: (moneyDiff > 0) ? (moneyDiff ~/ 1000) : 0,
                            fatigueMessage: moneyDiff < 0 ? "(돈을 잃었어요.)" : null,
                          );

                          miniGameManager.processGameResult(context, result);
                        }
                      });
                    }),

                    _buildGameCard('WATERMELON GAME', 'assets/images/watermelon.png', () {
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
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ 🔥 스탯을 막대바로 표시하는 위젯
  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent, // 컨테이너 투명하게
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow('SPEED     ', day10Stats.speed, Colors.blue),
          _buildStatRow('BURST     ', day10Stats.burst, Colors.red),
          _buildStatRow('STAMINA', day10Stats.stamina, Colors.green),
        ],
      ),
    );
  }

  // ✅ 🔹 각 스탯을 막대바로 표현하는 위젯 (오류 수정됨!)
  Widget _buildStatRow(String label, ValueNotifier<int> stat, Color color) {
    return ValueListenableBuilder<int>(
      valueListenable: stat,
      builder: (context, value, _) {
        return Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: value / 100.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameCard(String title, String imagePath, VoidCallback onTap) {
    return Card(
      color: Colors.transparent,
      elevation: 0, // ✅ 그림자 투명명
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 180,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.games, size: 200);
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

  Widget _buildGameScreen(BuildContext context, FlameGame game, String title) {
    final focusNode = FocusNode();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: GameWidget(game: game, focusNode: focusNode),
      ),
    );
  }