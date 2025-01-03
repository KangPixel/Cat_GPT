import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'status.dart';

class CatGame extends FlameGame with TapCallbacks {
  late SpriteComponent background;
  late SpriteComponent cat;

  late TextComponent hungerText;
  late TextComponent fatigueText;
  late TextComponent happinessText;
  late TextComponent weightText;

  late List<GameButton> buttons;

  final VoidCallback onTalk;

  CatGame({required this.onTalk});

  @override
  Future<void> onLoad() async {
    // Background loading
    background = SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size;
    add(background);

    // Cat sprite loading
    cat = SpriteComponent()
      ..sprite = await loadSprite('cat.png')
      ..size = Vector2(size.x * 0.4, size.y * 0.4)
      ..position = Vector2(size.x / 2 - size.x * 0.2, size.y / 2 - size.y * 0.1);
    add(cat);

    // Text components
    hungerText = TextComponent(
      text: 'Hunger: ${catStatus.hunger.value}',
      position: Vector2(10, 10),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 24, color: Colors.white)),
    );
    fatigueText = TextComponent(
      text: 'Fatigue: ${catStatus.fatigue.value}',
      position: Vector2(10, 40),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 24, color: Colors.white)),
    );
    happinessText = TextComponent(
      text: 'Happiness: ${catStatus.happiness.value}',
      position: Vector2(10, 70),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 24, color: Colors.white)),
    );
    weightText = TextComponent(
      text: 'Weight: ${catStatus.weight.value}',
      position: Vector2(10, 100),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 24, color: Colors.white)),
    );

    add(hungerText);
    add(fatigueText);
    add(happinessText);
    add(weightText);

    // Listen for changes in catStatus and update text
    catStatus.hunger.addListener(() {
      hungerText.text = 'Hunger: ${catStatus.hunger.value}';
    });
    catStatus.fatigue.addListener(() {
      fatigueText.text = 'Fatigue: ${catStatus.fatigue.value}';
    });
    catStatus.happiness.addListener(() {
      happinessText.text = 'Happiness: ${catStatus.happiness.value}';
    });
    catStatus.weight.addListener(() {
      weightText.text = 'Weight: ${catStatus.weight.value}';
    });

    // Game buttons
    buttons = [
      GameButton(label: 'Feed', onTap: feedCat),
      GameButton(label: 'Play', onTap: playWithCat),
      GameButton(label: 'Talk', onTap: onTalk),
    ];
    updateLayout();
    buttons.forEach(add);
  }

  void updateLayout() {
    final buttonWidth = size.x * 0.25;
    final buttonHeight = size.y * 0.1;
    final buttonY = size.y * 0.85; // 화면 하단에 고정
    final spacing = size.x * 0.05;
    final totalWidth = (buttonWidth * buttons.length) + (spacing * (buttons.length - 1));
    final startX = (size.x - totalWidth) / 2;

    for (var i = 0; i < buttons.length; i++) {
      buttons[i]
        ..size = Vector2(buttonWidth, buttonHeight)
        ..position = Vector2(
          startX + (buttonWidth + spacing) * i,
          buttonY,
        );
    }
  }

  void feedCat() {
    catStatus.updateStatus(hungerDelta: -10, happinessDelta: 5);
  }

  void playWithCat() {
    catStatus.updateStatus(fatigueDelta: 10, happinessDelta: 10);
  }
}

class GameButton extends PositionComponent with TapCallbacks {
  final String label;
  final VoidCallback onTap;
  final Paint _paint = Paint()..color = Colors.blue;
  late TextComponent _labelComponent;

  GameButton({required this.label, required this.onTap});

  @override
  Future<void> onLoad() async {
    _labelComponent = TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
    add(_labelComponent);
    updateTextPosition();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
    super.render(canvas);
  }

  void updateTextPosition() {
    _labelComponent.position = Vector2(
      size.x / 2 - _labelComponent.size.x / 2,
      size.y / 2 - _labelComponent.size.y / 2,
    );
  }

  @override
  bool onTapDown(TapDownEvent event) {
    onTap();
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateTextPosition();
  }
}
