//game_service_impl.dart

import 'package:flutter_blackjack_pkg/models/player_model.dart';
import 'package:flutter_blackjack_pkg/services/card_service_impl.dart';
import 'package:flutter_blackjack_pkg/services/game_service.dart';
import 'package:playing_cards/playing_cards.dart';

import 'card_service.dart';

const HIGHES_SCORE_VALUE = 21;
const int DEALER_MIN_SCORE = 17;

class GameServiceImpl extends GameService {
  late Player player;
  late Player dealer;
  GameState gameState = GameState.equal;

  final CardServiceImpl _cardService = CardServiceImpl();

  GameServiceImpl() {
    // 초기 생성 시점에 새 덱 + 2장씩 분배는 안 하고,
    // 아래 startNewGame()에서 진행하도록
    dealer = Player([]);
    player = Player([]);
  }

  @override
  void startNewGame() {
    // 1. 새 덱 생성
    _cardService.new52Deck();

    // 2. 플레이어 / 딜러에게 카드 2장씩 배분
    player.hand = _cardService.drawCards(2);
    dealer.hand = _cardService.drawCards(2);

    // 플레이어 bet이 500 미만이면 기본값 보정(없어도 되지만 안전차)
    if (player.bet < 500) {
      player.bet = 500;
    }

    gameState = GameState.playerActive;
  }

  @override
  PlayingCard drawCard() {
    final drawnCard = _cardService.drawCard();
    player.hand.add(drawnCard);
    if (getScore(player) >= HIGHES_SCORE_VALUE) {
      endTurn();
    }
    return drawnCard;
  }

  @override
  void endTurn() {
    // 딜러는 최소 17점까지 자동으로 카드 뽑음
    int dealerScore = getScore(dealer);
    while (dealerScore < DEALER_MIN_SCORE) {
      dealer.hand.add(_cardService.drawCard());
      dealerScore = getScore(dealer);
    }

    // 플레이어 / 딜러의 점수 상태 파악
    final playerScore = getScore(player);
    final bool burntDealer = (dealerScore > HIGHES_SCORE_VALUE);
    final bool burntPlayer = (playerScore > HIGHES_SCORE_VALUE);

    // 승패 판정
    if (burntDealer && burntPlayer) {
      gameState = GameState.equal;
    } else if (dealerScore == playerScore) {
      gameState = GameState.equal;
    } else if (burntDealer && playerScore <= HIGHES_SCORE_VALUE) {
      playerWon();
    } else if (burntPlayer && dealerScore <= HIGHES_SCORE_VALUE) {
      dealerWon();
    } else if (dealerScore < playerScore) {
      playerWon();
    } else if (dealerScore > playerScore) {
      dealerWon();
    }
  }

  void playerWon() {
    gameState = GameState.playerWon;
    player.won += 1;
    dealer.lose += 1;
    player.wonBet();
  }

  void dealerWon() {
    gameState = GameState.dealerWon;
    dealer.won += 1;
    player.lose += 1;
    player.lostBet();
  }

  @override
  Player getPlayer() {
    return player;
  }

  @override
  Player getDealer() {
    return dealer;
  }

  @override
  int getScore(Player player) {
    return mapCardValueRules(player.hand);
  }

  @override
  GameState getGameState() {
    return gameState;
  }

  @override
  String getWinner() {
    if (GameState.dealerWon == gameState) {
      return "딜러";
    }
    if (GameState.playerWon == gameState) {
      return "You";
    }
    return "Nobody";
  }
}

/// Map blackjack rules for card values to the PlayingCard enum
int mapCardValueRules(List<PlayingCard> cards) {
  List<PlayingCard> standardCards = cards
      .where((card) => (0 <= card.value.index && card.value.index <= 11))
      .toList();

  final sumStandardCards = getSumOfStandardCards(standardCards);

  int acesAmount = cards.length - standardCards.length;
  if (acesAmount == 0) {
    return sumStandardCards;
  }

  // Special case: Ace could be value 1 or 11
  final pointsLeft = HIGHES_SCORE_VALUE - sumStandardCards;
  final oneAceIsEleven = 11 + (acesAmount - 1);

  // One Ace with value 11 fits
  if (pointsLeft >= oneAceIsEleven) {
    return sumStandardCards + oneAceIsEleven;
  }

  return sumStandardCards + acesAmount;
}

int getSumOfStandardCards(List<PlayingCard> standardCards) {
  return standardCards.fold<int>(
      0, (sum, card) => sum + mapStandardCardValue(card.value.index));
}

int mapStandardCardValue(int cardEnumIdex) {
  // ignore: constant_identifier_names
  const GAP_BETWEEN_INDEX_AND_VALUE = 2;

  // Card value 2-10 -> index between 0 and 8
  if (0 <= cardEnumIdex && cardEnumIdex <= 8) {
    return cardEnumIdex + GAP_BETWEEN_INDEX_AND_VALUE;
  }

  // Card is jack, queen, king -> index between90 and 11
  if (9 <= cardEnumIdex && cardEnumIdex <= 11) {
    return 10;
  }

  return 0;
}
