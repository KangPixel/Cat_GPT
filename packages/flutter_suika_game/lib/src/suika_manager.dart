// packages/suika_game/lib/src/suika_manager.dart

library suika_manager;

class SuikaGameManager {
  static final SuikaGameManager _instance = SuikaGameManager._internal();
  factory SuikaGameManager() => _instance;
  SuikaGameManager._internal();

  int _totalScore = 0;
  int _gameOverCount = 0;
  bool _sessionStarted = false;
  bool _madeWatermelon = false;

  int get totalScore => _totalScore;
  int get gameOverCount => _gameOverCount;
  bool get madeWatermelon => _madeWatermelon;

  /// 새로운 게임 세션을 시작합니다.
  void startNewSession() {
    _totalScore = 0;
    _gameOverCount = 0;
    _madeWatermelon = false;
    _sessionStarted = true;
  }

  /// 게임 진행 중 점수를 추가합니다.
  void addScore(int score) {
    if (_sessionStarted) {
      _totalScore += score;
    }
  }

  /// 게임오버 시 호출하여 횟수를 누적합니다.
  /// madeWatermelon 매개변수로 수박(최대 과일)을 만들었는지 여부를 전달합니다.
  void incrementGameOver({bool madeWatermelon = false}) {
    if (_sessionStarted) {
      _gameOverCount++;
      if (madeWatermelon) {
        _madeWatermelon = true;
      }
    }
  }

  /// 세션을 종료(리셋)합니다.
  void resetSession() {
    _sessionStarted = false;
  }
}

/// suika 게임의 최종 결과를 나타내는 모델
class SuikaGameResult {
  final String gameName;
  final int totalScore;
  final int gameOverCount;
  final bool madeWatermelon;

  SuikaGameResult({
    required this.gameName,
    required this.totalScore,
    required this.gameOverCount,
    required this.madeWatermelon,
  });
}

/// suika 게임 결과를 바탕으로 메인 패키지에 전달할 Outcome을 계산합니다.
/// - 점수: 1000점당 1포인트 지급 (정수 나눗셈)
/// - 게임오버 시 피로도: 일반적으로 20, 수박을 만들었으면 10
/// - 수박을 만들었으면 메시지 포함
class SuikaOutcome {
  final String gameName;
  final int pointsEarned;
  final int fatigueIncrease;
  final String? fatigueMessage;

  SuikaOutcome({
    required this.gameName,
    required this.pointsEarned,
    required this.fatigueIncrease,
    this.fatigueMessage,
  });
}

/// suika 게임 결과를 계산하는 함수
SuikaOutcome computeSuikaOutcome(String gameName, SuikaGameManager manager) {
  int pointsEarned = manager.totalScore ~/ 1000;
  int fatigueIncrease = manager.madeWatermelon ? 10 : 20;
  String? fatigueMessage = manager.madeWatermelon ? "수박을 만들었어요!" : null;

  return SuikaOutcome(
    gameName: gameName,
    pointsEarned: pointsEarned,
    fatigueIncrease: fatigueIncrease,
    fatigueMessage: fatigueMessage,
  );
}

/// 싱글톤 인스턴스로 외부에서 쉽게 접근할 수 있도록 합니다.
final suikaGameManager = SuikaGameManager();
