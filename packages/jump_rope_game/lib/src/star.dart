//star.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// game_core.dart 내 JumpRopeGame 을 import 해주세요.
import 'game_core.dart';

/// 왼쪽 나무 -> (최고점) -> 오른쪽 나무 로 날아가는 생선
class star extends SpriteComponent with HasGameRef<JumpRopeGame> {
  /// 생선이 왼쪽에서 오른쪽으로 날아가는 전체 걸리는 시간(초)
  final double travelTime;
  double elapsed = 0; // 경과 시간

  // 포물선 경로에 필요한 값들
  late final double leftX; // 왼쪽 시작 X
  late final double rightX; // 오른쪽 끝 X
  late final double bottomY; // 양 끝 최저점의 Y

  // ★ 이전에는 screenH * 0.3 으로 너무 높았음.
  //   고양이 점프(약 60px)로 닿지 못하는 경우가 생김.
  //   -> 약 0.1~0.15 정도로 낮춰 주면, 최대 높이가 크게 낮아짐.
  late final double arcHeight;

  bool isCollected = false;

  star({required this.travelTime})
      : super(size: Vector2(40, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load('star.png');

    final screenW = gameRef.size.x;
    final screenH = gameRef.size.y;

    leftX = screenW * 0.15;
    rightX = screenW * 0.85;

    // 바닥 y = 화면 높이의 60%
    bottomY = screenH * 0.6;

    // ★ arcHeight를 낮게 설정 (예: 10% 화면 높이)
    arcHeight = screenH * 0.1;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameRef.isGameOver) {
      removeFromParent();
      return;
    }

    elapsed += dt;
    double t = elapsed / travelTime;
    if (t > 1.0) {
      removeFromParent();
      return;
    }

    // (1) x(t): 좌->우 직선 보간
    double xPos = leftX + (rightX - leftX) * t;

    // (2) y(t): U자 궤적 (포물선)
    //    최대 높이는 bottomY - arcHeight
    //    t=0과 t=1에서 bottomY(바닥), t=0.5에서 가장 높이
    double yPos = bottomY - arcHeight * 4 * t * (1 - t);

    position = Vector2(xPos, yPos);

    // 고양이 충돌 체크
    if (!isCollected) {
      final cat = gameRef.cat;
      if (toRect().overlaps(cat.toRect())) {
        isCollected = true;
        gameRef.score += 50;
        removeFromParent();
      }
    }
  }
}
