import 'package:flutter/material.dart';
import 'cat_game.dart';

class RunButton extends StatelessWidget {
  final CatGame game;

  const RunButton({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20, // 화면 하단에서 20px 떨어짐
      left: 0, // 왼쪽 끝
      right: 0, // 오른쪽 끝
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            game.startRunAnimation();
          },
          child: const Text('달리기'),
        ),
      ),
    );
  }
}
