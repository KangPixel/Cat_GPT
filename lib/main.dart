// main.dart
import 'package:flutter/material.dart';
import 'cat_game.dart';
import 'chat.dart';
import 'status.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await catStatus.loadStatus(); // 로컬 저장된 상태 로드
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => GameScreen(),
        '/chat': (context) => const ResultPage(),
      },
    );
  }
}