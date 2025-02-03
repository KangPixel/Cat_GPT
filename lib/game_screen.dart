// game_screen.dart (ui 대부분)
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
            ? Colors.green // 70% 이상이면 초록
            : (clampedValue > 30
                ? Colors.yellow // 70% 미만이고 30% 이상이면 노랑
                : Colors.red); // 그 이하면 빨강
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
                  color: Colors.white, // 빈 화면(배경)을 하얀색
                ),
                FractionallySizedBox(
                  widthFactor: clampedValue / 100, // 100분율
                  child: Container(color: color),
                ),
                Center(// 에너지 표시는 따로 Text에서 표기하기로 바뀜
                    // child: Text(
                    //   '$clampedValue%', // 현재 에너지 표시
                    //   style: const TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  // cat 버튼 에너지 막대 그래프 생성
  static Widget _buildCatButtonEnergyBar(ValueNotifier<int> energy) {
    return ValueListenableBuilder<int>(
      valueListenable: energy,
      builder: (context, value, _) {
        final clampedValue = value.clamp(0, 100); // 0~100 범위로 강제
        final color = clampedValue > 70
            ? Colors.green // 70% 이상이면 초록
            : (clampedValue > 30
                ? Colors.yellow // 70% 미만이고 30% 이상이면 노랑
                : Colors.red); // 그 이하면 빨강
        return Container(
          height: 15,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2.5),
            borderRadius: BorderRadius.circular(13), // 테두리 둥굴게
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13), // 내부 색상 바 둥굴게(외부에 채울 정도)
            child: Stack(
              children: [
                Container(
                  color: Colors.white, // 빈 화면(배경)을 하얀색
                ),
                FractionallySizedBox(
                  widthFactor: clampedValue / 100, // 100분율
                  child: Container(color: color),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 상태(스테이터스) 막대 그래프 생성
  static Widget _buildStatBar(
      String label, int value, Color color, int percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // 스테이터스 이름 및 현재 량
          '$label: $value',
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4.0),
        Container(
          height: 20,
          decoration: BoxDecoration(
            // 외각선
            border: Border.all(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: FractionallySizedBox(
            // percentage 만큼 % 표시
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
    required String label, // label
    required String backgroundImage, // 배경 이미지 받기
    required VoidCallback onTap, // 누를 시 작동
  }) {
    return Container(
      // 버튼 형식
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage), // 이미지 받아온 것
          fit: BoxFit.contain, // BoxFit.cover로는 이미지가 짤려서 바꿈
          alignment: Alignment.center, // 중앙 정렬
        ),
        borderRadius: BorderRadius.circular(8.0), // 둥굴게
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(''
            //label,
            //style: const TextStyle(fontSize: 16, color: Colors.white),
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
            borderRadius: BorderRadius.circular(12.0), // 모서리 둥굴게
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
                      'assets/images/cat/gray_cat.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain, // BoxFit.cover로는 이미지가 짤려서 바꿈
                      alignment: Alignment.center, // 중앙 정렬
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // 고양이 이름, 품종, 생일
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '이름: cat_name', // 고양이 이름
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                decoration: BoxDecoration(
                  // 상태 배경 추가
                  color: const Color.fromARGB(255, 105, 35, 30),
                  borderRadius: BorderRadius.circular(13.0),
                ),

                padding: const EdgeInsets.all(16.0), // 여백 추가
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      // 텍스트만 적용시킬려고 이격 함
                      alignment: Alignment.center, // 텍스트만 중앙 정렬
                      child: Text(
                        '에너지 ${catStatus.energy.value}%',
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
                    UIComponents._buildStatBar(
                        '피로도', catStatus.fatigue.value, Colors.deepOrange, 100),
                    const SizedBox(height: 5.0),
                    UIComponents._buildStatBar(
                        '친밀도', catStatus.intimacy.value, Colors.green, 10),
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
      appBar: AppBar(
        title: const Text(
          '게임명 / 로고',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.cyan[50],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline), // 정보 버튼
            onPressed: () {
              showCatProfilePopup(context); // 정보 팝업 창 호출
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Flame 게임 화면 전체를 차지
          Positioned.fill(
            child: GameWidget(
              game: game,
              backgroundBuilder: (BuildContext context) {
                return Container(
                  color: Colors.cyan[50],
                );
              },
            ),
          ),

          // Cat 정보 버튼 (화면 중앙 정렬)
          Align(
            alignment: const Alignment(0, 0.6), // 화면 아래쪽 위치
            child: GestureDetector(
              onTap: () {
                print("Cat button pressed"); // 디버깅 용도
                showCatProfilePopup(context); // 팝업 창 호출
              },
              child: Container(
                height: 65, // 버튼 높이 조정
                width: 300, // 버튼 너비 조정
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 187, 210), // 배경 색
                  borderRadius: BorderRadius.circular(50.0), // 모서리 둥글게
                  border: Border.all(
                    color: Colors.black, // 테두리 색
                    width: 2.0, // 테두리 두께
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 왼쪽: 원형 고양이 이미지
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipOval(
                        child: Container(
                          width: 40,
                          height: 40,
                          color: Colors.white, // 흰 배경
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Image.asset(
                              'assets/images/pixel_cat.png', // 고양이 이미지
                              fit: BoxFit.contain, // BoxFit.cover로는 이미지가 짤려서 바꿈
                              alignment: Alignment.center, // 중앙 정렬
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 오른쪽: 고양이 이름 & 에너지 텍스트 + 에너지 바
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 고양이 이름과 에너지 텍스트
                            ValueListenableBuilder<int>(
                              // ValueNotifier의 변경을 감지하고 자동으로 UI를 업데이트해 줌
                              valueListenable: catStatus.energy,
                              builder: (context, value, _) {
                                return Text(
                                  'cat_name | 에너지 $value%', // 실시간 에너지 값 반영
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                );
                              },
                            ),
                            // Text를 사용하니 상태 변화를 감지하지 못하여 energy값이 실시간으로 적용되지 않음
                            // Text(
                            //   'cat_name | 에너지 ${catStatus.energy.value}%',
                            //   style: const TextStyle(
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.black,
                            //   ),
                            // ),
                            const SizedBox(height: 2),
                            // 에너지 막대 그래프
                            UIComponents._buildCatButtonEnergyBar(
                                catStatus.energy),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Eat 버튼
          Positioned(
            top: 30,
            left: 20,
            child: UIComponents.buildButtonWithBackground(
              label: 'Eat',
              backgroundImage: 'assets/images/food.png',
              onTap: () {
                debugPrint("Eat pressed");
                eatAction(context); // eatsleep.dart 파일에서 불러옴
              },
            ),
          ),

          // Sleep 버튼 (Nap -> Sleep)
          Positioned(
            top: 30,
            left: 110,
            child: UIComponents.buildButtonWithBackground(
              label: 'Sleep',
              backgroundImage: 'assets/images/sleep.png',
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
              backgroundImage: 'assets/images/play.png',
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
              backgroundImage: 'assets/images/speech_bubble.png',
              onTap: () => Navigator.pushNamed(context, '/chat'),
            ),
          ),

          // Flutter 쪽 D-day 위젯은 추가하지 않음
        ],
      ),
    );
  }
}
