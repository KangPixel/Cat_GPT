//packages/jump_rope_game/lib/src/cat_shadow.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CatShadow extends PositionComponent {
  // 고양이(Component) 정보를 받아와서 x좌표만 공유할 예정
  final PositionComponent cat;
  // 바닥 높이(그림자가 위치할 y값)
  final double floorY;

  CatShadow({
    required this.cat,
    required this.floorY,
  });

  @override
  void update(double dt) {
    super.update(dt);
    // 고양이의 x 좌표(수평 위치)만 따라가되, y는 바닥에 고정
    x = cat.x;
    y = floorY + 40;
  }

  @override
  void render(Canvas canvas) {
    // 고양이 크기를 참조해서 그림자 크기 결정
    // (원하는 크기로 조절 가능)
    double shadowWidth = cat.width * 0.4;
    double shadowHeight = cat.height * 0.15;

    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.2);
    final shadowRect = Rect.fromCenter(
      center: Offset(0, 0), // 본 컴포넌트의 (0,0)은 CatShadow.position과 동일
      width: shadowWidth,
      height: shadowHeight,
    );
    canvas.drawOval(shadowRect, shadowPaint);
  }
}
