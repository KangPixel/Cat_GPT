class BlackjackGameManager {
  static final BlackjackGameManager _instance =
      BlackjackGameManager._internal();
  factory BlackjackGameManager() => _instance;
  BlackjackGameManager._internal();

  bool _sessionStarted = false;
  int _initialWallet = 0;

  // getter 추가
  int get initialWallet => _initialWallet;

  void startNewSession(int startingWallet) {
    _sessionStarted = true;
    _initialWallet = startingWallet;
  }

  int getMoneyDifference(int currentWallet) {
    if (!_sessionStarted) return 0;
    return currentWallet - _initialWallet;
  }

  void endSession() {
    _sessionStarted = false;
    _initialWallet = 0;
  }
}

final blackjackManager = BlackjackGameManager();
