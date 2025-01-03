import 'package:flutter/material.dart';
import 'cat_game.dart';

class FeedButton extends StatelessWidget {
  final CatGame game;

  const FeedButton({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: ElevatedButton(
        onPressed: () {
          game.dropFish(); // 물고기 드롭 호출
        },
        child: const Text('밥 주기'),
      ),
    );
  }
}
