import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'cat_game.dart'; // CatGame을 가져옵니다.

class FishComponent extends SpriteComponent with HasGameRef, CollisionCallbacks {
  FishComponent({Vector2? position, Vector2? size})
      : super(
          position: position,
          size: size ?? Vector2(64, 64), // 물고기 크기
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('fish.png'); // fish.png 로드
    add(RectangleHitbox()); // 충돌 감지 추가
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += Vector2(0, 200 * dt); // 아래로 떨어지도록 위치 업데이트

    // 화면 아래로 나가면 제거
    if (position.y > gameRef.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is SpriteAnimationComponent) {
      final catGame = gameRef as CatGame; // CatGame으로 gameRef를 캐스팅
      catGame.startJumpAnimation(); // 고양이의 점프 애니메이션 실행
      removeFromParent(); // 물고기 삭제
    }
    super.onCollision(intersectionPoints, other);
  }
}
