import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'game_core.dart';

class Rope extends PositionComponent with HasGameRef<JumpRopeGame> {
  double angle = 0;
  double length = 400; // 더 길게 설정

  @override
  void render(Canvas canvas) {
    // 앞뒤 효과를 위한 스케일 계산
    double depthScale = math.sin(angle) * 0.5 + 1.5; // 1.0 ~ 2.0 사이 변화
    double strokeWidth = depthScale * 3; // 줄 두께 변화

    // 양쪽 고정점의 y좌표 변화
    double baseY = 20 * math.sin(angle);

    // 왼쪽 고정 지점
    final leftPoint = Vector2(-length / 2, baseY);
    // 오른쪽 고정 지점
    final rightPoint = Vector2(length / 2, baseY);

    // 줄 손잡이 (왼쪽)
    canvas.drawCircle(
      Offset(leftPoint.x, leftPoint.y),
      10 * depthScale,
      Paint()..color = Colors.red,
    );

    // 줄 손잡이 (오른쪽)
    canvas.drawCircle(
      Offset(rightPoint.x, rightPoint.y),
      10 * depthScale,
      Paint()..color = Colors.red,
    );

    // 줄 그리기 (앞으로 넘기는 모션)
    final path = Path()
      ..moveTo(leftPoint.x, leftPoint.y)
      ..quadraticBezierTo(
        0, // 조절점 x (중앙)
        length * 0.3 * math.sin(angle - math.pi / 2), // 조절점 y
        rightPoint.x,
        rightPoint.y,
      );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    final JumpRopeGame game = gameRef as JumpRopeGame;

    if (!game.isPaused && game.isReady) {
      // 항상 앞으로 넘기는 모션
      angle += dt * game.currentSpeed;
    }
  }

  bool isAtJumpPosition() {
    // 판정을 더 관대하게
    return math.sin(angle - math.pi / 2).abs() > 0.8;
  }

  void reset() {
    angle = 0;
  }
}
