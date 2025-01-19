import 'package:flutter/material.dart';

class Day10Stats {
  // 기본 스탯
  ValueNotifier<int> speed = ValueNotifier<int>(0);
  ValueNotifier<int> burst = ValueNotifier<int>(0);
  ValueNotifier<int> stamina = ValueNotifier<int>(0);
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
  }
}

final day10Stats = Day10Stats();
