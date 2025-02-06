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
  }) : super(
          position: Vector2(200, 160),
          size: Vector2(30, 30),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('star.png');

    final endPosition = Vector2(650, 200);
    final controlPoint = Vector2(430, 75);

    final path = Path()
      ..moveTo(position.x, position.y)
      ..quadraticBezierTo(
        controlPoint.x,
        controlPoint.y,
        endPosition.x,
        endPosition.y,
      );

    add(
      MoveAlongPathEffect(
        path,
        EffectController(duration: travelTime / 1.5),
        onComplete: () => removeFromParent(),
      ),
    );
  }
}

StarComponent star({
  required double travelTime,
  int points = 20,
}) {
  return StarComponent(
    travelTime: travelTime,
    points: points,
  );
}
