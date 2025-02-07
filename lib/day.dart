import 'package:flutter/material.dart';
import 'status.dart';
import 'touch.dart';
import 'flameui.dart';
import '../screens/character_selection_screen.dart'; // 캐릭터 선택 화면 추가

class DayManager {
  int currentDay = 10;

  void onSleep(BuildContext context) {
    currentDay -= 1;
    debugPrint("Current day before check: $currentDay"); // 로그 추가

    if (currentDay < 1) {
      debugPrint("Entering character selection, resetting day to 10"); // 로그 추가
      currentDay = 10;

      // 🔥 Named Route 대신 직접 화면 이동하도록 수정
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CharacterSelectionScreen()),
      );

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
