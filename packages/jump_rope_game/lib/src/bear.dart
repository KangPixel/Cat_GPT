import 'package:flame/components.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RopeWithBears extends PositionComponent {
  Vector2? playerPosition;
  late final Sprite leftBear;
  late final Sprite rightBear;

  // 현재 줄 각도
  double angle = math.pi / 3;

  // 첫 바퀴 속도 (시계 방향)
  final double baseSwingSpeed = -2.5;
  // 현재 줄 속도
  double swingSpeed = -2.5;

  // 줄의 굴곡(진폭)
  final double ropeAmplitude = 100.0;

  // 줄이 돌아가고 있는지 여부
  bool started = false;

  // 고양이 크기/위치 (충돌 체크용)
  Vector2 catBounds;
  Vector2 catPosition;

  // 줄이 뒤쪽(angle in [0.4..4.0])으로 넘어갔을 때 속도 바꾸는 용도
  bool hasJustGoneBehind = false;

  // 첫 바퀴인지 여부 (첫 바퀴엔 -2.5 그대로)
  bool firstRound = true;

  RopeWithBears({
    required this.catBounds,
    required this.catPosition,
  });

  @override
  Future<void> onLoad() async {
    // 곰 스프라이트 로드
    leftBear = await Sprite.load('left_bear.png');
    rightBear = await Sprite.load('right_bear.png');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!started) return;

    // 줄 각도 업데이트
    angle += swingSpeed * dt;

    // 시계 방향(음수)로 갈 때 angle이 0 미만 → 2π 더해 한 바퀴 인식
    if (angle < 0) {
      angle += math.pi * 2;
      firstRound = false;
    }
    // 반시계(양수)로 갈 때 angle이 2π 이상이면 → 2π 빼기
    else if (angle >= math.pi * 2) {
      angle -= math.pi * 2;
      firstRound = false;
    }

    // angle < 0.4 or angle > 4.0 => 줄이 '앞쪽'
    // 그 밖(0.4 <= angle <= 4.0) => 줄이 '뒤쪽'
    //else부분이 줄을 넘은 직후구간
    if (angle < 0.4 || angle > 4.0) {
      priority = 2;
      hasJustGoneBehind = false;
    } else {
      priority = 0;

      // "처음 뒤쪽 구간에 들어갔을 때"만 속도 변경
      if (!hasJustGoneBehind) {
        hasJustGoneBehind = true;
        if (!firstRound) {
          _randomizeRopeSpeed();
        }
      }
    }
  }

  /// 두 번째 바퀴부터 -3 ~ -15 사이 랜덤 속도로!
  void _randomizeRopeSpeed() {
    final rand = math.Random();
    // factor: 1.2 ~ 6.0 => 최종 -3 ~ -15
    final factor = 1.2 + 0.9 * rand.nextDouble();
    swingSpeed = baseSwingSpeed * factor;
    // 예: print('New rope speed = $swingSpeed');
  }

  @override
  void render(Canvas canvas) {
    canvas.save();

    _drawRope(canvas);
    _drawBears(canvas);

    // (기존 로직) angle이 특정 범위면 고양이 히트박스를 덮는 Rect
    if (angle < -0.1 || angle > math.pi - 0.1) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(catPosition.x, catPosition.y),
          width: catBounds.x,
          height: catBounds.y,
        ),
        Paint()..color = const Color(0xFFF5F5DC),
      );
    }

    canvas.restore();
  }

  void _drawRope(Canvas canvas) {
    final path = Path()
      ..moveTo(100, 0)
      ..quadraticBezierTo(0, -ropeAmplitude * math.sin(angle), -100, 0);

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFC0CB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
  }

  void _drawBears(Canvas canvas) {
    leftBear.render(canvas,
        position: Vector2(-150, -50), size: Vector2(75, 75));
    rightBear.render(canvas, position: Vector2(70, -50), size: Vector2(75, 75));
  }

  /// 초기 위치(게임 시작 시)
  void initializePosition(Vector2 screenSize, Vector2 playerPosition) {
    position = Vector2(playerPosition.x, screenSize.y * 0.6);
    this.playerPosition = playerPosition;
  }

  /// 줄 돌리기 시작
  void start() {
    started = true;
  }

  /// 줄 회전 멈춤 / 리셋
  void reset() {
    angle = math.pi / 3;
    started = false;
    swingSpeed = baseSwingSpeed;
    hasJustGoneBehind = false;
    firstRound = true;
  }

  /// 고양이와 충돌 체크
  bool checkCollision() {
    // "줄이 앞으로 움직일 때(π~1.5π)"만 체크하는 기존 로직
    if (angle > math.pi && angle < math.pi * 1.5) return false;

    final ropeY = position.y - (ropeAmplitude * math.sin(angle));

    final legBoxTop = playerPosition!.y + (catBounds.y * 0.65);
    final legBoxBottom = playerPosition!.y + (catBounds.y * 0.67);
    final legBoxLeft = playerPosition!.x - (catBounds.x * 0.20);
    final legBoxRight = playerPosition!.x + (catBounds.x * 0.20);

    final ropeLeft = position.x - 100;
    final ropeRight = position.x + 100;

    // 충돌 조건
    final verticalCollision = (ropeY >= legBoxTop) && (ropeY <= legBoxBottom);
    final horizontalCollision =
        (ropeLeft <= legBoxRight) && (ropeRight >= legBoxLeft);

    // '&&'로 최종 충돌 여부
    return verticalCollision && horizontalCollision;
  }
}
