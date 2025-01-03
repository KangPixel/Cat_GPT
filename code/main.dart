import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'cat_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(
          game: CatGame(), // CatGame 인스턴스
        ),
      ),
    );
  }
}