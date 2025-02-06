//day10_stats  경주게임에 사용되는 미니게임을 통해 올릴 수 있는 스탯
import 'package:flutter/material.dart';

class Day10Stats {
  // 기본 스탯
  ValueNotifier<int> speed = ValueNotifier<int>(50);
  ValueNotifier<int> burst = ValueNotifier<int>(40);
  ValueNotifier<int> stamina = ValueNotifier<int>(30);
  // 포인트 추가
  ValueNotifier<int> points = ValueNotifier<int>(0);

  void updateStats({
    int speedDelta = 0,
    int burstDelta = 0,
    int staminaDelta = 0,
    int pointsDelta = 0,
  }) {
    speed.value = (speed.value + speedDelta).clamp(0, 100);
    burst.value = (burst.value + burstDelta).clamp(0, 100);
    stamina.value = (stamina.value + staminaDelta).clamp(0, 100);
    points.value =
        (points.value + pointsDelta).clamp(0, 999); // 포인트는 0-999 범위로 설정
  }

  void resetStats() {
    speed.value = 0;
    burst.value = 0;
    stamina.value = 0;
    points.value = 0;
    print("Stats Reset: Speed=${speed.value}, Burst=${burst.value}, Stamina=${stamina.value}, Points=${points.value}");
    
  }
  // 4가지 스탯의 합을 1~10 사이 값으로 변환
  double get normalizedScore {
    int total = speed.value + burst.value + stamina.value + points.value;
    return (total / 400.0 * 3).clamp(1.0, 3.0); //400은 최대 합합
  }
}

final day10Stats = Day10Stats();
