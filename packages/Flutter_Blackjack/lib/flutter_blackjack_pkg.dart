//flutter_blackjack_pkg.dart

library flutter_blackjack_pkg;

import 'package:flutter/material.dart';

import 'view/bj_game.dart';
import 'package:flutter_blackjack_pkg/services/game_service_impl.dart';

class BlackJackApp extends StatelessWidget {
  const BlackJackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlackJackGame(gameService: GameServiceImpl()),
    );
  }
}
