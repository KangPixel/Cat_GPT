//blackjack_manager.dart
import 'package:flutter_blackjack_pkg/models/player_model.dart';
import 'package:flutter_blackjack_pkg/services/game_service.dart';
export 'blackjack_manager.dart' show blackjackManager; // export 추가

class BlackjackGameManager {
  static final BlackjackGameManager _instance =
      BlackjackGameManager._internal();
  factory BlackjackGameManager() => _instance;
  BlackjackGameManager._internal();

  bool _sessionStarted = false;
  int _initialWallet = 0;

  bool _hasActiveGame = false;

  bool get hasActiveGame => _hasActiveGame;

  Player? _savedPlayer;
  Player? _savedDealer;
  GameState? _savedGameState;

  bool get sessionStarted => _sessionStarted;
  int get initialWallet => _initialWallet;

  void saveGameState(
      {required Player player,
      required Player dealer,
      required GameState gameState}) {
    _savedPlayer = Player([]); // 새로운 플레이어 객체 생성
    _savedPlayer!.hand = List.from(player.hand);
    _savedPlayer!.wallet = player.wallet;
    _savedPlayer!.bet = player.bet;
    _savedPlayer!.won = player.won;
    _savedPlayer!.lose = player.lose;

    _savedDealer = Player([]); // 새로운 딜러 객체 생성
    _savedDealer!.hand = List.from(dealer.hand);

    _savedGameState = gameState;
  }

  Map<String, dynamic>? getSavedState() {
    if (_savedPlayer == null ||
        _savedDealer == null ||
        _savedGameState == null) {
      return null;
    }

    return {
      'player': _savedPlayer,
      'dealer': _savedDealer,
      'gameState': _savedGameState,
    };
  }

  void startNewSession(int startingWallet) {
    if (!_sessionStarted) {
      _sessionStarted = true;
      _initialWallet = startingWallet;
      // clearSavedState()는 호출하지 않음
    }
  }

  int getMoneyDifference(int currentWallet) {
    if (!_sessionStarted) return 0;
    return currentWallet - _initialWallet;
  }

  void clearSavedState() {
    _savedPlayer = null;
    _savedDealer = null;
    _savedGameState = null;
  }

  void endSession() {
    _sessionStarted = false;
    _initialWallet = 0;
    clearSavedState();
  }

  void startNewGame() {
    _hasActiveGame = true;
  }

  void endGame() {
    _hasActiveGame = false;
  }
}

// 싱글톤 인스턴스
final blackjackManager = BlackjackGameManager();
