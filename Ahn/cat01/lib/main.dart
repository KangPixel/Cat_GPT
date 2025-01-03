import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'cat_game.dart';
import 'feed_button.dart';
import 'shoot_button.dart';
import 'run_button.dart'; // RunButton 추가

void main() {
  runApp(GameWidget(
    game: CatGame(),
    overlayBuilderMap: {
      'FeedButton': (context, CatGame game) => FeedButton(game: game),
      'ShootButton': (context, CatGame game) => ShootButton(game: game),
      'RunButton': (context, CatGame game) => RunButton(game: game), // RunButton 추가
    },
    initialActiveOverlays: ['FeedButton', 'ShootButton', 'RunButton'], // 초기 활성화
  ));
}
