//먹기,자기 로직
import 'package:flutter/material.dart';
import 'status.dart';
import 'touch.dart';
import 'day.dart';

void eatAction() {
  if (catStatus.intimacy.value >= 5) {
    catStatus.updateStatus(energyDelta: 30);
    print("Eat success! Energy increased by 30");
  } else {
    print("Intimacy too low to eat! Need intimacy level 5 or higher");
  }
}

void sleepAction(BuildContext context) {
  // context 매개변수 추가
  catStatus.energy.value = 40;
  catStatus.resetFatigue();
  touchManager.resetTouchCount();
  dayManager.onSleep(context); // context 전달
  print("Sleep pressed. Day: ${dayManager.currentDay}");
}
