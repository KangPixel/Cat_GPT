//packages/ski_master/lib/game/game.dart
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart' hide Route, OverlayRoute;
import 'package:ski_master/game/routes/gameplay.dart';
import 'package:ski_master/game/routes/level_complete.dart';
import 'package:ski_master/game/routes/level_selection.dart';
import 'package:ski_master/game/routes/main_menu.dart';
import 'package:ski_master/game/routes/pause_menu.dart';
import 'package:ski_master/game/routes/retry_menu.dart';
import 'package:ski_master/game/routes/settings.dart';

class SkiMasterGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  static const bgm = '8BitDNALoop.wav';
  static const jumpSfx = 'Jump.wav';
  static const collectSfx = 'Collect.wav';
  static const hurtSfx = 'Hurt.wav';

  final musicValueNotifier = ValueNotifier(true);
  final sfxValueNotifier = ValueNotifier(true);
  final musicVolumeNotifier = ValueNotifier(0.1); // 10%로 수정

  AudioPlayer? _bgmPlayer;

  // 점수 관련 변수 추가
  int _currentScore = 0;
  int get currentScore => _currentScore;
  void updateScore(int score) {
    _currentScore = score;
  }

  static const isMobile = bool.fromEnvironment('MOBILE_BUILD');

  late final _routes = <String, Route>{
    MainMenu.id: OverlayRoute(
      (context, game) => MainMenu(
        onPlayPressed: () => _routeById(LevelSelection.id),
        onSettingsPressed: () => _routeById(Settings.id),
      ),
    ),
    Settings.id: OverlayRoute(
      (context, game) => Settings(
        musicValueListenable: musicValueNotifier,
        sfxValueListenable: sfxValueNotifier,
        musicVolumeListenable: musicVolumeNotifier,
        onMusicValueChanged: (value) => musicValueNotifier.value = value,
        onSfxValueChanged: (value) => sfxValueNotifier.value = value,
        onMusicVolumeChanged: (value) {
          musicVolumeNotifier.value = value;
          _bgmPlayer?.setVolume(value);
        },
        onBackPressed: _popRoute,
      ),
    ),
    LevelSelection.id: OverlayRoute(
      (context, game) => LevelSelection(
        onLevelSelected: _startLevel,
        onBackPressed: _popRoute,
      ),
    ),
    PauseMenu.id: OverlayRoute(
      (context, game) => PauseMenu(
        onResumePressed: _resumeGame,
        onRestartPressed: _restartLevel,
        onExitPressed: _exitToMainMenu,
      ),
    ),
    RetryMenu.id: OverlayRoute(
      (context, game) => RetryMenu(
        currentScore: _currentScore,
        onRetryPressed: _restartLevel,
        onSettlePressed: () => _settleGame(isGameOver: true),
      ),
    ),
  };

  late final _routeFactories = <String, Route Function(String)>{
    LevelComplete.id: (argument) => OverlayRoute(
          (context, game) {
            final args = argument.split('/');
            return LevelComplete(
              nStars: int.parse(args[0]),
              currentLevel: int.parse(args[1]),
              currentScore: _currentScore,
              clearCount: int.parse(args[2]),
              onNextPressed: _startNextLevel,
              onRetryPressed: _restartLevel,
              onSettlePressed: () => _settleGame(isGameOver: false),
            );
          },
        ),
  };

  late final _router = RouterComponent(
    initialRoute: MainMenu.id,
    routes: _routes,
    routeFactories: _routeFactories,
  );

  @override
  Color backgroundColor() => const Color.fromARGB(255, 238, 248, 254);

  @override
  Future<void> onLoad() async {
    if (isMobile) {
      await Flame.device.setPortrait();
      await Flame.device.fullScreen();
    }
    await FlameAudio.audioCache.loadAll([bgm, jumpSfx, collectSfx, hurtSfx]);
    await add(_router);
  }

  void _routeById(String id) {
    _router.pushNamed(id);
  }

  void _popRoute() {
    _router.pop();
  }

  void _startLevel(int levelIndex, {int? initialScore}) {
    _router.pop();
    _router.pushReplacement(
      Route(
        () => Gameplay(
          levelIndex,
          onPausePressed: _pauseGame,
          onLevelCompleted: _showLevelCompleteMenu,
          onGameOver: _showRetryMenu,
          key: ComponentKey.named(Gameplay.id),
          initialScore: initialScore,
        ),
      ),
      name: Gameplay.id,
    );
  }

  void _restartLevel() {
    final gameplay = findByKeyName<Gameplay>(Gameplay.id);

    if (gameplay != null) {
      _startLevel(gameplay.currentLevel);
      resumeEngine();
    }
  }

  void _startNextLevel() {
    final gameplay = findByKeyName<Gameplay>(Gameplay.id);

    if (gameplay != null) {
      final currentScore = gameplay.score; // 현재 점수 가져오기
      _startLevel(gameplay.currentLevel + 1,
          initialScore: currentScore); // 새 레벨에 점수 전달
    }
  }

  void _pauseGame() {
    _router.pushNamed(PauseMenu.id);
    pauseEngine();
  }

  void _resumeGame() {
    _router.pop();
    resumeEngine();
  }

  void _exitToMainMenu() {
    _resumeGame();
    _router.pushReplacementNamed(MainMenu.id);
  }

  void _showLevelCompleteMenu(int nStars) {
    final gameplay = findByKeyName<Gameplay>(Gameplay.id);
    if (gameplay != null) {
      _router.pushNamed(
          '${LevelComplete.id}/$nStars/${gameplay.currentLevel}/${gameplay.clearCount}');
    }
  }

  void _showRetryMenu() {
    _router.pushNamed(RetryMenu.id);
  }

  // 점수 정산을 위한 메서드 추가
  void _settleGame({required bool isGameOver}) {
    final gameplay = findByKeyName<Gameplay>(Gameplay.id);
    if (gameplay != null) {
      gameplay.handleSettle(isGameOver: isGameOver);
    }
  }

  @override
  void onRemove() {
    _bgmPlayer?.stop();
    _bgmPlayer?.dispose();
    super.onRemove();
  }
}
