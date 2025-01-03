import 'package:flutter/material.dart';
import 'cat_game.dart';

class ShootButton extends StatelessWidget {
  final CatGame game;

  const ShootButton({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      child: ElevatedButton(
        onPressed: () {
          game.startDeadAnimation();
        },
        child: const Text('총쏘기'),
      ),
    );
  }
}
