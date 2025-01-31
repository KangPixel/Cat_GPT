// eatsleep.dart (먹기,자기 로직)
import 'package:flutter/material.dart';
import 'flameui.dart';
import 'status.dart';
import 'touch.dart';
import 'day.dart';

bool isEating = false;

void eatAction(BuildContext context) {
  if (isEating) return; // 이미 먹고 있다면 실행하지 않음
  isEating = true;

  if (catStatus.intimacy.value >= 5) {
    if (catStatus.energy.value < 100) { // 첫 활성화 시에만 시작 타이밍이 안맞음
      // 생선 이미지 표시
      _showFishOverlay(context);

      // catSprite의 상태 업데이트
      // ✅ Getter 사용하여 접근 후 이미지 변경
      if (CatGame.instance != null) {
        catStatus.catSprite.value = CatGame.instance?.openMouthSprite;
        Future.delayed(Duration(milliseconds: 600), () {
          if (CatGame.instance != null) {
            catStatus.catSprite.value = CatGame.instance?.normalSprite;
          }
          isEating = false; // 버튼을 다시 눌 수 있도록 활성화
        });
      } else {
        print("CatGame instance is not available.");
      }
      debugPrint('Eat success! Energy increased by 30');
      catStatus.updateStatus(energyDelta: 30);
    } else {
      debugPrint("Energy is full! Please press when you are low on energy.");
    }
  } else {
    debugPrint("Intimacy too low to eat! Need intimacy level 5 or higher");
  }
}

// 생선 이미지 오버레이 표시
void _showFishOverlay(BuildContext context) {
  OverlayState overlayState = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.55, // 고양이 입 위치 정도
      left: MediaQuery.of(context).size.width * 0.35, // 화면 중앙 정도
      child: Image.asset(
        'assets/images/fish.png',  // 생선 이미지 경로
        width: 100,
        height: 100,
      ),
    ),
  );

  // 오버레이 추가
  overlayState.insert(overlayEntry);

  // 1초 후에 오버레이 제거
  Future.delayed(const Duration(milliseconds: 600), () {
    overlayEntry.remove();
  });
}

void sleepAction(BuildContext context) {
  // context 매개변수 추가
  catStatus.energy.value = 40;
  catStatus.resetFatigue();
  touchManager.resetTouchCount();
  dayManager.onSleep(context); // context 전달
  print("Sleep pressed. Day: ${dayManager.currentDay}");
}