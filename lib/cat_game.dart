import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'status.dart';

class CatGame extends FlameGame {
  late SpriteComponent background;
  late SpriteComponent cat;
  late TextComponent countdown;
  int remainingDays = 10;

  final VoidCallback onTalk;

  CatGame({required this.onTalk});

  @override
  Future<void> onLoad() async {
    background = SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size;
    add(background);

    cat = SpriteComponent()
      ..sprite = await loadSprite('cat.png')
      ..size = Vector2(size.x * 0.4, size.y * 0.4)
      ..position = Vector2(size.x / 2 - size.x * 0.2, size.y / 2 - size.y * 0.1);
    add(cat);

    countdown = TextComponent(
      text: 'D-day: $remainingDays',
      position: Vector2(size.x - 10, 20),
      anchor: Anchor.topRight,
    );
    add(countdown);
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Status Info'),
          content: ValueListenableBuilder(
            valueListenable: catStatus.hunger,
            builder: (context, hunger, _) {
              return ValueListenableBuilder(
                valueListenable: catStatus.intimacy,
                builder: (context, intimacy, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Hunger: $hunger'),
                      Text('Intimacy: $intimacy'),
                    ],
                  );
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: GameWidget(
        game: CatGame(onTalk: () => Navigator.pushNamed(context, '/chat')),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildButton(context, 'Feed', Icons.food_bank, () {
              catStatus.updateStatus(hungerDelta: -10);
            }),
            _buildButton(context, 'Play', Icons.sports_soccer, () {
              catStatus.updateStatus(intimacyDelta: 5);
            }),
            _buildButton(context, 'Talk', Icons.chat, () {
              Navigator.pushNamed(context, '/chat');
            }),
            _buildButton(context, 'Rest', Icons.bedtime, () {
              catStatus.updateStatus();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return IconButton(
      onPressed: onTap,
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
