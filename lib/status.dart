//친밀도, 에너지, 피로도 관리
import 'package:flutter/material.dart';

class CatStatus {
  ValueNotifier<int> intimacy = ValueNotifier<int>(1); // 초기값 1
  ValueNotifier<int> energy = ValueNotifier<int>(40); // 초기값 40
  ValueNotifier<int> fatigue = ValueNotifier<int>(0); // 초기값 0

  void updateStatus({
    int intimacyDelta = 0,
    int energyDelta = 0,
    int fatigueDelta = 0,
  }) {
    print("Before update - Energy: ${energy.value}");
    print("Energy delta: $energyDelta");

    intimacy.value = (intimacy.value + intimacyDelta).clamp(1, 10);
    energy.value = (energy.value + energyDelta).clamp(0, 100 - fatigue.value);
    fatigue.value = (fatigue.value + fatigueDelta).clamp(0, 100);
    

    print("After update - Energy: ${energy.value}");
  }

  void resetStatus() {
    // 직접 값을 설정하되, 로그 출력 추가
    print("Resetting status:");
    intimacy.value = 1;
    print("Intimacy reset to 1");
    energy.value = 40;
    print("Energy reset to 40");
    fatigue.value = 0;
    print("Fatigue reset to 0");
  }

  void resetFatigue() {
    fatigue.value = 0;
  }
}

final catStatus = CatStatus();
