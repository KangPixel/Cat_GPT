import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CatStatus {
  ValueNotifier<int> hunger = ValueNotifier(100);
  ValueNotifier<int> fatigue = ValueNotifier(0);
  ValueNotifier<int> happiness = ValueNotifier(50);
  ValueNotifier<int> weight = ValueNotifier(50);

  Future<void> loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    hunger.value = prefs.getInt('hunger') ?? 100;
    fatigue.value = prefs.getInt('fatigue') ?? 0;
    happiness.value = prefs.getInt('happiness') ?? 50;
    weight.value = prefs.getInt('weight') ?? 50;
  }

  Future<void> saveStatus() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('hunger', hunger.value);
    prefs.setInt('fatigue', fatigue.value);
    prefs.setInt('happiness', happiness.value);
    prefs.setInt('weight', weight.value);
  }

  void updateStatus({
    int hungerDelta = 0,
    int fatigueDelta = 0,
    int happinessDelta = 0,
    int weightDelta = 0,
  }) {
    hunger.value = (hunger.value + hungerDelta).clamp(0, 100);
    fatigue.value = (fatigue.value + fatigueDelta).clamp(0, 100);
    happiness.value = (happiness.value + happinessDelta).clamp(0, 100);
    weight.value = (weight.value + weightDelta).clamp(0, 100);

    saveStatus(); // 상태 업데이트 후 저장
  }
}

final catStatus = CatStatus();
