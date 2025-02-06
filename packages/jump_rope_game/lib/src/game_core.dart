//packages/jump_rope_game/lib/src/game_core.dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async' as async;
import 'package:flame_audio/flame_audio.dart';

import 'cat.dart';
import 'cat_shadow.dart';
import 'bear.dart';
import 'background.dart';
import 'star.dart';
import 'jump_rope_manager.dart';

class JumpRopeGame extends FlameGame with KeyboardEvents, TapDetector {
  final VoidCallback onRestartAttempt;

  late final Cat cat;
  late CatShadow catShadow;
  late final RopeWithBears ropeWithBears;

  int score = 0;
  late TextComponent scoreText;
  bool isGameOver = false;
  bool isReady = false;
  bool gameStarted = false;

  int lastPriority = 2;
  bool scoredThisRotation = false;

  async.Timer? starSpawnTimer;

  JumpRopeGame({required this.onRestartAttempt});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await FlameAudio.audioCache
        .loadAll(['catjump.wav', 'catstar.wav', 'catgameover.wav']);

    final background = Background();
    background.size = size;
    add(background);

    cat = Cat()..priority = 1;
    ropeWithBears = RopeWithBears(
      catBounds: cat.size,
      catPosition: cat.position,
    )..priority = 2;

    add(cat);
    add(ropeWithBears);

    double floorY = size.y * 0.6;
    cat.initializePosition(size);
    ropeWithBears.initializePosition(size, cat.position);

    catShadow = CatShadow(cat: cat, floorY: floorY);
    add(catShadow);

    _addUI();
    _showReadyMessage();

    Future.delayed(const Duration(seconds: 2), () {
      startSpawningStars();
    });
  }

  void startSpawningStars() {
    starSpawnTimer = async.Timer.periodic(const Duration(seconds: 4), (_) {
      if (!isGameOver && isReady) {
        spawnStar();
      }
    });
  }

  void spawnStar() {
    final star1 = star(travelTime: 3.0, points: 20);
    add(star1);
  }

  void _addUI() {
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 30),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);
  }

  void _showReadyMessage() {
    final readyText = TextComponent(
      text: 'Ready...\nPress SPACE to Jump\nPress R to Restart',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(readyText);

    Future.delayed(const Duration(seconds: 2), () {
      readyText.removeFromParent();
      isReady = true;
      ropeWithBears.start();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isReady || isGameOver) return;

    if (gameStarted && lastPriority == 2 && ropeWithBears.priority == 0) {
      if (!scoredThisRotation) {
        score += 10;
        jumpRopeManager.addScore(10);
        scoredThisRotation = true;
      }
    } else if (lastPriority == 0 && ropeWithBears.priority == 2) {
      scoredThisRotation = false;
    }

    lastPriority = ropeWithBears.priority;

    if (ropeWithBears.checkCollision() && !cat.isJumping) {
      gameOver();
    }

    for (final component in children) {
      if (component is StarComponent) {
        final starBounds = component.toRect();
        final catBounds = Rect.fromCenter(
          center: Offset(cat.position.x, cat.position.y),
          width: cat.size.x * 0.5,
          height: cat.size.y * 0.5,
        );

        if (starBounds.overlaps(catBounds)) {
          score += component.points;
          jumpRopeManager.addScore(component.points);
          FlameAudio.play('catstar.wav', volume: 0.4);
          component.removeFromParent();
        }
      }
    }

    scoreText.text = 'Score: $score';
  }

  void gameOver() {
    if (isGameOver) return;

    isGameOver = true;
    starSpawnTimer?.cancel();

    FlameAudio.play('catgameover.wav', volume: 0.4);
    jumpRopeManager.incrementGameOver();

    add(
      TextComponent(
        text: 'Game Over!\nScore: $score\nPress R to Restart',
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 32,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyR) {
        if (isGameOver) {
          onRestartAttempt(); // 콜백 호출
        }
        return KeyEventResult.handled;
      }

      if (event.logicalKey == LogicalKeyboardKey.space) {
        if (!isGameOver && isReady && !cat.isJumping) {
          if (!gameStarted) {
            gameStarted = true;
          }
          FlameAudio.play('catjump.wav', volume: 0.5);
          cat.jump();
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  void resetGame() {
    score = 0;
    lastPriority = 2;
    scoredThisRotation = false;
    isGameOver = false;
    isReady = false;
    gameStarted = false;

    starSpawnTimer?.cancel();

    cat.reset();
    ropeWithBears.reset();

    children.whereType<StarComponent>().forEach(remove);

    children
        .whereType<TextComponent>()
        .where((text) => text.text.contains('Game Over'))
        .forEach(remove);

    _showReadyMessage();

    Future.delayed(const Duration(seconds: 2), () {
      startSpawningStars();
    });
  }
}
