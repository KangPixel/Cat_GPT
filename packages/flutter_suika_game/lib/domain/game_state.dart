// packages/flutter_suika_game/lib/domain/game_state.dart

import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_suika_game/model/fruit.dart';
import 'package:flutter_suika_game/model/physics_fruit.dart';
import 'package:flutter_suika_game/model/physics_wall.dart';
import 'package:flutter_suika_game/model/wall.dart';
import 'package:flutter_suika_game/presenter/dialog_presenter.dart';
import 'package:flutter_suika_game/presenter/next_fruit_label_presenter.dart';
import 'package:flutter_suika_game/presenter/prediction_line_presenter.dart';
import 'package:flutter_suika_game/presenter/score_presenter.dart';
import 'package:flutter_suika_game/presenter/world_presenter.dart';
import 'package:flutter_suika_game/repository/game_repository.dart';
import 'package:flutter_suika_game/rule/next_size_fruit.dart';
import 'package:flutter_suika_game/rule/score_calculator.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

typedef ScreenCoordinateFunction = Vector2 Function(Vector2);
typedef ComponentFunction = FutureOr<void> Function(Component);

class GameState {
  GameState({
    required this.buildContext,
    required this.worldToScreen,
    required this.screenToWorld,
    required this.camera,
    required this.add,
  });

  final BuildContext buildContext;
  final ScreenCoordinateFunction worldToScreen;
  final ScreenCoordinateFunction screenToWorld;
  final ComponentFunction add;
  final CameraComponent camera;

  final screenSize = Vector2(15, 20);
  final center = Vector2(0, 7);

  Vector2? draggingPosition;
  PhysicsFruit? draggingFruit;
  PhysicsFruit? nextFruit;

  bool isDragEnd = false;
  int overGameOverLineCount = 0;
  bool isGameOver = false;
  bool madeWatermelon = false;

  GameRepository get _gameRepository => GetIt.I.get<GameRepository>();
  WorldPresenter get _worldPresenter => GetIt.I.get<WorldPresenter>();
  ScorePresenter get _scorePresenter => GetIt.I.get<ScorePresenter>();
  NextFruitLabelPresenter get _nextFruitLabelPresenter =>
      GetIt.I.get<NextFruitLabelPresenter>();
  PredictionLinePresenter get _predictLinePresenter =>
      GetIt.I.get<PredictionLinePresenter>();
  DialogPresenter get _dialogPresenter => GetIt.I.get<DialogPresenter>();

  void onLoad() {
    // 물리 월드(바닥, 양옆 벽) 세팅
    _worldPresenter
      ..add(
        PhysicsWall(
          wall: Wall(
            pos: center + Vector2(screenSize.x, 0),
            size: Vector2(1, screenSize.y),
          ),
        ),
      )
      ..add(
        PhysicsWall(
          wall: Wall(
            pos: center - Vector2(screenSize.x, 0),
            size: Vector2(1, screenSize.y),
          ),
        ),
      )
      ..add(
        PhysicsWall(
          wall: Wall(
            pos: center + Vector2(0, screenSize.y),
            size: Vector2(screenSize.x + 1, 1),
          ),
        ),
      );

    // 스코어, 'Next Fruit' 라벨 위치
    _scorePresenter.position = worldToScreen(
      center - Vector2(screenSize.x + 1, screenSize.y + 13),
    );
    _nextFruitLabelPresenter.position = worldToScreen(
      center - Vector2(-screenSize.x + 5, screenSize.y + 13),
    );

    // 처음에 떨굴 과일(드래그 중인 과일) 세팅
    final rect = camera.visibleWorldRect;
    draggingPosition = Vector2((rect.left + rect.right) / 2, rect.top);
    draggingFruit = PhysicsFruit(
      fruit: Fruit.cherry(
        id: const Uuid().v4(),
        pos: Vector2(
          draggingPosition!.x,
          -screenSize.y + center.y - FruitType.cherry.radius,
        ),
      ),
      isStatic: true,
    );
    _worldPresenter.add(draggingFruit!);

    // 'Next Fruit' 미리보기 과일 세팅
    final newNextFruit = getNextFruit();
    nextFruit = PhysicsFruit(
      fruit: newNextFruit.copyWith(
        pos: Vector2(
          screenSize.x - 2,
          -screenSize.y + center.y - 7,
        ),
      ),
      overrideRadius: 2,
      isStatic: true,
    );
    _worldPresenter.add(nextFruit!);

    // Next Fruit Label 갱신
    _nextFruitLabelPresenter.updateFruit(newNextFruit);
  }

  void onUpdate() {
    if (isGameOver) {
      return;
    }

    // 1) 게임오버 조건 체크
    _countOverGameOverLine();
    if (overGameOverLineCount > 100) {
      isGameOver = true;

      // --- 2) 게임오버 시점에서 곧바로 팝 ---
      final score = _scorePresenter.score;
      final isMadeWatermelon = madeWatermelon;
      Navigator.of(buildContext).pop({
        'gameName': 'Suika Game',
        'totalScore': score,
        'fatigueIncrease': isMadeWatermelon ? 5 : 10,
        'pointsEarned': score ~/ 100,
        'fatigueMessage': isMadeWatermelon ? '수박을 만들었어요!' : '게임 오버!',
      });
      return; // 이후 로직 중단
    }

    // 2) 드래그 끝났으면 과일 던지기 로직
    if (isDragEnd) {
      onDragEnd();
      isDragEnd = false;
    }

    // 3) 충돌한 과일 처리 (합치기)
    final collidedFruits = _gameRepository.getCollidedFruits();
    if (collidedFruits.isEmpty) {
      return;
    }

    for (final collideFruit in collidedFruits) {
      final fruit1 = collideFruit.fruit1.userData! as PhysicsFruit;
      final fruit2 = collideFruit.fruit2.userData! as PhysicsFruit;
      final newFruit = _getNextSizeFruit(
        fruit1: fruit1,
        fruit2: fruit2,
      );
      // 새 과일 합쳐진 점수 추가
      _scorePresenter.addScore(getScore(newFruit));

      // 기존 2개 제거, 새 과일 1개 추가
      _worldPresenter
        ..remove(fruit1)
        ..remove(fruit2);
      if (newFruit != null) {
        _worldPresenter.add(PhysicsFruit(fruit: newFruit));
      }
    }
    // 충돌 목록 클리어
    _gameRepository.clearCollidedFruits();
  }

  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    final rect = camera.visibleWorldRect;

    // 드래그 좌표 → 월드 좌표
    draggingPosition = screenToWorld(info.eventPosition.global);
    final draggingPositionX = _adjustDraggingPositionX(draggingPosition!.x);

    // 예측선 표시
    _predictLinePresenter.updateLine(
      worldToScreen(Vector2(draggingPositionX, rect.top)),
      worldToScreen(Vector2(draggingPositionX, rect.bottom)),
    );

    // 드래그 중인 과일 위치 갱신
    if (draggingFruit?.isMounted == true) {
      draggingFruit?.body.setTransform(
        Vector2(
          draggingPositionX,
          -screenSize.y + center.y - draggingFruit!.fruit.radius,
        ),
        0,
      );
    }
  }

  void onDragEnd() {
    if (draggingFruit == null) {
      return;
    }
    // 드래그 중인 과일을 월드에서 제거
    _worldPresenter.remove(draggingFruit!);

    // 드래그 끝난 위치에 새로 동적 과일 생성
    final fruit = draggingFruit!.fruit;
    final draggingPositionX = _adjustDraggingPositionX(draggingPosition!.x);
    final newFruit = fruit.copyWith(
      pos: Vector2(
        draggingPositionX,
        -screenSize.y + center.y - fruit.radius,
      ),
    );
    _worldPresenter.add(PhysicsFruit(fruit: newFruit));

    // draggingFruit 초기화
    draggingFruit = null;

    // 1초 뒤에 다음 과일(Next Fruit)을 현재 드래그 위치로 옮긴 뒤, 새 'Next Fruit'를 생성
    Future.delayed(const Duration(seconds: 1), () {
      // 현재 위치에 nextFruit를 배치
      draggingFruit = PhysicsFruit(
        fruit: nextFruit!.fruit.copyWith(
          pos: Vector2(
            draggingPositionX,
            -screenSize.y + center.y - nextFruit!.fruit.radius,
          ),
        ),
        isStatic: true,
      );

      // 이전 nextFruit 제거, 새 draggingFruit 등록
      _worldPresenter
        ..remove(nextFruit!)
        ..add(draggingFruit!);

      // 새 nextFruit 준비
      final newNextFruit = getNextFruit();
      nextFruit = PhysicsFruit(
        fruit: newNextFruit.copyWith(
          pos: Vector2(
            screenSize.x - 2,
            -screenSize.y + center.y - 7,
          ),
        ),
        overrideRadius: 2,
        isStatic: true,
      );
      _worldPresenter.add(nextFruit!);

      // Next Fruit Label 갱신
      _nextFruitLabelPresenter.updateFruit(newNextFruit);
    });
  }

  /// 게임 전체를 리셋 (재시작)
  void reset() {
    _worldPresenter.clear();
    _gameRepository.clearCollidedFruits();
    _scorePresenter.reset();
    draggingPosition = null;
    draggingFruit = null;
    nextFruit = null;
    isGameOver = false;
    madeWatermelon = false;

    // 월드 초기화 다시 수행
    onLoad();
  }

  double _adjustDraggingPositionX(double x) {
    // 드래그 범위 제한
    final fruitRadius = draggingFruit?.fruit.radius ?? 1;
    if (x < screenSize.x * -1 + fruitRadius + 1) {
      return screenSize.x * -1 + fruitRadius + 1;
    }
    if (x > screenSize.x - fruitRadius - 1) {
      return screenSize.x - fruitRadius - 1;
    }
    return x;
  }

  /// 과일이 화면 위쪽(게임오버 라인) 넘어서면 카운팅
  void _countOverGameOverLine() {
    final components = _worldPresenter.getComponents();
    final fruits = components.whereType<PhysicsFruit>();
    final dynamicFruits = fruits.where((fruit) => !fruit.isStatic);

    // 모든 동적 과일 y좌표 중 최솟값
    final minY = dynamicFruits.fold<double>(
      0,
      (previousValue, element) =>
          min(previousValue, element.body.position.y + center.y + 2.25),
    );

    // minY < 0 = 화면 위로 넘어갔다는 뜻
    if (minY < 0) {
      overGameOverLineCount++;
    } else {
      overGameOverLineCount = 0;
    }
  }

  /// 같은 크기의 과일 충돌 시 호출
  void onCollidedSameSizeFruits({
    required Body bodyA,
    required Body bodyB,
  }) {
    GetIt.I.get<GameRepository>().addCollidedFruits(
          CollidedFruits(bodyA, bodyB),
        );
  }

  void clearCollidedFruits() {
    GetIt.I.get<GameRepository>().clearCollidedFruits();
  }

  /// 합쳐질 과일이 다음 단계로 업그레이드됐는지 체크
  Fruit? _getNextSizeFruit({
    required PhysicsFruit fruit1,
    required PhysicsFruit fruit2,
  }) {
    final merged = getNextSizeFruit(
      fruit1: fruit1.fruit.copyWith(pos: fruit1.body.position),
      fruit2: fruit2.fruit.copyWith(pos: fruit2.body.position),
    );

    // 만약 수박(최대 크기)이 됐다면 madeWatermelon = true
    if (merged?.radius == FruitType.watermelon.radius) {
      madeWatermelon = true;
    }
    return merged;
  }

  /// Cherry~Kaki 중 랜덤 생성
  Fruit getNextFruit() {
    final id = const Uuid().v4();
    final pos = Vector2(0, 0);

    final candidates = [
      FruitType.cherry,
      FruitType.strawberry,
      FruitType.grape,
      FruitType.orange,
      FruitType.kaki,
    ];
    final random = Random();
    candidates.shuffle(random);

    return Fruit(
      id: id,
      pos: pos,
      radius: candidates[0].radius,
      color: candidates[0].color,
      image: candidates[0].image,
    );
  }
}
