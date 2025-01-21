import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame/flame.dart'; // Flame 패키지 임포트
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_suika_game/model/fruit.dart';

class PhysicsFruit extends BodyComponent {
  PhysicsFruit({
    required this.fruit,
    this.isStatic = false,
    this.overrideRadius,
  }) : super(
          paint: BasicPalette.transparent.paint(),
        );

  final Fruit fruit;
  final bool isStatic;
  final double? overrideRadius;

  late final SpriteComponent _spriteComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // fruit.image 값만 사용하여 경로 설정
      final imagePath = 'suika_game/${fruit.image}';
      print('Loading sprite from path: $imagePath');

      // 에셋 로드
      final spriteImage = await Flame.images.load(imagePath);
      print('Sprite loaded successfully: $imagePath');

      // SpriteComponent 생성
      _spriteComponent = SpriteComponent(
        sprite: Sprite(spriteImage),
        size: Vector2.all((overrideRadius ?? fruit.radius) * 2),
        anchor: Anchor.center,
      );

      add(_spriteComponent);
    } catch (e) {
      print('Error loading sprite: $e');
    }
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = overrideRadius ?? fruit.radius;

    final fixtureDef = FixtureDef(
      shape,
      restitution: Fruit.restitution,
      density: Fruit.density,
      friction: Fruit.friction,
    );

    final bodyDef = BodyDef(
      userData: this,
      position: fruit.pos,
      type: isStatic ? BodyType.static : BodyType.dynamic,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    super.renderCircle(canvas, center, radius);

    canvas.drawLine(
      center,
      center + Offset(0, radius),
      BasicPalette.black.paint(),
    );
  }
}
