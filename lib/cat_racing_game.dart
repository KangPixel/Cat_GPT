import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'models/cat.dart';
import '../lottie_background.dart';
import '../components/lottie_cat_runner.dart';
import 'package:flutter/foundation.dart';
import 'day10_stats.dart';
import 'package:flutter/material.dart';

class CatRacingGame extends FlameGame with ChangeNotifier {
  final Cat selectedCat;
  final double raceDuration = 20.0; // 총 경주 시간 (20초)
  final List<LottieCatRunner> catRunners = []; // 고양이 객체 리스트
  bool isRaceFinished = false;
  final List<Map<String, dynamic>> raceResults = []; // 최종 결과 저장

  // 고양이 색상과 이름 매칭
  final Map<String, String> catNameMap = {
    'one': 'Player',
    'two': '흰냥이',
    'three': '갈냥이',
    'four': '아이보리냥이',
  };

  CatRacingGame({required this.selectedCat});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 🔹 `size`가 설정될 때까지 대기
    await Future.delayed(const Duration(milliseconds: 100));

    final double screenWidth = size.x;
    final double screenHeight = size.y;

    if (screenWidth == 0 || screenHeight == 0) {
      print("❌ [Error] 게임 크기가 설정되지 않았음.");
      return;
    }

    print("✅ [Debug] 게임 화면 크기: ${screenWidth}x${screenHeight}");

    // 고양이들의 기본 위치 조정
    final double baseY = screenHeight * 0.75; // 화면 높이의 75% 위치
    final double spacing = screenHeight * 0.04; // 고양이 간격

    final List<String> colors = ['one', 'two', 'three', 'four'];
    final random = Random();

    for (int i = 0; i < colors.length; i++) {
      final double baseSpeed = 1.0 + random.nextDouble() * 5.0; // 기본 속도 (1~5)
      final double speedVariation = 1.0 + random.nextDouble() * 5.0; // 속도 변동 범위
      final double phaseOffset = i * pi / 4; // 위상 차이 적용
      final double speedFrequency = 1.0 + random.nextDouble();

      final catRunner = LottieCatRunner(
        raceDuration: raceDuration,
        position: Vector2(50, baseY + (i * spacing)), // 고양이 위치 조정
        size: Vector2(screenWidth * 0.1, screenHeight * 0.1), // 고양이 크기 비율 조정
        color: colors[i],
        baseSpeed: i == 0 ? baseSpeed + day10Stats.normalizedScore : baseSpeed,
        speedVariation: speedVariation,
        phaseOffset: phaseOffset,
        speedFrequency: speedFrequency,
      );

      catRunners.add(catRunner);
      add(catRunner);
    }

    // 🔥 Overlay 추가 (배경 + 고양이)
    Future.delayed(const Duration(milliseconds: 500), () {
      overlays.add('background');
      for (var cat in catRunners) {
        overlays.add(cat.color);
      }
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isRaceFinished) {
      bool allFinished = true;

      for (final catRunner in catRunners) {
        if (catRunner.position.x < size.x - catRunner.size.x) {
          allFinished = false;
          break;
        }
      }

      if (allFinished) {
        isRaceFinished = true;
        _sortResults();
        pauseEngine();
      }
    }
  }


  // 🏆 레이스 결과 정리 (결승선 통과 시 바로 실행)
  void registerFinish(LottieCatRunner cat) {
    if (isRaceFinished) return;

    if (!raceResults.any((r) => r['color'] == cat.color)) {
      raceResults.add({
        'name': catNameMap[cat.color] ?? cat.color,
        'color': cat.color,
        'position': cat.position.x,
      });
    }

    if (raceResults.length == catRunners.length) {
      isRaceFinished = true;
      _sortResults();
    }
  }

  // 순위 정렬 및 UI 업데이트
  void _sortResults() {
    raceResults.sort((a, b) => (b['position'] as double).compareTo(a['position'] as double));
    notifyListeners();

    print("🏆 Race Results:");
    for (int i = 0; i < raceResults.length; i++) {
      print("${i + 1}위: ${raceResults[i]['name']} (위치: ${raceResults[i]['position']})");
    }
  }
}
