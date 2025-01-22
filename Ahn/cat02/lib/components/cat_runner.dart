import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../day10_stats.dart';

class CatRunner extends SpriteAnimationComponent with HasGameRef {
  final double baseSpeed; // 기본 속도 (고정값)
  final double speedVariation; // 속도 변동 폭
  final double raceDuration; // 경주 시간
  final String color; // 고양이 색상
  final double speedFrequency; // 속도 변동 주기
  final double phaseOffset; // 고양이별 위상 차이
  final Random random = Random();

  double elapsedTime = 0.0; // 경과 시간
  double currentSpeed = 0.0; // 현재 속도
  double boostTime = 0.0; // 다음 부스트까지의 시간

  CatRunner({
    required List<Sprite> frames,
    required this.raceDuration,
    required Vector2 position,
    required Vector2 size,
    required this.color,
    this.baseSpeed = 3.0,
    this.speedVariation = 3.0,
    this.speedFrequency = 8.0,
    this.phaseOffset = 0.0,
  }) : super(
          position: position,
          size: size,
          animation: SpriteAnimation.spriteList(
            frames,
            stepTime: 0.1,
          ),
        ) {
    currentSpeed = baseSpeed; // 초기 속도 설정
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 경과 시간 업데이트
    elapsedTime += dt;
    boostTime += dt;

    // 고양이 1만 스탯 보너스 적용
    double speedBonus = 0.0;
    if (color == 'one') {
      print("Normalized Score for 'one': ${day10Stats.normalizedScore}");
      speedBonus = day10Stats.normalizedScore; // day10Stats에서 보너스 값 가져오기
    }

    // 랜덤 변동
    double variation = sin((elapsedTime * 2 * pi / (speedFrequency * 1000)) + phaseOffset) * speedVariation;

    // 추가 부스트
    if (boostTime > (1.0 + random.nextDouble() * 2.0)) {
      variation += random.nextDouble() * 5.0; // 최대 5픽셀/초 부스트
      boostTime = 0.0;
    }

    // 패널티 적용
    if (random.nextDouble() < 0.1) { // 10% 확률로 패널티
      variation -= random.nextDouble() * 2.0;
    }

    // 최종 속도 계산 (기본 속도 + 보너스 + 변동값)
    currentSpeed = baseSpeed + speedBonus + variation;

    // 속도 제한
    currentSpeed = currentSpeed.clamp(1.0, 20.0);

    // 고양이 위치 업데이트
    position.x += currentSpeed * dt;

    // 위치 업데이트 로그
    print("Color: $color, Current Speed: $currentSpeed, Updated Position: ${position.x}");

    // 화면을 초과하지 않도록 제한
    if (position.x > gameRef.size.x - size.x) {
      position.x = gameRef.size.x - size.x;
    }

    print("Color: $color, Current Speed: $currentSpeed, Position: ${position.x}");
  }
}
