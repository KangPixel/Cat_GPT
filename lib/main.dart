import 'package:flutter/material.dart';
import 'flameui.dart';
import 'chat.dart';
import 'status.dart';
import 'day.dart';
import 'touch.dart';
import 'eatsleep.dart';
import 'day10_game.dart';
import 'game_screen.dart';
import 'play.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cat Game',
      initialRoute: '/',
      routes: {
        '/': (context) => GameScreen(),
        '/chat': (context) => const ChatScreen(),
        '/day10Game': (context) => const Day10GameScreen(),
        '/play': (context) => const PlayScreen(),
      },
    );
  }
}
