//packages/ski_master/lib/game/routes/gameplay.dart
import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ski_master/game/actors/snowman.dart';
import 'package:ski_master/game/game.dart';
import 'package:ski_master/game/hud.dart';
import 'package:ski_master/game/input.dart';
import 'package:ski_master/game/actors/player.dart';

class Gameplay extends Component with HasGameReference<SkiMasterGame> {
  Gameplay(
    this.currentLevel, {
    super.key,
    required this.onPausePressed,
    required this.onLevelCompleted,
    required this.onGameOver,
    int? initialScore,
  }) : _score = initialScore ?? 0; // 생성자 초기화 리스트 형태로 수정

  int clearCount = 0;

  static const id = 'Gameplay';
  static const _timeScaleRate = 1;
  static const _bgmFadeRate = 1;
  static const _bgmMinVol = 0;

  final int currentLevel;
  final VoidCallback onPausePressed;
  final ValueChanged<int> onLevelCompleted;
  final VoidCallback onGameOver;
  int _score; // var나 final 없이 선언된 변수를 수정
  int get score => _score;

  late final input = Input(
    keyCallbacks: {
      LogicalKeyboardKey.keyP: onPausePressed,
      LogicalKeyboardKey.keyC: () => onLevelCompleted.call(3),
      LogicalKeyboardKey.keyO: onGameOver,
    },
  );

  late final _resetTimer = Timer(1, autoStart: false, onTick: _resetPlayer);
  late final _cameraShake = MoveEffect.by(
    Vector2(0, 3),
    InfiniteEffectController(ZigzagEffectController(period: 0.2)),
  );

  late final World _world;
  late final CameraComponent _camera;
  late final Player _player;
  late final Vector2 _lastSafePosition;
  late final RectangleComponent _fader;
  late final Hud _hud;
  late final SpriteSheet _spriteSheet;

  int _nSnowmanCollected = 0;
  int _nLives = 3;

  int _nTrailTriggers = 0;
  bool get _isOffTrail => _nTrailTriggers == 0;

  bool _levelCompleted = false;
  bool _gameOver = false;

  AudioPlayer? _bgmPlayer;

  void _finishGame({
    required bool isGameOver,
    int additionalFatigue = 0,
  }) {
    if (_bgmPlayer != null) {
      _bgmPlayer?.stop();
      _bgmPlayer?.dispose();
      _bgmPlayer = null;
    }

    if (game.buildContext != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(game.buildContext!).pop({
          'score': _score,
          'levelCompleted': !isGameOver,
          'gameOver': isGameOver,
          'additionalFatigue': additionalFatigue,
        });
      });
    }
  }

  @override
  Future<void> onLoad() async {
    if (game.musicValueNotifier.value) {
      _bgmPlayer = await FlameAudio.loopLongAudio(
        SkiMasterGame.bgm,
        volume: game.musicVolumeNotifier.value,
      );
    }

    final map = await TiledComponent.load(
      'Level$currentLevel.tmx',
      Vector2.all(16),
    );

    final tiles = game.images.fromCache('../images/tilemap_packed.png');
    _spriteSheet = SpriteSheet(image: tiles, srcSize: Vector2.all(16));

    await _setupWorldAndCamera(map);
    await _handleSpawnPoints(map);
    await _handleTriggers(map);

    _fader = RectangleComponent(
      size: _camera.viewport.virtualSize,
      paint: Paint()..color = game.backgroundColor(),
      children: [OpacityEffect.fadeOut(LinearEffectController(1.5))],
      priority: 1,
    );

    _hud = Hud(
      playerSprite: _spriteSheet.getSprite(5, 10),
      snowmanSprite: _spriteSheet.getSprite(5, 9),
      input: SkiMasterGame.isMobile ? input : null,
      onPausePressed: SkiMasterGame.isMobile ? onPausePressed : null,
    );
    _hud.updateScore(_score);

    await _camera.viewport.addAll([_fader, _hud]);
    await _camera.viewfinder.add(_cameraShake);
    _cameraShake.pause();
  }

  @override
  void update(double dt) {
    if (_levelCompleted || _gameOver) {
      _player.timeScale = lerpDouble(
        _player.timeScale,
        0,
        _timeScaleRate * dt,
      )!;
    } else {
      if (_isOffTrail && input.active) {
        _resetTimer.update(dt);

        if (!_resetTimer.isRunning()) {
          _resetTimer.start();
        }

        if (_cameraShake.isPaused) {
          _cameraShake.resume();
        }
      } else {
        if (_resetTimer.isRunning()) {
          _resetTimer.stop();
        }

        if (!_cameraShake.isPaused) {
          _cameraShake.pause();
        }
      }
    }

    if (_bgmPlayer != null) {
      if (_levelCompleted || _gameOver) {
        if (_bgmPlayer!.volume > _bgmMinVol) {
          _bgmPlayer!.setVolume(
            lerpDouble(_bgmPlayer!.volume, _bgmMinVol, _bgmFadeRate * dt)!,
          );
        }
      } else {
        if (_bgmPlayer!.volume < game.musicVolumeNotifier.value) {
          _bgmPlayer!.setVolume(
            lerpDouble(_bgmPlayer!.volume, game.musicVolumeNotifier.value,
                _bgmFadeRate * dt)!,
          );
        }
      }
    }
  }

  @override
  void onRemove() {
    if (_bgmPlayer != null) {
      _bgmPlayer?.stop();
      _bgmPlayer?.dispose();
      _bgmPlayer = null;
    }
    super.onRemove();
  }

  Future<void> _setupWorldAndCamera(TiledComponent map) async {
    _world = World(children: [map, input]);
    await add(_world);

    final aspectRatio = MediaQuery.of(game.buildContext!).size.aspectRatio;
    const height = SkiMasterGame.isMobile ? 200.0 : 180.0;
    final width = SkiMasterGame.isMobile ? height * aspectRatio : 320.0;

    _camera = CameraComponent.withFixedResolution(
      width: width,
      height: height,
      world: _world,
    );
    await add(_camera);
  }

  late double _initialX;
  late double _initialY;

  Future<void> _handleSpawnPoints(TiledComponent map) async {
    final spawnPointLayer = map.tileMap.getLayer<ObjectGroup>('SpawnPoint');
    final objects = spawnPointLayer?.objects;

    if (objects != null) {
      for (final object in objects) {
        switch (object.class_) {
          case 'Player':
            _initialX = object.x;
            _initialY = object.y;
            _player = Player(
              position: Vector2(_initialX, _initialY),
              sprite: _spriteSheet.getSprite(5, 10),
              priority: 1,
            );
            await _world.add(_player);
            _camera.follow(_player);
            _lastSafePosition = Vector2(_initialX, _initialY);
            break;
          case 'Snowman': // 눈사람 생성 부분 추가
            final snowman = Snowman(
              position: Vector2(object.x, object.y),
              sprite: _spriteSheet.getSprite(5, 9),
              onCollected: _onSnowmanCollected,
            );
            await _world.add(snowman);
            break;
        }
      }
    }
  }

  Future<void> _handleTriggers(TiledComponent map) async {
    final triggerLayer = map.tileMap.getLayer<ObjectGroup>('Trigger');
    final objects = triggerLayer?.objects;

    if (objects != null) {
      for (final object in objects) {
        switch (object.class_) {
          case 'Trail':
            final vertices = <Vector2>[];
            for (final point in object.polygon) {
              vertices.add(Vector2(point.x + object.x, point.y + object.y));
            }

            final hitbox = PolygonHitbox(
              vertices,
              collisionType: CollisionType.passive,
              isSolid: true,
            );

            hitbox.onCollisionStartCallback = (_, __) => _onTrailEnter();
            hitbox.onCollisionEndCallback = (_) => _onTrailExit();

            await map.add(hitbox);
            break;

          case 'Checkpoint':
            final checkpoint = RectangleHitbox(
              position: Vector2(object.x, object.y),
              size: Vector2(object.width, object.height),
              collisionType: CollisionType.passive,
            );

            checkpoint.onCollisionStartCallback =
                (_, __) => _onCheckpoint(checkpoint);

            await map.add(checkpoint);
            break;

          case 'Ramp':
            final ramp = RectangleHitbox(
              position: Vector2(object.x, object.y),
              size: Vector2(object.width, object.height),
              collisionType: CollisionType.passive,
            );

            ramp.onCollisionStartCallback = (_, __) => _onRamp();

            await map.add(ramp);
            break;

          case 'Start':
            final trailStart = RectangleHitbox(
              position: Vector2(object.x, object.y),
              size: Vector2(object.width, object.height),
              collisionType: CollisionType.passive,
            );

            trailStart.onCollisionStartCallback = (_, __) => _onTrailStart();

            await map.add(trailStart);
            break;

          case 'End':
            final trailEnd = RectangleHitbox(
              position: Vector2(object.x, object.y),
              size: Vector2(object.width, object.height),
              collisionType: CollisionType.passive,
            );

            trailEnd.onCollisionStartCallback = (_, __) => _onTrailEnd();

            await map.add(trailEnd);
            break;
        }
      }
    }
  }

  void _onTrailEnter() {
    ++_nTrailTriggers;
  }

  void _onTrailExit() {
    --_nTrailTriggers;
  }

  void _onCheckpoint(RectangleHitbox checkpoint) {
    _lastSafePosition.setFrom(checkpoint.absoluteCenter);
    checkpoint.removeFromParent();
  }

  void _onRamp() {
    final jumpFactor = _player.jump();
    final jumpScore = (jumpFactor * 500).toInt();
    _score += jumpScore;
    _hud.updateScore(_score);
    game.updateScore(_score);

    final jumpScale = lerpDouble(1, 1.08, jumpFactor)!;
    final jumpDuration = lerpDouble(0, 0.8, jumpFactor)!;
    _camera.viewfinder.add(
      ScaleEffect.by(
        Vector2.all(jumpScale),
        EffectController(
          duration: jumpDuration,
          alternate: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  void _onTrailStart() {
    input.active = true;
    _lastSafePosition.setFrom(_player.position);
  }

  void _onTrailEnd() {
    _fader.add(OpacityEffect.fadeIn(LinearEffectController(1.5)));
    input.active = false;
    _levelCompleted = true;
    clearCount++; // _clearCount -> clearCount

    int stars;
    if (_score >= 5000)
      stars = 3;
    else if (_score >= 3000)
      stars = 2;
    else if (_score >= 1000)
      stars = 1;
    else
      stars = 0;

    onLevelCompleted.call(stars);
    // 여기서는 정산으로 바로 가지 않고 별점 화면만 표시
  }

  // 정산 처리를 위한 새로운 메서드
  void handleSettle({required bool isGameOver}) {
    _finishGame(isGameOver: isGameOver);
  }

// retry 처리 수정
  void handleRetry() {
    _finishGame(
        isGameOver: false, additionalFatigue: clearCount * 5 // 클리어 횟수만큼 피로도 추가
        );
  }

  void _onSnowmanCollected() {
    ++_nSnowmanCollected;
    _score += 1000;
    _hud.updateSnowmanCount(_nSnowmanCollected);
    _hud.updateScore(_score);
    game.updateScore(_score);
  }

  void _resetPlayer() {
    --_nLives;
    _hud.updateLifeCount(_nLives);

    if (_nLives > 0) {
      _player.resetTo(Vector2(_initialX, _initialY));
    } else {
      _gameOver = true;
      _fader.add(OpacityEffect.fadeIn(LinearEffectController(1.5)));
      onGameOver.call();
      // 바로 정산하지 않고 RetryMenu로 이동
    }
  }
}
