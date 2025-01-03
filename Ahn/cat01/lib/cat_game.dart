import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/collisions.dart';
import 'fish_component.dart';

class CatGame extends FlameGame with HasCollisionDetection {
  late SpriteAnimationComponent cat;

  late SpriteAnimation idleAnimation;
  late SpriteAnimation jumpAnimation;
  late SpriteAnimation deadAnimation;
  late SpriteAnimation runAnimation;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Idle 애니메이션 로드
    final idleFrames = await images.loadAll([
      for (int i = 1; i <= 11; i++) 'idle/frame$i.png',
    ]);
    idleAnimation = SpriteAnimation.spriteList(
      idleFrames.map((image) => Sprite(image)).toList(),
      stepTime: 0.1,
    );

    // Jump 애니메이션 로드
    final jumpFrames = await images.loadAll([
      for (int i = 1; i <= 5; i++) 'jump/frame$i.png',
    ]);
    jumpAnimation = SpriteAnimation.spriteList(
      jumpFrames.map((image) => Sprite(image)).toList(),
      stepTime: 0.1,
    );

    // Dead 애니메이션 로드
    final deadFrames = await images.loadAll([
      for (int i = 1; i <= 8; i++) 'dead/frame$i.png',
    ]);
    deadAnimation = SpriteAnimation.spriteList(
      deadFrames.map((image) => Sprite(image)).toList(),
      stepTime: 0.1,
    );

    // Run 애니메이션 로드
    final runFrames = await images.loadAll([
      for (int i = 1; i <= 10; i++) 'run/frame$i.png',
    ]);
    runAnimation = SpriteAnimation.spriteList(
      runFrames.map((image) => Sprite(image)).toList(),
      stepTime: 0.1,
    );

    // 고양이 추가
    cat = SpriteAnimationComponent()
      ..animation = idleAnimation
      ..size = Vector2(128, 128)
      ..position = Vector2(50, size.y - 150) // 바닥 근처에 고양이 배치
      ..add(RectangleHitbox()); // 충돌 감지 추가

    add(cat);
  }

  void startJumpAnimation() {
    cat.animation = jumpAnimation;
    Future.delayed(
      const Duration(milliseconds: 500),
      () => cat.animation = idleAnimation,
    );
  }

  void startDeadAnimation() {
    cat.animation = deadAnimation;
    Future.delayed(
      const Duration(milliseconds: 800),
      () => cat.animation = idleAnimation,
    );
  }

  void startRunAnimation() {
    cat.animation = runAnimation;
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => cat.animation = idleAnimation,
    );
  }

  void dropFish() {
    final fish = FishComponent(
      position: Vector2(cat.position.x + cat.size.x / 2 - 32, 0), // 화면 중앙 상단에서 시작
      size: Vector2(64, 64), // 물고기 크기
    );
    add(fish); // 물고기 추가
  }
}
