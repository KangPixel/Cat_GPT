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

import 'package:flutter_suika_game/ui/next_fruit_label.dart';
import 'package:flutter_suika_game/presenter/next_fruit_label_presenter.dart';

class ExitButton extends PositionComponent with TapCallbacks {
  final BuildContext? hostContext;
  final GameState gameState;

  ExitButton({
    required Vector2 position,
    required this.hostContext,
    required this.gameState,
  }) : super(
          position: position,
          // 버튼 크기를 지정 (글자 + 여백에 맞춰 적절히 조정)
          size: Vector2(100, 40),
          anchor: Anchor.topLeft,
        );

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

    // 나가기 버튼
    final exitButton = ExitButton(
      position: Vector2(size.x - 120, 30),
      hostContext: hostContext,
      gameState: _gameState,
    );

    // 버튼 안에 표시될 텍스트
    final exitText = TextComponent(
      text: '나가기',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    // 텍스트 중앙 정렬
    exitText.anchor = Anchor.center;
    // exitButton.size에 맞춰, 중앙 배치
    exitText.position = exitButton.size / 2;

    exitButton.add(exitText);
    add(exitButton);

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
