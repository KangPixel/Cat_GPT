import 'package:flutter/material.dart';
import 'status.dart';
import 'day10_stats.dart';
import 'package:flutter_blackjack_pkg/view/bj_game.dart';
import 'package:flame/game.dart';
import 'package:flutter_suika_game/ui/main_game.dart';
import 'package:ski_master/game/game.dart'; // ski_master의 게임 import

class PlayScreen extends StatelessWidget {
  const PlayScreen({Key? key}) : super(key: key);

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
                    _buildGameCard(
                      'Jump Rope',
                      'assets/images/jump_rope.png',
                      () => print('Jump Rope selected'),
                    ),
                    _buildGameCard(
                      'Ski',
                      'assets/images/ski.png',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: const Text('Ski Master'),
                                leading: IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                              body: SafeArea(
                                child: GameWidget(
                                  game:
                                      SkiMasterGame(), // Ski Master 게임 인스턴스 생성
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildGameCard(
                      'Blackjack',
                      'assets/images/blackjack.png',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BlackJackGame(),
                          ),
                        );
                      },
                    ),
                    _buildGameCard(
                      'Watermelon Game',
                      'assets/images/watermelon.png',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: const Text('Suika Game'),
                                leading: IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                              body: SafeArea(
                                child: GameWidget(
                                  game: MainGame(), // Watermelon 게임 인스턴스
                                ),
                              ),
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
}
