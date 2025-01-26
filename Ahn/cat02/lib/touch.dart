//만지기 상호작용 관리
import 'status.dart';

class TouchManager {
  int touchCount = 0;

  void touchCat() {
    if (touchCount < 2) {
      touchCount++;
      catStatus.updateStatus(intimacyDelta: 1); // 친밀도 1씩 증가
      print("Cat touched. Intimacy: ${catStatus.intimacy.value}");
    } else {
      print("No more touches allowed today!");
    }
  }

  void resetTouchCount() {
    touchCount = 0;
  }
}

final touchManager = TouchManager();
