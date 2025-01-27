// star.dart
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
          position: Vector2(-50, 300),
          size: Vector2(50, 50),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('star.png');

    final endPosition = Vector2(450, 300);
    final controlPoint = Vector2(200, 100);

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
        EffectController(duration: travelTime),
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
