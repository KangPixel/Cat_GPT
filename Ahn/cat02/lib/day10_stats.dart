import 'package:flutter/material.dart';

class Day10Stats {
  // 기본 스탯
  ValueNotifier<int> speed = ValueNotifier<int>(300);
  ValueNotifier<int> burst = ValueNotifier<int>(200);
  ValueNotifier<int> stamina = ValueNotifier<int>(400);
  // 포인트 추가
  ValueNotifier<int> points = ValueNotifier<int>(300);

  void updateStats({
    int speedDelta = 300,
    int burstDelta = 200,
    int staminaDelta = 300,
    int pointsDelta = 300,
  }) {
    speed.value = (speed.value + speedDelta).clamp(0, 100);
    burst.value = (burst.value + burstDelta).clamp(0, 100);
    stamina.value = (stamina.value + staminaDelta).clamp(0, 100);
    points.value =
        (points.value + pointsDelta).clamp(0, 999); // 포인트는 0-999 범위로 설정
  }

  void resetStats() {
    speed.value = 150;
    burst.value = 150;
    stamina.value = 150;
    points.value = 150;
    print("Stats Reset: Speed=${speed.value}, Burst=${burst.value}, Stamina=${stamina.value}, Points=${points.value}");
    
  }
  // 4가지 스탯의 합을 1~10 사이 값으로 변환
  double get normalizedScore {
    int total = speed.value + burst.value + stamina.value + points.value;
    return (total / 400.0 * 5).clamp(1.0, 5.0); //400은 최대 합합
  }
}

final day10Stats = Day10Stats();
