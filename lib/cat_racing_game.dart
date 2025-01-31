import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'models/cat.dart';
import 'background.dart';
import 'components/cat_runner.dart';
import 'package:flutter/foundation.dart';
import 'day10_stats.dart';

class CatRacingGame extends FlameGame with ChangeNotifier {
  final Cat selectedCat;
  late ScrollingBackground scrollingBackground;
  final double raceDuration = 30.0; // 총 경주 시간
  final List<CatRunner> catRunners = [];
  bool isRaceFinished = false;
  final List<Map<String, dynamic>> raceResults = [];

  CatRacingGame({required this.selectedCat});

  @override
  Future<void> onLoad() async {
    // 배경 로드 및 추가
    final backgroundSprite = await loadSprite('background1.png');
    scrollingBackground = ScrollingBackground(
      sprite: backgroundSprite,
      size: Vector2(576, 324),
      speed: 110,
    );
    add(scrollingBackground);

    // 고양이 로드 및 추가
    final List<String> colors = ['one', 'two', 'three', 'four'];
    final random = Random();

    for (int i = 0; i < colors.length; i++) {
      final List<Sprite> catFrames = await Future.wait(
        List.generate(
          9,
          (j) => loadSprite('frame_${(j + 1).toString().padLeft(2, '0')}_${colors[i]}.png'),
        ),
      );

      final double baseSpeed = 5.0 + random.nextDouble() * 5.0;
      final double speedVariation = 5.0 + random.nextDouble() * 10.0;
      final double phaseOffset = i * pi / 4; // 각 고양이별 위상 차이
      final double speedFrequency = 5.0 + random.nextDouble(); // 고양이별 속도 주기

      final catRunner = CatRunner(
        frames: catFrames,
        raceDuration: raceDuration,
        position: Vector2(50, 230 + (i * 10)),
        size: Vector2(64, 64),
        color: colors[i],
        baseSpeed: i == 0 
            ? baseSpeed + day10Stats.normalizedScore
            : baseSpeed,
        speedVariation: speedVariation,
        phaseOffset: phaseOffset,
        speedFrequency: speedFrequency,
      );

      catRunners.add(catRunner);
      add(catRunner);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 레이스 종료 조건 확인
    if (!isRaceFinished && scrollingBackground.currentRepeats >= scrollingBackground.maxRepeats) {
      isRaceFinished = true;
      calculateResults();
      notifyListeners();
      pauseEngine();
    }
  }

  void calculateResults() {
  // 배경 반복 종료 여부 확인
    final bool raceFinished = scrollingBackground.currentRepeats >= scrollingBackground.maxRepeats;

    final List<Map<String, dynamic>> completed = [];
    final List<Map<String, dynamic>> notCompleted = [];

    for (final catRunner in catRunners) {
      if (raceFinished && catRunner.position.x >= size.x) {
        // 완주한 고양이: 도착 순서 기록
        completed.add({
          'color': catRunner.color,
          'position': catRunner.position.x,
        });
      } else {
        // 미완주한 고양이
        notCompleted.add({
          'color': catRunner.color,
          'position': catRunner.position.x,
        });
      }
    }

    // 완주한 고양이 정렬 (위치 기준 내림차순)
    completed.sort((a, b) => (b['position'] as double).compareTo(a['position'] as double));

    // 미완주한 고양이 정렬 (위치 기준 내림차순)
    notCompleted.sort((a, b) => (b['position'] as double).compareTo(a['position'] as double));

    // 완주 + 미완주 결과 합치기
    raceResults.clear();
    raceResults.addAll(completed);
    raceResults.addAll(notCompleted);

    // 결과 출력
    print("Race Results: $raceResults");
    print("Background Loops: ${scrollingBackground.currentRepeats} / ${scrollingBackground.maxRepeats}");
    for (final catRunner in catRunners) {
      print("Cat ${catRunner.color}: Position ${catRunner.position.x}");
    }
  }

}
