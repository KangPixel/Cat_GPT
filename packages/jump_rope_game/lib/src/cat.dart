//cat.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class Cat extends SpriteComponent {
  bool isJumping = false;
  bool isPreparingJump = false;
  double jumpHeight = 60;
  double initialY = 0;
  double jumpTime = 0;
  double prepareJumpTime = 0;
  final double jumpDuration = 0.3;
  final double prepareJumpDuration = 0.2;

  Cat() : super(size: Vector2(120, 120), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('ropecat.png');
  }

  void initializePosition(Vector2 screenSize) {
    position = Vector2(screenSize.x / 2, screenSize.y * 0.6); // 0.7 -> 0.6
    initialY = position.y;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isPreparingJump) {
      prepareJumpTime += dt;
      scale = Vector2(
          1,
          1 -
              0.2 *
                  math.sin((prepareJumpTime / prepareJumpDuration) * math.pi));

      if (prepareJumpTime >= prepareJumpDuration) {
        isPreparingJump = false;
        isJumping = true;
        jumpTime = 0;
        scale = Vector2.all(1);
      }
    } else if (isJumping) {
      jumpTime += dt;
      double progress = jumpTime / jumpDuration;

      if (progress <= 1.0) {
        double height = jumpHeight * math.sin(progress * math.pi);
        position.y = initialY - height;
      } else {
        isJumping = false;
        position.y = initialY;
      }
    }
  }

  /// 여기서 그림자를 함께 그려줍니다.
  @override
  void render(Canvas canvas) {
    // (2) 그 뒤 고양이 스프라이트 그리기
    super.render(canvas);
  }

  /// 점프 시작
  void jump() {
    if (!isJumping && !isPreparingJump) {
      isPreparingJump = true;
      prepareJumpTime = 0;
    }
  }

  /// 초기화
  void reset() {
    isJumping = false;
    isPreparingJump = false;
    jumpTime = 0;
    prepareJumpTime = 0;
    position.y = initialY;
  }
}
