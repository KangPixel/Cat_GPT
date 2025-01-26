//game_core.dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cat.dart';
import 'cat_shadow.dart';
import 'bear.dart';
import 'background.dart';
import 'star.dart';

class JumpRopeGame extends FlameGame with KeyboardEvents, TapDetector {
  late final Cat cat;
  late CatShadow catShadow;
  late final RopeWithBears ropeWithBears;
  int score = 0;
  late TextComponent scoreText;
  late TextComponent comboText;
  int comboCount = 0;
  bool isGameOver = false;
  bool isReady = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

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
    // CatShadow 컴포넌트 생성 & 추가
    catShadow = CatShadow(cat: cat, floorY: floorY);
    add(catShadow);

    _addUI();
    _showReadyMessage();
    Future.delayed(Duration(seconds: 2), () {
      spawnStar();
    });
  }

  void spawnStar() {
    // 3초 동안 왼->오른 포물선 이동하는 FlyingFish
    final star1 = star(travelTime: 3.0);
    add(star1);
  }

  void _addUI() {
    // 점수 표시
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

    // 콤보 표시
    comboText = TextComponent(
      text: 'Combo: 0',
      position: Vector2(20, 60),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(comboText);
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
      ropeWithBears.start(); // 여기에 추가
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isReady || isGameOver) return;

    // 줄과 고양이 충돌 체크
    if (ropeWithBears.checkCollision()) {
      if (cat.isJumping) {
        // 성공적인 점프
        score += (10 * (1 + comboCount * 0.1)).round();
        comboCount++;
      } else {
        // 점프 실패
        gameOver();
      }
    }

    // 점수와 콤보 갱신
    scoreText.text = 'Score: $score';
    comboText.text = 'Combo: $comboCount';
  }

  void gameOver() {
    isGameOver = true;

    // 게임 오버 메시지 추가
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
        resetGame();
        return KeyEventResult.handled;
      }

      if (event.logicalKey == LogicalKeyboardKey.space) {
        if (!isGameOver && isReady && !cat.isJumping) {
          cat.jump();
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  void resetGame() {
    score = 0;
    comboCount = 0;
    isGameOver = false;
    isReady = false;

    // 고양이와 줄/곰 초기화
    cat.reset();
    ropeWithBears.reset();

    // 기존 메시지 제거
    children
        .whereType<TextComponent>()
        .where((text) => text.text.contains('Game Over'))
        .forEach(remove);

    // 준비 메시지 다시 표시
    _showReadyMessage();
  }
}
