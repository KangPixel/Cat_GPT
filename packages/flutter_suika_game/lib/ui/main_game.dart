// packages/flutter_suika_game/lib/ui/main_game.dart
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter_suika_game/domain/game_state.dart';
import 'package:flutter_suika_game/model/game_over_line.dart';
import 'package:flutter_suika_game/model/physics_fruit.dart';
import 'package:flutter_suika_game/model/prediction_line.dart';
import 'package:flutter_suika_game/model/score.dart';
import 'package:flutter_suika_game/presenter/dialog_presenter.dart';
import 'package:flutter_suika_game/presenter/game_over_panel_presenter.dart';
import 'package:flutter_suika_game/presenter/prediction_line_presenter.dart';
import 'package:flutter_suika_game/presenter/score_presenter.dart';
import 'package:flutter_suika_game/presenter/world_presenter.dart';
import 'package:flutter_suika_game/repository/game_repository.dart';
import 'package:get_it/get_it.dart';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_suika_game/ui/next_fruit_label.dart';
import 'package:flutter_suika_game/presenter/next_fruit_label_presenter.dart';

class ExitButton extends PositionComponent with TapCallbacks, HoverCallbacks {
  final BuildContext? hostContext;
  final GameState gameState;
  bool _isHovered = false;
  final Paint _buttonPaint = Paint();
  late final RRect _buttonRect;
  static const cornerRadius = 8.0;

  ExitButton({
    required Vector2 position,
    required this.hostContext,
    required this.gameState,
  }) : super(
          position: position,
          size: Vector2(80, 35),
          anchor: Anchor.topLeft,
        );

  @override
  void onMount() {
    super.onMount();
    _buttonRect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(cornerRadius),
    );
  }

  @override
  void render(Canvas canvas) {
    // 그림자 효과
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      _buttonRect.shift(const Offset(2, 2)),
      shadowPaint,
    );

    // 버튼 배경
    _buttonPaint.color =
        _isHovered ? const Color(0xFFE74C3C) : const Color(0xFFFF6B6B);
    canvas.drawRRect(_buttonRect, _buttonPaint);

    // 테두리
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(_buttonRect, borderPaint);

    // 텍스트 렌더링
    final textConfig = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );

    final text = '나가기';
    textConfig.render(
      canvas,
      text,
      Vector2(size.x / 2 - 30, size.y / 2 - 14), // 대략적인 중앙 위치로 조정
    );
  }

  @override
  bool onHoverEnter() {
    _isHovered = true;
    return true;
  }

  @override
  bool onHoverExit() {
    _isHovered = false;
    return true;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (hostContext != null) {
      final score = GetIt.I.get<ScorePresenter>().score;
      final madeWatermelon = gameState.madeWatermelon;

      final result = {
        'gameName': 'Suika Game',
        'totalScore': score,
        'fatigueIncrease': madeWatermelon ? 5 : 10,
        'pointsEarned': score ~/ 100,
        'fatigueMessage': madeWatermelon ? '수박을 만들었어요!' : null,
      };

      Navigator.of(hostContext!).pop(result);
    }
  }
}

class MainGame extends Forge2DGame with TapCallbacks, MultiTouchDragDetector {
  BuildContext? hostContext;
  void setContext(BuildContext context) {
    hostContext = context;
  }

  final Vector2 screenSize = Vector2(15, 20);
  final Vector2 center = Vector2(0, 7);

  MainGame() : super(gravity: Vector2(0, 69.8));

  @override
  Color backgroundColor() {
    return const PaletteEntry(Color(0xFFE4CE9D)).color;
  }

  GameState get _gameState => GetIt.I.get<GameState>();

  @override
  void update(double dt) {
    super.update(dt);
    _gameState.onUpdate();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await GetIt.I.reset();
    await FlameAudio.audioCache.loadAll(['drop.wav', 'pop.wav']);

    final predictionLineComponent = PredictionLineComponent();
    final scoreComponent = ScoreComponent();
    final nextFruitLabel = NextFruitLabel(initialText: "Next");

    final gameOverLine = GameOverLine(
      worldToScreen(center - Vector2(screenSize.x + 1, screenSize.y)),
      worldToScreen(center - Vector2(-screenSize.x - 1, screenSize.y)),
    );

    add(predictionLineComponent);
    add(scoreComponent);
    add(nextFruitLabel);
    add(gameOverLine);

    GetIt.I.registerSingleton<GameRepository>(GameRepository());
    GetIt.I.registerSingleton<WorldPresenter>(WorldPresenter(world));
    GetIt.I.registerSingleton<PredictionLinePresenter>(
        PredictionLinePresenter(predictionLineComponent));
    GetIt.I.registerSingleton<ScorePresenter>(ScorePresenter(scoreComponent));
    GetIt.I.registerSingleton<NextFruitLabelPresenter>(
        NextFruitLabelPresenter(nextFruitLabel));
    GetIt.I.registerSingleton<GameOverPanelPresenter>(GameOverPanelPresenter());
    GetIt.I.registerSingleton<DialogPresenter>(DialogPresenter());

    if (!GetIt.I.isRegistered<GameState>()) {
      GetIt.I.registerSingleton<GameState>(
        GameState(
          buildContext: hostContext!,
          worldToScreen: worldToScreen,
          screenToWorld: screenToWorld,
          camera: camera,
          add: add,
        ),
      );
    }

    // 새로운 나가기 버튼 추가
    add(ExitButton(
      position: Vector2(size.x - 100, 20),
      hostContext: hostContext,
      gameState: _gameState,
    ));

    GetIt.I.get<GameState>().onLoad();
    world.physicsWorld.setContactListener(FruitsContactListener());
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    super.onDragUpdate(pointerId, info);
    _gameState.onDragUpdate(pointerId, info);
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    super.onDragEnd(pointerId, info);
    _gameState.isDragEnd = true;
  }
}

class FruitsContactListener extends ContactListener {
  FruitsContactListener();
  @override
  void beginContact(Contact contact) {
    final bodyA = contact.fixtureA.body;
    final bodyB = contact.fixtureB.body;
    final userDataA = bodyA.userData;
    final userDataB = bodyB.userData;

    if (userDataA is PhysicsFruit && userDataB is PhysicsFruit) {
      if (userDataA.isStatic || userDataB.isStatic) {
        return;
      }
      if (userDataA.fruit.radius == userDataB.fruit.radius) {
        GetIt.I.get<GameState>().onCollidedSameSizeFruits(
              bodyA: bodyA,
              bodyB: bodyB,
            );
      }
    }
  }
}
