import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';

class CatGame extends FlameGame with TapCallbacks {
  late SpriteComponent background;
  late SpriteComponent cat;

  late TextComponent hungerText;
  late TextComponent fatigueText;
  late TextComponent happinessText;
  late TextComponent weightText;

  late RectangleComponent hungerBackground;
  late RectangleComponent fatigueBackground;
  late RectangleComponent happinessBackground;
  late RectangleComponent weightBackground;
  
  late List<GameButton> buttons;

  int hunger = 100; // 배고픔 (0~100)
  int fatigue = 0; // 피로도 (0~100)
  int happiness = 50; // 행복도 (0~100)
  int weight = 50;  // 체중 (20~100) (원레 종 기준 평균 4.8kg)

  @override
  Future<void> onLoad() async {
    // Load background
    background = SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size;
    add(background);

    // Load cat sprite
    cat = SpriteComponent()
      ..sprite = await loadSprite('cat.png')
      ..size = Vector2(size.x * 0.4, size.y * 0.4)
      ..position = Vector2(size.x / 2 - size.x * 0.2, size.y / 2 - size.y * 0.1);
    add(cat);

    const double backgroundPadding = 10; // 텍스트와 배경 간 여백

    // 배고픔 텍스트와 배경
    hungerBackground = RectangleComponent(
      size: Vector2(200, 40),
      position: Vector2(10, 10), // 텍스트보다 약간 위로
      paint: Paint()..color = Colors.white.withOpacity(0.7),
    );
    hungerText = TextComponent(
      text: 'Hunger: $hunger',
      position: hungerBackground.position + Vector2(backgroundPadding, backgroundPadding / 2),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 24, color: Colors.black)),
    );
    add(hungerBackground);
    add(hungerText);

    // 피로도 텍스트와 배경
    fatigueBackground = RectangleComponent(
      size: Vector2(200, 40),
      position: Vector2(10, 60),
      paint: Paint()..color = Colors.white.withOpacity(0.7),
    );
    fatigueText = TextComponent(
      text: 'Fatigue: $fatigue',
      position: fatigueBackground.position + Vector2(backgroundPadding, backgroundPadding / 2),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 24, color: Colors.black)),
    );
    add(fatigueBackground);
    add(fatigueText);

    // 행복도 텍스트와 배경
    happinessBackground = RectangleComponent(
      size: Vector2(200, 40),
      position: Vector2(10, 110),
      paint: Paint()..color = Colors.white.withOpacity(0.7),
    );
    happinessText = TextComponent(
      text: 'Happiness: $happiness',
      position: happinessBackground.position + Vector2(backgroundPadding, backgroundPadding / 2),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 24, color: Colors.black)),
    );
    add(happinessBackground);
    add(happinessText);

    // 체중 텍스트와 배경
    weightBackground = RectangleComponent(
      size: Vector2(200, 40),
      position: Vector2(10, 160),
      paint: Paint()..color = Colors.white.withOpacity(0.7),
    );
    weightText = TextComponent(
      text: 'Weight: $weight',
      position: weightBackground.position + Vector2(backgroundPadding, backgroundPadding / 2),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 24, color: Colors.black)),
    );
    add(weightBackground);
    add(weightText);

    // Add state text components
    // hungerText = TextComponent(
    //   text: 'Hunger: $hunger',
    //   position: Vector2(20, 20),
    //   textRenderer: TextPaint(style: const TextStyle(fontSize: 24, color: Colors.black)),
    // );
    // fatigueText = TextComponent(
    //   text: 'Fatigue: $fatigue',
    //   position: Vector2(20, 50),
    //   textRenderer: TextPaint(style: const TextStyle(fontSize: 24, color: Colors.black)),
    // );
    // happinessText = TextComponent(
    //   text: 'Happiness: $happiness',
    //   position: Vector2(20, 80),
    //   textRenderer: TextPaint(style: const TextStyle(fontSize: 24, color: Colors.black)),
    // );
    // weightText = TextComponent(
    //   text: 'Weight: $weight',
    //   position: Vector2(20, 110),
    //   textRenderer: TextPaint(style: const TextStyle(fontSize: 24, color: Colors.black)),
    // );
    // add(hungerText);
    // add(fatigueText);
    // add(happinessText);
    // add(weightText);

    // Add TimerComponent for periodic updates
    add(
      TimerComponent(
        period: 2, // 매 2초마다 실행
        repeat: true, // 반복 실행
        onTick: () {
          updateStates(-1, 1, -1, 0); // 배고픔 증가, 피로 증가, 행복 감소, 체중 유지
        },
      ),
    );

    // Initialize buttons
    buttons = [
      GameButton(label: 'Feed', onTap: feedCat),
      GameButton(label: 'Play', onTap: playWithCat),
      GameButton(label: 'Talk', onTap: talkToCat),
    ];
    buttons.forEach(add);
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateLayout();
  }

  void updateStates(int hungerDelta, int fatigueDelta, int happinessDelta, int weightDelta) {
    hunger = (hunger + hungerDelta).clamp(0, 100);
    fatigue = (fatigue + fatigueDelta).clamp(0, 100);
    happiness = (happiness + happinessDelta).clamp(0, 100);
    weight = (weight + weightDelta).clamp(20, 100);

    hungerText.text = 'Hunger: $hunger';
    fatigueText.text = 'Fatigue: $fatigue';
    happinessText.text = 'Happiness: $happiness';
    weightText.text = 'Weight: $weight';
  }

  void updateLayout() {
    final buttonWidth = size.x * 0.2;
    final buttonHeight = size.y * 0.08;
    final buttonY = size.y * 0.85;
    final spacing = size.x * 0.05;
    final totalWidth = (buttonWidth * 3) + (spacing * 2);
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
    updateStates(20, 0, 10, 10); // 배고픔 감소, 행복 증가, 체중 증가
  }

  void playWithCat() {
    updateStates(0, 10, 15, -10); // 피로 증가, 행복 증가, 체중 감소
  }

  void talkToCat() {
    updateStates(0, -10, 10, 0); // 피로 감소, 행복 증가
  }
}

class GameButton extends PositionComponent with TapCallbacks {
  final String label;
  final VoidCallback onTap;
  final Paint _paint = Paint()..color = Colors.blue;
  late TextComponent _labelComponent;

  GameButton({
    required this.label,
    required this.onTap,
  }) : super();

  @override
  Future<void> onLoad() async {
    // 텍스트 컴포넌트 생성
    _labelComponent = TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
    add(_labelComponent);
    updateTextPosition(); // 텍스트를 중앙에 맞추기
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
    super.render(canvas);
  }

  // 버튼 크기와 위치를 기준으로 텍스트를 중앙에 배치
  void updateTextPosition() {
    _labelComponent.position = Vector2(
      size.x / 2 - _labelComponent.size.x / 2, // 버튼의 가로 중앙
      size.y / 2 - _labelComponent.size.y / 2, // 버튼의 세로 중앙
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
    updateTextPosition(); // 버튼 크기 변경 시 텍스트 위치 갱신
  }
}