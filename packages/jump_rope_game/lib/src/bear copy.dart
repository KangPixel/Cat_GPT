//bear.dart
import 'package:flame/components.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RopeWithBears extends PositionComponent {
  Vector2? playerPosition;
  late final Sprite leftBear;
  late final Sprite rightBear;
  double angle = math.pi / 3;
  double swingSpeed = -2.5;
  final double baseSwingSpeed = -2.5;
  final double ropeAmplitude = 100.0;
  bool isReversed = false;
  int swingCount = 0;
  final int swingsBeforeDirectionChange = 3;
  bool started = false;
  Vector2 catBounds;
  Vector2 catPosition;

  RopeWithBears({required this.catBounds, required this.catPosition});

  @override
  Future<void> onLoad() async {
    leftBear = await Sprite.load('left_bear.png');
    rightBear = await Sprite.load('right_bear.png');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!started) return;

    angle += swingSpeed * dt;

    if (angle < 0) {
      angle = angle + math.pi * 2;
    } else if (angle >= math.pi * 2) {
      angle = angle - math.pi * 2;
    }

    if (angle > 4.0 || angle < 0.4) {
      priority = 2;
    } else {
      priority = 0;
    }

    if (swingCount >= swingsBeforeDirectionChange) {
      isReversed = !isReversed;
      swingSpeed = baseSwingSpeed * (math.Random().nextDouble() * 0.3 + 0.9);
      swingCount = 0;
    }
  }

  void initializePosition(Vector2 screenSize, Vector2 playerPosition) {
    position = Vector2(playerPosition.x, screenSize.y * 0.6);
    this.playerPosition = playerPosition;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();

    _drawRope(canvas);
    _drawBears(canvas);

    if (angle < -0.1 || angle > math.pi - 0.1) {
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset(catPosition.x, catPosition.y),
              width: catBounds.x,
              height: catBounds.y),
          Paint()..color = Color(0xFFF5F5DC));
    }

    canvas.restore();
  }

  void _drawRope(Canvas canvas) {
    final path = Path()
      ..moveTo(100, 0)
      ..quadraticBezierTo(0, -ropeAmplitude * math.sin(angle), -100, 0);

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFC0CB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
  }

  void _drawBears(Canvas canvas) {
    leftBear.render(canvas,
        position: Vector2(-150, -50), size: Vector2(75, 75));
    rightBear.render(canvas, position: Vector2(70, -50), size: Vector2(75, 75));
  }

  void reset() {
    angle = math.pi / 3;
    started = false;
    isReversed = false;
    swingCount = 0;
  }

  void start() {
    started = true;
  }

  double previousAngle = 0; // 클래스 변수로 추가
  bool checkCollision() {
    // 줄이 앞으로 움직일 때만
    if (angle > math.pi && angle < math.pi * 1.5) return false;

    double ropeY = position.y - (ropeAmplitude * math.sin(angle));

    double legBoxTop = playerPosition!.y + (catBounds.y * 0.55);
    double legBoxBottom = playerPosition!.y + (catBounds.y * 0.79);
    double legBoxLeft = playerPosition!.x - (catBounds.x * 0.25);
    double legBoxRight = playerPosition!.x + (catBounds.x * 0.25);

    double ropeLeft = position.x - 100;
    double ropeRight = position.x + 100;

    bool verticalCollision = ropeY >= legBoxTop && ropeY <= legBoxBottom;
    bool horizontalCollision =
        ropeLeft <= legBoxRight && ropeRight >= legBoxLeft;

    if ((angle * 2).round() % 1 == 0) {
      print(
          'Rad: ${angle.toStringAsFixed(1)} | RY: ${ropeY.round()} | Legs: ${legBoxTop.round()}~${legBoxBottom.round()} | Hit: ${verticalCollision && horizontalCollision}');
    }

    return verticalCollision && horizontalCollision;
  }
}
