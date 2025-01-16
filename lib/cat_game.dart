// cat_game.dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'status.dart';

class CatGame extends FlameGame {
  late SpriteComponent background;
  late SpriteComponent cat;
  late TextComponent countdown;
  int touchCount = 0;
  int remainingDays = 10;

  final VoidCallback onTalk;
  final ValueNotifier<int> barValue = ValueNotifier<int>(100); // 막대 그래프 초기 값

  CatGame({required this.onTalk});

  @override
  Future<void> onLoad() async {
    // 배경 이미지 로드
    background = SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size;
    add(background);

    // 고양이 스프라이트 추가
    cat = SpriteComponent()
      ..sprite = await loadSprite('grayCat.png')
      ..size = Vector2(size.x * 0.4, size.y * 0.4)
      ..position = Vector2(size.x / 2 - size.x * 0.2, size.y / 2 - size.y * 0.1);
    add(cat);

    // 카운트다운 텍스트 추가
    countdown = TextComponent(
      text: 'D-day: $remainingDays',
      position: Vector2(size.x * 0.8, size.y / 5.5),
      anchor: Anchor.topCenter,
    );
    add(countdown);

    // 고양이 스프라이트 클릭 이벤트 설정
    add(TappableAreaComponent(cat, onTap: _onCatTap));
  }

  void _onCatTap() {
    touchCount += 1;
    catStatus.updateStatus(intimacyDelta: 5); // 친밀도 증가
    _changeCatSpriteTemporarily(); // 스프라이트 변경

    // 막대 그래프 값 변경
    barValue.value = (barValue.value - 10) % 101;
  }

  Future<void> _changeCatSpriteTemporarily() async {
    // 스프라이트 변경
    final originalSprite = cat.sprite;
    cat.sprite = await loadSprite('grayCat_open_mouth.png');
    await Future.delayed(const Duration(milliseconds: 500)); // 0.5초 대기
    cat.sprite = originalSprite; // 원래 스프라이트로 복구
  }
}

class TappableAreaComponent extends PositionComponent with TapCallbacks {
  final SpriteComponent target;
  final VoidCallback onTap;

  TappableAreaComponent(this.target, {required this.onTap}) {
    size = target.size;
    position = target.position;
  }

  @override
  void onTapDown(TapDownEvent event) {
    print('TappableAreaComponent tapped'); // 디버깅용 출력
    onTap();
  }
}

class GameScreen extends StatelessWidget {
  final CatGame game; // CatGame 인스턴스 생성
  GameScreen({Key? key})
      : game = CatGame(onTalk: () => print("Talk button pressed")),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GameWidget(
            game: game,
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: _buildHorizontalBar(), // 막대 그래프 위젯
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: _buildButtonWithBackground(
              context,
              label: 'Play',
              backgroundImage: 'assets/images/grayCat.png',
              onTap: () {
                print("Play button pressed");
                catStatus.updateStatus(hungerDelta: -10);
              },
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildButtonWithBackground(
              context,
              label: 'Talk',
              backgroundImage: 'assets/images/grayCat_open_mouth.png',
              onTap: () {
                print("Talk button pressed");
                catStatus.updateStatus(intimacyDelta: 5);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalBar() {
    return ValueListenableBuilder<int>(
      valueListenable: game.barValue, // CatGame의 barValue 사용
      builder: (context, value, _) {
        // 색상 결정
        Color barColor;
        if (value <= 30) {
          barColor = Colors.red;
        } else if (value <= 70) {
          barColor = Colors.yellow;
        } else {
          barColor = Colors.green;
        }

        return Container(
          width: double.infinity,
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              Center(
                child: Text(
                  '$value%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButtonWithBackground(
    BuildContext context, {
    required String label,
    required String backgroundImage,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 60,
      width: 140,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage), // 버튼 배경 이미지
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // 배경 투명 처리
          shadowColor: Colors.transparent, // 그림자 제거
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
