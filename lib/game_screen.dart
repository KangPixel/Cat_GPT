// game_screen.dart (ui 대부분)
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'flameui.dart'; // CatGame 및 Flame 관련 로직
import 'status.dart';
import 'day.dart';
import 'eatsleep.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'copyright.dart';
import 'game_manual.dart';
// import 'speech_bubble.dart';

// UI 구성 요소들을 제공하는 클래스
class UIComponents {
  // 에너지 막대 그래프 생성
  static Widget _buildEnergyBar(ValueNotifier<int> energy) {
    return ValueListenableBuilder<int>(
      valueListenable: energy,
      builder: (context, value, _) {
        final clampedValue = value.clamp(0, 100); // 0~100 범위로 강제
        final color = clampedValue >= 70
            ? Colors.green // 70% 이상이면 초록
            : (clampedValue >= 30
                ? Colors.yellow // 70% 미만이고 30% 이상이면 노랑
                : Colors.red); // 그 이하면 빨강
        return Container(
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(
                color: const Color.fromARGB(255, 255, 255, 255), width: 2.5),
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
                Center(
                    // 에너지 표시는 따로 Text에서 표기하기로 바뀜
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
        final color = clampedValue >= 70
            ? Colors.green // 70% 이상이면 초록
            : (clampedValue >= 30
                ? Colors.yellow // 70% 미만이고 30% 이상이면 노랑
                : Colors.red); // 그 이하면 빨강
        return Container(
          height: 15,
          decoration: BoxDecoration(
            border: Border.all(
                color: const Color.fromARGB(255, 255, 255, 255), width: 2.5),
            borderRadius: BorderRadius.circular(13), // 테두리 둥글게
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
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Pretendard', // 폰트 적용
          ),
        ),
        const SizedBox(height: 4.0),
        Container(
          height: 20,
          decoration: BoxDecoration(
            // 외각선
            border: Border.all(
                color: const Color.fromARGB(255, 255, 255, 255), width: 1.5),
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
          textStyle: const TextStyle(fontFamily: 'Pretendard'),
        ),
        child: Text(
          '',
          //label,
          //style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}

// 고양이 정보 팝업 창을 표시하는 함수
void showCatProfilePopup(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator()); // 데이터 로딩 중
          }

          final prefs = snapshot.data!;
          final catName = prefs.getString('catName') ?? '이름 없음';
          final catSpecies = prefs.getString('catSpecies') ?? '품종 없음';
          final catBirthday = prefs.getString('catBirthday') ?? '2025년 02월 05일';

          // SharedPreferences에서 선택한 고양이 종 가져오기
          String selectedCat = prefs.getString('selectedCat') ?? '회냥이'; // 기본값

          // 선택한 고양이 종에 맞는 이미지 파일 매핑
          final Map<String, String> catImages = {
            '회냥이': 'gray_cat',
            '흰냥이': 'white_cat',
            '갈냥이': 'brown_cat',
            '아이보리냥이': 'ivory_cat',
          };
          String catFileName = catImages[selectedCat] ?? 'gray_cat';

          return AlertDialog(
            backgroundColor: Colors.yellow[50], // 기본 배경 색 조정
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0), // 모서리 둥글게
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
                          'assets/images/cat/$catFileName.png',
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
                        children: [
                          Text(
                            '이름: $catName', // 저장된 이름 사용
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '품종: $catSpecies', // 저장된 품종 사용
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '생일: $catBirthday',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  // 에너지, 피로도, 친밀도 그래프 창
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 105, 35, 30),
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                    padding: const EdgeInsets.all(16.0), // 여백 추가
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            '에너지 ${catStatus.energy.value}%',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        UIComponents._buildEnergyBar(catStatus.energy),
                        const SizedBox(height: 15.0),
                        UIComponents._buildStatBar(
                          '피로도',
                          catStatus.fatigue.value,
                          Colors.deepOrange,
                          100,
                        ),
                        const SizedBox(height: 5.0),
                        UIComponents._buildStatBar(
                          '친밀도',
                          catStatus.intimacy.value,
                          Colors.green,
                          10,
                        ),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // 닫기 버튼을 중앙에 배치
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontFamily: 'Pretendard'),
                      ),
                      child: const Text('닫기'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// 게임 정보 팝업 창을 표시하는 함수
void showCatGamePopup(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.yellow[50], // 기본 배경 색 조정
        contentPadding: EdgeInsets.zero,
        content: Container(
          // height: MediaQuery.of(context).size.height * 0.5,
          // width: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0), // 모서리 둥글게
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                // 게임 설명 화면 버튼
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GameManualPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontFamily: 'Pretendard'),
                  ),
                  child: const Text('게임 설명'),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                // 저작권 확인 버튼
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CopyrightPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontFamily: 'Pretendard'),
                  ),
                  child: const Text('저작권'),
                ),
              ),
              const SizedBox(height: 20.0),
              // 닫기 버튼을 중앙에 배치
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontFamily: 'Pretendard'),
                  ),
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
      // 상단 AppBar
      appBar: AppBar(
        title: const Text(
          '빌려온 고양이',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Pretendard', // 폰트 적용
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE8F3FF), // (1) 배경색 변경
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline), // 정보 버튼
            onPressed: () {
              showCatGamePopup(context); // 게임 정보 팝업 창 호출
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // (2) Flame 게임 화면 배경도 Color(0xFFE8F3FF)로 설정
          Positioned.fill(
            child: GameWidget(
              game: game,
              backgroundBuilder: (BuildContext context) {
                return Container(
                  color: const Color(0xFFE8F3FF),
                );
              },
            ),
          ),

          Positioned(
            top: 165, // 말풍선을 고양이 위로 올림
            right: 60,
            // 말풍선 위젯을 DefaultTextStyle로 감싼다.
            child: DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'OwnglyphPDH',
                fontSize: 19,
                color: Colors.black, // 원하는 폰트 이름
              ),
              child: SpeechBubble(text: "나랑 대화하쟈냥¢"), // 말풍선 본체
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
                width: 320, // 버튼 너비 조정
                decoration: BoxDecoration(
                  // (3) 분홍 RadialGradient 적용
                  gradient: const RadialGradient(
                    center: Alignment(0, 0),
                    radius: 1.41,
                    colors: [
                      Color.fromARGB(255, 255, 190, 190),
                      Color.fromARGB(255, 251, 190, 192),
                      Color.fromARGB(255, 251, 185, 188),
                      Color.fromARGB(255, 248, 196, 197),
                      Color.fromARGB(255, 250, 214, 215),
                      Color(0xFFF7E2E5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(50.0), // 모서리 둥글게
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
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
                              fit: BoxFit.contain,
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
                            vertical: 5, horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 고양이 이름과 에너지 텍스트
                            ValueListenableBuilder<int>(
                              valueListenable: catStatus.energy,
                              builder: (context, value, _) {
                                return FutureBuilder<SharedPreferences>(
                                  future: SharedPreferences.getInstance(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text(
                                        'Loading...',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                      );
                                    }
                                    final prefs = snapshot.data!;
                                    final catName =
                                        prefs.getString('catName') ?? '이름 없음';

                                    return Text(
                                      '$catName | 에너지 $value% ▶',
                                      style: const TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
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
                sleepAction(context);
              },
            ),
          ),

          // Play 버튼
          Positioned(
            bottom:
                MediaQuery.of(context).size.height * 0.05, // 화면 높이의 5% 만큼 떨어짐
            left: MediaQuery.of(context).size.width * 0.08, // 화면 너비의 8% 만큼 떨어짐
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
            bottom:
                MediaQuery.of(context).size.height * 0.05, // 화면 높이의 5% 만큼 떨어짐
            right: MediaQuery.of(context).size.width * 0.08, // 화면 너비의 8% 만큼 떨어짐
            child: UIComponents.buildButtonWithBackground(
              label: 'Talk',
              backgroundImage: 'assets/images/speech_bubble.png',
              onTap: () => Navigator.pushNamed(context, '/chat'),
            ),
          ),
        ],
      ),
    );
  }
}
