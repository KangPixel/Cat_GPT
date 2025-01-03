import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class FeedingGame extends FlameGame {
  late Rect character;
  late Paint characterPaint;

  double growthRate = 10;

  @override
  Future<void> onLoad() async {
    character = Rect.fromLTWH(100, 100, 50, 50);
    characterPaint = Paint()..color = Colors.blue;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(character, characterPaint);
  }

  void feedCharacter() {
    character = character.inflate(growthRate);
  }
}
