//packages/ski_master/lib/game/actors/player.dart
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'dart:math' show Random;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';
import 'package:ski_master/game/game.dart';
import 'package:ski_master/game/routes/gameplay.dart';

class Player extends PositionComponent
    with HasGameReference<SkiMasterGame>, HasAncestor<Gameplay>, HasTimeScale {
  Player({super.position, required Sprite sprite, super.priority})
      : _body = SpriteComponent(sprite: sprite, anchor: Anchor.center);

  final SpriteComponent _body;
  final _random = Random();
  final _moveDirection = Vector2(0, 1);
  final _currentDirection = Vector2(0, 1);

  late final _trailParticlePaint = Paint()..color = game.backgroundColor();
  late final _offsetLeft = Vector2(-_body.width * 0.25, 0);
  late final _offsetRight = Vector2(_body.width * 0.25, 0);

  static const _maxSpeed = 200.0; // 최대 속도 약간 감소
  static const _minTurnSpeed = 30.0; // 회전 시작 속도를 낮춤
  static const _baseAcceleration = 0.3;
  static const _baseTurnRate = 2.5; // 기본 회전 속도 증가
  static const _speedTurnMultiplier = 0.45; // 속도에 따른 회전 제한을 완화

  var _speed = 0.0;
  var _isOnGround = true;
  var _angularVelocity = 0.0;
  var _slipAngle = 0.0;

  @override
  Future<void> onLoad() async {
    await add(_body);
    await add(
      CircleHitbox.relative(1, parentSize: _body.size, anchor: Anchor.center),
    );
  }

  @override
  void update(double dt) {
    final input = -ancestor.input.hAxis; // 방향키 반전

    final speedFactor = (_speed - _minTurnSpeed) / (_maxSpeed - _minTurnSpeed);
    final turnRate = _baseTurnRate * (1 - speedFactor * _speedTurnMultiplier);

    final targetAngularVel = input * turnRate;
    _angularVelocity =
        lerpDouble(_angularVelocity, targetAngularVel, 0.15)!; // 회전 반응성 증가

    final rotationAmount = _angularVelocity * dt;
    _currentDirection.rotate(rotationAmount);

    final targetSlipAngle = input * 0.2 * speedFactor; // 미끄러짐 감소
    _slipAngle =
        lerpDouble(_slipAngle, targetSlipAngle, 0.08)!; // 미끄러짐 회복 속도 증가

    final moveVector = _currentDirection.clone()..rotate(_slipAngle);

    final accelerationMultiplier = 1 - _slipAngle.abs() * 0.5;
    final targetSpeed = _maxSpeed * accelerationMultiplier;
    _speed = lerpDouble(_speed, targetSpeed, _baseAcceleration * dt)!;

    position.addScaled(moveVector, _speed * dt);
    angle = moveVector.screenAngle() + pi;

    if (_isOnGround) {
      _emitTrailParticles();
    }
  }

  void _emitTrailParticles() {
    final spread = _slipAngle.abs() * 0.5;
    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 3,
          lifespan: 2.5,
          generator: (index) {
            final randomOffset = Vector2(
              (_random.nextDouble() - 0.5) * spread,
              (_random.nextDouble() - 0.5) * spread,
            );
            final baseOffset = index == 0
                ? _offsetLeft
                : index == 1
                    ? _offsetRight
                    : Vector2.zero();
            return TranslatedParticle(
              child: CircleParticle(
                radius: 1.2,
                paint: _trailParticlePaint,
              ),
              offset: baseOffset + randomOffset,
            );
          },
        ),
      ),
    );
  }

  void resetTo(Vector2 resetPosition) {
    if (game.sfxValueNotifier.value) {
      FlameAudio.play(SkiMasterGame.hurtSfx);
    }
    position.setFrom(resetPosition);
    _speed *= 0.3;
    // 방향 완전 초기화
    _currentDirection.setFrom(Vector2(0, 1));
    _moveDirection.setFrom(Vector2(0, 1));
    _angularVelocity = 0.0;
    _slipAngle = 0.0;
    angle = pi; // 정면을 바라보도록 회전 초기화
  }

  double jump() {
    if (game.sfxValueNotifier.value) {
      FlameAudio.play(SkiMasterGame.jumpSfx);
    }
    _isOnGround = false;
    final jumpFactor = _speed / _maxSpeed;
    final jumpScale = lerpDouble(1, 1.2, jumpFactor)!;
    final jumpDuration = lerpDouble(0, 0.8, jumpFactor)!;

    _body.add(
      ScaleEffect.by(
        Vector2.all(jumpScale),
        EffectController(
          duration: jumpDuration,
          alternate: true,
          curve: Curves.easeInOut,
        ),
        onComplete: () => _isOnGround = true,
      ),
    );

    return jumpFactor;
  }
}
