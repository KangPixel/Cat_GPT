import 'package:flame/components.dart';
import 'dart:ui';

class ScrollingBackground extends Component {
  final Sprite sprite; // 배경 스프라이트
  final Vector2 size; // 배경 크기
  final double speed; // 배경 스크롤 속도
  final int maxRepeats; // 최대 반복 횟수
  int currentRepeats = 0; // 현재 반복 횟수
  late List<SpriteComponent> _backgrounds; // 배경 리스트 선언
  bool isScrollingComplete = false; // 스크롤 완료 여부

  ScrollingBackground({
    required this.sprite,
    required this.size,
    required this.speed,
    this.maxRepeats = 5,
  });

  @override
  Future<void> onLoad() async {
    // 배경 리스트 초기화: 2개로 시작하여 반복 스크롤
    _backgrounds = List.generate(2, (index) {
      return SpriteComponent(
        sprite: sprite,
        size: size,
        position: Vector2(size.x * index - 3, 0), // 배경을 오른쪽으로 나열, -3 픽셀 겹치기
      )..paint.filterQuality = FilterQuality.low; // 안티앨리어싱 낮게 설정
    });

    addAll(_backgrounds); // 배경 컴포넌트를 게임에 추가
  }

  @override
  void update(double dt) {
    if (isScrollingComplete) return; // 스크롤 완료 시 업데이트 중단

    // 배경 이동 로직
    for (final background in _backgrounds) {
      background.position.x -= speed * dt; // 배경을 왼쪽으로 이동

      // 배경이 화면 밖으로 나가면 오른쪽 끝으로 재배치
      if (background.position.x + size.x <= 0) {
        currentRepeats++;
        if (currentRepeats < maxRepeats) {
          background.position.x += size.x * _backgrounds.length;
        } else {
          isScrollingComplete = true; // 스크롤 완료 설정
        }
      }
    }
  }
}
