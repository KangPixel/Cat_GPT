//player_model.dart
import 'dart:math';
import 'package:playing_cards/playing_cards.dart';

const START_MONEY = 10000;
const BET_MULTIPLICATOR = 2;

class Player {
  List<PlayingCard> hand;
  int won = 0;
  int lose = 0;

  int wallet = START_MONEY;

  // 한 번 정해진 베팅은 다음 게임까지 유지
  // 최소값 500
  int bet = 500;

  Player(this.hand);

  void wonBet() {
    wallet += bet * BET_MULTIPLICATOR;
  }

  void lostBet() {
    wallet -= bet;
    // 여기서 wallet이 0 이하일 때 초기화하는 코드를 제거
  }
}
