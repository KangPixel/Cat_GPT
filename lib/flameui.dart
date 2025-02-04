// flameui.dart (flame으로 구현한 ui)
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'status.dart';
import 'day.dart';
import 'touch.dart';
// import 'onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CatGame extends FlameGame with TapDetector {
  static CatGame? instance;
  late SpriteComponent cat;
  // 스프라이트를 정의
  late final Sprite _openMouthSprite;
  late final Sprite _normalSprite;

  late CalendarComponent _calendarComponent;

  @override
  Future<void> onLoad() async {
    instance = this;

    // SharedPreferences에서 선택한 고양이 종 가져오기
    final prefs = await SharedPreferences.getInstance();
    String selectedCat = prefs.getString('selectedCat') ?? '회냥이'; // 기본값

    // 선택한 고양이 종에 맞는 이미지 파일 매핑
    final Map<String, String> catImages = {
      '회냥이': 'gray_cat',
      '흰냥이': 'white_cat',
      '갈냥이': 'brown_cat',
      '아이보리냥이': 'ivory_cat',
    };

    String catFileName = catImages[selectedCat] ?? 'gray_cat';

    _normalSprite = await loadSprite('cat/$catFileName.png');
    _openMouthSprite = await loadSprite('cat/${catFileName}_open_mouth.png');

    // ValueNotifier에 초기 스프라이트 설정
    catStatus.catSprite.value = _normalSprite;

    // 이미지 원본 비율 유지하며 크기 조정
    double catWidth = size.x * 0.45;
    double aspectRatio = _normalSprite.image.height / _normalSprite.image.width;
    double catHeight = catWidth * aspectRatio;

    // 고양이 컴포넌트
    cat = SpriteComponent()
      ..sprite = catStatus.catSprite.value
      // ..size = Vector2(size.x * 0.45, size.y * 0.4)
      ..size = Vector2(catWidth, catHeight)
      ..position = Vector2(
        (size.x - catWidth) / 2,
        size.y / 2 - catHeight * 0.45,
      );
    add(cat);

    // 캘린더 컴포넌트 추가
    _calendarComponent = CalendarComponent(dayManager.currentDay)
      ..position = Vector2(size.x * 0.7, size.y / 19.0);
    add(_calendarComponent);

    // ValueNotifier 리스너 추가 (스프라이트 변경 감지)
    catStatus.catSprite.addListener(() {
      cat.sprite = catStatus.catSprite.value; // 상태 변경 시 자동 업데이트
    });
  }

  // ✅ 외부에서 접근할 수 있도록 Getter 추가
  Sprite get normalSprite => _normalSprite;
  Sprite get openMouthSprite => _openMouthSprite;

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
    catStatus.catSprite.value = _openMouthSprite; // ValueNotifier로 스프라이트 변경
    await Future.delayed(const Duration(milliseconds: 500));
    catStatus.catSprite.value = _normalSprite; // 원래 상태 복구
  }

  // 잠자기 기능에서 호출할 리셋 함수
  // void resetGame() {
  //   touchManager.resetTouchCount();
  //   catStatus.catSprite.value = _normalSprite; // 스프라이트 초기화
  //   updateDday();
  // }

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
      text: ' D -',
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
