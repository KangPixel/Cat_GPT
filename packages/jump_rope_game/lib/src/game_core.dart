import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'player_character.dart';
import 'jump_rope.dart';

class JumpRopeGame extends FlameGame with KeyboardEvents, TapDetector {
  late final Player player;
  late final Rope rope;
  int score = 0;
  late TextComponent scoreText;
  late TextComponent comboText;
  int comboCount = 0;
  bool isGameOver = false;
  bool isReady = false;
  final random = math.Random();

  // 줄넘기 상태 관리
  double normalSpeed = 5.0; // 기본 속도 조정
  double currentSpeed = 5.0;
  bool isBackward = false;
  double speedChangeTimer = 0;
  double nextSpeedChange = 3.0;
  bool isPaused = false;
  double pauseTimer = 0;
  double pauseDuration = 0.5;

  @override
  Future<void> onLoad() async {
    // 배경 설정
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFFB8E1FF),
    ));

    // 플레이어 추가 (중앙에 위치)
    player = Player();
    player.position = Vector2(size.x / 2, size.y * 0.7);
    add(player);

    // 줄 추가
    rope = Rope();
    rope.position = Vector2(size.x / 2, size.y * 0.7);
    add(rope);

    // 점수 표시
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 20),
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
      position: Vector2(20, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(comboText);

    // 초기 속도 설정
    currentSpeed = normalSpeed;

    // 준비 메시지 표시
    final readyText = TextComponent(
      text: 'Ready...\nPress SPACE, UP or W to Jump\nPress R to Restart',
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
    readyText.add(RemoveEffect(delay: 2));

    // 2초 후 게임 시작
    Future.delayed(const Duration(seconds: 2), () {
      isReady = true;
    });
  }

  void updateRopeState() {
    if (isPaused) {
      pauseTimer += 0.016;
      if (pauseTimer >= pauseDuration) {
        isPaused = false;
        pauseTimer = 0;

        if (random.nextDouble() < 0.3) {
          isBackward = !isBackward;
        }
        if (random.nextDouble() < 0.3) {
          currentSpeed = normalSpeed * (1 + random.nextDouble() * 0.5);
        }
      }
      return;
    }

    speedChangeTimer += 0.016;
    if (speedChangeTimer >= nextSpeedChange) {
      speedChangeTimer = 0;
      nextSpeedChange = 2 + random.nextDouble() * 4;

      double rand = random.nextDouble();
      if (rand < 0.2) {
        isPaused = true;
        pauseTimer = 0;
      } else if (rand < 0.5) {
        isBackward = !isBackward;
      } else if (rand < 0.8) {
        currentSpeed = normalSpeed * (0.7 + random.nextDouble() * 0.6);
      } else {
        isBackward = false;
        currentSpeed = normalSpeed;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isReady || isGameOver) return;

    updateRopeState();

    // 줄과 플레이어의 충돌 체크
    if (rope.isAtJumpPosition()) {
      if (player.isJumping) {
        // 성공적인 점프
        score += (10 * (1 + comboCount * 0.1)).round();
        comboCount++;

        // 콤보 효과 표시
        if (comboCount > 1) {
          _showComboEffect();
        }
      } else {
        // 실패
        gameOver();
      }
    }

    scoreText.text = 'Score: $score';
    comboText.text = 'Combo: $comboCount';
  }

  void _showComboEffect() {
    final comboEffect = TextComponent(
      text: '$comboCount Combo!',
      position: Vector2(size.x / 2, size.y * 0.4),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 32,
          color: Colors.orange[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(comboEffect);

    comboEffect.add(
      MoveEffect.by(
        Vector2(0, -50),
        EffectController(duration: 0.5),
      ),
    );

    comboEffect.add(
      RemoveEffect(delay: 0.5),
    );
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    if (!isGameOver && isReady) {
      player.jump();
    }
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      print(
          'KeyDownEvent detected: KeyCode: ${event.physicalKey.debugName}, LogicalKey: ${event.logicalKey.keyLabel}');
    }

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.keyW ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (!isGameOver && isReady) {
          print('Jump key pressed!');
          player.jump();
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
        print('Reset key pressed!');
        resetGame();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void gameOver() {
    isGameOver = true;
    add(
      TextComponent(
        text: 'Game Over!\nScore: $score\nPress R to restart',
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

  void resetGame() {
    score = 0;
    comboCount = 0;
    isGameOver = false;
    isReady = false;
    currentSpeed = normalSpeed;
    isBackward = false;
    isPaused = false;
    speedChangeTimer = 0;
    nextSpeedChange = 3.0;
    player.reset();
    rope.reset();

    // 준비 메시지 다시 표시
    final readyText = TextComponent(
      text: 'Ready...\nPress SPACE, UP or W to Jump\nPress R to Restart',
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
    readyText.add(RemoveEffect(delay: 2));

    // 2초 후 게임 다시 시작
    Future.delayed(const Duration(seconds: 2), () {
      isReady = true;
    });
  }
}
