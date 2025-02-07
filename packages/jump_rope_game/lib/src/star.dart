//packages/jump_rope_game/lib/src/star.dart
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class StarComponent extends SpriteComponent with HasGameRef {
  final double travelTime;
  final int points;

  StarComponent({
    required this.travelTime,
    this.points = 20,
  }) : super(size: Vector2(30, 30), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('star.png');

    position = Vector2(-30, gameRef.size.y * 0.3);
    final endPosition = Vector2(gameRef.size.x + 30, gameRef.size.y * 0.3);
    final controlPoint1 = Vector2(gameRef.size.x * 0.155, gameRef.size.y * 0.2);
    final controlPoint2 = Vector2(gameRef.size.x * 0.75, gameRef.size.y * 0.2);

    final path = Path()
      ..moveTo(position.x, position.y)
      ..cubicTo(
        controlPoint1.x,
        controlPoint1.y,
        controlPoint2.x,
        controlPoint2.y,
        endPosition.x,
        endPosition.y,
      );

    add(
      MoveAlongPathEffect(
        path,
        EffectController(duration: travelTime),
        onComplete: () => removeFromParent(),
      ),
    );
  }
}
