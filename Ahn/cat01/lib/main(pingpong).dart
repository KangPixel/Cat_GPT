import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart'; // 키보드 입력 처리
import 'package:flutter/services.dart'; // LogicalKeyboardKey 사용
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: PingPongGame()));
}

class PingPongGame extends FlameGame with KeyboardEvents {
  late Paddle bottomPaddle;
  late ComputerPaddle topPaddle;
  late Ball ball;

  @override
  Future<void> onLoad() async {
    // 배경 추가
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black,
    ));

    // 위쪽 패들 생성 (컴퓨터가 조작)
    topPaddle = ComputerPaddle(screenSize: size)..position = Vector2(size.x / 2 - 50, 20);

    // 아래쪽 패들 생성 (사용자가 조작)
    bottomPaddle = Paddle(screenSize: size)..position = Vector2(size.x / 2 - 50, size.y - 40);

    // 공 생성
    ball = Ball(screenSize: size)..position = size / 2;

    // 패들 및 공 추가
    addAll([topPaddle, bottomPaddle, ball]);
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // 아래쪽 패들 이동
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      bottomPaddle.moveLeft();
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      bottomPaddle.moveRight();
    }

    return KeyEventResult.handled;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 컴퓨터 패들에 공 위치 전달
    topPaddle.updatePosition(ball.position);

    // 공과 패들 충돌 처리
    if (ball.isCollidingWith(topPaddle) || ball.isCollidingWith(bottomPaddle)) {
      ball.reverseYDirection();
    }

    // 공이 화면을 벗어나면 초기화
    if (ball.position.y < 0 || ball.position.y > size.y) {
      ball.reset();
    }
  }
}

class Paddle extends RectangleComponent {
  final Vector2 screenSize;

  Paddle({required this.screenSize})
      : super(size: Vector2(100, 20), paint: Paint()..color = Colors.white);

  void moveLeft() {
    position.x = (position.x - 10).clamp(0, screenSize.x - size.x);
  }

  void moveRight() {
    position.x = (position.x + 10).clamp(0, screenSize.x - size.x);
  }
}

class ComputerPaddle extends RectangleComponent {
  final Vector2 screenSize;
  double speed = 200; // 컴퓨터 패들의 이동 속도

  ComputerPaddle({required this.screenSize})
      : super(size: Vector2(100, 20), paint: Paint()..color = Colors.white);

  void updatePosition(Vector2 ballPosition) {
    if (ballPosition.x < position.x) {
      position.x = (position.x - speed * 0.02).clamp(0, screenSize.x - size.x);
    } else if (ballPosition.x > position.x + size.x) {
      position.x = (position.x + speed * 0.02).clamp(0, screenSize.x - size.x);
    }
  }
}

class Ball extends CircleComponent {
  Vector2 velocity = Vector2(200, 200); // 공의 초기 속도
  final Vector2 screenSize;

  Ball({required this.screenSize})
      : super(radius: 10, paint: Paint()..color = Colors.red);

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    // 벽 충돌 처리
    if (position.x <= 0 || position.x >= screenSize.x - radius * 2) {
      velocity.x = -velocity.x;
    }
  }

  bool isCollidingWith(RectangleComponent paddle) {
    // 공과 패들의 충돌 감지
    return toRect().overlaps(paddle.toRect());
  }

  void reverseYDirection() {
    velocity.y = -velocity.y;
  }

  void reset() {
    position = screenSize / 2;
    velocity = Vector2(200, 200);
  }
}
