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
  late SpriteComponent cat;
  late Sprite _normalSprite; // 일반 스프라이트 저장용
  late Sprite _openMouthSprite; // 입 벌린 스프라이트 저장용
  late CalendarComponent _calendarComponent;

  @override
  Future<void> onLoad() async {
    instance = this;

    // 고양이 스프라이트 미리 로드
    _normalSprite = await loadSprite('gray_cat.png');
    _openMouthSprite = await loadSprite('gray_cat_open_mouth.png');

    cat = SpriteComponent()
      ..sprite = _normalSprite
      ..size = Vector2(size.x * 0.45, size.y * 0.4)
      ..position = Vector2(
        size.x / 2 - size.x * 0.23,
        size.y / 2 - size.y * 0.18,
      );
    add(cat);

    // 캘린더 컴포넌트 추가
    _calendarComponent = CalendarComponent(dayManager.currentDay)
      ..position = Vector2(size.x * 0.7, size.y / 19.0);
    add(_calendarComponent);
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
    _calendarComponent.updateDays(dayManager.currentDay); // 캘린더 업데이트
  }
}

// D - day 표시 (달력 모양)
class CalendarComponent extends PositionComponent {
  int remainingDays;
  late TextComponent daysTextComponent;

  CalendarComponent(this.remainingDays);

  @override
  Future<void> onLoad() async {
    size = Vector2(85, 60);

    // 빨간색 상단 사각형
    add(RectangleComponent(
      position: Vector2(0, 0),
      size: Vector2(size.x, size.y * 0.25),
      paint: Paint()..color = Colors.red,
    ));

    // 흰색 하단 사각형
    add(RectangleComponent(
      position: Vector2(0, size.y * 0.25),
      size: Vector2(size.x, size.y * 0.75),
      paint: Paint()..color = Colors.white,
    ));

    // 일반 텍스트 부분
    add(TextComponent(
      text: 'D -',
      position: Vector2(size.x / 4, size.y * 0.6),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ));

    // 붉은 색으로 강조된 날짜 텍스트
    daysTextComponent = TextComponent(
      text: '$remainingDays',
      position: Vector2(size.x / 2 + 15, size.y * 0.6),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
    add(daysTextComponent);
  }

  // 날짜 업데이트 메서드
  void updateDays(int newDays) {
    remainingDays = newDays;
    daysTextComponent.text = '$remainingDays';
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
