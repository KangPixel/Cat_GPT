import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../cat_racing_game.dart';
import '../models/cat.dart';
import '../screens/character_selection_screen.dart';
import '../screens/ranking_screen.dart';
import '../components/lottie_cat_runner.dart';
import '../lottie_background.dart'; // ✅ 배경 import 확인!

class GameScreen extends StatefulWidget {
  final Cat selectedCat;

  const GameScreen({Key? key, required this.selectedCat}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late CatRacingGame catRacingGame;

  final Map<String, String> catNameMap = {
    'one': 'Player',
    'two': '흰냥이',
    'three': '갈냥이',
    'four': '아이보리냥이',
  };

  @override
  void initState() {
    super.initState();
    catRacingGame = CatRacingGame(selectedCat: widget.selectedCat);

    // ✅ 오버레이 추가 (배경 + 고양이)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      catRacingGame.overlays.add('background'); // 🔥 배경 추가
      for (var cat in catRacingGame.catRunners) {
        catRacingGame.overlays.add(cat.color); // 🔥 고양이 추가
      }
    });

    // ✅ 레이스 종료 감지 후 결과 화면 이동
    catRacingGame.addListener(() {
      if (catRacingGame.isRaceFinished) {
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RankingScreen(
                raceResults: catRacingGame.raceResults,
                isPlayerWinner: catRacingGame.raceResults.isNotEmpty &&
                    catRacingGame.raceResults[0]['color'] == 'one',
              ),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('고양이 경주')),
      body: Stack(
        children: [
          Positioned.fill(
            child: GameWidget(
              game: catRacingGame,
              overlayBuilderMap: {
                // ✅ 배경을 올바르게 추가 (오류 해결!)
                'background': (context, _) => const LottieBackgroundWidget(
                  lottieFile: 'assets/car_background.json',
                ),

                // ✅ 고양이 애니메이션 Overlay 추가
                'one': (context, _) => catRacingGame.catRunners.isNotEmpty
                    ? catRacingGame.catRunners[0].buildLottieOverlay(context)
                    : Container(),
                'two': (context, _) => catRacingGame.catRunners.length > 1
                    ? catRacingGame.catRunners[1].buildLottieOverlay(context)
                    : Container(),
                'three': (context, _) => catRacingGame.catRunners.length > 2
                    ? catRacingGame.catRunners[2].buildLottieOverlay(context)
                    : Container(),
                'four': (context, _) => catRacingGame.catRunners.length > 3
                    ? catRacingGame.catRunners[3].buildLottieOverlay(context)
                    : Container(),
              },
            ),
          ),

          if (catRacingGame.isRaceFinished)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  const Text('🏆 경주 결과 🏆', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  for (int i = 0; i < catRacingGame.raceResults.length; i++)
                    Text(
                      '${i + 1}위: ${catNameMap[catRacingGame.raceResults[i]['name']] ?? catRacingGame.raceResults[i]['name']}',
                      style: TextStyle(
                        fontSize: catRacingGame.raceResults[i]['name'] == widget.selectedCat.color ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: catRacingGame.raceResults[i]['color'] == widget.selectedCat.color ? Colors.red : Colors.black,
                      ),
                    ),
                  const SizedBox(height: 20),

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

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
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
