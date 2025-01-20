//날짜 관련 로직
import 'package:flutter/material.dart';
import 'status.dart';
import 'touch.dart';
import 'flameui.dart';

class DayManager {
  int currentDay = 10;

  void onSleep(BuildContext context) {
    currentDay -= 1;
    debugPrint("Current day before check: $currentDay"); // 로그 추가

    if (currentDay < 1) {
      debugPrint("Entering mini game, resetting day to 10"); // 로그 추가
      currentDay = 10;
      Navigator.pushNamed(context, '/day10Game');
      CatGame.instance?.updateDday(); // D-day UI 업데이트
    } else {
      _resetAll();
      debugPrint("DayManager: onSleep → currentDay=$currentDay");
      CatGame.instance?.updateDday();
    }
  }

  void resetDay() {
    currentDay = 10;
    _resetAll();
    debugPrint("DayManager: resetDay → currentDay=10");
  }

  void _resetAll() {
    touchManager.resetTouchCount();
    debugPrint("Touch count reset");
    catStatus.resetStatus();
    debugPrint("All stats reset");
  }
}

final dayManager = DayManager();
