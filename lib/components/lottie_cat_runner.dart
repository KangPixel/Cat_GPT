import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import '../day10_stats.dart';
import '../cat_racing_game.dart';

class LottieCatRunner extends PositionComponent with HasGameRef<CatRacingGame> {
  final double baseSpeed;
  final double speedVariation;
  final double raceDuration;
  final String color;
  final double speedFrequency;
  final double phaseOffset;
  final Random random = Random();

  double elapsedTime = 0.0;
  double currentSpeed = 0.0;
  bool hasFinished = false;

  late double distancePerSecond;

  late LottieBuilder lottieAnimation;

  LottieCatRunner({
    required this.raceDuration,
    required Vector2 position,
    required Vector2 size,
    required this.color,
    this.baseSpeed = 0.5,
    this.speedVariation = 1.0,
    this.speedFrequency = 1.5,
    this.phaseOffset = 0.0,
  }) : super(position: position, size: size) {
    currentSpeed = baseSpeed;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    gameRef.overlays.add(color);

    // ✅ 30초 동안 이동해야 할 거리 설정
    distancePerSecond = (gameRef.size.x - 50) / raceDuration;

    // ✅ Lottie 애니메이션을 설정하고 초기화
    lottieAnimation = Lottie.asset(
      'assets/cat_run.json',
      width: size.x,
      height: size.y,
      fit: BoxFit.cover,
      repeat: true,
    );

    print("✅ [Debug] $color 초기 위치: ${position.x}");
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (hasFinished) return;

    elapsedTime += dt;

    // ✅ 속도 변동 추가 (랜덤한 요소 추가)
    double variation = sin((elapsedTime * 2 * pi / speedFrequency) + phaseOffset) * speedVariation;
    currentSpeed = baseSpeed + variation;

    // ✅ 속도 제한 (너무 빠르거나 느리지 않도록 조정)
    currentSpeed = currentSpeed.clamp(0.1, 1.0);

    // ✅ 거리 기반 이동
    position.x += currentSpeed * dt * 50;

    // ✅ 디버깅용 로그 출력
    print("Color: $color, Position: ${position.x}, Speed: $currentSpeed");

    // ✅ 결승선 도달 확인
    if (position.x >= gameRef.size.x - size.x) {
      position.x = gameRef.size.x - size.x;
      hasFinished = true;
      gameRef.registerFinish(this);
    }

    // ✅ **Lottie 애니메이션 위치를 업데이트**
    gameRef.overlays.remove(color);
    gameRef.overlays.add(color);
  }

  Widget buildLottieOverlay(BuildContext context) {
    return Positioned(
      left: position.x, // ✅ 고양이의 위치를 업데이트하여 반영
      top: position.y,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(pi), // ✅ 좌우 반전 적용
        child: lottieAnimation, // ✅ 기존 Lottie 애니메이션 사용
      ),
    );
  }
}
