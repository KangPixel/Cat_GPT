import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(GameWidget(game: InfiniteRunnerGame()));
}

class InfiniteRunnerGame extends FlameGame with KeyboardEvents {
  late Player player;
  late Timer obstacleTimer;
  final double gravity = 800; // 중력값
  final double jumpForce = 300;

  @override
  Future<void> onLoad() async {
    // 배경 추가
    add(Background(size: size));

    // 플레이어 추가
    player = Player()..position = Vector2(100, size.y - 50);
    add(player);

    // 장애물 생성 타이머
    obstacleTimer = Timer(2, onTick: _spawnObstacle, repeat: true);
    obstacleTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    obstacleTimer.update(dt);

    // 중력 적용
    player.applyGravity(gravity, dt);

    // 바닥 충돌 처리
    if (player.position.y >= size.y - player.size.y) {
      player.position.y = size.y - player.size.y;
      player.velocity.y = 0;
      player.resetJump(); // 바닥에 닿으면 점프 카운터 초기화
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      player.jump(jumpForce); // 점프 시도
    }
    return KeyEventResult.handled;
  }

  void _spawnObstacle() {
    final height = Random().nextDouble() * 50 + 20; // 장애물 높이 (20 ~ 70)
    final obstacle = Obstacle(
      size: Vector2(30, height),
      position: Vector2(size.x, size.y - height),
    );
    add(obstacle);
  }
}

class Player extends RectangleComponent {
  Vector2 velocity = Vector2(0, 0);
  int remainingJumps = 2; // 이중 점프 가능 횟수
  final int maxJumps = 2;

  Player()
      : super(
          size: Vector2(30, 30),
          paint: Paint()..color = Colors.green,
        );

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  void jump(double jumpForce) {
    if (remainingJumps > 0) {
      velocity.y = -jumpForce; // 위쪽으로 힘을 가함
      remainingJumps--; // 점프 횟수 차감
    }
  }

  void applyGravity(double gravity, double dt) {
    velocity.y += gravity * dt; // 중력을 적용하여 아래로 가속
  }

  void resetJump() {
    remainingJumps = maxJumps; // 점프 횟수 초기화
  }
}

class Obstacle extends RectangleComponent {
  final double speed = 200;

  Obstacle({required Vector2 size, required Vector2 position})
      : super(size: size, position: position, paint: Paint()..color = Colors.red);

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;

    // 장애물이 화면 왼쪽을 벗어나면 제거
    if (position.x + size.x < 0) {
      removeFromParent();
    }
  }
}

class Background extends RectangleComponent {
  Background({required Vector2 size})
      : super(
          size: size,
          paint: Paint()..color = Colors.lightBlue,
        );
}
