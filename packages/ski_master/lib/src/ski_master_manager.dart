class SkiMasterGameManager {
  static final SkiMasterGameManager _instance =
      SkiMasterGameManager._internal();
  factory SkiMasterGameManager() => _instance;
  SkiMasterGameManager._internal();

  bool _sessionStarted = false;
  int _score = 0;

  int get score => _score;

  void startNewSession() {
    _sessionStarted = true;
    _score = 0;
  }

  void updateScore(int newScore) {
    if (_sessionStarted) {
      _score = newScore;
    }
  }

  void endSession() {
    _sessionStarted = false;
  }
}

final skiMasterManager = SkiMasterGameManager();
