import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async' as async;

import 'cat.dart';
import 'cat_shadow.dart';
import 'bear.dart';
import 'background.dart';
import 'star.dart';

// 싱글턴 매니저 (점수/게임오버 관리)
import 'jump_rope_manager.dart';

class JumpRopeGame extends FlameGame with KeyboardEvents, TapDetector {
  late final Cat cat;
  late CatShadow catShadow;
  late final RopeWithBears ropeWithBears;

  /// 화면에 표시할 로컬 점수 (jumpRopeManager와 별개)
  int score = 0;

  late TextComponent scoreText;
  bool isGameOver = false;
  bool isReady = false;
  bool gameStarted = false; // 첫 점프 전까지 점수 카운트 안 함

  int lastPriority = 2;
  bool scoredThisRotation = false;

  async.Timer? starSpawnTimer;

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

    catShadow = CatShadow(cat: cat, floorY: floorY);
    add(catShadow);

    _addUI();
    _showReadyMessage();

    // ★ 여기서 더 이상 jumpRopeManager.startNewSession()을 부르지 않습니다. ★
    //   세션 초기화는 parent(PlayScreen)에서만 하도록.

    // 별 생성 타이머(2초 후 시작)
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

    // 점수 로직 - gameStarted가 true일 때만 점수 추가
    if (gameStarted && lastPriority == 2 && ropeWithBears.priority == 0) {
      if (!scoredThisRotation) {
        score += 10;
        jumpRopeManager.addScore(10); // 싱글턴 매니저에도 누적
        scoredThisRotation = true;
      }
    } else if (lastPriority == 0 && ropeWithBears.priority == 2) {
      scoredThisRotation = false;
    }

    lastPriority = ropeWithBears.priority;

    // 줄과 고양이 충돌 체크 (줄이 앞으로 왔을 때)
    if (ropeWithBears.checkCollision() && !cat.isJumping) {
      gameOver();
    }

    // 별과 충돌 체크
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
          jumpRopeManager.addScore(component.points); // 매니저에도 추가
          component.removeFromParent();
        }
      }
    }

    scoreText.text = 'Score: $score';
  }

  void gameOver() {
    isGameOver = true;
    starSpawnTimer?.cancel();

    // 매니저에 게임오버 횟수 +1
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
      // R 키 => 게임 재시작
      if (event.logicalKey == LogicalKeyboardKey.keyR) {
        resetGame();
        return KeyEventResult.handled;
      }

      // 스페이스 => 점프
      if (event.logicalKey == LogicalKeyboardKey.space) {
        if (!isGameOver && isReady && !cat.isJumping) {
          if (!gameStarted) {
            gameStarted = true; // 첫 점프에서만 true
          }
          cat.jump();
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  /// R 키로 “로컬 게임”만 리셋 → 매니저 점수/오버 횟수는 그대로 유지
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

    // 화면에 있는 StarComponent 제거
    children.whereType<StarComponent>().forEach(remove);

    // "Game Over!" 텍스트 제거
    children
        .whereType<TextComponent>()
        .where((text) => text.text.contains('Game Over'))
        .forEach(remove);

    _showReadyMessage();

    // ★ 여기서도 startNewSession() 호출 안 함! (누적 계속)
    // jumpRopeManager.startNewSession();  <-- 제거

    Future.delayed(const Duration(seconds: 2), () {
      startSpawningStars();
    });
  }
}
