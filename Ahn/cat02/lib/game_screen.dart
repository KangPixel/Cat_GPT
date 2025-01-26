import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'flameui.dart'; // CatGame 및 Flame 관련 로직
import 'status.dart';
import 'day.dart';
import 'eatsleep.dart';
import 'screens/character_selection_screen.dart'; // CharacterSelectionScreen 임포트

class UIComponents {
  static Widget buildEnergyBar(ValueNotifier<int> energy) {
    return ValueListenableBuilder<int>(
      valueListenable: energy,
      builder: (context, value, _) {
        final color = value > 70
            ? Colors.green
            : (value > 30 ? Colors.yellow : Colors.red);
        return Container(
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(color: color),
              ),
              Center(
                child: Text(
                  '$value%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
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
    return Container(
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

          // Cat 버튼 복원
          Positioned(
            top: 120,
            left: 20,
            child: UIComponents.buildButtonWithBackground(
              label: 'Cat',
              backgroundImage: 'assets/images/grayCat.png',
              onTap: () {
                print("Cat button pressed");
                // 고양이 정보 팝업 등의 로직 추가 가능
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
                sleepAction(context);
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
                if (catStatus.energy.value >= 30) {
                  // CharacterSelectionScreen으로 네비게이션
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CharacterSelectionScreen(),
                    ),
                  );
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
        ],
      ),
    );
  }
}
