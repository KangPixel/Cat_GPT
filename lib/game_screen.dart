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
  // 에너지 막대 그래프 생성
  static Widget _buildEnergyBar(ValueNotifier<int> energy) {
    return ValueListenableBuilder<int>(
      valueListenable: energy,
      builder: (context, value, _) {
        final clampedValue = value.clamp(0, 100); // 0~100 범위로 강제
        final color = clampedValue > 70
            ? Colors.green                                        // 70% 이상이면 초록
            : (clampedValue > 30 ? Colors.yellow : Colors.red); // 70% 미만이고 30% 이상이면 노랑, 그 이하면 빨강
        return Container(
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2.5),
            borderRadius: BorderRadius.circular(13), // 테두리 둥굴게
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13), // 내부 색상 바 둥굴게(외부에 채울 정도)
            child: Stack(
              children: [
                Container(
                  color: Colors.white,  // 빈 화면(배경)을 하얀색 
                ),
                FractionallySizedBox(
                  widthFactor: clampedValue / 100,  // 100분율
                  child: Container(color: color),
                ),
                Center(
                  child: Text(
                    '$clampedValue%', // 현재 에너지 표시
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

  // 상태(스테이터스) 막대 그래프 생성
  static Widget _buildStatBar(String label, int value, Color color, int percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text( // 스테이터스 이름 및 현재 량
          '$label: $value',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4.0),
        Container(
          height: 20,
          decoration: BoxDecoration(  // 외각선
            border: Border.all(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: FractionallySizedBox(  // percentage 만큼 % 표시
            widthFactor: value / percentage,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: color, // 색상을 받아와서 지정
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 버튼 형태 생성
  static Widget buildButtonWithBackground({
    required String label,            // label
    required String backgroundImage,  // 배경 이미지 받기
    required VoidCallback onTap,      // 누를 시 작동
  }) {
    return Container( // 버튼 형식
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage), // 이미지 받아온 것
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8.0), // 둥굴게
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
        backgroundColor: Colors.yellow[50], // 기본 배경 색 조정
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),  // 모서리 둥굴게
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
              // 에너지, 피로도, 친밀도 그래프 창
              Container(
                decoration: BoxDecoration(  // 상태 배경 추가
                  color: const Color.fromARGB(255, 105, 35, 30),
                  borderRadius: BorderRadius.circular(13.0),
                ),
                
                padding: const EdgeInsets.all(16.0), // 여백 추가
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(  // 텍스트만 적용시킬려고 이격 함
                      alignment: Alignment.center, // 텍스트만 중앙 정렬
                      child: Text(
                        '에너지',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    UIComponents._buildEnergyBar(catStatus.energy),
                    const SizedBox(height: 15.0),
                    UIComponents._buildStatBar('피로도', catStatus.fatigue.value, Colors.deepOrange, 100),
                    const SizedBox(height: 5.0),
                    UIComponents._buildStatBar('친밀도', catStatus.intimacy.value, Colors.green, 10),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              // 닫기 버튼을 중앙에 배치
              Center(
                // 닫기 버튼
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
            child: UIComponents._buildEnergyBar(catStatus.energy),
          ),

          // Cat 정보 버튼
          Positioned(
            top: 120,
            left: 20,
            child: UIComponents.buildButtonWithBackground(  // UIComponents의 buildButtonWithBackground 형식 불러오기
              label: 'Cat',
              backgroundImage: 'assets/images/grayCat.png',
              onTap: () {
                print("Cat button pressed");  // 디버깅 용도
                showCatProfilePopup(context); // 팝업 창 호출
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
                eatAction();  // eatsleep.dart 파일에서 불러옴
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
