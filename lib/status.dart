// status.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CatStatus {
  ValueNotifier<int> hunger = ValueNotifier(100);
  ValueNotifier<int> intimacy = ValueNotifier(0);
  // ValueNotifier<int> speed = ValueNotifier(0);
  // ValueNotifier<int> stamina = ValueNotifier(0);
  // ValueNotifier<int> burst = ValueNotifier(0);

  Future<void> loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    hunger.value = prefs.getInt('hunger') ?? 100;
    intimacy.value = prefs.getInt('intimacy') ?? 0;
  }

  Future<void> saveStatus() async {
    final prefs = await SharedPreferences.getInstance();
    prefs
      ..setInt('hunger', hunger.value)
      ..setInt('intimacy', intimacy.value);
  }

  void updateStatus({
    int hungerDelta = 0,
    int intimacyDelta = 0,
  }) {
    hunger.value = (hunger.value + hungerDelta).clamp(0, 100);
    intimacy.value = (intimacy.value + intimacyDelta).clamp(0, 100);
    saveStatus();
  }
}

final catStatus = CatStatus();