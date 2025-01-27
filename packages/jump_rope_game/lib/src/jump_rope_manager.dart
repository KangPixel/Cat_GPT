// packages/jump_rope_game/lib/src/jump_rope_manager.dart  획득점수, 게임오버 회수 넘겨줌
import 'package:flutter/material.dart';

class JumpRopeGameManager {
  static final JumpRopeGameManager _instance = JumpRopeGameManager._internal();
  factory JumpRopeGameManager() => _instance;
  JumpRopeGameManager._internal();

  int _totalScore = 0;
  int _gameOverCount = 0;
  bool _sessionStarted = false;

  int get totalScore => _totalScore;
  int get gameOverCount => _gameOverCount;

  void startNewSession() {
    _totalScore = 0;
    _gameOverCount = 0;
    _sessionStarted = true;
  }

  void addScore(int score) {
    if (_sessionStarted) {
      _totalScore += score;
    }
  }

  void incrementGameOver() {
    if (_sessionStarted) {
      _gameOverCount++;
    }
  }
}

// ★ 여기 중요! ★
final jumpRopeManager = JumpRopeGameManager();
