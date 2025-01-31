import 'package:chat_cat_game/flameui.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../cat_racing_game.dart';
import '../models/cat.dart';
import '../screens/character_selection_screen.dart';


class GameScreen extends StatefulWidget {
  final Cat selectedCat;

  const GameScreen({Key? key, required this.selectedCat}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late CatRacingGame catRacingGame;

  @override
  void initState() {
    super.initState();
    catRacingGame = CatRacingGame(selectedCat: widget.selectedCat);
    catRacingGame.addListener(() {
      if (catRacingGame.isRaceFinished) {
        setState(() {}); // 상태 업데이트
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('고양이 경주'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GameWidget(game: catRacingGame), // 게임 실행
          ),
          if (catRacingGame.isRaceFinished) // 경주 종료 시 결과 표시
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  const Text(
                    '경주 결과',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  for (int i = 0; i < catRacingGame.raceResults.length; i++)
                    Text(
                      '${i + 1}위: ${catRacingGame.raceResults[i]['color']}',
                      style: TextStyle(
                        fontSize: catRacingGame.raceResults[i]['color'] == widget.selectedCat.color
                            ? 22 // 선택한 고양이는 큰 글씨
                            : 18, // 나머지는 기본 크기
                        fontWeight: FontWeight.bold,
                        color: catRacingGame.raceResults[i]['color'] == widget.selectedCat.color
                            ? Colors.red // 선택한 고양이는 빨간색
                            : Colors.black, // 나머지는 검은색
                      ),
                    ),
                  const SizedBox(height: 20), // 결과와 버튼 사이 여백
                  
                  // 🔥 다시 하기 버튼
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CharacterSelectionScreen(),
                        ),
                      );
                    },
                    child: const Text('다시 하기'),
                  ),

                  const SizedBox(height: 10), // 버튼 간격 추가

                  // 🔥 메인으로 돌아가기 버튼 수정
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/', // initialRoute로 설정된 첫 화면'
                        (route) => false, // 🔥 모든 이전 화면 제거 (중요!)
                      );
                    },
                    child: const Text('메인으로'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
