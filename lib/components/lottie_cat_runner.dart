import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import '../day10_stats.dart';
import '../cat_racing_game.dart';
import '../day10_stats.dart';

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

  late Widget lottieAnimation; // ✅ Lottie 애니메이션 (Widget으로 저장)

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

    // catNameMap에서 color를 기반으로 이름 가져오기
    String catName = gameRef.catNameMap[color] ?? color;

    print("✅ [Debug] $catName 초기 위치: ${position.x}");

    // ✅ 30초 동안 이동해야 할 거리 설정
    distancePerSecond = (gameRef.size.x - 50) / raceDuration;

    // ✅ 모든 고양이에 좌우 반전 적용
    Widget lottie = Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi), // 🔹 좌우 반전
      child: Lottie.asset(
        'assets/cat_run.json',
        width: size.x,
        height: size.y,
        fit: BoxFit.cover,
        repeat: true,
      ),
    );

    // ✅ Player는 원본 사용, AI 3마리는 색상 반전 적용
    if (catName == "Player") {
      lottieAnimation = lottie; // 원본 적용
    } else {
      lottieAnimation = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          -1,  0,  0,  0, 255, // R 반전
           0, -1,  0,  0, 255, // G 반전
           0,  0, -1,  0, 255, // B 반전
           0,  0,  0,  1,   0, // Alpha 유지
        ]),
        child: lottie, // 🔹 색상 반전된 Lottie 적용
      );
    }

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

    // player에게만 보너스 속도 추가
    if (color == 'one') { //player인지 확인
      double bonusSpeed = day10Stats.normalizedScore * 0.1; //보너스 스코어를 속도에 반영
      currentSpeed += bonusSpeed;
    }

    // ✅ 속도 제한 (너무 빠르거나 느리지 않도록 조정)
    currentSpeed = currentSpeed.clamp(0.1, 1.2); //보너스 반영하여 최대 속도 증가 가능능
 
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

    // ✅ Lottie 애니메이션 업데이트
    gameRef.overlays.remove(color);
    gameRef.overlays.add(color);
  }

  Widget buildLottieOverlay(BuildContext context) {
    return Positioned(
      left: position.x,
      top: position.y,
      child: lottieAnimation, // ✅ 반전된 Lottie 적용
    );
  }
}
