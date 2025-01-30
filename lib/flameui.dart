//flameui.dart flame으로 구현한 ui
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'status.dart';
import 'day.dart';
import 'touch.dart';

class CatGame extends FlameGame with TapDetector {
  static CatGame? instance;
  late SpriteComponent background;
  late SpriteComponent cat;
  late TextComponent _countdown;
  late Sprite _normalSprite; // 일반 스프라이트 저장용
  late Sprite _openMouthSprite; // 입 벌린 스프라이트 저장용

  @override
  Future<void> onLoad() async {
    instance = this;
    background = SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size;
    add(background);

    // 스프라이트 미리 로드
    _normalSprite = await loadSprite('grayCat.png');
    _openMouthSprite = await loadSprite('grayCat_open_mouth.png');

    cat = SpriteComponent()
      ..sprite = _normalSprite
      ..size = Vector2(size.x * 0.4, size.y * 0.4)
      ..position = Vector2(
        size.x / 2 - size.x * 0.2,
        size.y / 2 - size.y * 0.1,
      );
    add(cat);

    _countdown = TextComponent(
      text: 'D-day: ${dayManager.currentDay}',
      position: Vector2(size.x * 0.8, size.y / 5.5),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
    add(_countdown);
  }

  @override
  bool onTapUp(TapUpInfo info) {
    final touchPosition = info.eventPosition.global;

    final catRect = cat.toRect();
    if (catRect.contains(touchPosition.toOffset())) {
      if (touchManager.touchCount < 2) {
        // 터치 횟수 체크
        touchManager.touchCat();
        _changeCatSpriteTemporarily();
      } else {
        print("No more touches allowed today!");
      }
      return true;
    }

    return false;
  }

  Future<void> _changeCatSpriteTemporarily() async {
    cat.sprite = _openMouthSprite;
    await Future.delayed(const Duration(milliseconds: 500));
    cat.sprite = _normalSprite; // 원래 스프라이트로 반드시 복구
  }

  // 잠자기 기능에서 호출할 리셋 함수
  void resetGame() {
    touchManager.resetTouchCount();
    cat.sprite = _normalSprite; // 스프라이트도 초기상태로 리셋
    updateDday();
  }

  void updateDday() {
    _countdown.text = 'D-day: ${dayManager.currentDay}';
  }
}

class FlameGameScreen extends StatelessWidget {
  final CatGame game = CatGame();

  FlameGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: game),
    );
  }
}
