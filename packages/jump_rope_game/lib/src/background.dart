//packages/jump_rope_game/lib/src/background.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'game_core.dart';

class Background extends PositionComponent with HasGameRef<JumpRopeGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = gameRef.size;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Color(0xFFF5F5DC),
    );

    final linePaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.y; y += 20) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.x, y),
        linePaint,
      );
    }

    _drawSun(canvas, Offset(size.x * 0.8, size.y * 0.2));
    _drawCloud(canvas, Offset(size.x * 0.2, size.y * 0.15));
    _drawCloud(canvas, Offset(size.x * 0.6, size.y * 0.25));
    _drawCuteTree(canvas, size.x * 0.15, size.y * 0.6);
    _drawCuteTree(canvas, size.x * 0.85, size.y * 0.6);
    _drawGrassAndFlowers(canvas);
  }

  void _drawSun(Canvas canvas, Offset position) {
    final paint = Paint()..color = Colors.orange.shade300;
    canvas.drawCircle(position, 25, paint);

    final facePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCenter(center: position.translate(-7, -2), width: 8, height: 8),
      0,
      math.pi,
      false,
      facePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: position.translate(7, -2), width: 8, height: 8),
      0,
      math.pi,
      false,
      facePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: position.translate(0, 5), width: 16, height: 16),
      0,
      math.pi,
      false,
      facePaint,
    );
  }

  void _drawCloud(Canvas canvas, Offset position) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(position, 20, paint);
    canvas.drawCircle(position.translate(-15, 5), 15, paint);
    canvas.drawCircle(position.translate(15, 5), 15, paint);
  }

  void _drawCuteTree(Canvas canvas, double x, double y) {
    final trunkPaint = Paint()..color = Colors.brown.shade300;
    canvas.drawRect(
      Rect.fromLTWH(x - 8, y - 80, 16, 80),
      trunkPaint,
    );

    final leafPaint = Paint()..color = Colors.green.shade300;
    final path = Path();
    path.moveTo(x, y - 80);
    path.quadraticBezierTo(x + 30, y - 120, x, y - 60);
    path.quadraticBezierTo(x - 30, y - 120, x, y - 80);
    canvas.drawPath(path, leafPaint);
  }

  void _drawGrassAndFlowers(Canvas canvas) {
    final random = math.Random(42);
    final grassPaint = Paint()..color = Colors.green.shade200;

    for (int i = 0; i < 20; i++) {
      double x = random.nextDouble() * size.x;
      double baseY = size.y * 0.67;

      final path = Path();
      path.moveTo(x, baseY);
      path.quadraticBezierTo(
        x - 5,
        baseY - 15,
        x,
        baseY - 20,
      );
      canvas.drawPath(path, grassPaint);
    }

    for (int i = 0; i < 10; i++) {
      double x = random.nextDouble() * size.x;
      double y = size.y * 0.63 + random.nextDouble() * 20;

      final flowerColors = [
        Colors.yellow.shade200,
        Colors.pink.shade200,
        Colors.orange.shade200,
      ];
      final color = flowerColors[random.nextInt(flowerColors.length)];

      canvas.drawCircle(Offset(x, y), 3, Paint()..color = color);

      for (int j = 0; j < 5; j++) {
        double angle = j * math.pi * 2 / 5;
        double petalX = x + math.cos(angle) * 5;
        double petalY = y + math.sin(angle) * 5;
        canvas.drawCircle(
          Offset(petalX, petalY),
          2,
          Paint()..color = color,
        );
      }
    }
  }
}
