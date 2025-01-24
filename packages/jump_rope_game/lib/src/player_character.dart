import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Player extends PositionComponent {
  bool isJumping = false;
  double jumpHeight = 100;
  double initialY = 0;
  double jumpTime = 0;
  final double jumpDuration = 0.5;

  Player() : super(size: Vector2(50, 80));

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(-size.x / 2, 0);

    // 플레이어 몸체
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.blue[700]!,
    );

    // 얼굴 표정
    final faceY = isJumping ? size.y * 0.2 : size.y * 0.3;

    // 눈
    canvas.drawCircle(
      Offset(size.x * 0.3, faceY),
      5,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(size.x * 0.7, faceY),
      5,
      Paint()..color = Colors.white,
    );

    // 입
    final smileY = isJumping ? size.y * 0.3 : size.y * 0.4;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.x * 0.5, smileY),
        width: size.x * 0.4,
        height: size.y * 0.2,
      ),
      0,
      math.pi,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isJumping) {
      jumpTime += dt;
      double progress = jumpTime / jumpDuration;

      if (progress <= 1) {
        double height = math.sin(progress * math.pi) * jumpHeight;
        y = initialY - height;
      } else {
        isJumping = false;
        y = initialY;
        jumpTime = 0;
      }
    }
  }

  void jump() {
    if (!isJumping) {
      isJumping = true;
      initialY = y;
      jumpTime = 0;
    }
  }

  void reset() {
    isJumping = false;
    jumpTime = 0;
    y = initialY;
  }
}
