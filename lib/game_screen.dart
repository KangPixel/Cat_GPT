//ui 대부분
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'flameui.dart'; // CatGame 및 Flame 관련 로직
import 'status.dart';
import 'day.dart';
import 'eatsleep.dart';

// UI 구성 요소들을 제공하는 클래스
class UIComponents {
  static Widget buildEnergyBar(ValueNotifier<int> energy) {
    return ValueListenableBuilder<int>(
      valueListenable: energy,
      builder: (context, value, _) {
        final clampedValue = value.clamp(0, 100); // 0~100 범위로 강제
        final color = clampedValue > 70
            ? Colors.green
            : (clampedValue > 30 ? Colors.yellow : Colors.red);
        return Container(
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2.5),
            borderRadius: BorderRadius.circular(8), // 테두리 둥굴게
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6), // 내부 색상 바 둥굴게(외부에 채울 정도)
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: clampedValue / 100,
                  child: Container(color: color),
                ),
                Center(
                  child: Text(
                    '$clampedValue%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget buildButtonWithBackground({
    required String label,
    required String backgroundImage,
    required VoidCallback onTap,
  }) {
    return Container( // 버튼 형식
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}

// 팝업 창을 표시하는 함수
void showCatProfilePopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 고양이 프로필 상단
              Row(
                children: [
                  // 고양이 프로필 사진
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/grayCat.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // 고양이 이름, 품종, 생일
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '이름: cat_name', // 고양이 이름
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        '품종: cat_species', // 고양이 품종
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        '생일: 2023-01-01', // 고양이 생일
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              // 에너지, 피로도, 친밀도
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatBar('에너지', (catStatus.energy.value ~/ 10), Colors.green),
                  const SizedBox(height: 10.0),
                  _buildStatBar('피로도', catStatus.fatigue.value, Colors.yellow),
                  const SizedBox(height: 10.0),
                  _buildStatBar('친밀도', catStatus.intimacy.value, Colors.blue),
                ],
              ),
              const SizedBox(height: 20.0),
              // 닫기 버튼을 중앙에 배치
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('닫기'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


// 상태 막대 그래프 생성 함수
Widget _buildStatBar(String label, int value, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$label: $value''0%',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4.0),
      Container(
        height: 20,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: FractionallySizedBox(
          widthFactor: value / 10,
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
        ),
      ),
    ],
  );
}

// FlameGameScreen과 UI를 결합한 화면
class GameScreen extends StatelessWidget {
  final CatGame game = CatGame();

  GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Flame 게임 화면 전체를 차지
          Positioned.fill(
            child: GameWidget(game: game),
          ),

          // 에너지 바
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: UIComponents.buildEnergyBar(catStatus.energy),
          ),

          // Cat 정보 버튼
          Positioned(
            top: 120,
            left: 20,
            child: UIComponents.buildButtonWithBackground(
              label: 'Cat',
              backgroundImage: 'assets/images/grayCat.png',
              onTap: () {
                print("Cat button pressed");
                // 고양이 정보 팝업 등의 로직 추가 가능
                showCatProfilePopup(context); // 팝업 창 호출

                // 에너지 값을 10 줄이고 0으로 제한
                // catStatus.fatigue.value += 5;
                // catStatus.energy.value -= 5;

                // 현재 에너지 값을 출력 (디버깅용)
                // print("Current energy: ${catStatus.energy.value}");
                // print("Current fatigue: ${catStatus.fatigue.value}");
              },
            ),
          ),

          // Eat 버튼
          Positioned(
            top: 210,
            left: 20,
            child: UIComponents.buildButtonWithBackground(
              label: 'Eat',
              backgroundImage: 'assets/images/grayCat.png',
              onTap: () {
                print("Eat pressed");
                eatAction();
              },
            ),
          ),

          // Sleep 버튼 (Nap -> Sleep)
          Positioned(
            top: 300,
            left: 20,
            child: UIComponents.buildButtonWithBackground(
              label: 'Sleep',
              backgroundImage: 'assets/images/grayCat.png',
              onTap: () {
                print("Sleep pressed");
                sleepAction(
                    context); // dayManager.onSleep(context) 대신 sleepAction(context) 사용
              },
            ),
          ),

          // Play 버튼
          Positioned(
            bottom: 20,
            left: 30,
            child: UIComponents.buildButtonWithBackground(
              label: 'Play',
              backgroundImage: 'assets/images/grayCat.png',
              onTap: () {
                if (catStatus.energy.value >= 50) {
                  Navigator.pushNamed(context, '/play');
                } else {
                  print("Need more energy to play!");
                }
              },
            ),
          ),

          // Talk 버튼
          Positioned(
            bottom: 20,
            right: 30,
            child: UIComponents.buildButtonWithBackground(
              label: 'Talk',
              backgroundImage: 'assets/images/grayCat_open_mouth.png',
              onTap: () => Navigator.pushNamed(context, '/chat'),
            ),
          ),

          // Flutter 쪽 D-day 위젯은 추가하지 않음
        ],
      ),
    );
  }
}
