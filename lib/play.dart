import 'package:flutter/material.dart';

// 본 게임(메인) 상태들
import 'status.dart';
import 'day10_stats.dart';
import 'mini_game_manager.dart';

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
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildGameCard('Jump Rope', '/jump_rope.png', () {
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
                    _buildGameCard('Ski', '/ski.png', () {
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
                    _buildGameCard('Blackjack', '/blackjack.png', () {
                      final currentWallet = 10000;
                      blackjackManager.startNewSession(currentWallet);
                      Navigator.push<int>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BlackJackGame(),
                        ),
                      ).then((finalWallet) {
                        if (finalWallet != null) {
                          final moneyDiff = blackjackManager.getMoneyDifference(finalWallet);
                          final result = MiniGameResult(
                            gameName: 'Blackjack',
                            totalScore: moneyDiff,
                            fatigueIncrease: (moneyDiff < 0) ? 10 : 5,
                            pointsEarned: (moneyDiff > 0) ? (moneyDiff ~/ 1000) : 0,
                            fatigueMessage: moneyDiff < 0 ? '(돈을 잃었어요.)' : null,
                          );
                          miniGameManager.processGameResult(context, result);
                        }
                        blackjackManager.endSession();
                      });
                    }),
                    _buildGameCard('Watermelon Game', '/watermelon.png', () {
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
              Expanded( // 이미지가 카드 크기에 맞게 확장됨
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
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: GameWidget(game: game),
      ),
    );
  }
}
